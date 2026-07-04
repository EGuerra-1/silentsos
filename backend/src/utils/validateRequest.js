
const ApiResponse = require('./apiResponse');

const validateRequest = (schema) => (req, res, next) => {
    try {
        const result = schema.safeParse({
            body: req.body || {},
            query: req.query || {},
            params: req.params || {},
        });

        if (!result.success) {
            const validationErrors = result.error.errors.map(err => ({
                field: err.path.join('.'),
                message: err.message
            }));

            return ApiResponse.error(res, {
                error: validationErrors,
                route: req.originalUrl,
                message: 'Error de validación en los datos enviados',
                status: 400
            });
        }

        next(); // Si todo está bien, continúa con el controlador
    } catch (error) {
        next(error); // Enviar cualquier otro error inesperado al manejador de errores
    }
};

module.exports = validateRequest;
