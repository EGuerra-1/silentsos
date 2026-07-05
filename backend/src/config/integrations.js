const fs = require('fs');
const path = require('path');

// Lee una variable de entorno y descarta placeholders comunes del .env.example.
function env(name) {
    const value = process.env[name];
    if (!value || value.includes('your_') || value === '...') {
        return null;
    }
    return value.trim();
}

function isConfigured(keys) {
    return keys.every((key) => Boolean(env(key)));
}

// Centraliza defaults y validación de integraciones externas.
const integrations = {
    openai: {
        configured: () => isConfigured(['OPENAI_API_KEY']),
        keys: ['OPENAI_API_KEY'],
        model: () => env('OPENAI_MODEL') || 'gpt-4o',
        timeoutMs: () => Number(env('OPENAI_TRIAGE_TIMEOUT_MS') || 15000),
    },
    elevenlabs: {
        configured: () => isConfigured(['ELEVENLABS_API_KEY', 'ELEVENLABS_VOICE_ID']),
        keys: ['ELEVENLABS_API_KEY', 'ELEVENLABS_VOICE_ID'],
        voiceId: () => env('ELEVENLABS_VOICE_ID'),
        ttsModel: () => env('ELEVENLABS_TTS_MODEL') || 'eleven_turbo_v2_5',
        sttModel: () => env('ELEVENLABS_STT_MODEL') || 'scribe_v2',
    },
    zavu: {
        configured: () => isConfigured(['ZAVU_API_KEY']),
        keys: ['ZAVU_API_KEY'],
        senderId: () => env('ZAVU_SENDER_ID'),
        defaultChannel: () => env('ZAVU_DEFAULT_CHANNEL') || 'sms',
        apiUrl: () => 'https://api.zavu.dev/v1/messages',
    },
    n8n: {
        configured: () => isConfigured(['N8N_EMERGENCY_WEBHOOK_URL']),
        keys: ['N8N_EMERGENCY_WEBHOOK_URL'],
        webhookUrl: () => env('N8N_EMERGENCY_WEBHOOK_URL'),
        medicationWebhookUrl: () => env('N8N_MEDICATION_WEBHOOK_URL'),
        webhookSecret: () => env('N8N_EMERGENCY_WEBHOOK_SECRET'),
        timeoutMs: () => Number(env('N8N_WEBHOOK_TIMEOUT_MS') || 10000),
    },
    twilio: {
        configured: () => isConfigured(['TWILIO_ACCOUNT_SID', 'TWILIO_AUTH_TOKEN', 'TWILIO_PHONE_NUMBER']),
        keys: ['TWILIO_ACCOUNT_SID', 'TWILIO_AUTH_TOKEN', 'TWILIO_PHONE_NUMBER'],
        fromNumber: () => env('TWILIO_PHONE_NUMBER'),
        emergencyNumber: () => env('EMERGENCY_PHONE_NUMBER'),
        // 1 reintento por defecto (2 intentos en total) si la llamada no se contesta o falla.
        maxCallAttempts: () => Number(env('MAX_CALL_ATTEMPTS') || 2),
        callRetryDelayMs: () => Number(env('CALL_RETRY_DELAY_MS') || 20000),
    },
    awsS3: {
        configured: () => isConfigured(['AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY', 'AWS_S3_BUCKET']),
        keys: ['AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY', 'AWS_S3_BUCKET'],
        region: () => env('AWS_REGION') || 'us-east-1',
        bucket: () => env('AWS_S3_BUCKET'),
    },
    publicUrl: {
        configured: () => isConfigured(['PUBLIC_BASE_URL']),
        value: () => env('PUBLIC_BASE_URL'),
    },
};

function getLocalStoragePath() {
    const configuredPath = env('LOCAL_STORAGE_PATH') || 'storage';
    return path.resolve(process.cwd(), configuredPath);
}

// Crea carpeta local para archivos cuando S3 no está disponible.
function ensureLocalStorage(subfolder = '') {
    const targetPath = path.join(getLocalStoragePath(), subfolder);
    fs.mkdirSync(targetPath, { recursive: true });
    return targetPath;
}

function getIntegrationStatus() {
    // Este resumen alimenta el endpoint de diagnóstico /api/dev/integrations/status.
    return {
        openai: integrations.openai.configured(),
        elevenlabs: integrations.elevenlabs.configured(),
        zavu: integrations.zavu.configured(),
        n8n: integrations.n8n.configured(),
        twilio: integrations.twilio.configured(),
        awsS3: integrations.awsS3.configured(),
        publicUrl: integrations.publicUrl.configured(),
        localStorage: getLocalStoragePath(),
    };
}

module.exports = {
    env,
    integrations,
    getLocalStoragePath,
    ensureLocalStorage,
    getIntegrationStatus,
};
