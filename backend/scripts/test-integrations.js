require('dotenv').config();

const BASE_URL = process.env.API_URL || `http://localhost:${process.env.API_PORT || 4000}`;

async function request(method, path, body) {
    const response = await fetch(`${BASE_URL}${path}`, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: body ? JSON.stringify(body) : undefined,
    });

    const data = await response.json().catch(() => ({}));
    return { status: response.status, data };
}

async function main() {
    console.log(`\nSilentSOS integration smoke test -> ${BASE_URL}\n`);

    const status = await request('GET', '/api/dev/integrations/status');
    console.log('1) Status integraciones:', status.status, status.data);

    const triage = await request('POST', '/api/dev/integrations/openai/triage', {
        contextText: 'Usuario reporta dificultad para respirar despues de caida.',
    });
    console.log('2) OpenAI triage:', triage.status, triage.data?.data?.source || triage.data);

    const tts = await request('POST', '/api/dev/integrations/elevenlabs/tts', {
        text: 'Prueba SilentSOS. Emergencia medica reportada. Enviar ambulancia.',
    });
    console.log('3) ElevenLabs TTS:', tts.status, tts.data?.data?.url || tts.data?.data?.publicPath || tts.data);

    if (tts.data?.data?.filename) {
        const audioList = await request('GET', '/api/dev/integrations/audio');
        console.log('4) Audios generados:', audioList.status, audioList.data?.data?.length || 0);
    }

    console.log('\nListo. Abre en navegador la URL del paso 3 para escuchar el audio.\n');
}

main().catch((error) => {
    console.error('Error en test:integrations', error.message);
    process.exit(1);
});
