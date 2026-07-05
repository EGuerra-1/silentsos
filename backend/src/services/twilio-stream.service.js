const ElevenLabsService = require('./elevenlabs.service');
const GestureService = require('./gesture.service');
const LocalStorageService = require('./local-storage.service');
const { integrations } = require('../config/integrations');

// Acumula chunks de audio µ-law de Twilio y transcribe por lotes.
const CHUNK_BUFFER_MS = 3000;
const SAMPLE_RATE = 8000;
const BYTES_PER_MS = SAMPLE_RATE / 1000;

// Encabezado WAV para µ-law 8kHz mono, necesario para enviar a ElevenLabs STT.
function buildMulawWavHeader(dataLength) {
    const buffer = Buffer.alloc(44);
    buffer.write('RIFF', 0);
    buffer.writeUInt32LE(36 + dataLength, 4);
    buffer.write('WAVE', 8);
    buffer.write('fmt ', 12);
    buffer.writeUInt32LE(16, 16);
    buffer.writeUInt16LE(7, 20);    // WAVE_FORMAT_MULAW
    buffer.writeUInt16LE(1, 22);    // mono
    buffer.writeUInt32LE(SAMPLE_RATE, 24);
    buffer.writeUInt32LE(SAMPLE_RATE, 28);
    buffer.writeUInt16LE(1, 32);
    buffer.writeUInt16LE(8, 34);    // 8 bits/sample
    buffer.write('data', 36);
    buffer.writeUInt32LE(dataLength, 40);
    return buffer;
}

class TwilioStreamService {
    // Mantiene el estado activo por emergencia: WS de Twilio + socket de Flutter.
    static activeStreams = new Map();

    static register({ emergencyId, ws, streamSid }) {
        this.activeStreams.set(emergencyId, {
            ws,
            streamSid,
            audioChunks: [],
            flushTimer: null,
        });
    }

    static unregister(emergencyId) {
        const state = this.activeStreams.get(emergencyId);
        if (state?.flushTimer) {
            clearTimeout(state.flushTimer);
        }
        this.activeStreams.delete(emergencyId);
    }

    static linkSocket(emergencyId, ioSocket) {
        const state = this.activeStreams.get(emergencyId);
        if (state) {
            state.ioSocket = ioSocket;
        }
    }

    static handleMediaChunk(emergencyId, payload) {
        const state = this.activeStreams.get(emergencyId);
        if (!state) return;

        const chunk = Buffer.from(payload, 'base64');
        state.audioChunks.push(chunk);

        // Programa flush tras CHUNK_BUFFER_MS; se reinicia con cada chunk nuevo.
        if (state.flushTimer) clearTimeout(state.flushTimer);
        state.flushTimer = setTimeout(
            () => this._flushChunks(emergencyId),
            CHUNK_BUFFER_MS
        );
    }

    static async _flushChunks(emergencyId) {
        const state = this.activeStreams.get(emergencyId);
        if (!state || state.audioChunks.length === 0) return;

        const audioData = Buffer.concat(state.audioChunks);
        state.audioChunks = [];
        state.flushTimer = null;

        if (audioData.length < BYTES_PER_MS * 500) return; // menos de 500ms → ignorar

        try {
            const wav = Buffer.concat([buildMulawWavHeader(audioData.length), audioData]);
            const { text } = await ElevenLabsService.speechToText(wav, {
                mimeType: 'audio/wav',
                filename: 'operator.wav',
            });

            if (text?.trim() && state.ioSocket) {
                // Envía subtítulos del operador a Flutter en tiempo real.
                state.ioSocket.emit('operator_message', { text: text.trim() });
            }
        } catch {
            // Error de STT no detiene la llamada.
        }
    }

    // Convierte gesto a voz y lo inyecta en el stream activo de Twilio.
    static async handleGesture(emergencyId, gestureId) {
        const state = this.activeStreams.get(emergencyId);
        if (!state?.ws) {
            throw new Error('No hay stream activo para esta emergencia');
        }

        const text = GestureService.getText(gestureId);
        if (!text) {
            throw new Error(`Gesto desconocido: ${gestureId}`);
        }

        // µ-law 8kHz — formato que Twilio acepta directamente en Media Streams.
        const audio = await ElevenLabsService.textToSpeech(text, {
            outputFormat: 'ulaw_8000',
        });

        const payload = audio.buffer.toString('base64');

        // Protocolo Twilio Media Streams: enviar event "media" con audio base64.
        if (state.ws.readyState === 1 /* OPEN */) {
            state.ws.send(
                JSON.stringify({
                    event: 'media',
                    streamSid: state.streamSid,
                    media: { payload },
                })
            );
        }

        return { gesture: gestureId, text, sent: true };
    }

    static getPublicUrl(emergencyId) {
        const base = integrations.publicUrl.value();
        if (!base) return null;
        // Twilio requiere wss:// en producción. Reemplaza http(s):// → wss://.
        return base.replace(/^https?:\/\//, 'wss://') + `/api/twilio/stream/${emergencyId}`;
    }
}

module.exports = TwilioStreamService;
