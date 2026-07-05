const twilio = require('twilio');
const { integrations } = require('../config/integrations');

class TwilioService {
    static getClient() {
        if (!integrations.twilio.configured()) {
            throw new Error('Twilio no esta configurado. Revisa TWILIO_* en .env');
        }

        return twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
    }

    static buildPlayTwiml(audioUrl) {
        // TwiML básico: reproduce audio pregrabado y cierra mensaje.
        const response = new twilio.twiml.VoiceResponse();
        response.play(audioUrl);
        response.pause({ length: 1 });
        response.say({ language: 'es-MX' }, 'Fin del mensaje de emergencia SilentSOS.');
        return response.toString();
    }

    static buildStreamTwiml({ audioUrl, streamUrl }) {
        // TwiML para fase 2: combina reproducción inicial + stream bidireccional.
        const response = new twilio.twiml.VoiceResponse();

        if (audioUrl) {
            response.play(audioUrl);
        }

        if (streamUrl) {
            const connect = response.connect();
            connect.stream({ url: streamUrl });
        }

        return response.toString();
    }

    static async makeCall({ to, twimlUrl, statusCallbackUrl }) {
        // Inicia llamada saliente hacia número objetivo o emergencia por defecto.
        const client = this.getClient();
        const destination = to || integrations.twilio.emergencyNumber();

        if (!destination) {
            throw new Error('No hay numero destino. Configura EMERGENCY_PHONE_NUMBER');
        }

        if (!twimlUrl) {
            throw new Error('twimlUrl es requerido para iniciar la llamada');
        }

        const call = await client.calls.create({
            to: destination,
            from: integrations.twilio.fromNumber(),
            url: twimlUrl,
            method: 'GET',
            statusCallback: statusCallbackUrl,
            statusCallbackMethod: 'POST',
        });

        return {
            sid: call.sid,
            status: call.status,
            to: call.to,
            from: call.from,
        };
    }
}

module.exports = TwilioService;
