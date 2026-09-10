"""Configuracion central de la API."""
import os

# Clave usada para firmar los JWT. La de respaldo solo sirve en local: esta
# publicada en el repositorio, asi que en Vercel es obligatorio definirla.
SECRET_KEY: str = os.getenv("SECRET_KEY") or ""
if not SECRET_KEY:
    if os.getenv("VERCEL"):
        raise RuntimeError("Falta la variable SECRET_KEY en el proyecto de Vercel.")
    SECRET_KEY = "sena-taller3-gestor-agenda-clave-local"
ALGORITHM: str = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 dia


def _normalizar_url_bd(url: str) -> str:
    """Neon/Vercel entregan la URL de Postgres como `postgresql://...` (o `postgres://`).

    SQLAlchemy necesita saber que driver usar, asi que se reescribe a
    `postgresql+psycopg://...` para usar psycopg 3.
    """
    for prefijo in ("postgres://", "postgresql://"):
        if url.startswith(prefijo):
            return "postgresql+psycopg://" + url[len(prefijo):]
    return url


def _leer_url_bd() -> str:
    """Base de datos relacional:

    - En local, si no hay DATABASE_URL, se usa SQLite (archivo agenda.db).
    - En Vercel, DATABASE_URL la agrega la integracion de Neon (PostgreSQL).
      Alli el disco es de solo lectura, asi que sin DATABASE_URL no hay
      donde guardar datos: se falla con un mensaje claro.
    """
    url = os.getenv("DATABASE_URL")
    if url:
        return _normalizar_url_bd(url)
    if os.getenv("VERCEL"):
        raise RuntimeError(
            "Falta la variable DATABASE_URL. Conecta una base de datos "
            "(Vercel > Storage > Neon) al proyecto y vuelve a desplegar."
        )
    return "sqlite:///./agenda.db"


DATABASE_URL: str = _leer_url_bd()

API_PREFIX: str = "/api"
PROJECT_NAME: str = "Gestor de Agenda API"
