import enum
from datetime import date, datetime
from sqlalchemy import Column, Integer, String, Date, DateTime, Enum, ForeignKey
from sqlalchemy.orm import relationship
from database import Base


class TaskStatus(str, enum.Enum):
    todo = "todo"
    in_progress = "in_progress"
    done = "done"


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True, default="")
    due_date = Column(Date, nullable=True)
    status = Column(Enum(TaskStatus), nullable=False, default=TaskStatus.todo)
    position = Column(Integer, nullable=False, default=0)

    # Self-referential FK for "Blocked By"
    blocked_by_id = Column(Integer, ForeignKey("tasks.id"), nullable=True)
    blocked_by = relationship(
        "Task",
        foreign_keys=[blocked_by_id],
        remote_side="Task.id",
        backref="blocking",
    )

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
