const { Emergency, Triage, CallHistory, User, EmergencyContact } = require('../models');
const MedicalService = require('./medical.service');
const OpenAIService = require('./openai.service');
const EmergencyOrchestrator = require('./emergency.orchestrator');
const TwilioService = require('./twilio.service');
const N8nService = require('./n8n.service');
const { integrations } = require('../config/integrations');

class EmergencyService {
  static medicalService = new MedicalService();

  static async createEmergency(userId, payload) {
    const emergency = await Emergency.create({
      user_id: userId,
      type: payload.type,
      call_mode: payload.call_mode,
      priority: payload.priority || null,
      latitude: payload.latitude || null,
      longitude: payload.longitude || null,
      address: payload.address || null,
      image_url: payload.image_url || null,
      video_url: payload.video_url || null,
      context_text: payload.context_text || null,
      status: 'PENDING'
    });

    // Se ejecuta en segundo plano para responder rápido al cliente móvil.
    setImmediate(() => {
      this.processEmergency(emergency.id).catch(async (error) => {
        await Emergency.update(
          { status: 'FAILED' },
          { where: { id: emergency.id } }
        );
        await CallHistory.create({
          emergency_id: emergency.id,
          mode: emergency.call_mode,
          status: 'failed_before_call',
          details: {
            error: error.message
          }
        });
      });
    });

    return emergency;
  }

  static async processEmergency(emergencyId) {
    const emergency = await Emergency.findByPk(emergencyId, {
      include: [
        { model: User, as: 'user' }
      ]
    });

    if (!emergency) {
      throw new Error('Emergency not found');
    }
    const contacts = await EmergencyContact.findAll({
      where: { user_id: emergency.user_id }
    });

    await emergency.update({ status: 'ANALYZING' });

    const baseContext = this.buildBaseContext(emergency);
    const triageData = await OpenAIService.analyzeEmergency({
      imageUrl: emergency.image_url,
      contextText: baseContext
    });

    const includeMedicalContext = this.shouldIncludeMedicalContext(emergency.type, triageData);
    const medicalSummary = includeMedicalContext
      ? await this.buildMedicalSummary(emergency.user_id)
      : null;

    const description = this.buildDescription({
      emergency,
      triage: triageData,
      medicalSummary
    });

    const savedTriage = await Triage.create({
      emergency_id: emergency.id,
      level: triageData.nivel || 'medium',
      severity: triageData.gravedad || 'moderate',
      injuries: triageData.lesiones || [],
      symptoms: triageData.sintomas || [],
      requires_ambulance: Boolean(triageData.requiere_ambulancia),
      summary: triageData.resumen || description,
      source: triageData.source || 'openai'
    });

    await emergency.update({
      status: 'TRIAGE_GENERATED',
      description
    });

    const audio = await EmergencyOrchestrator.generateEmergencyAudio(description);
    const audioUrl = audio.url || `${integrations.publicUrl.value()}${audio.publicPath}`;

    await emergency.update({
      status: 'AUDIO_GENERATED',
      audio_url: audioUrl
    });

    const callHistory = await CallHistory.create({
      emergency_id: emergency.id,
      mode: emergency.call_mode,
      status: 'queued',
      details: {
        triage_id: savedTriage.id,
        sms: {
          nums: this.extractContactNumbers(contacts),
          description
        }
      }
    });

    const twimlUrl = `${integrations.publicUrl.value()}/api/twilio/twiml/${emergency.id}`;
    const statusCallbackUrl = `${integrations.publicUrl.value()}/api/twilio/status/${emergency.id}`;
    const call = await TwilioService.makeCall({
      twimlUrl,
      statusCallbackUrl
    });

    await callHistory.update({
      twilio_call_sid: call.sid,
      status: call.status || 'initiated',
      started_at: new Date(),
      details: {
        ...(callHistory.details || {}),
        call: {
          sid: call.sid,
          to: call.to,
          from: call.from
        }
      }
    });

    await emergency.update({ status: 'CALL_STARTED' });

    const nums = this.extractContactNumbers(contacts);
    if (nums.length === 0) {
      return;
    }

    try {
      const n8nResponse = await N8nService.sendEmergencySmsPayload({ description, nums });
      await callHistory.update({
        details: {
          ...(callHistory.details || {}),
          sms: {
            ...(callHistory.details?.sms || {}),
            initial: { success: true, response: n8nResponse },
            retry_on_call_started: false
          }
        }
      });
      await emergency.update({ status: 'SMS_SENT' });
    } catch (error) {
      await callHistory.update({
        details: {
          ...(callHistory.details || {}),
          sms: {
            ...(callHistory.details?.sms || {}),
            initial: { success: false, error: error.message },
            retry_on_call_started: true
          }
        }
      });
    }
  }

