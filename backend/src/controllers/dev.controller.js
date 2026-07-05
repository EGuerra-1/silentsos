const fs = require('fs');
const path = require('path');
const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const { getIntegrationStatus } = require('../config/integrations');
const OpenAIService = require('../services/openai.service');
const ElevenLabsService = require('../services/elevenlabs.service');
const ZavuService = require('../services/zavu.service');
const TwilioService = require('../services/twilio.service');
const AwsS3Service = require('../services/aws-s3.service');
const EmergencyOrchestrator = require('../services/emergency.orchestrator');

class DevController {
    static routes = '/dev';

    // Verifica rápidamente si cada integración está lista para pruebas.
    static status = catchErrors(async (req, res) => {
        return ApiResponse.success(res, {
            route: `${this.routes}/integrations/status`,
            message: 'Estado de integraciones',
            data: getIntegrationStatus(),
        });
    });

    static testOpenAI = catchErrors(async (req, res) => {
        const { contextText = '', imageUrl, imageBase64, mimeType } = req.body;
        const triage = await OpenAIService.analyzeEmergency({
            contextText,
            imageUrl,
            imageBase64,
            mimeType,
        });

        return ApiResponse.success(res, {
            route: `${this.routes}/integrations/openai/triage`,
            message: 'Triage generado',
            data: triage,
        });
    });

    static testElevenLabsTts = catchErrors(async (req, res) => {
        // Genera un MP3 y lo publica en URL local o firmada de S3.
        const { text = 'Esta es una prueba de audio de emergencia SilentSOS.' } = req.body;
        const audio = await ElevenLabsService.textToSpeech(text);
        const saved = await AwsS3Service.upload({
            buffer: audio.buffer,
            folder: 'audio',
            filename: `dev-tts-${Date.now()}.${audio.extension}`,
            contentType: audio.contentType,
        });

        return ApiResponse.success(res, {
            route: `${this.routes}/integrations/elevenlabs/tts`,
            message: 'Audio generado',
            data: {
                text,
                storage: saved.storage,
                url: saved.url || saved.publicPath,
                filename: saved.filename || saved.key,
                sizeBytes: audio.buffer.length,
            },
        });
    });

    static testElevenLabsStt = catchErrors(async (req, res) => {
        // Transcribe un archivo de audio previamente generado en pruebas.
        const filename = req.body.filename;
        if (!filename) {
            return ApiResponse.error(res, {
                route: `${this.routes}/integrations/elevenlabs/stt`,
                message: 'Debes enviar filename de un audio generado previamente',
                error: 'filename requerido',
                status: 400,
            });
        }

        const filePath = AwsS3Service.resolveLocalFile('audio', filename);
        const buffer = fs.readFileSync(filePath);
        const transcription = await ElevenLabsService.speechToText(buffer, {
            filename,
            mimeType: 'audio/mpeg',
        });

        return ApiResponse.success(res, {
            route: `${this.routes}/integrations/elevenlabs/stt`,
            message: 'Transcripcion generada',
            data: transcription,
        });
    });

    static testZavu = catchErrors(async (req, res) => {
        const { to, text, channel } = req.body;
        if (!to || !text) {
            return ApiResponse.error(res, {
                route: `${this.routes}/integrations/zavu/message`,
                message: 'to y text son requeridos',
                error: 'Validacion fallida',
                status: 400,
            });
        }

        const response = await ZavuService.sendMessage({ to, text, channel });

        return ApiResponse.success(res, {
            route: `${this.routes}/integrations/zavu/message`,
            message: 'Mensaje enviado',
            data: response,
        });
    });

    static testTwilioCall = catchErrors(async (req, res) => {
        // Protección para evitar llamadas accidentales durante desarrollo.
        const { confirm = false, to, audioUrl } = req.body;

        if (!confirm) {
            return ApiResponse.error(res, {
                route: `${this.routes}/integrations/twilio/call`,
                message: 'Debes enviar confirm=true para iniciar una llamada real',
                error: 'Confirmacion requerida',
                status: 400,
            });
        }

        const emergencyId = `dev-${Date.now()}`;
        const call = await EmergencyOrchestrator.startEmergencyCall({
            emergencyId,
            audioUrl: audioUrl || `${process.env.PUBLIC_BASE_URL}/api/dev/sample-twiml-audio`,
            to,
        });

        return ApiResponse.success(res, {
            route: `${this.routes}/integrations/twilio/call`,
            message: 'Llamada iniciada',
            data: call,
        });
    });

    static testPipeline = catchErrors(async (req, res) => {
        // Ejecuta el flujo integrado para validar extremo a extremo.
        const {
            contextText = 'Usuario reporta caida con posible lesion en brazo.',
            imageUrl,
            notifyTo,
            call = false,
        } = req.body;

        const result = await EmergencyOrchestrator.runDemoFlow({
            contextText,
            imageUrl,
            notifyTo,
            call: Boolean(call),
        });

        return ApiResponse.success(res, {
            route: `${this.routes}/integrations/pipeline`,
            message: 'Pipeline demo ejecutado',
            data: result,
        });
    });

    static serveMedia = catchErrors(async (req, res) => {
        const { folder, filename } = req.params;
        const filePath = AwsS3Service.resolveLocalFile(folder, filename);
        return res.sendFile(filePath);
    });

    static listGeneratedAudio = catchErrors(async (req, res) => {
        // Lista archivos útiles para escuchar resultados de TTS desde navegador.
        const audioDir = path.join(process.cwd(), process.env.LOCAL_STORAGE_PATH || 'storage', 'audio');

        if (!fs.existsSync(audioDir)) {
            return ApiResponse.success(res, {
                route: `${this.routes}/integrations/audio`,
                message: 'Sin archivos generados',
                data: [],
            });
        }

        const files = fs.readdirSync(audioDir)
            .filter((file) => file.endsWith('.mp3'))
            .map((file) => ({
                filename: file,
                url: `/api/dev/media/audio/${file}`,
            }));

        return ApiResponse.success(res, {
            route: `${this.routes}/integrations/audio`,
            message: 'Audios generados',
            data: files,
        });
    });
}

module.exports = DevController;
