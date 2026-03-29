import asyncio
from typing import List, Optional
from sqlalchemy.orm import Session
from models import Task, TaskStatus
from schemas import TaskCreate, TaskUpdate, ReorderItem

SIMULATED_DELAY_SECONDS = 2


async def get_all_tasks(db: Session, q: Optional[str] = None) -> List[Task]:
    query = db.query(Task)
    if q:
        query = query.filter(Task.title.ilike(f"%{q}%"))
    return query.order_by(Task.position.asc(), Task.created_at.asc()).all()


async def get_task(db: Session, task_id: int) -> Optional[Task]:
    return db.query(Task).filter(Task.id == task_id).first()


async def create_task(db: Session, data: TaskCreate) -> Task:
    await asyncio.sleep(SIMULATED_DELAY_SECONDS)

    # Assign position as the next available slot
    max_pos = db.query(Task).count()
    task = Task(
        title=data.title,
        description=data.description,
        due_date=data.due_date,
        status=data.status,
        blocked_by_id=data.blocked_by_id,
        position=max_pos,
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    return task


async def update_task(db: Session, task_id: int, data: TaskUpdate) -> Optional[Task]:
    await asyncio.sleep(SIMULATED_DELAY_SECONDS)

    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        return None

    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(task, field, value)

    db.commit()
    db.refresh(task)
    return task


async def delete_task(db: Session, task_id: int) -> bool:
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        return False

    # Clear any task that is blocked by this one first
    blocked_tasks = db.query(Task).filter(Task.blocked_by_id == task_id).all()
    for bt in blocked_tasks:
        bt.blocked_by_id = None

    db.delete(task)
    db.commit()
    return True


async def reorder_tasks(db: Session, items: List[ReorderItem]) -> bool:
    for item in items:
        task = db.query(Task).filter(Task.id == item.id).first()
        if task:
            task.position = item.position
    db.commit()
    return True
