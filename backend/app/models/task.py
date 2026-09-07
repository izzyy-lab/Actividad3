"""Tabla Agenda/Tareas -- Aprendiz B."""
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class Task(Base):
    __tablename__ = "tareas"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    titulo: Mapped[str] = mapped_column(String(160), nullable=False)
    descripcion: Mapped[str | None] = mapped_column(Text, nullable=True)
    fecha: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    # pendiente | en_progreso | completada
    estado: Mapped[str] = mapped_column(String(20), default="pendiente", nullable=False)
    # baja | media | alta
    prioridad: Mapped[str] = mapped_column(String(10), default="media", nullable=False)
    completada: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    creado_en: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )

    # Relacion 1:N -> un usuario tiene muchas tareas
    usuario_id: Mapped[int] = mapped_column(
        ForeignKey("usuarios.id", ondelete="CASCADE"), nullable=False, index=True
    )
    usuario = relationship("User", back_populates="tareas")
