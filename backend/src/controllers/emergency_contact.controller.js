const CrudService = require('../services/crudService');
const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const { EmergencyContact } = require('../models');

class EmergencyContactController {
    static service = new CrudService(EmergencyContact);
    static routes = '/emergency_contacts';

    // POST: user_id se asigna desde el token, no se acepta en el body
    static save = catchErrors(async (req, res, next) => {
        req.body.user_id = req.user.id;
        const dataCreate = await this.service.create(req.body);
        if (dataCreate) {
            return ApiResponse.success(res, { data: dataCreate, route: this.routes, message: 'Emergency contact created' });
        }
        return ApiResponse.error(res, { error: 'Error creating emergency contact', route: this.routes });
    });

    // PUT: se ignora user_id del body. Admin puede actualizar cualquiera, cliente solo los suyos
    static update = catchErrors(async (req, res, next) => {
        delete req.body.user_id;
        const contact = await this.service.findById(req.params.id);
        if (!contact) {
            return ApiResponse.error(res, { error: 'Emergency contact not found', route: this.routes, status: 404 });
        }
        if (req.user.userType !== 'admin' && contact.user_id !== req.user.id) {
            return ApiResponse.error(res, { error: 'Unauthorized', route: this.routes, status: 403 });
        }
        const dataUpdate = await this.service.update(req.params.id, req.body);
        return ApiResponse.success(res, { data: dataUpdate, route: this.routes, message: 'Emergency contact updated' });
    });

    // GET ALL: Admin ve todos, cliente solo ve los suyos filtrados por user_id
    static getAll = catchErrors(async (req, res, next) => {
        const filters = req.user.userType === 'admin' ? {} : { user_id: req.user.id };
        const data = await this.service.findAll({ where: filters });
        return ApiResponse.success(res, { data, route: this.routes, message: 'Emergency contacts list' });
    });

    // GET BY ID: Admin puede ver cualquiera, cliente solo los suyos (403 si no pertenece)
    static getById = catchErrors(async (req, res, next) => {
        const data = await this.service.findById(req.params.id);
        if (!data) {
            return ApiResponse.error(res, { error: 'Emergency contact not found', route: this.routes, status: 404 });
        }
        if (req.user.userType !== 'admin' && data.user_id !== req.user.id) {
            return ApiResponse.error(res, { error: 'Unauthorized', route: this.routes, status: 403 });
        }
        return ApiResponse.success(res, { data, route: this.routes });
    });

    // DELETE: Admin puede eliminar cualquiera, cliente solo los suyos (403 si no pertenece)
    static destroy = catchErrors(async (req, res, next) => {
        const contact = await this.service.findById(req.params.id);
        if (!contact) {
            return ApiResponse.error(res, { error: 'Emergency contact not found', route: this.routes, status: 404 });
        }
        if (req.user.userType !== 'admin' && contact.user_id !== req.user.id) {
            return ApiResponse.error(res, { error: 'Unauthorized', route: this.routes, status: 403 });
        }
        await contact.destroy();
        return ApiResponse.success(res, { route: this.routes, message: 'Emergency contact deleted' });
    });
}

module.exports = EmergencyContactController;
