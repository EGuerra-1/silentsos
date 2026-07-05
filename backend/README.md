# SilentSOS API

API REST para gestión de usuarios y contactos de emergencia.

## Base URL
```
http://localhost:4000
```

## Autenticación

Los endpoints protegidos requieren un token JWT en el header:
```
Authorization: Bearer <token>
```

### Expiración del Token
| Rol | Duración |
|-----|----------|
| Admin | 30 días |
| User | 30 días |

---

## Endpoints

### 1. Registro de Usuario (Cliente)

Crea un nuevo usuario con rol `user`. **No requiere autenticación.**

**Endpoint:**
```
POST /auth/register
```

**Request Body:**
```json
{
  "full_name": "Daniel Morales",
  "email": "daniel@gmail.com",
  "cellphone": "12345678",
  "password": "Clave123!"
}
```

**Respuesta Exitosa (201):**
```json
{
  "success": true,
  "route": "/auth/register",
  "message": "User registered",
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "full_name": "Daniel Morales",
    "email": "daniel@gmail.com",
    "rol": "user",
    "cellphone": "12345678",
    "password": "$2b$10$...",
    "created_at": "2025-07-04T15:00:00.000Z",
    "updated_at": "2025-07-04T15:00:00.000Z",
    "deleted_at": null
  }
}
```

**Error - Email duplicado (400):**
```json
{
  "success": false,
  "route": "/auth/register",
  "message": "",
  "error": "Email already exists"
}
```

---

### 2. Login

Obtiene un token JWT. **No requiere autenticación.**

**Endpoint:**
```
POST /auth/login
```

**Request Body:**
```json
{
  "email": "daniel@gmail.com",
  "password": "Clave123!"
}
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/auth/login",
  "message": "User logged in",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "email": "daniel@gmail.com",
      "full_name": "Daniel Morales",
      "rol": "user"
    }
  }
}
```

**Error - Credenciales inválidas (401):**
```json
{
  "success": false,
  "route": "/auth/login",
  "message": "",
  "error": "Invalid credentials"
}
```

---

### 3. Crear Contacto de Emergencia

Crea un contacto de emergencia. El `user_id` se toma automáticamente del token. **Requiere autenticación (admin o user).**

**Endpoint:**
```
POST /emergency_contacts
```

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "full_name": "María López",
  "cellphone": "87654321",
  "relationship": "Madre"
}
```

**Respuesta Exitosa (201):**
```json
{
  "success": true,
  "route": "/emergency_contacts",
  "message": "Emergency contact created",
  "data": {
    "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
    "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "full_name": "María López",
    "cellphone": "87654321",
    "relationship": "Madre",
    "created_at": "2025-07-04T15:30:00.000Z",
    "updated_at": "2025-07-04T15:30:00.000Z",
    "deleted_at": null
  }
}
```

**Error - No autorizado (401):**
```json
{
  "error": "Token not provided"
}
```

---

### 4. Listar Contactos de Emergencia

**Admin:** Ve todos los contactos.
**User:** Solo ve sus propios contactos.

**Endpoint:**
```
GET /emergency_contacts
```

**Headers:**
```
Authorization: Bearer <token>
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/emergency_contacts",
  "message": "Emergency contacts list",
  "data": [
    {
      "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "full_name": "María López",
      "cellphone": "87654321",
      "relationship": "Madre",
      "created_at": "2025-07-04T15:30:00.000Z",
      "updated_at": "2025-07-04T15:30:00.000Z",
      "deleted_at": null
    }
  ]
}
```

---

### 5. Obtener Contacto por ID

**Admin:** Puede ver cualquier contacto.
**User:** Solo puede ver sus propios contactos (403 si no le pertenece).

**Endpoint:**
```
GET /emergency_contacts/:id
```

**Headers:**
```
Authorization: Bearer <token>
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/emergency_contacts/b2c3d4e5-f6a7-8901-bcde-f12345678901",
  "message": "",
  "data": {
    "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
    "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "full_name": "María López",
    "cellphone": "87654321",
    "relationship": "Madre",
    "created_at": "2025-07-04T15:30:00.000Z",
    "updated_at": "2025-07-04T15:30:00.000Z",
    "deleted_at": null
  }
}
```

**Error - No autorizado (403):**
```json
{
  "success": false,
  "route": "/emergency_contacts/b2c3d4e5-f6a7-8901-bcde-f12345678901",
  "message": "",
  "error": "Unauthorized"
}
```

---

### 6. Actualizar Contacto de Emergencia

**Admin:** Puede actualizar cualquier contacto.
**User:** Solo puede actualizar sus propios contactos. No se puede cambiar el `user_id`.

**Endpoint:**
```
PUT /emergency_contacts/:id
```

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "full_name": "María López García",
  "cellphone": "87654321",
  "relationship": "Madre"
}
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/emergency_contacts",
  "message": "Emergency contact updated",
  "data": {
    "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
    "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "full_name": "María López García",
    "cellphone": "87654321",
    "relationship": "Madre",
    "created_at": "2025-07-04T15:30:00.000Z",
    "updated_at": "2025-07-04T16:00:00.000Z",
    "deleted_at": null
  }
}
```

