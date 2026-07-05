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

  static async sendEmergencySmsPayload({ description, nums }) {
    const payload = {
      description,
      nums
    };

    const request = fetch(integrations.n8n.webhookUrl(), {
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
      throw new Error(`n8n webhook error (${response.status}): ${JSON.stringify(body)}`);
    }

    return body;
  }
}

module.exports = N8nService;
