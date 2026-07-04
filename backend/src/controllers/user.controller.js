const CrudService = require('../services/crudService');
const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const { User } = require('../models');
const { encryptPassword } = require('../utils/password');

class UserController {
    static service = new CrudService(User);
    static routes = '/users';

    // POST: Solo admin puede crear usuarios, se fuerza rol 'admin'
    static save = catchErrors(async (req, res, next) => {
        const isUnique = await this.service.isUnique('email', req.body.email);
        if (isUnique === false) {
            return ApiResponse.error(res, {
                error: 'Email already exists',
                route: this.routes,
                status: 400
            });
        }
        req.body.password = await encryptPassword(req.body.password);
        req.body.rol = 'admin';
        const dataCreate = await this.service.create(req.body);
        if (dataCreate) {
            return ApiResponse.success(res, { data: dataCreate, route: this.routes, message: 'User created' });
        }
        return ApiResponse.error(res, { error: 'Error creating user', route: this.routes });
    });

    // PUT: Admin puede actualizar cualquiera. Cliente solo el suyo, no puede cambiar su rol
    static update = catchErrors(async (req, res, next) => {
        const isUniqueForUpdate = await this.service.isUniqueForUpdate(req.params.id, 'email', req.body.email);
        if (isUniqueForUpdate === false) {
            return ApiResponse.error(res, {
                error: 'Email already exists',
                route: this.routes,
                status: 400
            });
        }
        const user = await this.service.findById(req.params.id);
        if (!user) {
            return ApiResponse.error(res, { error: 'User not found', route: this.routes, status: 404 });
        }
        if (req.user.userType !== 'admin' && user.id !== req.user.id) {
            return ApiResponse.error(res, { error: 'Unauthorized', route: this.routes, status: 403 });
        }
        delete req.body.rol;
        if (!req.body.password) {
            delete req.body.password;
        } else {
            req.body.password = await encryptPassword(req.body.password);
        }
        const dataUpdate = await this.service.update(req.params.id, req.body);
        return ApiResponse.success(res, { data: dataUpdate, route: this.routes, message: 'User updated' });
    });

    // GET ALL: Solo admin puede listar todos los usuarios
    static getAll = catchErrors(async (req, res, next) => {
        const data = await this.service.findAll();
        return ApiResponse.success(res, { data, route: this.routes, message: 'User list' });
    });

    // GET BY ID: Admin puede ver cualquiera, cliente solo su propio perfil
    static getById = catchErrors(async (req, res, next) => {
        const data = await this.service.findById(req.params.id);
        if (!data) {
            return ApiResponse.error(res, { error: 'User not found', route: this.routes, status: 404 });
        }
        if (req.user.userType !== 'admin' && data.id !== req.user.id) {
            return ApiResponse.error(res, { error: 'Unauthorized', route: this.routes, status: 403 });
        }
        return ApiResponse.success(res, { data, route: this.routes });
    });

    // DELETE: Solo admin puede eliminar usuarios
    static destroy = catchErrors(async (req, res, next) => {
        const success = await this.service.delete(req.params.id);
        if (success) {
            return ApiResponse.success(res, { route: this.routes, message: 'User deleted' });
        }
        return ApiResponse.error(res, { error: 'User not found', route: this.routes, status: 404 });
    });
}

module.exports = UserController;
