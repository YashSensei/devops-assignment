from datetime import date
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class EquipmentInput(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")
    asset_tag: str = Field(min_length=2, max_length=32, pattern=r"^[A-Z0-9-]+$")
    name: str = Field(min_length=2, max_length=100)
    category: str = Field(min_length=2, max_length=40)
    condition: Literal["ready", "maintenance", "retired"] = "ready"
    notes: str = Field(default="", max_length=500)


class EquipmentUpdate(EquipmentInput):
    version: int = Field(gt=0)


class EquipmentOutput(EquipmentUpdate):
    id: int
    available: bool


class LoanInput(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")
    equipment_id: int = Field(gt=0, le=2_147_483_647)
    borrower: str = Field(min_length=2, max_length=100)
    purpose: str = Field(min_length=3, max_length=200)
    due_on: date


class ReturnInput(BaseModel):
    model_config = ConfigDict(extra="forbid")
    condition: Literal["ready", "maintenance"] = "ready"


class LoanOutput(BaseModel):
    id: int
    equipment_id: int
    asset_tag: str
    equipment_name: str
    borrower: str
    purpose: str
    checked_out_on: date
    due_on: date
    returned_on: date | None
    status: Literal["active", "overdue", "returned"]
