const { User } = require('../models');
const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const { generateToken } = require('../auth'); // Module with functions: asignarToken, verificarToken
const { comparePassword } = require('../utils/password'); // Function to compare plain and hashed passwords

class AuthController {
    /**
     * Login endpoint.
     * Expects a JSON body with "email" and "password".
     * Returns a JWT token along with basic user information if the credentials are valid.
     */
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