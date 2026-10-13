from datetime import date

from sqlalchemy import CheckConstraint, Date, ForeignKey, Index, String, text
from sqlalchemy.orm import Mapped, mapped_column

from .db import Base


class Equipment(Base):
    __tablename__ = "equipment"
    __table_args__ = (
        CheckConstraint("condition IN ('ready', 'maintenance', 'retired')"),
    )
    id: Mapped[int] = mapped_column(primary_key=True)
    asset_tag: Mapped[str] = mapped_column(String(32), unique=True)
    name: Mapped[str] = mapped_column(String(100))
    category: Mapped[str] = mapped_column(String(40))
    condition: Mapped[str] = mapped_column(String(20), default="ready")
    notes: Mapped[str] = mapped_column(String(500), default="")


class Loan(Base):
    __tablename__ = "loans"
    __table_args__ = (
        CheckConstraint("due_on >= checked_out_on"),
        CheckConstraint("returned_on IS NULL OR returned_on >= checked_out_on"),
        Index(
            "one_active_loan_per_asset",
            "equipment_id",
            unique=True,
            postgresql_where=text("returned_on IS NULL"),
            sqlite_where=text("returned_on IS NULL"),
        ),
    )
    id: Mapped[int] = mapped_column(primary_key=True)
    equipment_id: Mapped[int] = mapped_column(
        ForeignKey("equipment.id", ondelete="RESTRICT")
    )
    borrower: Mapped[str] = mapped_column(String(100))
    purpose: Mapped[str] = mapped_column(String(200))
    checked_out_on: Mapped[date] = mapped_column(Date)
    due_on: Mapped[date] = mapped_column(Date)
    returned_on: Mapped[date | None] = mapped_column(Date, nullable=True)
