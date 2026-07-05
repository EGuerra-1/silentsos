const express = require('express');
const {
  createUrgency,
  createContextual,
  getById
} = require('../controllers/emergency.controller');
const { checkAuth } = require('../middlewares/checkAuth');
const validateRequest = require('../utils/validateRequest');
const {
  createUrgencyEmergencyRequestSchema,
  createContextualEmergencyRequestSchema,
  readEmergencyRequestSchema
} = require('../validations/emergency.schema');

const router = express.Router();

// Ruta para botón SOS urgente: siempre usa single_context.
router.post('/urgency', checkAuth('user'), validateRequest(createUrgencyEmergencyRequestSchema), createUrgency);

// Ruta para flujo con fotos/contexto: permite elegir single_context o interactive.
router.post('/contextual', checkAuth('user'), validateRequest(createContextualEmergencyRequestSchema), createContextual);

router.get('/:id', checkAuth('user'), validateRequest(readEmergencyRequestSchema), getById);

module.exports = router;
