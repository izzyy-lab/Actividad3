# Flujo de trabajo colaborativo — GitFlow

Guía del flujo de ramas usado por el equipo en el Taller 3.

---

## 1. Ramas del proyecto

| Rama | Propósito | Quién la toca |
|---|---|---|
| `main` | Versión estable y entregable. Nunca se programa directamente sobre ella. | Sólo se recibe mediante *merge* desde `release/*` o `develop` |
| `develop` | Rama de integración: aquí se juntan los avances de ambos aprendices. | Recibe *merge* de cada `feature/*` |
| `feature/auth-frontend` | Login, Register y recuperación de contraseña (Flutter) | Aprendiz A |
| `feature/auth-backend` | Tabla `usuarios` y endpoints de autenticación | Aprendiz A |
| `feature/agenda-frontend` | Lista de agenda, formulario de tarea y perfil (Flutter) | Aprendiz B |
| `feature/agenda-backend` | Tabla `tareas` y endpoints CRUD | Aprendiz B |
| `release/x.y.z` | Congelación previa a la entrega: ajustes menores y documentación | Ambos |
| `hotfix/x.y.z` | Corrección urgente sobre `main` ya entregado | Quien detecte el fallo |

```
main ─────────────●──────────────────────────────●──────────►  v1.0.0
                   \                            /
develop ───●────────●────────●────────●────────●───────────►
            \      /          \      /
             feature/auth-*    feature/agenda-*
             (Aprendiz A)      (Aprendiz B)
```

---

## 2. Puesta en marcha del repositorio

```bash
git init
git add .
git commit -m "chore: estructura inicial del proyecto"
git branch -M main
git checkout -b develop
```

Con remoto en GitHub:

```bash
git remote add origin https://github.com/<usuario>/<repositorio>.git
git push -u origin main
git push -u origin develop
```

---

## 3. Ciclo de vida de una feature

**Paso 1 — Crear la rama a partir de `develop`.**

```bash
git checkout develop
git pull origin develop
git checkout -b feature/auth-frontend
```

**Paso 2 — Trabajar y hacer commits pequeños.**

```bash
git add lib/features/auth/presentation/pages/login_page.dart
git commit -m "feat(auth): pantalla de login con validacion de formulario"
```

**Paso 3 — Publicar la rama.**

```bash
git push -u origin feature/auth-frontend
```

**Paso 4 — Sincronizar antes de integrar** (evita conflictos grandes).

```bash
git checkout develop
git pull origin develop
git checkout feature/auth-frontend
git merge develop          # se resuelven conflictos aquí, no en develop
```

**Paso 5 — Integrar a `develop`** (por *Pull Request* revisado por el compañero, o por merge local).

```bash
git checkout develop
git merge --no-ff feature/auth-frontend
git push origin develop
```

Se usa `--no-ff` para que quede registrado en el historial que hubo una rama de trabajo.

**Paso 6 — Borrar la rama ya integrada.**

```bash
git branch -d feature/auth-frontend
git push origin --delete feature/auth-frontend
```

---

## 4. Entrega (release)

```bash
git checkout develop
git checkout -b release/1.0.0
# ajustes finales, versión en pubspec.yaml, README, capturas
git commit -m "docs: documentacion final del taller 3"

git checkout main
git merge --no-ff release/1.0.0
git tag -a v1.0.0 -m "Taller 3 - Gestor de Agenda"
git push origin main --tags

git checkout develop            # develop también recibe los ajustes
git merge --no-ff release/1.0.0
git push origin develop
```

---

## 5. Corrección urgente (hotfix)

```bash
git checkout main
git checkout -b hotfix/1.0.1
git commit -m "fix(auth): corrige expiracion del token de recuperacion"

git checkout main   && git merge --no-ff hotfix/1.0.1 && git tag -a v1.0.1 -m "Hotfix"
git checkout develop && git merge --no-ff hotfix/1.0.1
```

---

## 6. Convención de mensajes de commit

`<tipo>(<alcance>): <descripción en presente y minúscula>`

| Tipo | Se usa para |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de un error |
| `refactor` | Reorganizar código sin cambiar el comportamiento |
| `style` | Formato, espacios, nombres (sin lógica) |
| `test` | Agregar o modificar pruebas |
| `docs` | Documentación |
| `chore` | Configuración, dependencias, tareas de mantenimiento |

Alcances del proyecto: `auth`, `agenda`, `core`, `backend`, `db`.

Ejemplos reales:

```
feat(auth): endpoints de registro y login con JWT
feat(agenda): formulario de nueva tarea con selector de fecha y hora
fix(core): traduce el detail de FastAPI al mensaje mostrado al usuario
test(agenda): pruebas del provider con repositorio simulado
docs: guia de instalacion y ejecucion del backend
```

---

## 7. Cómo evitar conflictos entre los dos aprendices

El encarpetado por *features* está pensado justamente para eso: cada aprendiz
trabaja en su propia carpeta y casi nunca tocan el mismo archivo.

| Archivo | Dueño |
|---|---|
| `lib/features/auth/**` | Aprendiz A |
| `lib/features/agenda/**` | Aprendiz B |
| `backend/app/models/user.py`, `backend/app/api/routes/auth.py` | Aprendiz A |
| `backend/app/models/task.py`, `backend/app/api/routes/tasks.py` | Aprendiz B |

**Archivos compartidos** — avisar al compañero antes de modificarlos:

- `lib/main.dart` (inyección de dependencias)
- `lib/core/**` (constantes, tema, cliente HTTP)
- `pubspec.yaml`
- `backend/app/main.py`

Reglas de oro:

1. `git pull origin develop` **antes** de empezar a trabajar cada día.
2. Commits pequeños y frecuentes; no acumular cambios de varios días.
3. Los conflictos se resuelven en la rama `feature/*`, nunca en `develop`.
4. Antes de integrar: `flutter analyze` sin errores y `flutter test` en verde.