---

### 7. Eliminar Contacto de Emergencia

**Admin:** Puede eliminar cualquier contacto.
**User:** Solo puede eliminar sus propios contactos (403 si no le pertenece).

**Endpoint:**
```
DELETE /emergency_contacts/:id
```

**Headers:**
```
Authorization: Bearer <token>
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/emergency_contacts",
  "message": "Emergency contact deleted",
  "data": null
}
```

---

## Módulo Médico (Enfermedades y Medicamentos)

Todos los endpoints del módulo médico requieren autenticación con rol `user`.

```
Authorization: Bearer <token>
```

---

### 8. Catálogo de Enfermedades

Obtiene la lista global de enfermedades disponibles para selección.

**Endpoint:**
```
GET /medical/disease_catalogs
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/medical/disease_catalogs",
  "message": "Disease catalog list",
  "data": [
    {
      "id": "c1d2e3f4-a5b6-7890-cdef-123456789012",
      "name": "Diabetes Tipo 2",
      "classification": "Endocrino",
      "description": "Enfermedad metabólica caracterizada por niveles altos de glucosa en sangre",
      "created_at": "2025-07-04T10:00:00.000Z",
      "updated_at": "2025-07-04T10:00:00.000Z"
    },
    {
      "id": "d2e3f4a5-b6c7-8901-defa-234567890123",
      "name": "Hipertensión",
      "classification": "Cardiovascular",
      "description": "Presión arterial elevada de forma crónica",
      "created_at": "2025-07-04T10:00:00.000Z",
      "updated_at": "2025-07-04T10:00:00.000Z"
    }
  ]
}
```

---

### 9. Registrar Enfermedad del Usuario

Registra una enfermedad para el usuario autenticado. El `user_id` se toma automáticamente del token.

**Endpoint:**
```
POST /medical/user_diseases
```

