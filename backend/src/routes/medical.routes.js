const express = require('express');
const {
  getDiseaseCatalogs,
  saveUserDisease,
  getUserDiseases,
  updateUserDisease,
  saveMedication,
  saveMedicationBulk,
  updateMedication,
  getMedications,
  saveConsumption,
  getConsumptions,
  getPendingMedicationsToday
} = require('../controllers/medical.controller');
const { checkAuth } = require('../middlewares/checkAuth');
const validateRequest = require('../utils/validateRequest');
const {
  createUserDiseaseRequestSchema,
  updateUserDiseaseRequestSchema,
  createMedicationRequestSchema,
  updateMedicationRequestSchema,
  createMedicationBulkRequestSchema,
  createConsumptionRequestSchema,
  readConsumptionsRequestSchema,
  readPendingTodayRequestSchema
} = require('../validations/medical.schema');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Medical
 *   description: Endpoints para enfermedades, medicamentos, horarios e historial de consumo
 */

/**
 * @swagger
 * /medical/disease_catalogs:
 *   get:
 *     summary: Obtener catálogo global de enfermedades
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Catálogo disponible para selección de enfermedades.
 *       401:
 *         description: Token inválido o ausente.
 */
router.get('/disease_catalogs', checkAuth('user'), getDiseaseCatalogs);

/**
 * @swagger
 * /medical/user_diseases:
 *   get:
 *     summary: Listar enfermedades del usuario autenticado
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de enfermedades asociadas al usuario autenticado.
 *       401:
 *         description: Token inválido o ausente.
 */
router.get('/user_diseases', checkAuth('user'), getUserDiseases);

/**
 * @swagger
 * /medical/user_diseases:
 *   post:
 *     summary: Registrar enfermedad para el usuario autenticado
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - disease_catalog_id
 *             properties:
 *               disease_catalog_id:
 *                 type: string
 *                 format: uuid
 *               notes:
 *                 type: string
 *               diagnosed_at:
 *                 type: string
 *                 format: date
 *                 example: "2026-07-04"
 *     responses:
 *       201:
 *         description: Enfermedad registrada correctamente.
 *       400:
 *         description: Error de validación en payload.
 *       401:
 *         description: Token inválido o ausente.
 */
router.post('/user_diseases', checkAuth('user'), validateRequest(createUserDiseaseRequestSchema), saveUserDisease);

/**
 * @swagger
 * /medical/user_diseases/{id}:
 *   put:
 *     summary: Actualizar enfermedad del usuario autenticado
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: ID del registro de enfermedad del usuario.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - disease_catalog_id
 *             properties:
 *               disease_catalog_id:
 *                 type: string
 *                 format: uuid
 *               notes:
 *                 type: string
 *               diagnosed_at:
 *                 type: string
 *                 format: date
 *     responses:
 *       200:
 *         description: Enfermedad actualizada.
 *       400:
 *         description: Error de validación.
 *       401:
 *         description: Token inválido o ausente.
 *       404:
 *         description: Registro no encontrado para el usuario autenticado.
 */
router.put('/user_diseases/:id', checkAuth('user'), validateRequest(updateUserDiseaseRequestSchema), updateUserDisease);

/**
 * @swagger
 * /medical/medications:
 *   get:
 *     summary: Listar tratamientos del usuario autenticado
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Planes de medicamento con versiones y horarios.
 *       401:
 *         description: Token inválido o ausente.
 */
router.get('/medications', checkAuth('user'), getMedications);

/**
 * @swagger
 * /medical/medications:
 *   post:
 *     summary: Crear medicamento con horarios
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: "#/components/schemas/MedicationInput"
 *     responses:
 *       201:
 *         description: Tratamiento creado con versión inicial y horarios.
 *       400:
 *         description: Error de validación.
 *       401:
 *         description: Token inválido o ausente.
 */
router.post('/medications', checkAuth('user'), validateRequest(createMedicationRequestSchema), saveMedication);

