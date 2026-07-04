const ApiResponse = require('../utils/apiResponse.js');

/**
 * Middleware global para manejar errores en Express.
 */
const errorHandler = (err, req, res, next) => {
  console.error('🔥 Error capturado:', err);

  return ApiResponse.error(res, {
    error: err.message || 'Error interno del servidor',
    route: req.originalUrl,
    message: 'Ocurrió un error inesperado',
    status: err.status || 500
  });
};

module.exports = errorHandler;