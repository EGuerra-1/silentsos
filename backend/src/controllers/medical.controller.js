const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const MedicalService = require('../services/medical.service');

class MedicalController {
  static service = new MedicalService();
  static routes = '/medical';

  // Catálogo maestro de enfermedades para que el cliente seleccione valores válidos.
  static getDiseaseCatalogs = catchErrors(async (req, res) => {
    const data = await this.service.getDiseaseCatalogs();
    return ApiResponse.success(res, {
      route: `${this.routes}/disease_catalogs`,
      message: 'Disease catalog list',
      data
    });
  });

  // Crea enfermedad del usuario autenticado; user_id siempre sale del token.
  static saveUserDisease = catchErrors(async (req, res) => {
    const data = await this.service.createUserDisease(req.user.id, req.body);
    return ApiResponse.success(res, {
      route: `${this.routes}/user_diseases`,
      message: 'User disease created',
      status: 201,
      data
    });
  });

  // Lista solo enfermedades del usuario autenticado.
  static getUserDiseases = catchErrors(async (req, res) => {
    const data = await this.service.getUserDiseases(req.user.id);
    return ApiResponse.success(res, {
      route: `${this.routes}/user_diseases`,
      message: 'User diseases list',
      data
    });
  });

  // Actualiza una enfermedad únicamente si pertenece al usuario autenticado.
  static updateUserDisease = catchErrors(async (req, res) => {
    const data = await this.service.updateUserDisease(req.user.id, req.params.id, req.body);
    if (!data) {
      return ApiResponse.error(res, {
        route: `${this.routes}/user_diseases/${req.params.id}`,
        message: 'User disease not found',
        error: 'Not found',
        status: 404
      });
    }
    return ApiResponse.success(res, {
      route: `${this.routes}/user_diseases/${req.params.id}`,
      message: 'User disease updated',
      data
    });
  });

  // Crea plan de medicamento con su primera versión y horarios.
  static saveMedication = catchErrors(async (req, res) => {
    const data = await this.service.createMedication(req.user.id, req.body);
    return ApiResponse.success(res, {
      route: `${this.routes}/medications`,
      message: 'Medication created',
      status: 201,
      data
    });
  });

  // Alta masiva transaccional: si falla una entrada, rollback completo.
  static saveMedicationBulk = catchErrors(async (req, res) => {
    const data = await this.service.createMedicationBulk(req.user.id, req.body.medications);
    return ApiResponse.success(res, {
      route: `${this.routes}/medications/bulk`,
      message: 'Bulk medication creation completed',
      status: 201,
      data
    });
  });

  // Versiona tratamiento: cierra versión actual y crea una nueva con horarios.
  static updateMedication = catchErrors(async (req, res) => {
    const data = await this.service.updateMedicationVersion(req.user.id, req.params.plan_id, req.body);
    if (!data) {
      return ApiResponse.error(res, {
        route: `${this.routes}/medications/${req.params.plan_id}`,
        message: 'Medication plan not found',
        error: 'Not found',
        status: 404
      });
    }
    return ApiResponse.success(res, {
      route: `${this.routes}/medications/${req.params.plan_id}`,
      message: 'Medication updated with new version',
      data
    });
  });

  // Lista tratamientos del usuario autenticado con versiones y horarios.
  static getMedications = catchErrors(async (req, res) => {
    const data = await this.service.getMedications(req.user.id);
    return ApiResponse.success(res, {
      route: `${this.routes}/medications`,
      message: 'User medication plans',
      data
    });
  });

  // Registra evento de consumo sin alterar historial previo.
  static saveConsumption = catchErrors(async (req, res) => {
    const data = await this.service.registerConsumption(req.user.id, req.body);
    if (!data) {
      return ApiResponse.error(res, {
        route: `${this.routes}/consumptions`,
        message: 'Medication plan not found',
        error: 'Not found',
        status: 404
      });
    }
    return ApiResponse.success(res, {
      route: `${this.routes}/consumptions`,
      message: 'Medication consumption registered',
      status: 201,
      data
    });
  });

  // Historial de consumos con filtros opcionales por estado y rango.
  static getConsumptions = catchErrors(async (req, res) => {
    const data = await this.service.getConsumptions(req.user.id, req.query);
    return ApiResponse.success(res, {
      route: `${this.routes}/consumptions`,
      message: 'Medication consumption history',
      data
    });
  });

  // Devuelve medicinas pendientes de hoy comparando horarios vs consumos registrados.
  static getPendingMedicationsToday = catchErrors(async (req, res) => {
    const data = await this.service.getPendingMedicationsToday(req.user.id, req.query.date);
    return ApiResponse.success(res, {
      route: `${this.routes}/medications/pending-today`,
      message: 'Pending medications for the day',
      data
    });
  });
}

module.exports = MedicalController;
