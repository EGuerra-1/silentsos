const fs = require('fs');
const path = require('path');
const { integrations, ensureLocalStorage } = require('../config/integrations');

class ElevenLabsService {
    static getHeaders(contentType = 'application/json') {
        if (!integrations.elevenlabs.configured()) {
            throw new Error('ElevenLabs no esta configurado. Revisa ELEVENLABS_API_KEY y ELEVENLABS_VOICE_ID');
        }

        return {
            'xi-api-key': process.env.ELEVENLABS_API_KEY,
            'Content-Type': contentType,
            Accept: 'audio/mpeg',
        };
    }

    static async textToSpeech(text, options = {}) {
        // Convierte resumen de emergencia en audio listo para reproducir por Twilio.
        const voiceId = options.voiceId || integrations.elevenlabs.voiceId();
        const modelId = options.modelId || integrations.elevenlabs.ttsModel();

        const response = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`, {
            method: 'POST',
            headers: this.getHeaders(),
            body: JSON.stringify({
                text,
                model_id: modelId,
                voice_settings: {
                    stability: 0.45,
                    similarity_boost: 0.8,
                },
            }),
        });

        if (!response.ok) {
            const errorBody = await response.text();
            throw new Error(`ElevenLabs TTS error (${response.status}): ${errorBody}`);
        }

        const arrayBuffer = await response.arrayBuffer();

        return {
            buffer: Buffer.from(arrayBuffer),
            contentType: 'audio/mpeg',
            extension: 'mp3',
        };
    }

    static async speechToText(audioInput, options = {}) {
        // Reutilizable para transcribir audio de operador (fase bidireccional).
        if (!process.env.ELEVENLABS_API_KEY) {
            throw new Error('ElevenLabs no esta configurado. Revisa ELEVENLABS_API_KEY');
        }

        const modelId = options.modelId || integrations.elevenlabs.sttModel();
        const formData = new FormData();

        if (Buffer.isBuffer(audioInput)) {
            const blob = new Blob([audioInput], { type: options.mimeType || 'audio/mpeg' });
            formData.append('file', blob, options.filename || 'audio.mp3');
        } else if (typeof audioInput === 'string') {
            // Permite enviar un archivo ya guardado en disco.
            formData.append('file', fs.createReadStream(audioInput));
        } else {
            throw new Error('audioInput debe ser Buffer o ruta de archivo');
        }

        formData.append('model_id', modelId);

        const response = await fetch('https://api.elevenlabs.io/v1/speech-to-text', {
            method: 'POST',
            headers: {
                'xi-api-key': process.env.ELEVENLABS_API_KEY,
            },
            body: formData,
        });

        if (!response.ok) {
            const errorBody = await response.text();
            throw new Error(`ElevenLabs STT error (${response.status}): ${errorBody}`);
        }

        const data = await response.json();

        return {
            text: data.text || data.transcript || '',
            raw: data,
        };
    }

    static async textToSpeechFile(text, filenamePrefix = 'tts') {
        // Útil para pruebas manuales: guarda el MP3 en almacenamiento local.
        const audio = await this.textToSpeech(text);
        const folder = ensureLocalStorage('audio');
        const filename = `${filenamePrefix}-${Date.now()}.${audio.extension}`;
        const filePath = path.join(folder, filename);

        fs.writeFileSync(filePath, audio.buffer);

        return {
            filename,
            filePath,
            contentType: audio.contentType,
            sizeBytes: audio.buffer.length,
        };
    }
}

module.exports = ElevenLabsService;
