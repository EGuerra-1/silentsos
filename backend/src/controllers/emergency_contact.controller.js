const CrudService = require('../services/crudService');
const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const { EmergencyContact } = require('../models');

class EmergencyContactController {
    static service = new CrudService(EmergencyContact);
    static routes = '/emergency_contacts';

    static save = catchErrors(async (req, res, next) => {
        const dataCreate = await this.service.create(req.body);
        if (dataCreate) {
            return ApiResponse.success(res, { data: dataCreate, route: this.routes, message: 'Emergency contact created' });
        }
        return ApiResponse.error(res, { error: 'Error creating emergency contact', route: this.routes });
    });

    static update = catchErrors(async (req, res, next) => {
        const dataUpdate = await this.service.update(req.params.id, req.body);
        if (dataUpdate) {
            return ApiResponse.success(res, { data: dataUpdate, route: this.routes, message: 'Emergency contact updated' });
        }
        return ApiResponse.error(res, { error: 'Emergency contact not found', route: this.routes, status: 404 });
    });

    static getAll = catchErrors(async (req, res, next) => {
        const data = await this.service.findAll();
        return ApiResponse.success(res, { data, route: this.routes, message: 'Emergency contacts list' });
    });

    static getById = catchErrors(async (req, res, next) => {
        const data = await this.service.findById(req.params.id);
        if (data) {
            return ApiResponse.success(res, { data, route: this.routes });
        }
        return ApiResponse.error(res, { error: 'Emergency contact not found', route: this.routes, status: 404 });
    });

    static destroy = catchErrors(async (req, res, next) => {
        const success = await this.service.delete(req.params.id);
        if (success) {
            return ApiResponse.success(res, { route: this.routes, message: 'Emergency contact deleted' });
        }
        return ApiResponse.error(res, { error: 'Emergency contact not found', route: this.routes, status: 404 });
    });
}

module.exports = EmergencyContactController;
