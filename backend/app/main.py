"""Punto de entrada de la API REST del Gestor de Agenda."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import auth, tasks
from app.core.config import API_PREFIX, PROJECT_NAME
from app.core.database import Base, engine
from app.models import Task, User  # noqa: F401  (necesario para registrar las tablas)

# Crea las tablas si aun no existen.
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=PROJECT_NAME,
    version="1.0.0",
    description="API REST para el Taller 3 - Flutter Gestor de Agenda (SENA)",
)

# Necesario para consumir la API desde Flutter Web.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix=API_PREFIX)
app.include_router(tasks.router, prefix=API_PREFIX)


@app.get("/", tags=["Estado"])
def raiz():
    return {"servicio": PROJECT_NAME, "estado": "activo", "docs": "/docs"}
