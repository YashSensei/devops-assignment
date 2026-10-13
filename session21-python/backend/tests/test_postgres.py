"""Real row-lock tests, only in a disposable loopback PostgreSQL test database.

Each test owns a randomly named schema. No existing schema/data is cleared.
"""

import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from datetime import date
from pathlib import Path
from threading import Barrier
from uuid import uuid4

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.engine import make_url
from sqlalchemy.schema import CreateSchema, DropSchema

from app.main import create_app

BACKEND = Path(__file__).resolve().parents[1]


@pytest.fixture
def postgres_url():
    raw = os.environ.get("TEST_POSTGRES_URL")
    if not raw:
        pytest.skip("TEST_POSTGRES_URL not configured; PostgreSQL races run in CI")
    url = make_url(raw)
    if (
        url.get_backend_name() != "postgresql"
        or url.host not in {"127.0.0.1", "localhost"}
        or not url.database.endswith("_test")
    ):
        pytest.fail("Use a disposable loopback PostgreSQL database ending in _test")
    schema = "review_" + uuid4().hex
    engine = create_engine(url)
    with engine.begin() as connection:
        connection.execute(CreateSchema(schema))
    try:
        yield url.update_query_dict({"options": f"-csearch_path={schema}"}).render_as_string(
            hide_password=False
        )
    finally:
        with engine.begin() as connection:
            connection.execute(DropSchema(schema, cascade=True))
        engine.dispose()


def migrate(url):
    result = subprocess.run(
        [sys.executable, "-m", "app.migrate"],
        cwd=BACKEND,
        env=os.environ | {"DATABASE_URL": url},
        capture_output=True,
        text=True,
        timeout=45,
    )
    assert result.returncode == 0, result.stderr


@pytest.fixture
def pg_client(postgres_url):
    migrate(postgres_url)
    app = create_app(postgres_url)
    with TestClient(app) as client:
        yield client
    app.state.engine.dispose()


def together(*actions):
    barrier = Barrier(len(actions))

    def run(action):
        barrier.wait(timeout=10)
        return action()

    with ThreadPoolExecutor(max_workers=len(actions)) as executor:
        futures = [executor.submit(run, action) for action in actions]
        return [future.result(timeout=20) for future in futures]


def equipment(client):
    response = client.post(
        "/api/equipment",
        json={
            "asset_tag": "RACE-001",
            "name": "Race camera",
            "category": "Test kit",
        },
    )
    assert response.status_code == 201
    return response.json()


def checkout(client, asset):
    return client.post(
        "/api/loans",
        json={
            "equipment_id": asset["id"],
            "borrower": "Concurrent borrower",
            "purpose": "Race regression",
            "due_on": str(date.today()),
        },
    )


def test_simultaneous_checkouts_have_one_winner(pg_client):
    asset = equipment(pg_client)
    results = together(*[lambda: checkout(pg_client, asset) for _ in range(8)])
    assert sorted(result.status_code for result in results) == [201] + [409] * 7
    assert len(pg_client.get("/api/loans").json()) == 1


def test_simultaneous_returns_have_one_winner(pg_client):
    asset = equipment(pg_client)
    loan = checkout(pg_client, asset).json()
    results = together(
        *[
            lambda: pg_client.post(
                f"/api/loans/{loan['id']}/return", json={"condition": "maintenance"}
            )
            for _ in range(4)
        ]
    )
    assert sorted(result.status_code for result in results) == [200, 409, 409, 409]
    assert checkout(pg_client, asset).status_code == 409


def test_checkout_racing_maintenance_is_consistent(pg_client):
    asset = equipment(pg_client)
    payload = {key: value for key, value in asset.items() if key not in {"id", "available"}}
    results = together(
        lambda: checkout(pg_client, asset),
        lambda: pg_client.put(
            f"/api/equipment/{asset['id']}", json=payload | {"condition": "maintenance"}
        ),
    )
    assert sorted(result.status_code for result in results) in ([200, 409], [201, 409])
    summary = pg_client.get("/api/summary").json()
    assert summary["maintenance"] + summary["on_loan"] == 1


def test_simultaneous_edits_reject_stale_version(pg_client):
    asset = equipment(pg_client)
    payload = {key: value for key, value in asset.items() if key not in {"id", "available"}}
    results = together(
        *[
            lambda name=name: pg_client.put(
                f"/api/equipment/{asset['id']}", json=payload | {"name": name}
            )
            for name in ["First editor", "Second editor"]
        ]
    )
    assert sorted(result.status_code for result in results) == [200, 409]


def test_delete_racing_checkout_never_loses_history(pg_client):
    asset = equipment(pg_client)
    checkout_result, delete_result = together(
        lambda: checkout(pg_client, asset),
        lambda: pg_client.delete(f"/api/equipment/{asset['id']}"),
    )
    assert (checkout_result.status_code, delete_result.status_code) in {(201, 409), (404, 204)}


def test_concurrent_replica_migrations_and_readiness(postgres_url):
    together(lambda: migrate(postgres_url), lambda: migrate(postgres_url))
    app = create_app(postgres_url)
    try:
        with TestClient(app) as client:
            assert client.get("/ready").status_code == 200
            assert equipment(client)["version"] == 1
        with app.state.engine.connect() as connection:
            assert connection.scalar(text("SELECT version_num FROM alembic_version")) == "0002"
    finally:
        app.state.engine.dispose()
