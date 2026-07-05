const OpenAI = require('openai');
const { integrations } = require('../config/integrations');

// Respuesta mínima para no frenar el flujo si OpenAI falla o expira por timeout.
const FALLBACK_TRIAGE = {
    nivel: 'medio',
    gravedad: 'moderada',
    lesiones: [],
    sintomas: ['situacion de emergencia no evaluada completamente'],
    requiere_ambulancia: true,
    resumen: 'Emergencia reportada por usuario con discapacidad auditiva. Se requiere asistencia inmediata. Ubicacion y detalles pendientes de confirmacion.',
};

class OpenAIService {
    static getClient() {
        if (!integrations.openai.configured()) {
            throw new Error('OpenAI no esta configurado. Revisa OPENAI_API_KEY en .env');
        }

        return new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
    }

    static getFallbackTriage(contextText = '') {
        const resumen = contextText
            ? `${FALLBACK_TRIAGE.resumen} Contexto adicional: ${contextText}`
            : FALLBACK_TRIAGE.resumen;

        return {
            ...FALLBACK_TRIAGE,
            resumen,
            source: 'fallback',
        };
    }

    static buildPrompt(contextText) {
        // Se fuerza formato JSON para facilitar guardado directo en BD.
        return [
            'Analiza la emergencia y responde SOLO JSON valido con esta estructura:',
            '{',
            '  "nivel": "bajo|medio|alto|critico",',
            '  "gravedad": "leve|moderada|grave|critica",',
            '  "lesiones": ["string"],',
            '  "sintomas": ["string"],',
            '  "requiere_ambulancia": true,',
            '  "resumen": "texto breve para operador de emergencias"',
            '}',
            contextText ? `Contexto adicional: ${contextText}` : '',
        ].join('\n');
    }

    static async analyzeEmergency({ imageUrl, imageBase64, mimeType = 'image/jpeg', contextText = '' }) {
        const timeoutMs = integrations.openai.timeoutMs();
        const client = this.getClient();
        const prompt = this.buildPrompt(contextText);

        const userContent = [{ type: 'text', text: prompt }];

        if (imageUrl) {
            userContent.push({ type: 'image_url', image_url: { url: imageUrl } });
        } else if (imageBase64) {
            userContent.push({
                type: 'image_url',
                image_url: { url: `data:${mimeType};base64,${imageBase64}` },
            });
        }

        const request = client.chat.completions.create({
            model: integrations.openai.model(),
            // Obliga a OpenAI a responder objeto JSON parseable.
            response_format: { type: 'json_object' },
            messages: [
                {
                    role: 'system',
                    content: 'Eres un asistente medico de triage para emergencias. Responde en espanol.',
                },
                {
                    role: 'user',
                    content: userContent,
                },
            ],
        });

        const timeout = new Promise((_, reject) => {
            setTimeout(() => reject(new Error(`OpenAI timeout after ${timeoutMs}ms`)), timeoutMs);
        });

        try {
            // Si OpenAI tarda demasiado, se usa fallback para continuar la orquestación.
            const response = await Promise.race([request, timeout]);
            const content = response.choices?.[0]?.message?.content;

            if (!content) {
                return this.getFallbackTriage(contextText);
            }

            return {
                ...JSON.parse(content),
                source: 'openai',
            };
        } catch (error) {
            return {
                ...this.getFallbackTriage(contextText),
                source: 'fallback',
                error: error.message,
            };
        }
    }
}

module.exports = OpenAIService;
