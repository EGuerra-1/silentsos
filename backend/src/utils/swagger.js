const swaggerJsdoc = require("swagger-jsdoc");
const swaggerUi = require("swagger-ui-express");
const path = require("path");
const fs = require("fs");
const swaggerDefinition = require("./swaggerDef");

const routesPath = path.join(__dirname, "../routes");
const validationsPath = path.join(__dirname, "../validations"); // 📌 Carpeta de validaciones

// Obtenemos todos los archivos .routes.js de la carpeta de rutas
const routeFiles = fs
  .readdirSync(routesPath)
  .filter((file) => file.endsWith(".routes.js"))
  .map((file) => path.join(routesPath, file));

// Obtenemos todos los archivos .schema.js de la carpeta de validaciones
const schemaFiles = fs
  .readdirSync(validationsPath)
  .filter((file) => file.endsWith(".schema.js"))
  .map((file) => path.join(validationsPath, file));

// Configuración de Swagger para escanear automáticamente los esquemas y rutas
const specs = swaggerJsdoc({
  swaggerDefinition,
  apis: [...routeFiles, ...schemaFiles], // 📌 Escanea rutas y esquemas de validación
});

function swaggerDocs(app) {
  if (process.env.NODE_ENV === "development") {
    console.log("✅ Swagger habilitado en /api-docs");
    app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(specs));
  } else {
    console.log("⚠️ Swagger está deshabilitado en producción.");
  }
}

module.exports = swaggerDocs;