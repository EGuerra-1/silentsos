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

## Resumen de Permisos

| Endpoint | Admin | User | Público |
|----------|-------|------|---------|
| `POST /auth/register` | - | - | Si |
| `POST /auth/login` | - | - | Si |
| `GET /emergency_contacts` | Todos | Solo los suyos | No |
| `GET /emergency_contacts/:id` | Cualquiera | Solo los suyos | No |
| `POST /emergency_contacts` | Si | Si | No |
| `PUT /emergency_contacts/:id` | Cualquiera | Solo los suyos | No |
| `DELETE /emergency_contacts/:id` | Cualquiera | Solo los suyos | No |

---

## Usuarios de Prueba (Seeders)

Ejecutar: `npx sequelize-cli db:seed:all`

| Rol | Email | Password |
|-----|-------|----------|
| Admin | admin@gmail.com | admin123 |
| User | user@gmail.com | admin123 |

---

## Swagger

Documentación interactiva disponible en:
```
http://localhost:4000/api-docs
```
