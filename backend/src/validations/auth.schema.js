
const { z } = require('zod');

/**
 * @swagger
 * components:
 *   schemas:
 *     Login:
 *       type: object
 *       required:
 *         - email
 *         - password
 *       properties:
 *         email:
 *           type: string
 *           description: The user's email address.
 *           example: "ale@gmail.com"
 *         password:
 *           type: string
 *           description: The user's password.
 *           example: "Clave123!"
 *     Register:
 *       type: object
 *       required:
 *         - full_name
 *         - email
 *         - cellphone
 *         - password
 *       properties:
 *         full_name:
 *           type: string
 *           description: The full name of the user.
 *           example: "Daniel Morales"
 *         email:
 *           type: string
 *           description: The email address of the user.
 *           example: "client@gmail.com"
 *         cellphone:
 *           type: string
 *           description: The cellphone number of the user.
 *           example: "1234567890"
 *         password:
 *           type: string
 *           description: The user password.
 *           example: "Clave123!"
 */

const loginSchema = z.object({
    body: z.object({
        email: z
            .string({ required_error: 'Email is required' })
            .email('Email must be valid')
            .max(250, 'Email must not exceed 250 characters'),
        password: z
            .string({ required_error: 'Password is required' })
            .min(8, 'Password must be at least 8 characters')
            .max(250, 'Password must not exceed 250 characters'),
    }),
});

const registerSchema = z.object({
    body: z.object({
        full_name: z.string({ required_error: 'Full name is required' })
            .min(2, 'Full name must be at least 2 characters')
            .max(250, 'Full name must not exceed 250 characters'),
        email: z.string({ required_error: 'Email is required' })
            .email('Email must be valid')
            .max(250, 'Email must not exceed 250 characters'),
        cellphone: z.string({ required_error: 'Cellphone is required' })
            .min(5, 'Cellphone must be at least 5 characters')
            .max(20, 'Cellphone must not exceed 20 characters'),
        password: z.string({ required_error: 'Password is required' })
            .min(8, 'Password must be at least 8 characters')
            .max(250, 'Password must not exceed 250 characters'),
    }),
});

module.exports = loginSchema;
module.exports.registerSchema = registerSchema;
