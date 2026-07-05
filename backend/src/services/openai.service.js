const OpenAI = require('openai');
const { integrations } = require('../config/integrations');

// Respuesta mínima para no frenar el flujo si OpenAI falla o expira por timeout.
// No repite datos que ya se agregan por separado en el mensaje final (nombre, discapacidad,
// ubicación, contexto del usuario), para evitar información duplicada en el speech.
const FALLBACK_TRIAGE = {
    tipo_emergencia: 'general',
    nivel: 'medio',
    gravedad: 'moderada',
    lesiones: [],
    sintomas: ['situacion de emergencia no evaluada completamente'],
    requiere_ambulancia: true,
    resumen: 'No fue posible analizar las imágenes en el tiempo disponible; se requiere asistencia inmediata en el lugar reportado.',
};

class OpenAIService {
    static getClient() {
        if (!integrations.openai.configured()) {
            throw new Error('OpenAI no esta configurado. Revisa OPENAI_API_KEY en .env');
        }
        return new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
    }

    static getFallbackTriage() {
        return { ...FALLBACK_TRIAGE, source: 'fallback' };
    }

    static buildPrompt(contextText) {
        // Se fuerza formato JSON para facilitar guardado directo en BD.
        return [
            'Analiza las imágenes de la emergencia (cámara frontal y trasera si están disponibles) y responde SOLO con JSON válido con esta estructura exacta:',
            '{',
            '  "tipo_emergencia": "medical|general",',
            '  "nivel": "bajo|medio|alto|critico",',
            '  "gravedad": "leve|moderada|grave|critica",',
            '  "lesiones": ["string"],',
            '  "sintomas": ["string"],',
            '  "requiere_ambulancia": true,',
            '  "resumen": "texto breve en español para el operador de emergencias 911"',
            '}',
            'tipo_emergencia debe ser "medical" si hay señales de lesión, enfermedad o emergencia médica visible.',
            'El campo "resumen" debe describir ÚNICAMENTE lo que observas en las imágenes (fuego, humo, heridas, lugar, riesgos visibles, personas involucradas, etc). Sé específico sobre lo que ves.',
            'NO menciones en "resumen" la discapacidad auditiva del reportante, su nombre, ni si puede hablar o escuchar: esa información ya la agrega el sistema por separado y no debe repetirse.',
            contextText ? `Contexto adicional escrito por el usuario (compleméntalo con lo que ves, no lo repitas textualmente): ${contextText}` : '',
        ].join('\n');
    }

    // Analiza las imágenes de la emergencia en base64 (no se guarda nada en disco).
    static async analyzeEmergency({ frontImageBase64, frontMime = 'image/jpeg', backImageBase64, backMime = 'image/jpeg', contextText = '' }) {
        const timeoutMs = integrations.openai.timeoutMs();
        const client = this.getClient();
        const prompt = this.buildPrompt(contextText);

        const userContent = [{ type: 'text', text: prompt }];

        // Imagen frontal: cámara delantera del usuario (contexto personal).
        if (frontImageBase64) {
            userContent.push({
                type: 'image_url',
                image_url: { url: `data:${frontMime};base64,${frontImageBase64}` },
            });
        }
        // Imagen trasera: cámara trasera (contexto de la escena/entorno).
        if (backImageBase64) {
            userContent.push({
                type: 'image_url',
                image_url: { url: `data:${backMime};base64,${backImageBase64}` },
            });
        }

        const request = client.chat.completions.create({
            model: integrations.openai.model(),
            response_format: { type: 'json_object' },
            messages: [
                {
                    role: 'system',
                    content: 'Eres un asistente médico de triage para emergencias. Responde siempre en español. Analiza imágenes con cuidado.',
                },
                { role: 'user', content: userContent },
            ],
        });

        const timeout = new Promise((_, reject) =>
            setTimeout(() => reject(new Error(`OpenAI timeout after ${timeoutMs}ms`)), timeoutMs)
        );

        try {
            // Si OpenAI tarda demasiado, se usa fallback para continuar la orquestación.
            const response = await Promise.race([request, timeout]);
            const content = response.choices?.[0]?.message?.content;

            if (!content) {
                console.error('OpenAI Vision devolvió respuesta vacía; usando fallback.');
                return this.getFallbackTriage();
            }

            const parsed = JSON.parse(content);
            return { ...parsed, source: 'openai' };
        } catch (error) {
            // Se loguea el motivo real (timeout, error de API, JSON inválido, etc.) para poder
            // diagnosticar por qué Vision no proceso las imágenes en un caso puntual.
            console.error('OpenAI Vision falló, usando fallback:', error.message);
            return this.getFallbackTriage();
        }
    }
}

module.exports = OpenAIService;
