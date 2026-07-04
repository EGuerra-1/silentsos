const { User } = require('../models');
const CrudService = require('../services/crudService');
const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const { generateToken } = require('../auth');
const { comparePassword, encryptPassword } = require('../utils/password');

class AuthController {
    static userService = new CrudService(User);

    // POST /auth/register: público, solo crea usuarios con rol 'user'
    static registerRoute = '/auth/register';
    static register = catchErrors(async (req, res) => {
        const isUnique = await this.userService.isUnique('email', req.body.email);
        if (!isUnique) {
            return ApiResponse.error(res, {
                error: 'Email already exists',
                route: this.registerRoute,
                status: 400,
            });
        }
        req.body.password = await encryptPassword(req.body.password);
        req.body.rol = 'user';
        const dataCreate = await this.userService.create(req.body);
        return ApiResponse.success(res, { data: dataCreate, route: this.registerRoute, message: 'User registered' });
    });

    // POST /auth/login: público, retorna token JWT
    static routes = '/auth/login';
    static login = catchErrors(async (req, res) => {
        const { email, password } = req.body;

        // Find the user by email
        const user = await User.findOne({ where: { email } });
        if (!user) {
            return ApiResponse.error(res, {
                error: 'Invalid credentials',
                route: this.routes,
                status: 401,
            });
        }

        // Compare the provided password with the stored hash
        const isValid = await comparePassword(password, user.password);
        if (!isValid) {
            return ApiResponse.error(res, {
                error: 'Invalid credentials',
                route: this.routes,
                status: 401,
            });
        }

        // Generate a JWT token with the user role (admin or user)
        const token = generateToken(
            {
                id: user.id,
                email: user.email,
                full_name: user.full_name,
            },
            user.rol
        );

        // Respond with the token and basic user info (excluding the password)
        return ApiResponse.success(
            res,
            {
                data: {
                    token,
                    user: {
                        id: user.id,
                        email: user.email,
                        full_name: user.full_name,
                        rol: user.rol,
                    },
                },
                message: 'User logged in',
                status: 200,
                route: this.routes
            },

        );
    });
}

module.exports = AuthController;