  static async handleTwilioStatusCallback(emergencyId, payload) {
    const emergency = await Emergency.findByPk(emergencyId);
    if (!emergency) {
      return;
    }

    const callHistory = await CallHistory.findOne({
      where: { emergency_id: emergencyId },
      order: [['created_at', 'DESC']]
    });

    if (!callHistory) {
      return;
    }

    const callStatus = payload.CallStatus || payload.CallStatusCallbackEvent || 'unknown';
    const details = callHistory.details || {};
    const smsDetails = details.sms || {};

    const shouldRetrySms =
      callStatus === 'in-progress' &&
      smsDetails.retry_on_call_started === true &&
      Array.isArray(smsDetails.nums) &&
      smsDetails.nums.length > 0 &&
      typeof smsDetails.description === 'string';

    if (shouldRetrySms) {
      try {
        const retryResponse = await N8nService.sendEmergencySmsPayload({
          description: smsDetails.description,
          nums: smsDetails.nums
        });

        details.sms = {
          ...smsDetails,
          retry: { success: true, response: retryResponse },
          retry_on_call_started: false
        };
        await emergency.update({ status: 'SMS_SENT' });
      } catch (error) {
        details.sms = {
          ...smsDetails,
          retry: { success: false, error: error.message },
          retry_on_call_started: false
        };
      }
    }

    await callHistory.update({
      status: callStatus,
      ended_at: ['completed', 'busy', 'failed', 'no-answer', 'canceled'].includes(callStatus)
        ? new Date()
        : callHistory.ended_at,
      details: {
        ...details,
        twilio_callback: payload
      }
    });

    if (['completed', 'busy', 'failed', 'no-answer', 'canceled'].includes(callStatus)) {
      const finalStatus = callStatus === 'completed' ? 'COMPLETED' : 'FAILED';
      await emergency.update({ status: finalStatus });
    }
  }

  static async getEmergencyById(emergencyId, user) {
    const emergency = await Emergency.findByPk(emergencyId, {
      include: [
        { model: Triage, as: 'triage' },
        { model: CallHistory, as: 'callHistories' }
      ]
    });

    if (!emergency) {
      return null;
    }

    // Admin puede consultar cualquiera; usuario normal solo sus propias emergencias.
    if (user.userType !== 'admin' && emergency.user_id !== user.id) {
      return 'forbidden';
    }

    return emergency;
  }

  static buildBaseContext(emergency) {
    const pieces = [
      `Emergency type: ${emergency.type}`,
      emergency.priority ? `Priority: ${emergency.priority}` : null,
      emergency.context_text ? `User context: ${emergency.context_text}` : null,
      emergency.address ? `Address: ${emergency.address}` : null,
      emergency.latitude && emergency.longitude
        ? `Coordinates: ${emergency.latitude}, ${emergency.longitude}`
        : null
    ].filter(Boolean);

    return pieces.join('\n');
  }

  static shouldIncludeMedicalContext(type, triageData) {
    if (type === 'medical') {
      return true;
    }

    const severity = String(triageData?.gravedad || '').toLowerCase();
    const requiresAmbulance = Boolean(triageData?.requiere_ambulancia);
    return requiresAmbulance || ['grave', 'critica', 'critical', 'severe'].includes(severity);
  }

  static async buildMedicalSummary(userId) {
    const diseases = await this.medicalService.getUserDiseases(userId);
    const medications = await this.medicalService.getMedications(userId);
    const pending = await this.medicalService.getPendingMedicationsToday(userId);

    const diseaseNames = diseases
      .map((item) => item?.diseaseCatalog?.name)
      .filter(Boolean);

    const medicationNames = medications
      .flatMap((plan) => plan.versions || [])
      .filter((version) => version.is_current)
      .map((version) => `${version.name} ${version.dose}${version.unit ? ` ${version.unit}` : ''}`.trim())
      .filter(Boolean);

    const pendingCount = pending?.total_pending || 0;

    const lines = [
      diseaseNames.length > 0 ? `Chronic conditions: ${diseaseNames.join(', ')}.` : null,
      medicationNames.length > 0 ? `Current medication: ${medicationNames.join(', ')}.` : null,
      pendingCount > 0 ? `Pending medication doses today: ${pendingCount}.` : null
    ].filter(Boolean);

    return lines.length > 0 ? lines.join(' ') : 'No relevant medical records found.';
  }

  static buildDescription({ emergency, triage, medicalSummary }) {
    const user = emergency.user;
    const summary = triage.resumen || 'Emergency reported without detailed triage summary.';

    const parts = [
      `Emergency report for ${user.full_name}.`,
      `Type: ${emergency.type}.`,
      emergency.address ? `Address: ${emergency.address}.` : null,
      emergency.latitude && emergency.longitude
        ? `Coordinates: ${emergency.latitude}, ${emergency.longitude}.`
        : null,
      emergency.context_text ? `User context: ${emergency.context_text}.` : null,
      `Triage summary: ${summary}`,
      medicalSummary ? `Medical background: ${medicalSummary}` : null
    ].filter(Boolean);

    return parts.join(' ');
  }

  static extractContactNumbers(contacts = []) {
    const unique = new Set(
      contacts
        .map((contact) => String(contact.cellphone || '').trim())
        .filter(Boolean)
    );

    return Array.from(unique);
  }
}

module.exports = EmergencyService;
