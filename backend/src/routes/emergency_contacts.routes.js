const express = require('express');
const {
  getAll,
  save,
  getById,
  update,
  destroy
} = require('../controllers/emergency_contact.controller');
const {checkAuth} = require('../middlewares/checkAuth');
const validateRequest = require('../utils/validateRequest');
const {
  readEmergencyContactRequestSchema,
  createEmergencyContactRequestSchema,
  updateEmergencyContactRequestSchema,
  deleteEmergencyContactRequestSchema,
} = require('../validations/emergency_contact.schema');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: EmergencyContacts
 *   description: Endpoints related to emergency contact operations
 */

/**
 * @swagger
 * /emergency_contacts:
 *   get:
 *     summary: Retrieve all emergency contacts
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: A list of emergency contacts.
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: "#/components/schemas/EmergencyContact"
 */
router.get('/', checkAuth('admin'), getAll);

/**
 * @swagger
 * /emergency_contacts:
 *   post:
 *     summary: Create a new emergency contact
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: "#/components/schemas/EmergencyContact"
 *     responses:
 *       201:
 *         description: Emergency contact created successfully.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/EmergencyContact"
 *       400:
 *         description: Error creating emergency contact.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/ErrorResponse"
 */
router.post('/', checkAuth('admin'), validateRequest(createEmergencyContactRequestSchema), save);

/**
 * @swagger
 * /emergency_contacts/{id}:
 *   get:
 *     summary: Retrieve an emergency contact by ID
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The emergency contact ID.
 *     responses:
 *       200:
 *         description: Emergency contact details.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/EmergencyContact"
 *       404:
 *         description: Emergency contact not found.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/ErrorResponse"
 */
router.get('/:id', checkAuth('admin'), validateRequest(readEmergencyContactRequestSchema), getById);

/**
 * @swagger
 * /emergency_contacts/{id}:
 *   put:
 *     summary: Update an emergency contact by ID
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The emergency contact ID.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: "#/components/schemas/EmergencyContact"
 *     responses:
 *       200:
 *         description: Emergency contact updated successfully.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/EmergencyContact"
 *       404:
 *         description: Emergency contact not found.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/ErrorResponse"
 */
router.put('/:id', checkAuth('admin'), validateRequest(updateEmergencyContactRequestSchema), update);

/**
 * @swagger
 * /emergency_contacts/{id}:
 *   delete:
 *     summary: Delete an emergency contact by ID
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The emergency contact ID.
 *     responses:
 *       200:
 *         description: Emergency contact deleted successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Emergency contact deleted successfully"
 *       404:
 *         description: Emergency contact not found.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/ErrorResponse"
 */
router.delete('/:id', checkAuth('admin'), validateRequest(deleteEmergencyContactRequestSchema), destroy);

module.exports = router;
