/**
 * Wraps an Express.js request handler to catch any errors that the handler might throw
 * and pass them to the next middleware in the stack.
 * This function is useful for asynchronous request handlers where errors might not be caught
 * by the standard Express error handling.
 *
 * @param {Function} requestHandler - The Express request handler to wrap.
 * @returns {Function} A new request handler that is wrapped in a try/catch to handle errors.
 */
const catchErrors = (requestHandler) => {
    return async (req, res, next) => {
        try {
            return await requestHandler(req, res, next);  // Llamar al handler y pasar next
        } catch (error) {
            console.log('🔥 Error capturado:', error);
            next(error);  // Pasar el error al siguiente middleware
        }
    };
};

module.exports =  catchErrors ;