const { z } = require('zod');

const uuidSchema = z.string().uuid({ message: 'The ID must be a valid UUID' });

const decimalSchema = z
  .union([z.number(), z.string()])
  .transform((value) => Number(value))
  .refine((value) => Number.isFinite(value), 'Invalid decimal value');

const commonEmergencyBody = z.object({
  type: z.enum(['medical', 'general']),
  priority: z.string().min(1).max(50).optional(),
  latitude: decimalSchema.optional(),
  longitude: decimalSchema.optional(),
  address: z.string().max(1000).optional(),
  image_url: z.string().url().optional(),
  video_url: z.string().url().optional(),
  context_text: z.string().max(5000).optional()
});

const createUrgencyEmergencyRequestSchema = z.object({
  body: commonEmergencyBody.extend({
    // Para botón SOS se fuerza single_context desde controlador.
    call_mode: z.any().optional()
  })
});

const createContextualEmergencyRequestSchema = z.object({
  body: commonEmergencyBody.extend({
    call_mode: z.enum(['single_context', 'interactive'])
  })
});

const readEmergencyRequestSchema = z.object({
  params: z.object({
    id: uuidSchema
  })
});

module.exports = {
  createUrgencyEmergencyRequestSchema,
  createContextualEmergencyRequestSchema,
  readEmergencyRequestSchema
};
