const CrudService = require('../services/crudService');
const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const { User } = require('../models');
const { encryptPassword } = require('../utils/password');
class UserController {
    // Instanciamos la clase genérica CRUDService
    static service = new CrudService(User);
    static routes = '/user';

    static save = catchErrors(async (req, res, next) => {
        const isUnique = await this.service.isUnique('email', req.body.email);
        if (isUnique === false) {
            return ApiResponse.error(res, {
                error: 'El correo ya existe, ingrese otro correo',
                route: this.routes,
                status: 400
            });
        }
        req.body.password = await encryptPassword(req.body.password); // Encrypt password before saving
        const dataCreate = await this.service.create(req.body);
        if (dataCreate) {
            return ApiResponse.success(res, { data: dataCreate, route: this.routes, message: 'User created' });
        }
        return ApiResponse.error(res, { dataCreate, route: this.routes });
    });

    static update = catchErrors(async (req, res, next) => {
        const isUniqueForUpdate = await this.service.isUniqueForUpdate(req.params.id, 'email', req.body.email);
        if (isUniqueForUpdate === false) {
            return ApiResponse.error(res, {
                error: 'El correo ya existe, ingrese otro correo',
                route: this.routes,
                status: 400
            });
        }
        if(req.body.password === null || req.body.password === ''){
            delete req.body.password;
        }
        if (req.body.password) {
            req.body.password = await encryptPassword(req.body.password); // Encrypt password before saving
        }
        const dataUpdate = await this.service.update(req.params.id, req.body);
        if (dataUpdate) {
            return ApiResponse.success(res, { data: dataUpdate, route: this.routes, message: 'User updated' });
        }
        return ApiResponse.error(res, { error, route: this.routes });
    });

    static getAll = catchErrors(async (req, res, next) => {
        const data = await this.service.findAll();
        return ApiResponse.success(res, { data, route: this.routes, message: 'User list' });
    });

    static getById = catchErrors(async (req, res, next) => {
        const data = await this.service.findById(req.params.id);
        if (data) {
            return ApiResponse.success(res, { data, route: this.routes });
        }
        return ApiResponse.error(res, { error: 'User not found', route: this.routes, status: 404 });
    });

    static destroy = catchErrors(async (req, res, next) => {
        const success = await this.service.delete(req.params.id);
        if (success) {
            return ApiResponse.success(res, { route: this.routes, message: 'User deleted' });
        }
        return ApiResponse.error(res, { error: 'User not found', route: this.routes, status: 404 });
    });
}


module.exports = UserController;