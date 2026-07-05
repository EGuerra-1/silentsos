# Silent SOS

Plataforma de emergencias accesible para personas con discapacidad auditiva y del habla. Coordina alertas SOS, contexto visual con IA, llamadas al 911 y notificaciones a contactos de confianza — sin depender de la voz.

---

## Enlaces en producción

| Componente | URL |
|---|---|
| **Landing page** | [landinghack.danielmorales.tech](https://landinghack.danielmorales.tech/) |
| **API REST** | [hackton.danielmorales.tech/api](https://hackton.danielmorales.tech/api) |
| **APK Android** | [Descargar en Google Drive](https://drive.google.com/file/d/1KHpwoZHwc965lBLDsoulaiRcnyDT-LET/view?usp=sharing) |

---

## Estructura del repositorio

```
silent-sos/
├── landing-page/   # Sitio web estático (Astro)
├── backend/        # API REST (Node.js + Sequelize)
└── mobile/         # App Android/iOS (Flutter)
```

---

## Stack por módulo

### Landing page — `landing-page/`

| Tecnología | Uso |
|---|---|
| **Astro 4** | HTML estático en build time |
| **TypeScript** | Tipado y configuración |
| **Tailwind CSS** | Estilos y design tokens (Google Stitch) |

Sitio informativo: funciones, flujo de emergencia, accesibilidad y CTA de descarga. Sin JavaScript en cliente.

→ Ver [landing-page/README.md](./landing-page/README.md)

---

### API — `backend/`

| Tecnología | Uso |
|---|---|
| **Node.js + Express** | Servidor HTTP y rutas REST |
| **Sequelize** | ORM, migraciones y seeders |
| **PostgreSQL** | Base de datos |
| **OpenAI Vision** | Triage de emergencias con fotos |
| **ElevenLabs** | Síntesis de voz para llamadas |
| **Twilio** | Llamadas al 911 |
| **AWS S3** | Almacenamiento de imágenes/videos |
| **JWT + bcrypt** | Autenticación y seguridad |

Orquesta el flujo completo: recibe emergencias desde la app, analiza con IA, genera audio, llama al 911 y notifica contactos vía n8n/SMS.

→ Ver [backend/README.md](./backend/README.md)

---

### App móvil — `mobile/`

| Tecnología | Uso |
|---|---|
| **Flutter / Dart** | UI multiplataforma (Android / iOS) |
| **Riverpod** | Estado e inyección de dependencias |
| **Geolocator** | GPS de alta precisión |
| **Image Picker** | Fotos para emergencia contextual |
| **Flutter Secure Storage** | Sesión y tokens |

Permite activar SOS en un toque, enviar contexto visual, gestionar salud (enfermedades/medicamentos) y configurar contactos de emergencia.

→ Ver [mobile/README.md](./mobile/README.md)

---

## Flujo general

```
Usuario (app Flutter)
    │
    ▼
API (Node + Sequelize) ──► PostgreSQL
    │
    ├── OpenAI Vision  (análisis de escena)
    ├── ElevenLabs     (voz para el 911)
    ├── Twilio         (llamada de emergencia)
    └── n8n / SMS      (alerta a contactos)
```

---

## Desarrollo local

### Landing page
```bash
cd landing-page
npm install && npm run dev
# → http://localhost:4321
```

### API
```bash
cd backend
cp .env.example .env
docker compose up --build -d
# → http://localhost:3000/api
```

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

---

## Licencia

Proyecto privado — Silent SOS Hackathon.