/**
 * @swagger
 * /medical/medications/bulk:
 *   post:
 *     summary: Crear múltiples medicamentos en una sola transacción
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - medications
 *             properties:
 *               medications:
 *                 type: array
 *                 minItems: 1
 *                 items:
 *                   $ref: "#/components/schemas/MedicationInput"
 *     responses:
 *       201:
 *         description: Registro masivo exitoso.
 *       400:
 *         description: Error de validación o fallo transaccional (rollback total).
 *       401:
 *         description: Token inválido o ausente.
 */
router.post('/medications/bulk', checkAuth('user'), validateRequest(createMedicationBulkRequestSchema), saveMedicationBulk);

/**
 * @swagger
 * /medical/medications/{plan_id}:
 *   put:
 *     summary: Actualizar medicamento creando nueva versión
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: plan_id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: ID del plan de medicamento.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: "#/components/schemas/MedicationInput"
 *     responses:
 *       200:
 *         description: Nueva versión creada y versión previa cerrada.
 *       400:
 *         description: Error de validación.
 *       401:
 *         description: Token inválido o ausente.
 *       404:
 *         description: Plan no encontrado para el usuario autenticado.
 */
router.put('/medications/:plan_id', checkAuth('user'), validateRequest(updateMedicationRequestSchema), updateMedication);

/**
 * @swagger
 * /medical/medications/pending-today:
 *   get:
 *     summary: Obtener medicinas pendientes del día
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: date
 *         required: false
 *         schema:
 *           type: string
 *           format: date
 *         description: Fecha objetivo en formato YYYY-MM-DD. Si se omite, usa la fecha actual del servidor.
 *     responses:
 *       200:
 *         description: Horarios pendientes del día para el usuario autenticado.
 *       400:
 *         description: Fecha inválida.
 *       401:
 *         description: Token inválido o ausente.
 */
router.get('/medications/pending-today', checkAuth('user'), validateRequest(readPendingTodayRequestSchema), getPendingMedicationsToday);

/**
 * @swagger
 * /medical/consumptions:
 *   get:
 *     summary: Consultar historial de consumo de medicamentos
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: from
 *         required: false
 *         schema:
 *           type: string
 *           format: date-time
 *         description: Fecha/hora inicial del filtro.
 *       - in: query
 *         name: to
 *         required: false
 *         schema:
 *           type: string
 *           format: date-time
 *         description: Fecha/hora final del filtro.
 *       - in: query
 *         name: status
 *         required: false
 *         schema:
 *           type: string
 *           enum: [consumed, skipped, missed]
 *         description: Estado del consumo.
 *     responses:
 *       200:
 *         description: Historial de consumos del usuario autenticado.
 *       400:
 *         description: Parámetros inválidos.
 *       401:
 *         description: Token inválido o ausente.
 */
router.get('/consumptions', checkAuth('user'), validateRequest(readConsumptionsRequestSchema), getConsumptions);

/**
 * @swagger
 * /medical/consumptions:
 *   post:
 *     summary: Registrar evento de consumo de medicamento
 *     tags: [Medical]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - medication_plan_id
 *             properties:
 *               medication_plan_id:
 *                 type: string
 *                 format: uuid
 *               scheduled_time:
 *                 type: string
 *                 example: "08:00"
 *               consumed_at:
 *                 type: string
 *                 format: date-time
 *               status:
 *                 type: string
 *                 enum: [consumed, skipped, missed]
 *               observations:
 *                 type: string
 *     responses:
 *       201:
 *         description: Consumo registrado.
 *       400:
 *         description: Error de validación.
 *       401:
 *         description: Token inválido o ausente.
 *       404:
 *         description: Plan de medicamento no encontrado para el usuario autenticado.
 */
router.post('/consumptions', checkAuth('user'), validateRequest(createConsumptionRequestSchema), saveConsumption);

module.exports = router;
