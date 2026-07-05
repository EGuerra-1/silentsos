Silent SOS API

API para gestión de usuarios y contactos de emergencia orientada a un caso de alto impacto social:  
las personas con discapacidad auditiva en El Salvador enfrentan barreras críticas en emergencias (accidentes, crisis médicas o desastres), porque los sistemas tradicionales dependen de llamadas de voz.

Esta API busca ser una base técnica para flujos de atención más accesibles.

## Stack

- Node.js + Express
- PostgreSQL
- Sequelize (migraciones y seeders)
- Docker + Docker Compose
- Swagger (/api-docs en desarrollo)

## Estructura rápida

- backend/: código de la API
- backend/src/routes: endpoints
- backend/src/database/migrations: migraciones
- backend/src/database/seeders: datos semilla

## Levantar con Docker (recomendado)

1. Ir al backend:

bash
cd backend


2. Crear archivo de entorno:

bash
cp .env.example .env


3. Levantar servicios:

bash
docker compose up --build -d


4. Ejecutar migraciones:

bash
docker compose exec api npx sequelize-cli db:migrate


5. Ejecutar seeders:

bash
docker compose exec api npx sequelize-cli db:seed:all


6. Verificar API:

- API: http://localhost:4000/api/health
- Swagger (solo NODE_ENV=development): http://localhost:4000/api-docs

## Levantar en local (sin Docker)

1. Ir al backend e instalar dependencias:

bash
cd backend
npm install


2. Crear .env:

bash
cp .env.example .env


3. Asegurar PostgreSQL corriendo con los valores de .env.

4. Ejecutar migraciones y seeders:

bash
npx sequelize-cli db:migrate
npx sequelize-cli db:seed:all


5. Iniciar API:

bash
npm run dev


## Comandos útiles de base de datos

Desde backend/:

bash
npx sequelize-cli db:migrate
npx sequelize-cli db:migrate:undo
npx sequelize-cli db:seed:all
npx sequelize-cli db:seed:undo:all


## Endpoints principales

- POST /api/auth/register
- POST /api/auth/login
- GET/POST /api/users
- GET/PUT/DELETE /api/users/:id
- GET/POST /api/emergency_contacts
- GET/PUT/DELETE /api/emergency_contacts/:id
- GET /api/health

## Nota

El proyecto usa .sequelizerc, por lo que sequelize-cli ya apunta a:

- configuración DB: backend/src/config/database.js
- migraciones: backend/src/database/migrations
- seeders: backend/src/database/seeders