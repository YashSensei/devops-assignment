"""Serialize migrations across PostgreSQL replicas with a session advisory lock."""

import os

from alembic.config import Config
from sqlalchemy import create_engine, text

from alembic import command

engine = create_engine(os.environ["DATABASE_URL"])
with engine.connect() as connection:
    postgres = engine.dialect.name == "postgresql"
    if postgres:
        connection.execute(text("SELECT pg_advisory_lock(2410164)"))
    try:
        command.upgrade(Config("alembic.ini"), "head")
    finally:
        if postgres:
            connection.execute(text("SELECT pg_advisory_unlock(2410164)"))
engine.dispose()
