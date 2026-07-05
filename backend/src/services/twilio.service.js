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
        // TwiML básico: reproduce audio pregrabado y cierra la llamada.
        const response = new twilio.twiml.VoiceResponse();
        response.play(audioUrl);
        response.pause({ length: 1 });
        response.say({ language: 'es-MX' }, 'Fin del mensaje de emergencia.');
        return response.toString();
    }

    // Respaldo si Twilio no logra descargar el audio (ej. dominio público mal configurado):
    // lee el mensaje con la voz nativa de Twilio en vez de dejar la llamada en silencio.
    static buildSayFallbackTwiml(text) {
        const response = new twilio.twiml.VoiceResponse();
        response.say({ language: 'es-MX' }, text || 'No se pudo cargar el mensaje de emergencia. Por favor envíe ayuda de inmediato.');
        return response.toString();
    }

    static buildStreamTwiml({ audioUrl, streamUrl }) {
        // TwiML para modo interactivo: reproduce audio inicial y abre canal bidireccional.
        const response = new twilio.twiml.VoiceResponse();

        if (audioUrl) {
            response.play(audioUrl);
        }

        // <Connect><Stream> mantiene la llamada abierta y envía audio del operador
        // a nuestro WebSocket para transcripción con ElevenLabs STT.
        const connect = response.connect();
        connect.stream({ url: streamUrl });

        return response.toString();
    }

    static async makeCall({ to, twimlUrl, statusCallbackUrl, fallbackUrl }) {
        // Inicia llamada saliente siempre al número de emergencia configurado.
        const client = this.getClient();
        const destination = to || integrations.twilio.emergencyNumber();

        if (!destination) {
            throw new Error('No hay numero destino. Configura EMERGENCY_PHONE_NUMBER en .env');
        }
        if (!twimlUrl) {
            throw new Error('twimlUrl es requerido para iniciar la llamada');
        }

        const call = await client.calls.create({
            to: destination,
            from: integrations.twilio.fromNumber(),
            url: twimlUrl,
            method: 'GET',
            // Si la URL principal no responde (dominio caído, timeout, etc.), Twilio
            // reintenta aquí en vez de dejar la llamada en silencio.
            fallbackUrl,
            fallbackMethod: 'GET',
            statusCallback: statusCallbackUrl,
            statusCallbackMethod: 'POST',
            // Incluye "in-progress" para soportar reintento de WhatsApp en n8n.
            statusCallbackEvent: ['initiated', 'ringing', 'answered', 'completed'],
        });

        return { sid: call.sid, status: call.status, to: call.to, from: call.from };
    }
}

module.exports = TwilioService;
