const express = require('express');
const { twiml, statusCallback } = require('../controllers/twilio.controller');

const router = express.Router();

router.get('/twiml/:emergencia_id', twiml);
router.post('/status/:emergency_id', statusCallback);

module.exports = router;
