
// src/utils/apiResponse.js

class ApiResponse {
    /**
     * Respuesta exitosa con datos.
     * @param {object} res - Objeto Response de Express.
     * @param {object} options - Configuración de la respuesta.
     * @param {any}    [options.data=null]    - Datos a enviar en la respuesta.
     * @param {string} [options.route='']     - Ruta o endpoint que se está respondiendo.
     * @param {string} [options.message='']   - Mensaje informativo.
     * @param {number} [options.status=200]   - Código de estado HTTP.
     */
    static success(res, { data = null, route = '', message = '', status = 200 }) {
      return res.status(status).json({
        success: true,
        route,
        message,
        data
      });
    }
  
    /**
     * Respuesta de error.
     * @param {object} res - Objeto Response de Express.
     * @param {object} options - Configuración de la respuesta.
     * @param {Error|string} options.error  - Error capturado (objeto Error o string).
     * @param {string}       [options.route='']    - Ruta o endpoint que se está respondiendo.
     * @param {string}       [options.message='']  - Mensaje adicional.
     * @param {number}       [options.status=500]  - Código de estado HTTP.
     */
    static error(res, { error, route = '', message = '', status = 500 }) {
      const errorMessage = error instanceof Error ? error.message : error;
      return res.status(status).json({
        success: false,
        route,
        message,
        error: errorMessage
      });
    }
  }
  
  module.exports = ApiResponse;
  
