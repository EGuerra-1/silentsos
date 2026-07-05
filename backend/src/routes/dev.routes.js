const express = require('express');
const DevController = require('../controllers/dev.controller');

const router = express.Router();

function devOnly(req, res, next) {
    if (process.env.NODE_ENV === 'production') {
        return res.status(404).json({
            success: false,
            message: 'Rutas de desarrollo no disponibles en produccion',
        });
    }
    return next();
}

router.use(devOnly);

router.get('/integrations/status', DevController.status);
router.get('/integrations/audio', DevController.listGeneratedAudio);
router.post('/integrations/openai/triage', DevController.testOpenAI);
router.post('/integrations/elevenlabs/tts', DevController.testElevenLabsTts);
router.post('/integrations/elevenlabs/stt', DevController.testElevenLabsStt);
router.post('/integrations/zavu/message', DevController.testZavu);
router.post('/integrations/twilio/call', DevController.testTwilioCall);
router.post('/integrations/pipeline', DevController.testPipeline);
router.get('/media/:folder/:filename', DevController.serveMedia);

module.exports = router;
