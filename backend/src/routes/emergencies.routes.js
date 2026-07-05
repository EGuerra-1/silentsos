const express = require('express');
const EmergencyController = require('../controllers/emergency.controller');
const { checkAuth } = require('../middlewares/checkAuth');
const validateRequest = require('../utils/validateRequest');
const {
    createUrgencyEmergencyRequestSchema,
    createContextualEmergencyRequestSchema,
    readEmergencyRequestSchema,
} = require('../validations/emergency.schema');

const router = express.Router();

// Botón SOS: JSON, tipo requerido, ubicación requerida, sin interacción.
router.post(
    '/urgency',
    checkAuth('user'),
    validateRequest(createUrgencyEmergencyRequestSchema),
    EmergencyController.createUrgency
);

// Botón contextual: multipart con 2 fotos, Vision detecta tipo, modo seleccionable.
router.post(
    '/contextual',
    checkAuth('user'),
    EmergencyController.uploadContextualImages,
    validateRequest(createContextualEmergencyRequestSchema),
    EmergencyController.createContextual
);

// Polling de estado desde Flutter.
router.get(
    '/:id',
    checkAuth('user'),
    validateRequest(readEmergencyRequestSchema),
    EmergencyController.getById
);

module.exports = router;
