"""Protect equipment against stale edits without discarding existing data."""

import sqlalchemy as sa
from alembic import op

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column(
        "equipment", sa.Column("version", sa.Integer(), nullable=False, server_default="1")
    )


def downgrade():
    op.drop_column("equipment", "version")
