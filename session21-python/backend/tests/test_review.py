from datetime import date
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, event, text
from sqlalchemy.exc import IntegrityError

from app.models import Loan


@pytest.mark.parametrize("identifier", [0, -1, 2**70])
def test_invalid_ids_are_validation_errors_not_database_overflows(client, identifier):
    assert client.get(f"/api/equipment/{identifier}").status_code == 422
    assert client.delete(f"/api/equipment/{identifier}").status_code == 422
    assert client.post(f"/api/loans/{identifier}/return", json={}).status_code == 422
    assert (
        client.post(
            "/api/loans",
            json={
                "equipment_id": identifier,
                "borrower": "Test borrower",
                "purpose": "Identifier validation",
                "due_on": str(date.today()),
            },
        ).status_code
        == 422
    )


def test_readiness_checks_loan_schema(client):
    with client.app.state.engine.begin() as connection:
        connection.execute(text("DROP TABLE loans"))
    assert client.get("/ready").status_code == 503


def test_sqlite_enforces_foreign_keys(client):
    with client.app.state.sessions() as db:
        db.add(
            Loan(
                equipment_id=999,
                borrower="Test borrower",
                purpose="Orphan test",
                checked_out_on=date.today(),
                due_on=date.today(),
            )
        )
        with pytest.raises(IntegrityError):
            db.commit()


def test_unhandled_errors_are_counted(client):
    @client.app.get("/test-failure")
    def fail():
        raise RuntimeError("Deliberate test failure")

    with TestClient(client.app, raise_server_exceptions=False) as api:
        assert api.get("/test-failure").status_code == 500
        metrics = api.get("/metrics").text
        assert 'route="/test-failure",status="500"' in metrics


@pytest.mark.parametrize(
    "path", ["/api/equipment", "/api/equipment/1", "/api/summary", "/api/loans"]
)
def test_list_queries_use_one_database_snapshot(client, path):
    for index in range(4):
        asset = client.post(
            "/api/equipment",
            json={
                "asset_tag": f"REVIEW-{index}",
                "name": "Review asset",
                "category": "Tests",
            },
        ).json()
        client.post(
            "/api/loans",
            json={
                "equipment_id": asset["id"],
                "borrower": "Test borrower",
                "purpose": "Snapshot test",
                "due_on": str(date.today()),
            },
        )
    statements = []

    def track(connection, cursor, statement, parameters, context, executemany):
        if statement.lstrip().upper().startswith("SELECT"):
            statements.append(statement)

    event.listen(client.app.state.engine, "before_cursor_execute", track)
    try:
        assert client.get(path).status_code == 200
    finally:
        event.remove(client.app.state.engine, "before_cursor_execute", track)
    assert len(statements) == 1, statements


def test_stale_edit_does_not_overwrite_newer_equipment(client, asset):
    payload = {key: value for key, value in asset.items() if key not in ("id", "available")}
    url = f"/api/equipment/{asset['id']}"
    assert client.put(url, json=payload | {"name": "Newer edit"}).status_code == 200
    assert client.put(url, json=payload | {"name": "Stale edit"}).status_code == 409
    assert client.get(url).json()["name"] == "Newer edit"


def test_version_migration_preserves_existing_equipment(tmp_path, monkeypatch):
    backend = Path(__file__).resolve().parents[1]
    url = f"sqlite:///{tmp_path / 'migration-test.db'}"
    monkeypatch.setenv("DATABASE_URL", url)
    config = Config(str(backend / "alembic.ini"))
    config.set_main_option("script_location", str(backend / "alembic"))
    command.upgrade(config, "0001")
    engine = create_engine(url)
    try:
        with engine.begin() as connection:
            connection.execute(
                text(
                    "INSERT INTO equipment (id, asset_tag, name, category, condition, notes) "
                    "VALUES (1, 'EXISTING-1', 'Existing camera', 'Camera', 'ready', 'Preserve me')"
                )
            )
        command.upgrade(config, "head")
        with engine.connect() as connection:
            assert connection.execute(
                text("SELECT name, notes, version FROM equipment WHERE id=1")
            ).one() == ("Existing camera", "Preserve me", 1)
    finally:
        engine.dispose()
