from datetime import date, datetime
from typing import Optional, List
from pydantic import BaseModel
from models import TaskStatus


# ── Request Schemas ───────────────────────────────────────────────

class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = ""
    due_date: Optional[date] = None
    status: TaskStatus = TaskStatus.todo
    blocked_by_id: Optional[int] = None


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    due_date: Optional[date] = None
    status: Optional[TaskStatus] = None
    blocked_by_id: Optional[int] = None


class ReorderItem(BaseModel):
    id: int
    position: int


# ── Response Schemas ──────────────────────────────────────────────

class TaskOut(BaseModel):
    id: int
    title: str
    description: Optional[str]
    due_date: Optional[date]
    status: TaskStatus
    blocked_by_id: Optional[int]
    position: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
