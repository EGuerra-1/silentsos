const { z } = require('zod');

const uuidSchema = z.string().uuid({ message: 'The ID must be a valid UUID' });

const decimalSchema = z
    .union([z.number(), z.string()])
    .transform((v) => Number(v))
    .refine((v) => Number.isFinite(v), 'Valor decimal inválido');

// Ubicación requerida en ambos flujos para guiar al operador y eventuales ambulancias.
const locationFields = z.object({
    latitude: decimalSchema,
    longitude: decimalSchema,
    address: z.string().max(1000).optional(),
});

const createUrgencyEmergencyRequestSchema = z.object({
    body: locationFields.extend({
        type: z.enum(['medical', 'general'], {
            required_error: 'type es requerido: "medical" o "general"',
        }),
        priority: z.string().min(1).max(50).optional(),
    }),
});

// Contextual usa multipart; zod valida los campos de texto que llegan en req.body.
// Las imágenes se validan en el controlador (req.files).
const createContextualEmergencyRequestSchema = z.object({
    body: locationFields.extend({
        call_mode: z.enum(['single_context', 'interactive'], {
            required_error: 'call_mode es requerido: "single_context" o "interactive"',
        }),
        context_text: z.string().max(5000).optional(),
        // lat/lng llegan como strings desde multipart; decimalSchema los convierte.
    }),
});

const readEmergencyRequestSchema = z.object({
    params: z.object({ id: uuidSchema }),
});

module.exports = {
    createUrgencyEmergencyRequestSchema,
    createContextualEmergencyRequestSchema,
    readEmergencyRequestSchema,
};
