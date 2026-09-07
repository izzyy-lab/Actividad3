# Taller 3 — Flutter "Gestor de Agenda"

Aplicación móvil en **Flutter** (Android + Web) conectada a una **API REST en FastAPI**
con **base de datos relacional**, organizada bajo **Clean Architecture** y con flujo de
trabajo colaborativo **GitFlow**.

| | |
|---|---|
| Frontend | Flutter 3.47 · Dart 3.13 · Provider · http · shared_preferences · intl |
| Backend | FastAPI · SQLAlchemy 2 · SQLite · JWT (python-jose) · bcrypt |
| Plataformas | Android y Web |
| Pruebas | 41 pruebas Flutter + 19 verificaciones de la API |

---

## 1. Estructura del repositorio

```
Actividad3/
├── backend/            API REST (FastAPI + SQLAlchemy + SQLite)
├── gestor_agenda/      Aplicación Flutter (Clean Architecture)
├── GITFLOW.md          Guía del flujo de ramas del equipo
└── README.md
```

---

## 2. Reparto de módulos

| Módulo funcional | Aprendiz A (Desarrollador 1) | Aprendiz B (Desarrollador 2) |
|---|---|---|
| **Fase 1: Frontend (Flutter)** | Pantalla de Login, Register y recuperación de contraseña | Lista de Agenda, Formulario de Nueva Tarea y Perfil de Usuario |
| **Fase 2: Backend & BD** | Tabla `usuarios`, endpoints de autenticación (login/registro) | Tabla `tareas`, endpoints CRUD de actividades |

**Archivos de cada aprendiz**

| Aprendiz A | Aprendiz B |
|---|---|
| `lib/features/auth/**` | `lib/features/agenda/**` |
| `login_page.dart`, `register_page.dart`, `forgot_pass_page.dart` | `agenda_list_page.dart`, `task_form_page.dart` |
| `backend/app/models/user.py` | `backend/app/models/task.py` |
| `backend/app/api/routes/auth.py` | `backend/app/api/routes/tasks.py` |
| | `profile_page.dart` (ubicado dentro de `auth/`) |

---

## 3. Encarpetado Clean Architecture

```
lib/
├── core/                              # Código transversal (compartido)
│   ├── constants/                     # api_constants, app_colors, app_theme
│   ├── error/                         # failures.dart (Failure, ServerFailure, ...)
│   ├── network/                       # api_client.dart (cliente HTTP central)
│   ├── storage/                       # token_storage.dart (JWT en el dispositivo)
│   └── utils/                         # validators.dart
│
├── features/
│   ├── auth/                          # APRENDIZ A (Login, Register y recuperación)
│   │   ├── data/
│   │   │   ├── datasources/           # auth_remote_datasource.dart
│   │   │   ├── models/                # user_model.dart (fromJson / toJson)
│   │   │   └── repositories/          # auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/              # user.dart
│   │   │   ├── repositories/          # auth_repository.dart (contrato)
│   │   │   └── usecases/              # login, register, forgot_password, ...
│   │   └── presentation/
│   │       ├── providers/             # auth_provider.dart
│   │       ├── pages/                 # login_page, register_page,
│   │       │                          # forgot_pass_page, profile_page (Aprendiz B)
│   │       └── widgets/               # auth_text_field, auth_button
│   │
│   └── agenda/                        # APRENDIZ B (Lista, Formulario y perfil)
│       ├── data/
│       │   ├── datasources/           # task_remote_datasource.dart
│       │   ├── models/                # task_model.dart
│       │   └── repositories/          # task_repository_impl.dart
│       ├── domain/
│       │   ├── entities/              # task.dart (Task, EstadoTarea, PrioridadTarea)
│       │   ├── repositories/          # task_repository.dart (contrato)
│       │   └── usecases/              # get, create, update, delete, toggle
│       └── presentation/
│           ├── providers/             # agenda_provider.dart
│           ├── pages/                 # agenda_list_page.dart, task_form_page.dart
│           └── widgets/               # task_card.dart, status_badge.dart
│
└── main.dart                          # Punto de entrada e inyección de dependencias
```

**Regla de dependencia:** `presentation → domain ← data`.
El dominio no conoce Flutter, HTTP ni JSON; sólo define entidades, contratos y casos de uso.
`main.dart` arma el grafo completo: `TokenStorage → ApiClient → DataSource → Repository → UseCases → Provider`.

---

## 4. Base de datos relacional

