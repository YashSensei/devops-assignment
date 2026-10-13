from datetime import date, timedelta

import pytest
from fastapi.testclient import TestClient

from app.main import create_app
from app.models import Loan


def borrow(client, asset, **overrides):
    payload = {
        "equipment_id": asset["id"],
        "borrower": "Demo borrower",
        "purpose": "Photography workshop",
        "due_on": str(date.today() + timedelta(days=7)),
    }
    return client.post("/api/loans", json=payload | overrides)


def test_health_and_ready(client):
    assert client.get("/health").json()["application"] == "KitLedger"
    assert client.get("/ready").status_code == 200


def test_readiness_fails_without_schema(tmp_path):
    app = create_app(f"sqlite:///{tmp_path / 'unmigrated.db'}")
    with TestClient(app) as api:
        assert api.get("/health").status_code == 200
        assert api.get("/ready").status_code == 503
    app.state.engine.dispose()


def test_create_and_get_asset(client, asset):
    assert asset["available"] is True
    assert client.get(f"/api/equipment/{asset['id']}").json()["asset_tag"] == "CAM-001"


def test_duplicate_tag_is_conflict(client, asset):
    response = client.post(
        "/api/equipment",
        json={
            "asset_tag": asset["asset_tag"],
            "name": "Another camera",
            "category": "Camera",
        },
    )
    assert response.status_code == 409


@pytest.mark.parametrize(
    "field,value",
    [
        ("name", " "),
        ("asset_tag", "lowercase"),
        ("category", ""),
        ("condition", "unknown"),
        ("notes", "x" * 501),
    ],
)
def test_invalid_equipment(client, field, value):
    data = {
        "asset_tag": "CAM-002",
        "name": "Camera",
        "category": "Camera",
        field: value,
    }
    assert client.post("/api/equipment", json=data).status_code == 422


def test_update_and_delete_unused_equipment(client, asset):
    payload = {
        key: value for key, value in asset.items() if key not in ("id", "available")
    }
    payload["name"] = "Camera with lens"
    url = f"/api/equipment/{asset['id']}"
    assert client.put(url, json=payload).json()["name"] == "Camera with lens"
    assert client.delete(url).status_code == 204
    assert client.get(url).status_code == 404


def test_checkout_and_double_booking(client, asset):
    assert borrow(client, asset).status_code == 201
    assert borrow(client, asset).status_code == 409
    assert client.get(f"/api/equipment/{asset['id']}").json()["available"] is False


@pytest.mark.parametrize("days", [-1, 31])
def test_loan_date_window(client, asset, days):
    assert (
        borrow(
            client, asset, due_on=str(date.today() + timedelta(days=days))
        ).status_code
        == 422
    )


def test_cannot_loan_maintenance_or_retired(client, asset):
    payload = {
        key: value for key, value in asset.items() if key not in ("id", "available")
    }
    for condition in ("maintenance", "retired"):
        client.put(
            f"/api/equipment/{asset['id']}", json=payload | {"condition": condition}
        )
        assert borrow(client, asset).status_code == 409


def test_cannot_change_condition_during_loan(client, asset):
    borrow(client, asset)
    payload = {
        key: value for key, value in asset.items() if key not in ("id", "available")
    }
    assert (
        client.put(
            f"/api/equipment/{asset['id']}", json=payload | {"condition": "maintenance"}
        ).status_code
        == 409
    )


def test_return_retains_history_and_releases_asset(client, asset):
    loan = borrow(client, asset).json()
    url = f"/api/loans/{loan['id']}/return"
    assert client.post(url, json={}).json()["status"] == "returned"
    assert client.post(url, json={}).status_code == 409
    assert client.get("/api/loans?status=returned").json()[0]["id"] == loan["id"]
    assert client.delete(f"/api/equipment/{asset['id']}").status_code == 409
    assert borrow(client, asset).status_code == 201


def test_damaged_return_requires_maintenance(client, asset):
    loan = borrow(client, asset).json()
    assert (
        client.post(
            f"/api/loans/{loan['id']}/return", json={"condition": "maintenance"}
        ).status_code
        == 200
    )
    assert borrow(client, asset).status_code == 409


def test_overdue_is_derived_from_actual_dates(client, asset):
    with client.app.state.sessions() as db:
        db.add(
            Loan(
                equipment_id=asset["id"],
                borrower="Past borrower",
                purpose="Earlier workshop",
                checked_out_on=date.today() - timedelta(days=3),
                due_on=date.today() - timedelta(days=1),
            )
        )
        db.commit()
    assert client.get("/api/loans?status=overdue").json()[0]["status"] == "overdue"
    assert client.get("/api/summary").json()["overdue"] == 1


def test_filters_and_summary(client, asset):
    assert (
        len(client.get("/api/equipment?q=studio&category=Camera&available=true").json())
        == 1
    )
    assert client.get("/api/equipment?q=unknown").json() == []
    borrow(client, asset)
    assert client.get("/api/equipment?available=true").json() == []
    assert client.get("/api/summary").json() == {
        "total": 1,
        "available": 0,
        "maintenance": 0,
        "on_loan": 1,
        "overdue": 0,
    }


def test_metrics_have_real_requests_and_bounded_labels(client, asset):
    client.get(f"/api/equipment/{asset['id']}")
    metrics = client.get("/metrics").text
    assert "kitledger_http_requests_total" in metrics
    assert 'route="/api/equipment/{asset_id}"' in metrics


def test_missing_entities(client):
    assert client.delete("/api/equipment/999").status_code == 404
    assert client.post("/api/loans/999/return", json={}).status_code == 404
    assert borrow(client, {"id": 999}).status_code == 404


def test_saved_state_survives_new_app_instance(client, asset):
    engine = client.app.state.engine
    app = create_app(str(engine.url))
    with TestClient(app) as fresh:
        assert (
            fresh.get(f"/api/equipment/{asset['id']}").json()["name"] == "Studio camera"
        )
    app.state.engine.dispose()


def test_tests_begin_empty(client):
    assert client.get("/api/equipment").json() == []
    assert client.get("/api/loans").json() == []
