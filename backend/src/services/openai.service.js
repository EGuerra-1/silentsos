const OpenAI = require('openai');
const { integrations } = require('../config/integrations');

// Respuesta mínima para no frenar el flujo si OpenAI falla o expira por timeout.
const FALLBACK_TRIAGE = {
    tipo_emergencia: 'general',
    nivel: 'medio',
    gravedad: 'moderada',
    lesiones: [],
    sintomas: ['situacion de emergencia no evaluada completamente'],
    requiere_ambulancia: true,
    resumen: 'Emergencia reportada por usuario con discapacidad auditiva. Se requiere asistencia inmediata.',
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
        return { ...FALLBACK_TRIAGE, resumen, source: 'fallback' };
    }

    static buildPrompt(contextText) {
        // Se fuerza formato JSON para facilitar guardado directo en BD.
        return [
            'Analiza las imágenes de la emergencia y responde SOLO con JSON válido con esta estructura exacta:',
            '{',
            '  "tipo_emergencia": "medical|general",',
            '  "nivel": "bajo|medio|alto|critico",',
            '  "gravedad": "leve|moderada|grave|critica",',
            '  "lesiones": ["string"],',
            '  "sintomas": ["string"],',
            '  "requiere_ambulancia": true,',
            '  "resumen": "texto breve en español para operador de emergencias 911"',
            '}',
            'tipo_emergencia debe ser "medical" si hay señales de lesión, enfermedad o emergencia médica visible.',
            contextText ? `Contexto adicional del usuario: ${contextText}` : '',
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

            if (!content) return this.getFallbackTriage(contextText);

            const parsed = JSON.parse(content);
            return { ...parsed, source: 'openai' };
        } catch {
            return { ...this.getFallbackTriage(contextText), source: 'fallback' };
        }
    }
}

module.exports = OpenAIService;
