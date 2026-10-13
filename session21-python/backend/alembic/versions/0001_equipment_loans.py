"""Equipment inventory and loan history, with one active loan per asset."""

import sqlalchemy as sa
from alembic import op

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "equipment",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("asset_tag", sa.String(32), nullable=False, unique=True),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("category", sa.String(40), nullable=False),
        sa.Column("condition", sa.String(20), nullable=False),
        sa.Column("notes", sa.String(500), nullable=False),
        sa.CheckConstraint("condition IN ('ready', 'maintenance', 'retired')"),
    )
    op.create_table(
        "loans",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column(
            "equipment_id",
            sa.Integer(),
            sa.ForeignKey("equipment.id", ondelete="RESTRICT"),
            nullable=False,
        ),
        sa.Column("borrower", sa.String(100), nullable=False),
        sa.Column("purpose", sa.String(200), nullable=False),
        sa.Column("checked_out_on", sa.Date(), nullable=False),
        sa.Column("due_on", sa.Date(), nullable=False),
        sa.Column("returned_on", sa.Date(), nullable=True),
        sa.CheckConstraint("due_on >= checked_out_on"),
        sa.CheckConstraint("returned_on IS NULL OR returned_on >= checked_out_on"),
    )
    op.create_index(
        "one_active_loan_per_asset",
        "loans",
        ["equipment_id"],
        unique=True,
        postgresql_where=sa.text("returned_on IS NULL"),
        sqlite_where=sa.text("returned_on IS NULL"),
    )


def downgrade():
    op.drop_table("loans")
    op.drop_table("equipment")
