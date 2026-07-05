const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const TwilioService = require('../services/twilio.service');
const EmergencyService = require('../services/emergency.service');
const { Emergency } = require('../models');

class TwilioController {
    static routes = '/twilio';

    static twiml = catchErrors(async (req, res) => {
        // Endpoint público que Twilio consulta para obtener instrucciones de la llamada.
        const emergencyId = req.params.emergencia_id;
        let audioUrl = req.query.audioUrl;
        if (!audioUrl) {
            const emergency = await Emergency.findByPk(emergencyId);
            audioUrl = emergency?.audio_url || null;
        }

        if (!audioUrl) {
            return ApiResponse.error(res, {
                route: `${this.routes}/twiml/:emergencia_id`,
                message: 'No audio URL available for this emergency',
                error: 'audioUrl faltante',
                status: 400,
            });
        }

        const twiml = TwilioService.buildPlayTwiml(audioUrl);
        res.type('text/xml');
        return res.status(200).send(twiml);
    });

    static statusCallback = catchErrors(async (req, res) => {
        // Recibe cambios de estado de Twilio y ejecuta reintento de SMS en n8n si aplica.
        await EmergencyService.handleTwilioStatusCallback(req.params.emergency_id, req.body || {});
        return res.status(200).send('ok');
    });
}

module.exports = TwilioController;
