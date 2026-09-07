"""Endpoints CRUD de la Agenda -- Aprendiz B.

GET    /api/tasks        Listar tareas del usuario (filtro opcional por estado)
POST   /api/tasks        Crear tarea
GET    /api/tasks/{id}   Detalle de una tarea
PUT    /api/tasks/{id}   Actualizar tarea
DELETE /api/tasks/{id}   Eliminar tarea
"""
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models import Task, User
from app.schemas.task import TaskCreate, TaskOut, TaskUpdate

router = APIRouter(prefix="/tasks", tags=["Agenda"])


def _obtener_tarea(task_id: int, user: User, db: Session) -> Task:
    tarea = db.get(Task, task_id)
    # Se valida tambien la propiedad: un usuario no puede tocar tareas ajenas.
    if tarea is None or tarea.usuario_id != user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tarea no encontrada")
    return tarea


@router.get("", response_model=list[TaskOut])
def listar(
    estado: str | None = Query(default=None, description="pendiente | en_progreso | completada"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    consulta = db.query(Task).filter(Task.usuario_id == current_user.id)
    if estado:
        consulta = consulta.filter(Task.estado == estado)
    return consulta.order_by(Task.fecha.asc()).all()


@router.post("", response_model=TaskOut, status_code=status.HTTP_201_CREATED)
def crear(
    data: TaskCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    tarea = Task(
        **data.model_dump(),
        completada=data.estado == "completada",
        usuario_id=current_user.id,
    )
    db.add(tarea)
    db.commit()
    db.refresh(tarea)
    return tarea


@router.get("/{task_id}", response_model=TaskOut)
def detalle(
    task_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return _obtener_tarea(task_id, current_user, db)


@router.put("/{task_id}", response_model=TaskOut)
def actualizar(
    task_id: int,
    data: TaskUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    tarea = _obtener_tarea(task_id, current_user, db)
    cambios = data.model_dump(exclude_unset=True)
    for campo, valor in cambios.items():
        setattr(tarea, campo, valor)

    # Se mantienen sincronizados 'estado' y 'completada'.
    if "estado" in cambios and "completada" not in cambios:
        tarea.completada = tarea.estado == "completada"
    elif "completada" in cambios and "estado" not in cambios:
        tarea.estado = "completada" if tarea.completada else "pendiente"

    db.commit()
    db.refresh(tarea)
    return tarea


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar(
    task_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    tarea = _obtener_tarea(task_id, current_user, db)
    db.delete(tarea)
    db.commit()
