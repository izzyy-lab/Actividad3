"""Endpoints de Autenticacion -- Aprendiz A.

POST /api/auth/register          Registro de usuario
POST /api/auth/login             Inicio de sesion (JWT)
POST /api/auth/forgot-password   Solicitud de recuperacion
POST /api/auth/reset-password    Cambio de contrasena con token
GET  /api/auth/me                Perfil del usuario autenticado
PUT  /api/auth/me                Actualizacion del perfil
"""
import secrets
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.database import get_db
from app.core.security import create_access_token, hash_password, verify_password
from app.models import User
from app.schemas.user import (
    ForgotPasswordRequest,
    ForgotPasswordResponse,
    MessageResponse,
    ResetPasswordRequest,
    TokenResponse,
    UserLogin,
    UserOut,
    UserRegister,
    UserUpdate,
)

router = APIRouter(prefix="/auth", tags=["Autenticacion"])


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(data: UserRegister, db: Session = Depends(get_db)):
    existe = db.query(User).filter(User.email == data.email).first()
    if existe:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="El correo ya se encuentra registrado",
        )

    user = User(
        nombre=data.nombre,
        email=data.email,
        password_hash=hash_password(data.password),
        telefono=data.telefono,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return TokenResponse(access_token=create_access_token(user.id), user=UserOut.model_validate(user))


@router.post("/login", response_model=TokenResponse)
def login(data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if user is None or not verify_password(data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Correo o contrasena incorrectos",
        )

    return TokenResponse(access_token=create_access_token(user.id), user=UserOut.model_validate(user))


@router.post("/forgot-password", response_model=ForgotPasswordResponse)
def forgot_password(data: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    # Respuesta uniforme: no revela si el correo existe.
    mensaje = "Si el correo esta registrado recibiras instrucciones para restablecer la contrasena."
    if user is None:
        return ForgotPasswordResponse(message=mensaje)

    user.reset_token = secrets.token_urlsafe(24)
    user.reset_token_exp = datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(minutes=30)
    db.commit()

    return ForgotPasswordResponse(message=mensaje, reset_token=user.reset_token)


@router.post("/reset-password", response_model=MessageResponse)
def reset_password(data: ResetPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.reset_token == data.reset_token).first()
    ahora = datetime.now(timezone.utc).replace(tzinfo=None)
    if user is None or user.reset_token_exp is None or user.reset_token_exp < ahora:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token de recuperacion invalido o expirado",
        )

    user.password_hash = hash_password(data.new_password)
    user.reset_token = None
    user.reset_token_exp = None
    db.commit()

    return MessageResponse(message="Contrasena actualizada correctamente")


@router.get("/me", response_model=UserOut)
def perfil(current_user: User = Depends(get_current_user)):
    return current_user


@router.put("/me", response_model=UserOut)
def actualizar_perfil(
    data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    for campo, valor in data.model_dump(exclude_unset=True).items():
        setattr(current_user, campo, valor)
    db.commit()
    db.refresh(current_user)
    return current_user
