import os
import time
from datetime import date, timedelta
from typing import Annotated, Literal

from fastapi import FastAPI, HTTPException, Path, Query
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    CollectorRegistry,
    Counter,
    Histogram,
    generate_latest,
)
from sqlalchemy import func, select, text
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm.exc import StaleDataError
from starlette.responses import Response

from .db import database
from .models import Equipment, Loan
from .schemas import (
    EquipmentInput,
    EquipmentOutput,
    EquipmentUpdate,
    LoanInput,
    LoanOutput,
    ReturnInput,
)

RecordID = Annotated[int, Path(gt=0, le=2_147_483_647)]


def create_app(database_url=None):
    url = database_url or os.environ.get("DATABASE_URL")
    if not url:
        raise RuntimeError("DATABASE_URL must point to an explicitly selected database")
    engine, sessions = database(url)
    api = FastAPI(title="KitLedger", version="1.0.0")
    api.state.engine = engine
    api.state.sessions = sessions
    registry = CollectorRegistry()
    requests = Counter(
        "kitledger_http_requests_total",
        "HTTP requests",
        ["method", "route", "status"],
        registry=registry,
    )
    duration = Histogram(
        "kitledger_http_duration_seconds",
        "Request latency",
        ["route"],
        registry=registry,
    )

    @api.middleware("http")
    async def observe(request, call_next):
        started = time.perf_counter()
        status = 500
        try:
            response = await call_next(request)
            status = response.status_code
            return response
        finally:
            route = getattr(request.scope.get("route"), "path", "unmatched")
            if route != "/metrics":
                method = (
                    request.method
                    if request.method
                    in {
                        "GET",
                        "POST",
                        "PUT",
                        "DELETE",
                        "PATCH",
                        "HEAD",
                        "OPTIONS",
                    }
                    else "OTHER"
                )
                requests.labels(method, route, str(status)).inc()
                duration.labels(route).observe(time.perf_counter() - started)

    def asset_or_404(db, asset_id, lock=False):
        statement = select(Equipment).where(Equipment.id == asset_id)
        if lock:
            statement = statement.with_for_update()
        asset = db.scalar(statement)
        if asset is None:
            raise HTTPException(404, "Equipment not found")
        return asset

    def active_loan(db, asset_id):
        return db.scalar(
            select(Loan.id).where(Loan.equipment_id == asset_id, Loan.returned_on.is_(None))
        )

    loan_exists = (
        select(Loan.id)
        .where(Loan.equipment_id == Equipment.id, Loan.returned_on.is_(None))
        .exists()
    )
    is_available = (Equipment.condition == "ready") & ~loan_exists

    def equipment_json(db, asset, available=None):
        return {
            "id": asset.id,
            "asset_tag": asset.asset_tag,
            "name": asset.name,
            "category": asset.category,
            "condition": asset.condition,
            "notes": asset.notes,
            "version": asset.version,
            "available": available
            if available is not None
            else (asset.condition == "ready" and active_loan(db, asset.id) is None),
        }

    def loan_json(db, loan, asset=None):
        if asset is None:
            asset = asset_or_404(db, loan.equipment_id)
        status = (
            "returned"
            if loan.returned_on
            else ("overdue" if loan.due_on < date.today() else "active")
        )
        return {
            "id": loan.id,
            "equipment_id": asset.id,
            "asset_tag": asset.asset_tag,
            "equipment_name": asset.name,
            "borrower": loan.borrower,
            "purpose": loan.purpose,
            "checked_out_on": loan.checked_out_on,
            "due_on": loan.due_on,
            "returned_on": loan.returned_on,
            "status": status,
        }

    def commit(db, serialize=lambda: None):
        try:
            db.flush()
            # Build the response while locks still protect this transaction's state.
            result = serialize()
            db.commit()
            return result
        except StaleDataError as exc:
            db.rollback()
            raise HTTPException(409, "Equipment changed; refresh before retrying") from exc
        except IntegrityError as exc:
            db.rollback()
            raise HTTPException(409, "Duplicate asset tag or conflicting active loan") from exc

    @api.get("/health")
    def health():
        return {"status": "ok", "application": "KitLedger"}

    @api.get("/ready")
    def ready():
        try:
            with sessions() as db:
                db.execute(text("SELECT 1"))
                db.execute(select(Equipment).limit(1))
                db.execute(select(Loan).limit(1))
        except SQLAlchemyError as exc:
            raise HTTPException(503, "Database or schema is unavailable") from exc
        return {"status": "ready"}

    @api.get("/metrics", include_in_schema=False)
    def metrics():
        return Response(generate_latest(registry), media_type=CONTENT_TYPE_LATEST)

    @api.get("/api/equipment", response_model=list[EquipmentOutput])
    def list_equipment(
        q: str = Query("", max_length=100),
        category: str = Query("", max_length=40),
        condition: Literal["ready", "maintenance", "retired"] | None = None,
        available: bool | None = None,
    ):
        with sessions() as db:
            statement = select(Equipment, is_available).order_by(Equipment.asset_tag)
            if q:
                statement = statement.where(
                    Equipment.name.icontains(q, autoescape=True)
                    | Equipment.asset_tag.icontains(q, autoescape=True)
                )
            if category:
                statement = statement.where(Equipment.category == category)
            if condition:
                statement = statement.where(Equipment.condition == condition)
            if available is not None:
                statement = statement.where(is_available == available)
            return [equipment_json(db, item, ready) for item, ready in db.execute(statement)]

    @api.get("/api/equipment/{asset_id}", response_model=EquipmentOutput)
    def get_equipment(asset_id: RecordID):
        with sessions() as db:
            return equipment_json(db, asset_or_404(db, asset_id))

    @api.post("/api/equipment", response_model=EquipmentOutput, status_code=201)
    def create_equipment(payload: EquipmentInput):
        with sessions() as db:
            asset = Equipment(**payload.model_dump())
            db.add(asset)
            return commit(db, lambda: equipment_json(db, asset))

    @api.put("/api/equipment/{asset_id}", response_model=EquipmentOutput)
    def update_equipment(asset_id: RecordID, payload: EquipmentUpdate):
        with sessions() as db:
            asset = asset_or_404(db, asset_id, lock=True)
            if asset.version != payload.version:
                raise HTTPException(409, "Equipment changed; refresh before retrying")
            if payload.condition != "ready" and active_loan(db, asset_id) is not None:
                raise HTTPException(409, "Return the active loan before maintenance or retirement")
            for key, value in payload.model_dump(exclude={"version"}).items():
                setattr(asset, key, value)
            return commit(db, lambda: equipment_json(db, asset))

    @api.delete("/api/equipment/{asset_id}", status_code=204)
    def delete_equipment(asset_id: RecordID):
        with sessions() as db:
            asset = asset_or_404(db, asset_id, lock=True)
            if db.scalar(select(Loan.id).where(Loan.equipment_id == asset_id).limit(1)):
                raise HTTPException(409, "Equipment with loan history must be retired, not deleted")
            db.delete(asset)
            commit(db)
        return Response(status_code=204)

    @api.get("/api/loans", response_model=list[LoanOutput])
    def list_loans(status: Literal["active", "overdue", "returned"] | None = None):
        with sessions() as db:
            statement = select(Loan, Equipment).join(Equipment).order_by(Loan.id.desc())
            if status == "returned":
                statement = statement.where(Loan.returned_on.is_not(None))
            elif status is not None:
                statement = statement.where(Loan.returned_on.is_(None))
                statement = statement.where(
                    Loan.due_on < date.today()
                    if status == "overdue"
                    else Loan.due_on >= date.today()
                )
            return [loan_json(db, loan, asset) for loan, asset in db.execute(statement)]

    @api.post("/api/loans", response_model=LoanOutput, status_code=201)
    def checkout(payload: LoanInput):
        today = date.today()
        if not today <= payload.due_on <= today + timedelta(days=30):
            raise HTTPException(422, "Due date must be today through 30 days from today")
        with sessions() as db:
            asset = asset_or_404(db, payload.equipment_id, lock=True)
            if asset.condition != "ready":
                raise HTTPException(409, "Only ready equipment can be checked out")
            if active_loan(db, asset.id) is not None:
                raise HTTPException(409, "Equipment is already checked out")
            loan = Loan(**payload.model_dump(), checked_out_on=today)
            db.add(loan)
            asset.version += 1
            return commit(db, lambda: loan_json(db, loan, asset))

    @api.post("/api/loans/{loan_id}/return", response_model=LoanOutput)
    def return_equipment(loan_id: RecordID, payload: ReturnInput):
        with sessions() as db:
            loan = db.scalar(select(Loan).where(Loan.id == loan_id).with_for_update())
            if loan is None:
                raise HTTPException(404, "Loan not found")
            if loan.returned_on:
                raise HTTPException(409, "This loan has already been returned")
            asset = asset_or_404(db, loan.equipment_id, lock=True)
            loan.returned_on = date.today()
            asset.condition = payload.condition
            asset.version += 1
            return commit(db, lambda: loan_json(db, loan, asset))

    @api.get("/api/summary")
    def summary():
        with sessions() as db:

            def count(model, *conditions):
                return select(func.count()).select_from(model).where(*conditions).scalar_subquery()

            # All counters observe a single SQL statement snapshot, even during returns.
            statement = select(
                count(Equipment).label("total"),
                count(Equipment, is_available).label("available"),
                count(Equipment, Equipment.condition == "maintenance").label("maintenance"),
                count(Loan, Loan.returned_on.is_(None)).label("on_loan"),
                count(Loan, Loan.returned_on.is_(None), Loan.due_on < date.today()).label(
                    "overdue"
                ),
            )
            return dict(db.execute(statement).mappings().one())

    return api