**Request Body:**
```json
{
  "disease_catalog_id": "c1d2e3f4-a5b6-7890-cdef-123456789012",
  "notes": "Diagnosticada hace 5 años, controlada con dieta",
  "diagnosed_at": "2020-03-15"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `disease_catalog_id` | UUID | Si | ID del catálogo de enfermedades |
| `notes` | String | No | Notas adicionales sobre la enfermedad |
| `diagnosed_at` | Date | No | Fecha de diagnóstico (YYYY-MM-DD) |

**Respuesta Exitosa (201):**
```json
{
  "success": true,
  "route": "/medical/user_diseases",
  "message": "User disease created",
  "data": {
    "id": "e3f4a5b6-c7d8-9012-efab-345678901234",
    "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "disease_catalog_id": "c1d2e3f4-a5b6-7890-cdef-123456789012",
    "notes": "Diagnosticada hace 5 años, controlada con dieta",
    "diagnosed_at": "2020-03-15",
    "created_at": "2025-07-04T15:00:00.000Z",
    "updated_at": "2025-07-04T15:00:00.000Z"
  }
}
```

---

### 10. Listar Enfermedades del Usuario

Obtiene todas las enfermedades del usuario autenticado.

**Endpoint:**
```
GET /medical/user_diseases
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/medical/user_diseases",
  "message": "User diseases list",
  "data": [
    {
      "id": "e3f4a5b6-c7d8-9012-efab-345678901234",
      "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "disease_catalog_id": "c1d2e3f4-a5b6-7890-cdef-123456789012",
      "notes": "Diagnosticada hace 5 años",
      "diagnosed_at": "2020-03-15",
      "disease_catalog": {
        "name": "Diabetes Tipo 2",
        "classification": "Endocrino"
      },
      "created_at": "2025-07-04T15:00:00.000Z"
    }
  ]
}
```

---

### 11. Actualizar Enfermedad del Usuario

Actualiza una enfermedad registrada. Solo si pertenece al usuario autenticado.

**Endpoint:**
```
PUT /medical/user_diseases/:id
```

**Request Body:**
```json
{
  "disease_catalog_id": "c1d2e3f4-a5b6-7890-cdef-123456789012",
  "notes": "Actualización: nuevo tratamiento asignado",
  "diagnosed_at": "2020-03-15"
}
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/medical/user_diseases/e3f4a5b6-c7d8-9012-efab-345678901234",
  "message": "User disease updated",
  "data": {
    "id": "e3f4a5b6-c7d8-9012-efab-345678901234",
    "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "disease_catalog_id": "c1d2e3f4-a5b6-7890-cdef-123456789012",
    "notes": "Actualización: nuevo tratamiento asignado",
    "diagnosed_at": "2020-03-15",
    "updated_at": "2025-07-04T16:00:00.000Z"
  }
}
```

**Error - No encontrado (404):**
```json
{
  "success": false,
  "route": "/medical/user_diseases/e3f4a5b6-c7d8-9012-efab-345678901234",
  "message": "User disease not found",
  "error": "Not found"
}
```

---

### 12. Crear Medicamento con Horarios

Crea un plan de medicamento con su primera versión y horarios de toma.

**Endpoint:**
```
POST /medical/medications
```

**Request Body:**
```json
{
  "title": "Tratamiento Diabetes",
  "name": "Metformina",
  "dose": "500",
  "unit": "mg",
  "frequency": "Cada 8 horas",
  "observations": "Tomar con alimentos",
  "schedules": [
    {
      "time_of_day": "08:00",
      "notes": "Desayuno"
    },
    {
      "time_of_day": "14:00",
      "notes": "Almuerzo"
    },
    {
      "time_of_day": "20:00",
      "notes": "Cena"
    }
  ]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `title` | String | No | Título descriptivo del tratamiento |
| `name` | String | Si | Nombre del medicamento |
| `dose` | String | Si | Dosis (ej: "500") |
| `unit` | String | Si | Unidad (ej: "mg", "ml") |
| `frequency` | String | Si | Frecuencia de toma |
| `observations` | String | No | Observaciones adicionales |
| `schedules` | Array | Si | Horarios de toma (mínimo 1) |
| `schedules[].time_of_day` | String | Si | Hora en formato HH:mm |
| `schedules[].notes` | String | No | Nota para ese horario |

**Respuesta Exitosa (201):**
```json
{
  "success": true,
  "route": "/medical/medications",
  "message": "Medication created",
  "data": {
    "id": "f4a5b6c7-d8e9-0123-fabc-456789012345",
    "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "title": "Tratamiento Diabetes",
    "name": "Metformina",
    "dose": "500",
    "unit": "mg",
    "frequency": "Cada 8 horas",
    "observations": "Tomar con alimentos",
    "current_version": 1,
    "created_at": "2025-07-04T15:00:00.000Z",
    "versions": [
      {
        "id": "a5b6c7d8-e9f0-1234-abcd-567890123456",
        "version": 1,
        "name": "Metformina",
        "dose": "500",
        "unit": "mg",
        "frequency": "Cada 8 horas",
        "observations": "Tomar con alimentos",
        "valid_from": "2025-07-04T15:00:00.000Z",
        "valid_to": null,
        "schedules": [
          {
            "id": "b6c7d8e9-f0a1-2345-bcde-678901234567",
            "time_of_day": "08:00:00",
            "notes": "Desayuno"
          },
          {
            "id": "c7d8e9f0-a1b2-3456-cdef-789012345678",
            "time_of_day": "14:00:00",
            "notes": "Almuerzo"
          },
          {
            "id": "d8e9f0a1-b2c3-4567-defa-890123456789",
            "time_of_day": "20:00:00",
            "notes": "Cena"
          }
        ]
      }
    ]
  }
}
```

---

### 13. Crear Múltiples Medicamentos (Bulk)

Crea varios medicamentos en una sola transacción. Si falla uno, se hace rollback completo.

**Endpoint:**
```
POST /medical/medications/bulk
```

**Request Body:**
```json
{
  "medications": [
    {
      "title": "Tratamiento Diabetes",
      "name": "Metformina",
      "dose": "500",
      "unit": "mg",
      "frequency": "Cada 8 horas",
      "schedules": [
        { "time_of_day": "08:00" },
        { "time_of_day": "14:00" },
        { "time_of_day": "20:00" }
      ]
    },
    {
      "title": "Tratamiento Hipertensión",
      "name": "Losartán",
      "dose": "50",
      "unit": "mg",
      "frequency": "Cada 12 horas",
      "schedules": [
        { "time_of_day": "08:00" },
        { "time_of_day": "20:00" }
      ]
    }
  ]
}
```

**Respuesta Exitosa (201):**
```json
{
  "success": true,
  "route": "/medical/medications/bulk",
  "message": "Bulk medication creation completed",
  "data": [
    {
      "id": "f4a5b6c7-d8e9-0123-fabc-456789012345",
      "name": "Metformina",
      "dose": "500",
      "unit": "mg",
      "versions": [...]
    },
    {
      "id": "a5b6c7d8-e9f0-1234-abcd-567890123456",
      "name": "Losartán",
      "dose": "50",
      "unit": "mg",
      "versions": [...]
    }
  ]
}
```

---

### 14. Listar Medicamentos del Usuario

Obtiene todos los planes de medicamento con sus versiones y horarios.

**Endpoint:**
```
GET /medical/medications
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/medical/medications",
  "message": "User medication plans",
  "data": [
    {
      "id": "f4a5b6c7-d8e9-0123-fabc-456789012345",
      "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "title": "Tratamiento Diabetes",
      "name": "Metformina",
      "dose": "500",
      "unit": "mg",
      "frequency": "Cada 8 horas",
      "current_version": 1,
      "versions": [
        {
          "version": 1,
          "name": "Metformina",
          "dose": "500",
          "unit": "mg",
          "valid_from": "2025-07-04T15:00:00.000Z",
          "valid_to": null,
          "schedules": [
            { "time_of_day": "08:00:00", "notes": "Desayuno" },
            { "time_of_day": "14:00:00", "notes": "Almuerzo" },
            { "time_of_day": "20:00:00", "notes": "Cena" }
          ]
        }
      ]
    }
  ]
}
```

---

### 15. Actualizar Medicamento (Nueva Versión)

Crea una nueva versión del medicamento. La versión anterior se cierra automáticamente.

**Endpoint:**
```
PUT /medical/medications/:plan_id
```

**Request Body:**
```json
{
  "title": "Tratamiento Diabetes - Actualizado",
  "name": "Metformina",
  "dose": "850",
  "unit": "mg",
  "frequency": "Cada 12 horas",
  "observations": "Dosis aumentada por médico",
  "schedules": [
    { "time_of_day": "08:00", "notes": "Desayuno" },
    { "time_of_day": "20:00", "notes": "Cena" }
  ]
}
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/medical/medications/f4a5b6c7-d8e9-0123-fabc-456789012345",
  "message": "Medication updated with new version",
  "data": {
    "id": "f4a5b6c7-d8e9-0123-fabc-456789012345",
    "current_version": 2,
    "versions": [
      {
        "version": 1,
        "dose": "500",
        "valid_from": "2025-07-04T15:00:00.000Z",
        "valid_to": "2025-07-04T16:00:00.000Z"
      },
      {
        "version": 2,
        "dose": "850",
        "frequency": "Cada 12 horas",
        "valid_from": "2025-07-04T16:00:00.000Z",
        "valid_to": null,
        "schedules": [
          { "time_of_day": "08:00:00" },
          { "time_of_day": "20:00:00" }
        ]
      }
    ]
  }
}
```

---

### 16. Medicamentos Pendientes del Día

Obtiene los medicamentos pendientes de tomar hoy. Compara horarios vs consumos registrados.

**Endpoint:**
```
GET /medical/medications/pending-today
```

**Query Parameters (opcional):**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `date` | Date | Fecha en formato YYYY-MM-DD. Si se omite, usa la fecha actual. |

**Ejemplo:**
```
GET /medical/medications/pending-today?date=2025-07-04
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/medical/medications/pending-today",
  "message": "Pending medications for the day",
  "data": [
    {
      "medication_plan_id": "f4a5b6c7-d8e9-0123-fabc-456789012345",
      "medication_name": "Metformina",
      "dose": "850 mg",
      "scheduled_time": "08:00:00",
      "notes": "Desayuno",
      "status": "pending"
    },
    {
      "medication_plan_id": "a5b6c7d8-e9f0-1234-abcd-567890123456",
      "medication_name": "Losartán",
      "dose": "50 mg",
      "scheduled_time": "20:00:00",
      "notes": "Cena",
      "status": "pending"
    }
  ]
}
```

---

### 17. Registrar Consumo de Medicamento

Registra un evento de consumo (tomado, omitido o perdido).

**Endpoint:**
```
POST /medical/consumptions
```

**Request Body:**
```json
{
  "medication_plan_id": "f4a5b6c7-d8e9-0123-fabc-456789012345",
  "scheduled_time": "08:00",
  "consumed_at": "2025-07-04T08:05:00.000Z",
  "status": "consumed",
  "observations": "Tomado con desayuno"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `medication_plan_id` | UUID | Si | ID del plan de medicamento |
| `scheduled_time` | String | No | Hora programada (HH:mm) |
| `consumed_at` | DateTime | No | Fecha/hora de consumo real |
| `status` | Enum | No | `consumed`, `skipped`, `missed` |
| `observations` | String | No | Observaciones del consumo |

**Respuesta Exitosa (201):**
```json
{
  "success": true,
  "route": "/medical/consumptions",
  "message": "Medication consumption registered",
  "data": {
    "id": "e9f0a1b2-c3d4-5678-efab-901234567890",
    "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "medication_plan_id": "f4a5b6c7-d8e9-0123-fabc-456789012345",
    "scheduled_time": "08:00:00",
    "consumed_at": "2025-07-04T08:05:00.000Z",
    "status": "consumed",
    "observations": "Tomado con desayuno",
    "created_at": "2025-07-04T08:05:00.000Z"
  }
}
```

---

### 18. Historial de Consumos

Obtiene el historial de consumos con filtros opcionales.

**Endpoint:**
```
GET /medical/consumptions
```

**Query Parameters (todos opcionales):**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `from` | DateTime | Fecha/hora inicial del filtro |
| `to` | DateTime | Fecha/hora final del filtro |
| `status` | Enum | `consumed`, `skipped`, `missed` |

**Ejemplo:**
```
GET /medical/consumptions?from=2025-07-01T00:00:00Z&to=2025-07-04T23:59:59Z&status=consumed
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "route": "/medical/consumptions",
  "message": "Medication consumption history",
  "data": [
    {
      "id": "e9f0a1b2-c3d4-5678-efab-901234567890",
      "medication_plan_id": "f4a5b6c7-d8e9-0123-fabc-456789012345",
      "scheduled_time": "08:00:00",
      "consumed_at": "2025-07-04T08:05:00.000Z",
      "status": "consumed",
      "observations": "Tomado con desayuno",
      "medication_plan": {
        "name": "Metformina",
        "dose": "850",
        "unit": "mg"
      }
    },
    {
      "id": "f0a1b2c3-d4e5-6789-fabc-012345678901",
      "medication_plan_id": "a5b6c7d8-e9f0-1234-abcd-567890123456",
      "scheduled_time": "20:00:00",
      "consumed_at": null,
      "status": "missed",
      "observations": "Olvidó tomar",
      "medication_plan": {
        "name": "Losartán",
        "dose": "50",
        "unit": "mg"
      }
    }
  ]
}
```

---

## Flujo de Trabajo - Módulo Médico

### Registro de Enfermedades
1. Consultar catálogo de enfermedades disponibles (`GET /medical/disease_catalogs`)
2. Registrar enfermedad del usuario (`POST /medical/user_diseases`)
3. Listar enfermedades registradas (`GET /medical/user_diseases`)

### Gestión de Medicamentos
1. Crear medicamento con horarios (`POST /medical/medications`)
2. Consultar medicamentos activos (`GET /medical/medications`)
3. Actualizar medicamento (nueva versión) (`PUT /medical/medications/:plan_id`)
4. Ver pendientes del día (`GET /medical/medications/pending-today`)

### Control de Consumo
1. Registrar consumo (`POST /medical/consumptions`) con estado:
   - `consumed`: Tomado correctamente
   - `skipped`: Omitido intencionalmente
   - `missed`: Olvidado
2. Consultar historial (`GET /medical/consumptions`)

### Versionado de Medicamentos
Cada actualización de un medicamento crea una nueva versión:
- La versión anterior se cierra con `valid_to`
- La nueva versión inicia con `valid_from` = ahora
- Se mantiene historial completo de cambios

---

## Resumen de Permisos - Módulo Médico

| Endpoint | Auth | Descripción |
|----------|------|-------------|
| `GET /medical/disease_catalogs` | User | Catálogo global de enfermedades |
| `GET /medical/user_diseases` | User | Solo sus enfermedades |
| `POST /medical/user_diseases` | User | Registrar enfermedad propia |
| `PUT /medical/user_diseases/:id` | User | Solo si es suya |
| `GET /medical/medications` | User | Solo sus medicamentos |
| `POST /medical/medications` | User | Crear medicamento propio |
| `POST /medical/medications/bulk` | User | Crear varios medicamentos |
| `PUT /medical/medications/:plan_id` | User | Solo si es suyo (nueva versión) |
| `GET /medical/medications/pending-today` | User | Pendientes del día |
| `GET /medical/consumptions` | User | Solo su historial |
| `POST /medical/consumptions` | User | Registrar consumo propio |

---

## Resumen de Permisos General

| Endpoint | Admin | User | Público |
|----------|-------|------|---------|
| `POST /auth/register` | - | - | Si |
| `POST /auth/login` | - | - | Si |
| `GET /emergency_contacts` | Todos | Solo los suyos | No |
| `GET /emergency_contacts/:id` | Cualquiera | Solo los suyos | No |
| `POST /emergency_contacts` | Si | Si | No |
| `PUT /emergency_contacts/:id` | Cualquiera | Solo los suyos | No |
| `DELETE /emergency_contacts/:id` | Cualquiera | Solo los suyos | No |
| `GET /medical/disease_catalogs` | - | Si | No |
| `GET/POST /medical/user_diseases` | - | Solo suyos | No |
| `PUT /medical/user_diseases/:id` | - | Solo suyos | No |
| `GET/POST /medical/medications` | - | Solo suyos | No |
| `POST /medical/medications/bulk` | - | Si | No |
| `PUT /medical/medications/:plan_id` | - | Solo suyos | No |
| `GET /medical/medications/pending-today` | - | Solo suyos | No |
| `GET/POST /medical/consumptions` | - | Solo suyos | No |

---

## Usuarios de Prueba (Seeders)

Ejecutar: `npx sequelize-cli db:seed:all`

### Usuarios
| Rol | Email | Password |
|-----|-------|----------|
| Admin | admin@gmail.com | admin123 |
| User | user@gmail.com | admin123 |

### Catálogo de Enfermedades (Demo)
| Nombre | Clasificación |
|--------|---------------|
| Diabetes | Tipo 1 |
| Diabetes | Tipo 2 |
| Hipertensión | Cardiovascular |
| Asma | Respiratoria |

### Contactos de Emergencia (Demo)
- 2 contactos para el usuario común
- 1 contacto para el admin

---

## Swagger

Documentación interactiva disponible en:
```
http://localhost:4000/api-docs
```

---

## Ejemplo Completo - Flujo Médico

### Paso 1: Login
```bash
curl -X POST http://localhost:4000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@gmail.com","password":"admin123"}'
```

### Paso 2: Consultar enfermedades disponibles
```bash
curl -X GET http://localhost:4000/medical/disease_catalogs \
  -H "Authorization: Bearer <token>"
