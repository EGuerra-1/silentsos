const { z } = require('zod');

const uuidSchema = z.string().uuid({ message: 'The ID must be a valid UUID' });
const timeSchema = z
  .string({ required_error: 'Time is required' })
  .regex(/^([01]\d|2[0-3]):([0-5]\d)$/, 'Time must be in HH:mm format');
const dateSchema = z
  .string()
  .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format');

/**
 * @swagger
 * components:
 *   schemas:
 *     DiseaseCatalog:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         name:
 *           type: string
 *         classification:
 *           type: string
 *         description:
 *           type: string
 *     UserDisease:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         disease_catalog_id:
 *           type: string
 *           format: uuid
 *         notes:
 *           type: string
 *         diagnosed_at:
 *           type: string
 *           format: date
 *     MedicationInput:
 *       type: object
 *       required:
 *         - name
 *         - dose
 *         - unit
 *         - frequency
 *         - schedules
 *       properties:
 *         title:
 *           type: string
 *         name:
 *           type: string
 *         dose:
 *           type: string
 *         unit:
 *           type: string
 *         frequency:
 *           type: string
 *         observations:
 *           type: string
 *         schedules:
 *           type: array
 *           items:
 *             type: object
 *             required:
 *               - time_of_day
 *             properties:
 *               time_of_day:
 *                 type: string
 *                 example: "08:00"
 *               notes:
 *                 type: string
 */

const idParamsSchema = z.object({
  id: uuidSchema
});

const planParamsSchema = z.object({
  plan_id: uuidSchema
});

const scheduleSchema = z.object({
  time_of_day: timeSchema,
  notes: z.string().max(250).optional()
});

const medicationInputSchema = z.object({
  title: z.string().min(2).max(250).optional(),
  name: z.string({ required_error: 'Medication name is required' }).min(2).max(250),
  dose: z.string({ required_error: 'Dose is required' }).min(1).max(100),
  unit: z.string({ required_error: 'Unit is required' }).min(1).max(50),
  frequency: z.string({ required_error: 'Frequency is required' }).min(1).max(100),
  observations: z.string().max(1000).optional(),
  schedules: z.array(scheduleSchema).min(1, 'At least one schedule is required')
});

const createUserDiseaseRequestSchema = z.object({
  body: z.object({
    disease_catalog_id: uuidSchema,
    notes: z.string().max(1000).optional(),
    diagnosed_at: dateSchema.optional()
  })
});

const updateUserDiseaseRequestSchema = z.object({
  params: idParamsSchema,
  body: z.object({
    disease_catalog_id: uuidSchema,
    notes: z.string().max(1000).optional(),
    diagnosed_at: dateSchema.optional()
  })
});

const createMedicationRequestSchema = z.object({
  body: medicationInputSchema
});

const updateMedicationRequestSchema = z.object({
  params: planParamsSchema,
  body: medicationInputSchema
});

const createMedicationBulkRequestSchema = z.object({
  body: z.object({
    medications: z.array(medicationInputSchema).min(1, 'At least one medication is required')
  })
});

const createConsumptionRequestSchema = z.object({
  body: z.object({
    medication_plan_id: uuidSchema,
    scheduled_time: timeSchema.optional(),
    consumed_at: z.string().datetime().optional(),
    status: z.enum(['consumed', 'skipped', 'missed']).optional(),
    observations: z.string().max(1000).optional()
  })
});

const readConsumptionsRequestSchema = z.object({
  query: z.object({
    from: z.string().datetime().optional(),
    to: z.string().datetime().optional(),
    status: z.enum(['consumed', 'skipped', 'missed']).optional()
  })
});

const readPendingTodayRequestSchema = z.object({
  query: z.object({
    date: dateSchema.optional()
  })
});

module.exports = {
  createUserDiseaseRequestSchema,
  updateUserDiseaseRequestSchema,
  createMedicationRequestSchema,
  updateMedicationRequestSchema,
  createMedicationBulkRequestSchema,
  createConsumptionRequestSchema,
  readConsumptionsRequestSchema,
  readPendingTodayRequestSchema
};
