require('dotenv').config();
const ApiResponse = require('./apiResponse'); 

// Middleware para verificar el origen de la solicitud
const checkOrigin = (req, res, next) => {
    const originStr = process.env.ALLOWED_ORIGIN || process.env.CORS_ALLOWED_ORIGINS || '';
    const allowedOrigins = originStr ? originStr.split(',').map(o => o.trim()) : [];
    const origin = req.get('Origin') || req.get('Referer');

    // Permitir el acceso a la ruta de imágenes sin verificar el origen
    if (req.path.startsWith('/uploads')) {
        return next();
    }

    // Permitir solicitudes sin Origin/Referer (ej. herramientas como Postman, curl, DBeaver)
    if (!origin) {
        return next();
    }

    // Verificar si el origen está en la lista de permitidos
    if (allowedOrigins.includes(origin)) {
        return next();
    } else {
        return ApiResponse.error(res, {
            error: 'Origin not allowed',
            route: req.path,
            status: 403,
        });
    }
};

module.exports = checkOrigin;