const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const EmergencyService = require('../services/emergency.service');

class EmergencyController {
  static routes = '/emergencies';

  static createUrgency = catchErrors(async (req, res) => {
    // Modo fijo para botón SOS urgente: contexto único y cierre de llamada.
    const payload = {
      ...req.body,
      call_mode: 'single_context'
    };

    const emergency = await EmergencyService.createEmergency(req.user.id, payload);
    return ApiResponse.success(res, {
      route: `${this.routes}/urgency`,
      message: 'Emergency accepted and processing in background',
      status: 202,
      data: emergency
    });
  });

  static createContextual = catchErrors(async (req, res) => {
    // Botón contextual permite seleccionar modo de llamada.
    const emergency = await EmergencyService.createEmergency(req.user.id, req.body);
    return ApiResponse.success(res, {
      route: `${this.routes}/contextual`,
      message: 'Emergency accepted and processing in background',
      status: 202,
      data: emergency
    });
  });

  static getById = catchErrors(async (req, res) => {
    const result = await EmergencyService.getEmergencyById(req.params.id, req.user);
    if (!result) {
      return ApiResponse.error(res, {
        route: `${this.routes}/${req.params.id}`,
        message: 'Emergency not found',
        error: 'Not found',
        status: 404
      });
    }
    if (result === 'forbidden') {
      return ApiResponse.error(res, {
        route: `${this.routes}/${req.params.id}`,
        message: 'Unauthorized',
        error: 'Forbidden',
        status: 403
      });
    }

    return ApiResponse.success(res, {
      route: `${this.routes}/${req.params.id}`,
      message: 'Emergency details',
      data: result
    });
  });
}

module.exports = EmergencyController;
