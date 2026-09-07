"""Configuracion central de la API."""
import os

# Clave usada para firmar los JWT. En produccion debe venir de una variable de entorno.
SECRET_KEY: str = os.getenv("SECRET_KEY", "sena-taller3-gestor-agenda-clave-secreta")
ALGORITHM: str = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 dia

# Base de datos relacional (SQLite por simplicidad; el ORM permite migrar a MySQL/Postgres)
DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./agenda.db")

API_PREFIX: str = "/api"
PROJECT_NAME: str = "Gestor de Agenda API"
