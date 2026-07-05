# SilentSOS Movil

Base Flutter profesional para SilentSOS, alineada al design system de Google Stitch:

- Arquitectura modular `core/shared/features`.
- Tema completo Light/Dark con tokens centralizados.
- Flujo inicial de pantallas: Splash, Login, Registro (2 pasos), Home.
- Estado con Riverpod.
- Componentes reutilizables (`AppButton`, `AppTextField`, `AppCard`, `CustomAppBar`, estados de carga/error/vacio).

## Arquitectura (revision)

La estructura actual **si esta bien** para escalar: usa `core/shared/features`, separa UI de logica y evita pantallas gigantes.

Direccion de dependencias por feature:

```text
presentation -> controllers -> services -> repositories -> datasource
                              \-> entities/models
```

Reglas para mantenerla entendible:

- `presentation/`: solo UI, validaciones ligeras y navegacion.
- `controllers/`: estado y casos de uso de pantalla.
- `services/`: reglas de negocio.
- `repositories/`: contrato/adaptador de acceso a datos.
- `datasource/`: llamadas remotas/locales (API, cache, DB).
- `providers/`: unica zona para inyeccion de dependencias con Riverpod.
- `core/`: piezas transversales (theme, routing, constants, utils).
- `shared/`: widgets/modelos reutilizables entre features.

Plantilla recomendada para nuevas features:

```text
features/<feature>/
  presentation/
    pages/
    widgets/
  controllers/
  providers/
  services/
  repositories/
  datasource/
  entities/
  models/
```

Esta convencion es la que se esta usando en `auth` y `home`, por lo que el proyecto ya esta encaminado correctamente.

## Estructura

```text
lib/
  core/
    constants/
    exceptions/
    extensions/
    routing/
    services/
    themes/
    utils/
  shared/
    enums/
    mixins/
    models/
    widgets/
  features/
    auth/
    home/
    splash/
  app.dart
  main.dart
```

## Ejecutar

```bash
flutter pub get
flutter run
```
