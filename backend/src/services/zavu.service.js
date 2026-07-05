const { integrations } = require('../config/integrations');

class ZavuService {
    static getHeaders() {
        if (!integrations.zavu.configured()) {
            throw new Error('Zavu no esta configurado. Revisa ZAVU_API_KEY en .env');
        }

        const headers = {
            Authorization: `Bearer ${process.env.ZAVU_API_KEY}`,
            'Content-Type': 'application/json',
        };

        const senderId = integrations.zavu.senderId();
        if (senderId) {
            // Permite forzar el Sender configurado en Zavu para esta app.
            headers['Zavu-Sender'] = senderId;
        }

        return headers;
    }

    static async sendMessage({ to, text, channel, subject }) {
        // API unificada: mismo payload para SMS/WhatsApp (según canal configurado).
        const payload = {
            to,
            text,
            channel: channel || integrations.zavu.defaultChannel(),
        };

        if (subject) {
            payload.subject = subject;
        }

        const response = await fetch(integrations.zavu.apiUrl(), {
            method: 'POST',
            headers: this.getHeaders(),
            body: JSON.stringify(payload),
        });

        const body = await response.json().catch(() => ({}));

        if (!response.ok) {
            throw new Error(`Zavu error (${response.status}): ${JSON.stringify(body)}`);
        }

        return body;
    }

    static async sendEmergencyAlert({ contact, emergencySummary, locationText }) {
        // Formato estándar de notificación para contactos de emergencia.
        const text = [
            'ALERTA SilentSOS',
            `Contacto: ${contact.full_name} (${contact.relationship})`,
            `Resumen: ${emergencySummary}`,
            locationText ? `Ubicacion: ${locationText}` : null,
        ].filter(Boolean).join('\n');

        return this.sendMessage({
            to: contact.cellphone,
            text,
        });
    }
}

module.exports = ZavuService;
