const ElevenLabsService = require('./elevenlabs.service');
const OpenAIService = require('./openai.service');
const ZavuService = require('./zavu.service');
const TwilioService = require('./twilio.service');
const AwsS3Service = require('./aws-s3.service');
const { integrations } = require('../config/integrations');

class EmergencyOrchestrator {
    static async generateEmergencyAudio(summaryText) {
        // TTS + almacenamiento en una sola operación.
        const audio = await ElevenLabsService.textToSpeech(summaryText);
        const upload = await AwsS3Service.upload({
            buffer: audio.buffer,
            folder: 'audio',
            filename: `emergency-${Date.now()}.${audio.extension}`,
            contentType: audio.contentType,
        });

        return upload;
    }

    static async notifyContacts({ contacts, summary, locationText }) {
        // No detiene todo el flujo si un contacto falla; retorna resultado por contacto.
        const results = [];

        for (const contact of contacts) {
            try {
                const response = await ZavuService.sendEmergencyAlert({
                    contact,
                    emergencySummary: summary,
                    locationText,
                });
                results.push({ contactId: contact.id, success: true, response });
            } catch (error) {
                results.push({ contactId: contact.id, success: false, error: error.message });
            }
        }

        return results;
    }

    static async startEmergencyCall({ audioUrl, emergencyId }) {
        if (!integrations.publicUrl.configured()) {
            throw new Error('PUBLIC_BASE_URL no configurado. Twilio necesita una URL publica.');
        }

        const twimlUrl = `${integrations.publicUrl.value()}/api/twilio/twiml/${emergencyId}?audioUrl=${encodeURIComponent(audioUrl)}`;

        return TwilioService.makeCall({ twimlUrl });
    }

    static async runDemoFlow({ contextText, imageUrl, notifyTo, call = false }) {
        // Flujo de demo: triage -> audio -> mensajería -> llamada (opcional).
        const triage = await OpenAIService.analyzeEmergency({ contextText, imageUrl });
        const audio = await this.generateEmergencyAudio(triage.resumen);

        const result = {
            triage,
            audio,
            message: null,
            call: null,
        };

        if (notifyTo) {
            result.message = await ZavuService.sendMessage({
                to: notifyTo,
                text: `Demo SilentSOS\n${triage.resumen}`,
            });
        }

        if (call) {
            result.call = await this.startEmergencyCall({
                audioUrl: audio.url || `${integrations.publicUrl.value()}${audio.publicPath}`,
                emergencyId: `demo-${Date.now()}`,
            });
        }

        return result;
    }
}

module.exports = EmergencyOrchestrator;
