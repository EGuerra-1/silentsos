require('dotenv').config();
const ApiResponse = require('./apiResponse'); 

// Middleware para verificar el origen de la solicitud
const checkOrigin = (req, res, next) => {
    const allowedOrigins = process.env.ALLOWED_ORIGIN?.split(',').map(o => o.trim());
    const origin = req.get('Origin') || req.get('Referer');

    // Permitir el acceso a la ruta de imágenes sin verificar el origen
    if (req.path.startsWith('/uploads')) {
        return next();
    }

    // Verificar si el origen está en la lista de permitidos
    if (origin && allowedOrigins.includes(origin)) {
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