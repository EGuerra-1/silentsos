const express = require('express');
const fs = require('fs');
const path = require('path');

const router = express.Router();

// Ruta base de los archivos de rutas
const routesPath = __dirname;

// Leer todos los archivos de la carpeta "routes"
fs.readdirSync(routesPath)
  .filter((file) => file.endsWith('.routes.js'))
  .forEach((file) => {
    const route = require(path.join(routesPath, file));

    if (route && typeof route === 'function') {
      const routeName = `/${file.replace('.routes.js', '')}`; // Genera la ruta base
      console.log(`✅ Cargando rutas: ${routeName}`);
      
      router.use(routeName, route);
    } else {
      console.error(`⚠️ El archivo ${file} no exporta un router válido.`);
    }
  });

module.exports = router;