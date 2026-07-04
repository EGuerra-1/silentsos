const { z } = require('zod');

/**
 * @swagger
 * components:
 *   schemas:
 *     User:
 *       type: object
 *       required:
 *         - full_name
 *         - email
 *         - id_position
 *         - rol
 *         - password
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           description: Unique identifier for the user.
 *           example: "550e8400-e29b-41d4-a716-446655440000"
 *         full_name:
 *           type: string
 *           description: The full name of the user.
 *           example: "Daniel Morales"
 *         email:
 *           type: string
 *           description: The email address of the user.
 *           example: "ale@gmail.com"
 *         rol:
 *           type: string
 *           enum: [admin, user]
 *           description: The role of the user.
 *           example: "admin"
 *         cellphone:
 *           type: string
 *           description: The cellphone number of the user.
 *           example: "1234567890"
 *         password:
 *           type: string
 *           description: The user password.
 *           example: "Clave123!"
 *     ErrorResponse:
 *       type: object
 *       properties:
 *         error:
 *           type: string
 *           description: Error message.
 *           example: "User not found"
 *         route:
 *           type: string
 *           description: The route where the error occurred.
 *           example: "/users/123"
 *         status:
 *           type: integer
 *           description: HTTP status code.
 *           example: 404
 */

// Schema for request parameters
const params = z.object({
    id: z.string().uuid({ message: 'The ID must be a valid UUID' }),
});

// Define the User schema
const userSchema = z.object({
    id: z.string().uuid(),
    full_name: z.string({
        required_error: 'Full name is required',
    })
        .min(2, 'Full name must be at least 2 characters')
        .max(250, 'Full name must not exceed 250 characters'),
    email: z.string({
        required_error: 'Email is required',
    })
        .email('Email must be valid')
        .max(250, 'Email must not exceed 250 characters'),
    rol: z.enum(['admin', 'user'], {
        required_error: 'Role is required',
    }),
    cellphone: z.string({
        required_error: 'Cellphone is required',
    })
        .min(5, 'Cellphone must be at least 5 characters')
        .max(20, 'Cellphone must not exceed 20 characters'),
    password: z.union([
        z.string()
            .min(8, 'Password must be at least 8 characters')
            .max(250, 'Password must not exceed 250 characters'),
        z.null()
    ]).optional(),

});



const readUserRequestSchema = z.object({
    params,
});

const createUserRequestSchema = z.object({
    body: userSchema.omit({ id: true }),
});

const updateUserRequestSchema = z.object({
    params,
    body: userSchema.omit({ id: true }),
});

const deleteUserRequestSchema = z.object({
    params,
});

module.exports = {
    readUserRequestSchema,
    createUserRequestSchema,
    updateUserRequestSchema,
    deleteUserRequestSchema,
};