"""Esquemas Pydantic de Tarea/Agenda."""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

Estado = Literal["pendiente", "en_progreso", "completada"]
Prioridad = Literal["baja", "media", "alta"]


class TaskCreate(BaseModel):
    titulo: str = Field(min_length=3, max_length=160)
    descripcion: str | None = None
    fecha: datetime
    estado: Estado = "pendiente"
    prioridad: Prioridad = "media"


class TaskUpdate(BaseModel):
    titulo: str | None = Field(default=None, min_length=3, max_length=160)
    descripcion: str | None = None
    fecha: datetime | None = None
    estado: Estado | None = None
    prioridad: Prioridad | None = None
    completada: bool | None = None


class TaskOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    titulo: str
    descripcion: str | None = None
    fecha: datetime
    estado: Estado
    prioridad: Prioridad
    completada: bool
    usuario_id: int
    creado_en: datetime
