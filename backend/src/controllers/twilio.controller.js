const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const TwilioService = require('../services/twilio.service');

class TwilioController {
    static routes = '/twilio';

    static twiml = catchErrors(async (req, res) => {
        // Endpoint público que Twilio consulta para obtener instrucciones de la llamada.
        const audioUrl = req.query.audioUrl;

        if (!audioUrl) {
            return ApiResponse.error(res, {
                route: `${this.routes}/twiml/:emergencia_id`,
                message: 'audioUrl query param es requerido',
                error: 'audioUrl faltante',
                status: 400,
            });
        }

        const twiml = TwilioService.buildPlayTwiml(audioUrl);
        res.type('text/xml');
        return res.status(200).send(twiml);
    });
}

module.exports = TwilioController;