```

### Paso 3: Registrar enfermedad
```bash
curl -X POST http://localhost:4000/medical/user_diseases \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "disease_catalog_id": "<id_de_catalogo>",
    "notes": "Diagnóstico reciente",
    "diagnosed_at": "2025-01-15"
  }'
```

### Paso 4: Crear medicamento con horarios
```bash
curl -X POST http://localhost:4000/medical/medications \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Metformina",
    "dose": "500",
    "unit": "mg",
    "frequency": "Cada 8 horas",
    "schedules": [
      {"time_of_day": "08:00"},
      {"time_of_day": "14:00"},
      {"time_of_day": "20:00"}
    ]
  }'
```

### Paso 5: Ver pendientes del día
```bash
curl -X GET "http://localhost:4000/medical/medications/pending-today" \
  -H "Authorization: Bearer <token>"
```

### Paso 6: Registrar consumo
```bash
curl -X POST http://localhost:4000/medical/consumptions \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "medication_plan_id": "<id_del_plan>",
    "scheduled_time": "08:00",
    "status": "consumed",
    "observations": "Tomado correctamente"
  }'
```

---

## Migraciones y Seeders

### Ejecutar Migraciones
```bash
npx sequelize-cli db:migrate
```

### Ejecutar Seeders (datos de prueba)
```bash
npx sequelize-cli db:seed:all
```

### Deshacer Seeders
```bash
npx sequelize-cli db:seed:undo:all
```

### Tablas del Sistema
| Tabla | Descripción |
|-------|-------------|
| `Users` | Usuarios (admin/user) |
| `EmergencyContacts` | Contactos de emergencia |
| `DiseaseCatalogs` | Catálogo maestro de enfermedades |
| `UserDiseases` | Enfermedades del usuario |
| `MedicationPlans` | Planes de medicamentos |
| `MedicationVersions` | Versiones de medicamentos |
| `MedicationSchedules` | Horarios de toma |
| `MedicationConsumptionHistories` | Historial de consumos |
