
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

module.exports = loginSchema;
