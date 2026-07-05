const ElevenLabsService = require('./elevenlabs.service');
const OpenAIService = require('./openai.service');
const ZavuService = require('./zavu.service');
const TwilioService = require('./twilio.service');
const LocalStorageService = require('./local-storage.service');
const { integrations } = require('../config/integrations');

class EmergencyOrchestrator {
    static async generateEmergencyAudio(summaryText) {
        // TTS + almacenamiento local en una sola operación.
        const audio = await ElevenLabsService.textToSpeech(summaryText);
        const stored = LocalStorageService.save({
            buffer: audio.buffer,
            folder: 'audio',
            filename: `emergency-${Date.now()}.${audio.extension}`,
            contentType: audio.contentType,
        });
        return stored;
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

    // Usado en el endpoint de demo /api/dev para pruebas sin emergencia real.
    static async runDemoFlow({ contextText, frontImageUrl, backImageUrl, notifyTo, call = false }) {
        const triage = await OpenAIService.analyzeEmergency({ frontImageUrl, backImageUrl, contextText });
        const stored = await this.generateEmergencyAudio(triage.resumen);

        const result = { triage, audio: stored, message: null, call: null };

        if (notifyTo) {
            result.message = await ZavuService.sendMessage({
                to: notifyTo,
                text: `Demo SilentSOS\n${triage.resumen}`,
            });
        }

        if (call && integrations.publicUrl.configured()) {
            const audioUrl = `${integrations.publicUrl.value()}${stored.publicPath}`;
            result.call = await TwilioService.makeCall({
                twimlUrl: `${integrations.publicUrl.value()}/api/twilio/twiml/demo?audioUrl=${encodeURIComponent(audioUrl)}`,
                statusCallbackUrl: `${integrations.publicUrl.value()}/api/twilio/status/demo`,
            });
        }

        return result;
    }
}

module.exports = EmergencyOrchestrator;
