const express = require('express');
const TwilioController = require('../controllers/twilio.controller');

const router = express.Router();

router.get('/twiml/:emergencia_id', TwilioController.twiml);

module.exports = router;
