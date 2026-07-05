const express = require('express');
const TwilioController = require('../controllers/twilio.controller');

const router = express.Router();

// Twilio consulta este endpoint al contestar la llamada para obtener TwiML.
router.get('/twiml/:emergency_id', TwilioController.twiml);

// Respaldo si la URL principal no responde (ver fallbackUrl en TwilioService.makeCall).
router.get('/twiml-fallback/:emergency_id', TwilioController.twimlFallback);

// Twilio notifica cambios de estado de la llamada (iniciada, contestada, completada...).
router.post('/status/:emergency_id', TwilioController.statusCallback);

module.exports = router;
