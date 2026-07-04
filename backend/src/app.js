require('dotenv').config(); // 🔹 Cargar variables de entorno antes de todo
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const routes = require('./routes/index'); // Importa las rutas indexadas
const errorHandler = require('./middlewares/errorHandler.middleware'); // Middleware global de manejo de errores
const swaggerDocs = require("./utils/swagger"); // ajusta la ruta según tu estructura
const checkOrigin = require('./utils/check_origin'); // Middleware para verificar el origen de la solicitud
const app = express();

// Middlewares de seguridad y optimización
app.use(cors()); // Habilita CORS para todas las rutas
app.use(checkOrigin); // Verifica el origen de la solicitud
app.use(helmet()); // Protege contra vulnerabilidades comunes
app.use(compression()); // Reduce el tamaño de las respuestas HTTP
app.use(morgan('dev')); // Loguea las peticiones en consola

// Middleware para parsear JSON y URL-encoded
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


// Rutas principales (se cargan desde el index de `routes/`)
app.use('/api/', routes);
// Aquí llamas a la función que monta SwaggerUI3
swaggerDocs(app);
// Middleware de manejo de errores (debe ir al final)
app.use(errorHandler);

module.exports = app;