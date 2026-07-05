const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const TwilioService = require('../services/twilio.service');
const TwilioStreamService = require('../services/twilio-stream.service');
const EmergencyService = require('../services/emergency.service');
const { Emergency } = require('../models');

class TwilioController {
    static routes = '/twilio';

    static twiml = catchErrors(async (req, res) => {
        // Twilio llama a este endpoint para saber qué reproducir cuando contesten.
        const emergencyId = req.params.emergency_id;
        let audioUrl = req.query.audioUrl;

        if (!audioUrl) {
            const emergency = await Emergency.findByPk(emergencyId);
            audioUrl = emergency?.audio_url || null;
        }

        if (!audioUrl) {
            return ApiResponse.error(res, {
                route: `${this.routes}/twiml/:emergency_id`,
                message: 'No hay audio disponible para esta emergencia',
                error: 'audioUrl faltante',
                status: 400,
            });
        }

        const emergency = await Emergency.findByPk(emergencyId);
        const callMode = emergency?.call_mode || 'single_context';

        let twiml;
        if (callMode === 'interactive') {
            // Modo interactivo: reproduce mensaje inicial y abre stream bidireccional.
            const streamUrl = TwilioStreamService.getPublicUrl(emergencyId);
            if (streamUrl) {
                twiml = TwilioService.buildStreamTwiml({ audioUrl, streamUrl });
            } else {
                // Sin PUBLIC_BASE_URL no se puede abrir stream; cae a modo simple.
                twiml = TwilioService.buildPlayTwiml(audioUrl);
            }
        } else {
            twiml = TwilioService.buildPlayTwiml(audioUrl);
        }

        res.type('text/xml');
        return res.status(200).send(twiml);
    });

    static statusCallback = catchErrors(async (req, res) => {
        // Twilio notifica cambios de estado de la llamada.
        await EmergencyService.handleTwilioStatusCallback(
            req.params.emergency_id,
            req.body || {}
        );
        return res.status(200).send('ok');
    });
}

module.exports = TwilioController;
