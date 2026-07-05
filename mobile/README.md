# SilentSOS — App móvil (Flutter)

Aplicación móvil de **SilentSOS** orientada a personas con discapacidad auditiva. Permite activar emergencias con ubicación GPS precisa, enviar contexto visual (fotos + IA) al backend, gestionar salud (enfermedades y medicamentos) y configurar perfil y contacto de confianza.

Se conecta a la API REST de SilentSOS (`/api`) con autenticación JWT.

---

## Qué hace la app

| Módulo | Descripción |
|--------|-------------|
| **Emergencias** | SOS rápido (tipo médica/general) o emergencia con contexto (cámara trasera + frontal, texto opcional, análisis Vision en backend). Seguimiento en tiempo real del protocolo (audio, llamada, SMS). |
| **Salud** | Enfermedades del usuario, medicamentos, dosis pendientes de hoy e historial de consumos. |
| **Ajustes** | Perfil, contacto de emergencia, tema claro/oscuro y cierre de sesión. |
| **Auth** | Registro en 2 pasos, login y sesión persistida en almacenamiento seguro. |

---

## Stack

- **Flutter** 3.x (Dart ^3.12)
- **Riverpod** — estado e inyección de dependencias
- **http** — cliente REST con cola secuencial
- **flutter_secure_storage** — token y credenciales
- **flutter_dotenv** — configuración por entorno
- **geolocator / geocoding** — GPS de alta precisión
- **image_picker** — captura de fotos para emergencia contextual
- **google_fonts** — tipografía Inter (design system Stitch)

---

## Arquitectura

Organización **feature-first** con capas claras. Cada módulo sigue el mismo flujo de dependencias:

```text
presentation  →  controllers  →  services  →  repositories  →  datasource
                      ↑                                              ↓
                 providers (Riverpod)                          ApiService / GPS / cámara
```

| Capa | Responsabilidad |
|------|-----------------|
| `presentation/` | UI, navegación, validaciones ligeras |
| `controllers/` | Estado de pantalla (`StateNotifier`, `AsyncValue`) |
| `services/` | Reglas de negocio y orquestación |
| `repositories/` | Abstracción sobre fuentes de datos |
| `datasource/` | HTTP hacia la API |
| `providers/` | Wiring de dependencias con Riverpod |
| `models/` / `entities/` | DTOs y entidades de dominio |

Piezas transversales:

- **`core/`** — routing, tema, constantes, `AppConfig`, `ApiService`, `StorageService`
- **`shared/`** — widgets reutilizables (`AppButton`, `AppCard`, `AppTextField`, animaciones)

---

## Estructura del proyecto

```text
lib/
├── main.dart                 # AppConfig + ProviderScope
├── app.dart                  # MaterialApp, tema, rutas
├── core/
│   ├── constants/            # AppStrings, AppSpacing, AppConfig
│   ├── routing/              # AppRouter centralizado
│   ├── services/             # ApiService, StorageService, AppLogger
│   └── themes/               # Light / Dark (Stitch)
├── shared/widgets/           # Design system reutilizable
└── features/
    ├── auth/                 # Login, registro
    ├── splash/               # Boot + sesión guardada
    ├── shell/                # Bottom nav (3 tabs)
    ├── home/                 # Tab Emergencias
    ├── emergency/            # SOS, contextual, GPS, polling
    ├── medical/              # Salud: enfermedades y medicamentos
    └── settings/             # Perfil, contacto, tema
```

---

## Configuración

1. Copia el archivo de entorno:

```bash
cp .env.example .env
```

2. Ajusta variables en `.env`:

```env
BASE_URL=https://tu-servidor.com/api
TOKEN_DURATION_DAYS=30
```

> En emulador Android, `localhost` apunta al dispositivo. Usa `10.0.2.2:4000/api` para backend local, o la URL pública del servidor.

---

## Ejecutar

```bash
cd mobile
flutter pub get
flutter run
```

Análisis estático:

```bash
dart analyze lib
```

---

## Flujos principales (API)

### Autenticación
- `POST /auth/register` — registro + contacto de emergencia
- `POST /auth/login` — JWT guardado en secure storage

### Emergencia SOS
- `POST /emergencies/urgency` — alerta inmediata con GPS
- `POST /emergencies/contextual` — multipart: `front_image`, `back_image`, GPS, `call_mode: single_context`
- `GET /emergencies/:id` — polling cada 2 s del estado del protocolo

### Salud
- CRUD enfermedades, medicamentos, consumos y pendientes del día

### Ajustes
- `GET/PUT /users/:id` — perfil
- `GET/PUT /emergency_contacts/:id` — contacto de confianza

---

## Permisos nativos

| Permiso | Uso |
|---------|-----|
| Ubicación (fine/coarse) | Coordenadas de emergencia |
| Cámara | Fotos frontal/trasera en flujo contextual |
| Internet | Comunicación con la API |

---

## Design system

UI basada en tokens de **Google Stitch**: radios 16/24, espaciado en grid de 8 px, paleta índigo + acentos de error para SOS. Componentes compartidos en `shared/widgets/` para mantener consistencia visual.

---

## Repositorio

Este directorio (`mobile/`) es la app Flutter del monorepo **SilentSOS**. El backend Node.js vive en la carpeta hermana `backend/`.
