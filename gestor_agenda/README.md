# gestor_agenda — Aplicación Flutter

Cliente móvil (Android + Web) del Taller 3 "Gestor de Agenda", organizado con
**Clean Architecture**. Consume la API REST que está en `../backend`.

La documentación completa del proyecto (arquitectura, endpoints, base de datos,
reparto de módulos y GitFlow) está en el [README de la raíz](../README.md).

## Ejecutar

```bash
flutter pub get
flutter run -d chrome          # Web
flutter run -d emulator-5554   # Android
```

> El backend debe estar corriendo en `http://127.0.0.1:8000`.
> La URL base se resuelve sola por plataforma en
> [`lib/core/constants/api_constants.dart`](lib/core/constants/api_constants.dart):
> `127.0.0.1` en Web y `10.0.2.2` en el emulador de Android.

## Verificar

```bash
flutter analyze     # análisis estático
flutter test        # 42 pruebas unitarias
```

## Estructura

```
lib/
├── core/           # constantes, tema, cliente HTTP, almacenamiento, errores
├── features/
│   ├── auth/       # data · domain · presentation   (login, registro, recuperación, perfil)
│   └── agenda/     # data · domain · presentation   (lista, formulario, filtros)
└── main.dart       # punto de entrada e inyección de dependencias
```
