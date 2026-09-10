"""Configuracion central de la API."""
import os

# Clave usada para firmar los JWT. En produccion debe venir de una variable de entorno.
SECRET_KEY: str = os.getenv("SECRET_KEY", "sena-taller3-gestor-agenda-clave-secreta")
ALGORITHM: str = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 dia


def _normalizar_url_bd(url: str) -> str:
    """Railway entrega la URL de Postgres como `postgresql://...` (o `postgres://`).

    SQLAlchemy necesita saber que driver usar, asi que se reescribe a
    `postgresql+psycopg://...` para usar psycopg 3.
    """
    for prefijo in ("postgres://", "postgresql://"):
        if url.startswith(prefijo):
            return "postgresql+psycopg://" + url[len(prefijo):]
    return url


# Base de datos relacional:
#   - En local, si no hay DATABASE_URL, se usa SQLite (archivo agenda.db).
#   - En Railway, DATABASE_URL apunta al servicio PostgreSQL del proyecto.
DATABASE_URL: str = _normalizar_url_bd(os.getenv("DATABASE_URL", "sqlite:///./agenda.db"))

API_PREFIX: str = "/api"
PROJECT_NAME: str = "Gestor de Agenda API"
