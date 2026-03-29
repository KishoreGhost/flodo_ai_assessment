from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from database import get_db
from schemas import TaskCreate, TaskUpdate, TaskOut, ReorderItem
import crud

router = APIRouter(prefix="/tasks", tags=["tasks"])


@router.get("", response_model=List[TaskOut])
async def list_tasks(
    q: Optional[str] = Query(None, description="Search tasks by title"),
    db: Session = Depends(get_db),
):
    return await crud.get_all_tasks(db, q=q)


@router.post("", response_model=TaskOut, status_code=201)
async def create_task(data: TaskCreate, db: Session = Depends(get_db)):
    return await crud.create_task(db, data)


# Static route MUST come before /{task_id} to avoid shadowing
@router.patch("/reorder", status_code=200)
async def reorder_tasks(items: List[ReorderItem], db: Session = Depends(get_db)):
    await crud.reorder_tasks(db, items)
    return {"detail": "Reordered successfully"}


@router.get("/{task_id}", response_model=TaskOut)
async def get_task(task_id: int, db: Session = Depends(get_db)):
    task = await crud.get_task(db, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.put("/{task_id}", response_model=TaskOut)
async def update_task(task_id: int, data: TaskUpdate, db: Session = Depends(get_db)):
    task = await crud.update_task(db, task_id, data)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.delete("/{task_id}", status_code=204)
async def delete_task(task_id: int, db: Session = Depends(get_db)):
    deleted = await crud.delete_task(db, task_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Task not found")
