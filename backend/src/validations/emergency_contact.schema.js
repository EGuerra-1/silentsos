const { z } = require('zod');

/**
 * @swagger
 * components:
 *   schemas:
 *     EmergencyContact:
 *       type: object
 *       required:
 *         - user_id
 *         - full_name
 *         - cellphone
 *         - relationship
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           description: Unique identifier for the emergency contact.
 *           example: "550e8400-e29b-41d4-a716-446655440000"
 *         user_id:
 *           type: string
 *           format: uuid
 *           description: ID of the user who owns this emergency contact.
 *           example: "550e8400-e29b-41d4-a716-446655440001"
 *         full_name:
 *           type: string
 *           description: Full name of the emergency contact.
 *           example: "Juan Pérez"
 *         cellphone:
 *           type: string
 *           description: Cellphone number of the emergency contact.
 *           example: "1234567890"
 *         relationship:
 *           type: string
 *           description: Relationship with the user.
 *           example: "Father"
 */

const params = z.object({
    id: z.string().uuid({ message: 'The ID must be a valid UUID' }),
});

const emergencyContactSchema = z.object({
    id: z.string().uuid(),
    user_id: z.string().uuid({
        required_error: 'User ID is required',
    }),
    full_name: z.string({
        required_error: 'Full name is required',
    })
        .min(2, 'Full name must be at least 2 characters')
        .max(250, 'Full name must not exceed 250 characters'),
    cellphone: z.string({
        required_error: 'Cellphone is required',
    })
        .min(5, 'Cellphone must be at least 5 characters')
        .max(20, 'Cellphone must not exceed 20 characters'),
    relationship: z.string({
        required_error: 'Relationship is required',
    })
        .min(2, 'Relationship must be at least 2 characters')
        .max(100, 'Relationship must not exceed 100 characters'),
});

const readEmergencyContactRequestSchema = z.object({
    params,
});

const createEmergencyContactRequestSchema = z.object({
    body: emergencyContactSchema.omit({ id: true }),
});

const updateEmergencyContactRequestSchema = z.object({
    params,
    body: emergencyContactSchema.omit({ id: true }),
});

const deleteEmergencyContactRequestSchema = z.object({
    params,
});

module.exports = {
    readEmergencyContactRequestSchema,
    createEmergencyContactRequestSchema,
    updateEmergencyContactRequestSchema,
    deleteEmergencyContactRequestSchema,
};
