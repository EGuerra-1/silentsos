const { integrations } = require('../config/integrations');

class N8nService {
  static getHeaders() {
    if (!integrations.n8n.configured()) {
      throw new Error('n8n webhook no configurado. Revisa N8N_EMERGENCY_WEBHOOK_URL');
    }

    const headers = {
      'Content-Type': 'application/json'
    };

    const secret = integrations.n8n.webhookSecret();
    if (secret) {
      headers.Authorization = `Bearer ${secret}`;
    }

    return headers;
  }

  // POST genérico a un webhook n8n con timeout, reutilizado por los distintos flujos.
  static async postWebhook(url, payload, label = 'n8n webhook') {
    if (!url) {
      throw new Error(`${label} no configurado en .env`);
    }

    const request = fetch(url, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify(payload)
    });

    const timeout = new Promise((_, reject) => {
      setTimeout(() => reject(new Error(`n8n timeout after ${integrations.n8n.timeoutMs()}ms`)), integrations.n8n.timeoutMs());
    });

    const response = await Promise.race([request, timeout]);
    const body = await response.json().catch(() => ({}));

    if (!response.ok) {
      throw new Error(`${label} error (${response.status}): ${JSON.stringify(body)}`);
    }

    return body;
  }

  static async sendEmergencySmsPayload({ description, nums }) {
    return this.postWebhook(
      integrations.n8n.webhookUrl(),
      { description, nums },
      'n8n emergency webhook'
    );
  }

  // Notifica a los contactos que el usuario tomó su medicamento programado.
  static async sendMedicationTakenPayload({ message, nums }) {
    return this.postWebhook(
      integrations.n8n.medicationWebhookUrl(),
      { message, nums },
      'n8n medication webhook'
    );
  }
}

module.exports = N8nService;
