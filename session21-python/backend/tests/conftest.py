import pytest
from fastapi.testclient import TestClient

from app.db import Base
from app.main import create_app


@pytest.fixture
def client(tmp_path):
    app = create_app(f"sqlite:///{tmp_path / 'isolated-test.db'}")
    Base.metadata.create_all(app.state.engine)
    with TestClient(app) as test_client:
        yield test_client
    app.state.engine.dispose()


@pytest.fixture
def asset(client):
    return client.post(
        "/api/equipment",
        json={"asset_tag": "CAM-001", "name": "Studio camera", "category": "Camera"},
    ).json()