```
usuarios                          tareas
--------                          ------
id            PK                  id            PK
nombre                            titulo
email         UNIQUE              descripcion
password_hash (bcrypt)            fecha
telefono                          estado        pendiente | en_progreso | completada
reset_token                       prioridad     baja | media | alta
reset_token_exp                   completada
creado_en                         creado_en
                                  usuario_id    FK -> usuarios.id (ON DELETE CASCADE)
```

Relación **1:N** — un usuario tiene muchas tareas. Las contraseñas se guardan
siempre con hash bcrypt, nunca en texto plano.

---

## 5. Endpoints de la API

Base: `http://127.0.0.1:8000/api` · Documentación interactiva: `http://127.0.0.1:8000/docs`

### Autenticación (Aprendiz A)

| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| `POST` | `/auth/register` | Registro de usuario, devuelve JWT | No |
| `POST` | `/auth/login` | Inicio de sesión, devuelve JWT | No |
| `POST` | `/auth/forgot-password` | Genera token de recuperación (30 min) | No |
| `POST` | `/auth/reset-password` | Cambia la contraseña con el token | No |
| `GET` | `/auth/me` | Perfil del usuario autenticado | Bearer |
| `PUT` | `/auth/me` | Actualiza nombre y teléfono | Bearer |

### Agenda (Aprendiz B)

| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| `GET` | `/tasks?estado=` | Lista las tareas del usuario (filtro opcional) | Bearer |
| `POST` | `/tasks` | Crea una tarea | Bearer |
| `GET` | `/tasks/{id}` | Detalle de una tarea | Bearer |
| `PUT` | `/tasks/{id}` | Actualiza una tarea (parcial) | Bearer |
| `DELETE` | `/tasks/{id}` | Elimina una tarea | Bearer |

Cada usuario sólo ve y modifica sus propias tareas: el `usuario_id` se toma del
token, nunca del cuerpo de la petición, y las tareas ajenas responden `404`.

---

## 6. Cómo ejecutar el proyecto

### 6.1 Backend

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate          # Windows   (source .venv/bin/activate en Linux/Mac)
pip install -r requirements.txt
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

La base `agenda.db` se crea sola en el primer arranque.
Verifica en el navegador: <http://127.0.0.1:8000/docs>

### 6.2 Aplicación Flutter

```bash
cd gestor_agenda
flutter pub get
flutter run -d chrome          # Web
flutter run -d emulator-5554   # Android
```

> **Importante — URL de la API.** `lib/core/constants/api_constants.dart` cambia la URL base
> automáticamente según la plataforma: en Web usa `127.0.0.1:8000`, y en Android usa
> `10.0.2.2:8000`, que es como el emulador ve el `localhost` del PC. Si pruebas en un
> teléfono físico, reemplaza esa IP por la de tu computador en la red local.

### 6.3 Pruebas

```bash
cd gestor_agenda
flutter analyze     # 0 issues
flutter test        # 41 pruebas
```

---

## 7. Flujo de la aplicación

```
                  ┌──────────────┐
   sin sesión ───►│  LoginPage   │◄──── cerrar sesión
                  └──────┬───────┘
             ┌───────────┼────────────┐
             ▼           ▼            ▼
      RegisterPage  ForgotPassPage  (token válido)
             │           │            │
             └───────────┴────────────┘
                         ▼
                 ┌───────────────┐   FAB "Nueva tarea"   ┌──────────────┐
                 │ AgendaListPage│◄─────────────────────►│ TaskFormPage │
                 └───────┬───────┘   tocar una tarjeta   └──────────────┘
                         │ avatar
                         ▼
                   ┌────────────┐
                   │ ProfilePage│
                   └────────────┘
```

**Funcionalidades implementadas**

- Registro, login y sesión persistente (el token se guarda con `shared_preferences`).
- Recuperación de contraseña en dos pasos (solicitar código → definir nueva contraseña).
- Perfil editable con contadores de tareas y cierre de sesión.
- CRUD completo de tareas con estado, prioridad, fecha y hora.
- Filtros por estado, marcado rápido con checkbox, resaltado de tareas vencidas,
  `pull to refresh` y estados vacíos / de error con botón de reintento.

---

## 8. Flujo de trabajo GitFlow

Ver [GITFLOW.md](GITFLOW.md) para el detalle de ramas, convención de commits y
el paso a paso de una feature completa.

```
main                 versión estable entregable
 └── develop         integración del equipo
      ├── feature/auth-frontend      Aprendiz A
      ├── feature/auth-backend       Aprendiz A
      ├── feature/agenda-frontend    Aprendiz B
      └── feature/agenda-backend     Aprendiz B
```
