const { Op } = require('sequelize');
const { Emergency, Triage, CallHistory, User, EmergencyContact } = require('../models');
const MedicalService = require('./medical.service');
const OpenAIService = require('./openai.service');
const ElevenLabsService = require('./elevenlabs.service');
const LocalStorageService = require('./local-storage.service');
const TwilioService = require('./twilio.service');
const TwilioStreamService = require('./twilio-stream.service');
const N8nService = require('./n8n.service');
const { integrations } = require('../config/integrations');

// Map temporal en memoria: emergencyId → datos de imagen base64.
// Se limpia automáticamente al terminar el procesamiento.
const pendingImageData = new Map();

const DISPLAY_STATUS = {
    PENDING: 'Preparando emergencia...',
    ANALYZING: 'Analizando situación...',
    TRIAGE_GENERATED: 'Generando mensaje...',
    AUDIO_GENERATED: 'Preparando audio...',
    CALL_STARTED: 'Contactando emergencias...',
    SMS_SENT: 'Notificando contactos...',
    COMPLETED: 'Llamada finalizada',
    FAILED: 'Error en la llamada',
};

class EmergencyService {
    static medicalService = new MedicalService();

    // --- CREACIÓN ---

    // Evita doble disparo si el usuario presiona SOS varias veces en pocos segundos:
    // reutiliza una emergencia activa (no COMPLETED/FAILED) creada en los últimos 60s.
    static DUPLICATE_GUARD_WINDOW_MS = 60 * 1000;

    static async _findRecentActiveEmergency(userId) {
        return Emergency.findOne({
            where: {
                user_id: userId,
                status: { [Op.notIn]: ['COMPLETED', 'FAILED'] },
                created_at: { [Op.gte]: new Date(Date.now() - this.DUPLICATE_GUARD_WINDOW_MS) },
            },
            order: [['created_at', 'DESC']],
        });
    }

    static async createUrgency(userId, payload) {
        const existing = await this._findRecentActiveEmergency(userId);
        if (existing) {
            return existing;
        }

        const emergency = await Emergency.create({
            user_id: userId,
            type: payload.type,
            call_mode: 'single_context',
            priority: payload.priority || null,
            latitude: payload.latitude,
            longitude: payload.longitude,
            address: payload.address || null,
            status: 'PENDING',
        });

        // Procesamiento asíncrono: responde 202 de inmediato a Flutter.
        setImmediate(() =>
            this.processUrgency(emergency.id).catch((err) =>
                this._markFailed(emergency.id, 'single_context', err.message)
            )
        );

        return emergency;
    }

    static async createContextual(userId, payload) {
        const existing = await this._findRecentActiveEmergency(userId);
        if (existing) {
            return existing;
        }

        // type se setea a 'general' como placeholder; Vision lo actualizará tras analizar.
        const emergency = await Emergency.create({
            user_id: userId,
            type: 'general',
            call_mode: payload.call_mode,
            priority: null,
            latitude: payload.latitude,
            longitude: payload.longitude,
            address: payload.address || null,
            context_text: payload.context_text || null,
            status: 'PENDING',
        });

        // Guarda los datos de imagen en memoria para el proceso en background.
        // No se persisten en BD ni en disco.
        if (payload.front_image_base64) {
            pendingImageData.set(emergency.id, {
                frontBase64: payload.front_image_base64,
                frontMime:   payload.front_image_mime || 'image/jpeg',
                backBase64:  payload.back_image_base64 || null,
                backMime:    payload.back_image_mime || 'image/jpeg',
            });
        }

        setImmediate(() =>
            this.processContextual(emergency.id).catch((err) =>
                this._markFailed(emergency.id, emergency.call_mode, err.message)
            )
        );

        return emergency;
    }

    // --- PIPELINE URGENCIA (sin OpenAI, texto directo) ---

    static async processUrgency(emergencyId) {
        const emergency = await Emergency.findByPk(emergencyId, {
            include: [{ model: User, as: 'user' }],
        });
        if (!emergency) throw new Error('Emergency not found');

        const contacts = await EmergencyContact.findAll({ where: { user_id: emergency.user_id } });

        await emergency.update({ status: 'ANALYZING' });

        // Carga médica solo si tipo es medical (sin Vision).
        const medicalSummary = emergency.type === 'medical'
            ? await this.buildMedicalSummary(emergency.user_id)
            : null;

        const description = this.buildUrgencyDescription({ emergency, medicalSummary });

        // En urgencia no hay triage de OpenAI; se guarda un triage de fuente "urgency".
        const savedTriage = await Triage.create({
            emergency_id: emergency.id,
            level: emergency.type === 'medical' ? 'alto' : 'medio',
            severity: emergency.type === 'medical' ? 'grave' : 'moderada',
            injuries: [],
            symptoms: [],
            requires_ambulance: emergency.type === 'medical',
            summary: description,
            source: 'urgency',
        });

        await emergency.update({ status: 'TRIAGE_GENERATED', description });

        await this._continueFlow({ emergency, description, savedTriage, contacts });
    }

    // --- PIPELINE CONTEXTUAL (con OpenAI Vision) ---

    static async processContextual(emergencyId) {
        const emergency = await Emergency.findByPk(emergencyId, {
            include: [{ model: User, as: 'user' }],
        });
        if (!emergency) throw new Error('Emergency not found');

        const contacts = await EmergencyContact.findAll({ where: { user_id: emergency.user_id } });

        await emergency.update({ status: 'ANALYZING' });

        // Recupera y limpia el buffer base64 del Map en memoria.
        const imgData = pendingImageData.get(emergencyId);
        pendingImageData.delete(emergencyId);

        const triageData = await OpenAIService.analyzeEmergency({
            frontImageBase64: imgData?.frontBase64 || null,
            frontMime:        imgData?.frontMime || 'image/jpeg',
            backImageBase64:  imgData?.backBase64 || null,
            backMime:         imgData?.backMime || 'image/jpeg',
            contextText:      emergency.context_text || '',
        });

        // Vision detecta el tipo; sobreescribe el placeholder 'general'.
        const detectedType = triageData.tipo_emergencia === 'medical' ? 'medical' : 'general';
        await emergency.update({ type: detectedType });
        emergency.type = detectedType;

        const medicalSummary = this.shouldIncludeMedicalContext(detectedType, triageData)
            ? await this.buildMedicalSummary(emergency.user_id)
            : null;

        const description = this.buildContextualDescription({
            emergency,
            triage: triageData,
            medicalSummary,
        });

        const savedTriage = await Triage.create({
            emergency_id: emergency.id,
            level: triageData.nivel || 'medio',
            severity: triageData.gravedad || 'moderada',
            injuries: triageData.lesiones || [],
            symptoms: triageData.sintomas || [],
            requires_ambulance: Boolean(triageData.requiere_ambulancia),
            summary: triageData.resumen || description,
            source: triageData.source || 'openai',
        });

        await emergency.update({ status: 'TRIAGE_GENERATED', description });

        await this._continueFlow({ emergency, description, savedTriage, contacts });
    }

    // --- FLUJO COMPARTIDO (audio + Twilio + n8n) ---

    static async _continueFlow({ emergency, description, savedTriage, contacts }) {
        const audio = await ElevenLabsService.textToSpeech(description);
        const stored = LocalStorageService.save({
            buffer: audio.buffer,
            folder: 'audio',
            filename: `emergency-${emergency.id}.${audio.extension}`,
            contentType: audio.contentType,
        });

        const audioUrl = `${integrations.publicUrl.value()}${stored.publicPath}`;
        await emergency.update({ status: 'AUDIO_GENERATED', audio_url: audioUrl });

        const nums = this.extractContactNumbers(contacts);

        const callHistory = await this._attemptCall({
            emergency,
            triageId: savedTriage.id,
            nums,
            description,
            attempt: 1,
        });

        await emergency.update({ status: 'CALL_STARTED' });

        if (nums.length > 0) {
            try {
                const n8nResponse = await N8nService.sendEmergencySmsPayload({ description, nums });
                await callHistory.update({
                    details: {
                        ...(callHistory.details || {}),
                        sms: {
                            ...(callHistory.details?.sms || {}),
                            initial: { success: true, response: n8nResponse },
                            retry_on_call_started: false,
                        },
                    },
                });
                await emergency.update({ status: 'SMS_SENT' });
            } catch (error) {
                await callHistory.update({
                    details: {
                        ...(callHistory.details || {}),
                        sms: {
                            ...(callHistory.details?.sms || {}),
                            initial: { success: false, error: error.message },
                            retry_on_call_started: true,
                        },
                    },
                });
            }
        }
    }

    // Crea el registro de intento y dispara la llamada de Twilio. Reutilizado por el
    // intento inicial y por los reintentos automáticos en caso de no-answer/busy/failed.
    static async _attemptCall({ emergency, triageId, nums, description, attempt }) {
        const callHistory = await CallHistory.create({
            emergency_id: emergency.id,
            mode: emergency.call_mode,
            status: 'queued',
            details: {
                triage_id: triageId,
                attempt,
                sms: { nums, description },
            },
        });

        const base = integrations.publicUrl.value();
        const twimlUrl = `${base}/api/twilio/twiml/${emergency.id}`;
        const statusCallbackUrl = `${base}/api/twilio/status/${emergency.id}`;
        const fallbackUrl = `${base}/api/twilio/twiml-fallback/${emergency.id}`;

        const call = await TwilioService.makeCall({ twimlUrl, statusCallbackUrl, fallbackUrl });

        await callHistory.update({
            twilio_call_sid: call.sid,
            status: call.status || 'initiated',
            started_at: new Date(),
            details: {
                ...(callHistory.details || {}),
                call: { sid: call.sid, to: call.to, from: call.from },
            },
        });

        return callHistory;
    }

    // Reintento automático: solo procede si no hay ya un intento en curso (anti-duplicado)
    // y la emergencia no llegó a un estado terminal por otra vía mientras esperaba el delay.
    static async _retryCall(emergencyId, attempt) {
        const emergency = await Emergency.findByPk(emergencyId);
        if (!emergency || ['COMPLETED', 'FAILED'].includes(emergency.status)) {
            return;
        }

        const nonTerminalStatuses = ['queued', 'initiated', 'ringing', 'in-progress', 'answered'];
        const activeCall = await CallHistory.findOne({
            where: { emergency_id: emergencyId, status: { [Op.in]: nonTerminalStatuses } },
            order: [['created_at', 'DESC']],
        });
        if (activeCall) {
            return;
        }

        const lastCallHistory = await CallHistory.findOne({
            where: { emergency_id: emergencyId },
            order: [['created_at', 'DESC']],
        });
        const smsDetails = lastCallHistory?.details?.sms || {};

        await this._attemptCall({
            emergency,
            triageId: lastCallHistory?.details?.triage_id || null,
            nums: smsDetails.nums || [],
            description: smsDetails.description || emergency.description,
            attempt,
        });

        await emergency.update({ status: 'CALL_STARTED' });
    }

    static async _markFailed(emergencyId, callMode, errorMessage) {
        await Emergency.update({ status: 'FAILED' }, { where: { id: emergencyId } });
        await CallHistory.create({
            emergency_id: emergencyId,
            mode: callMode || 'single_context',
            status: 'failed_before_call',
            details: { error: errorMessage },
        });
    }

    // --- TWILIO CALLBACKS ---

    static async handleTwilioStatusCallback(emergencyId, payload) {
        const emergency = await Emergency.findByPk(emergencyId);
        if (!emergency) return;

        const callHistory = await CallHistory.findOne({
            where: { emergency_id: emergencyId },
            order: [['created_at', 'DESC']],
        });
        if (!callHistory) return;

        const callStatus = payload.CallStatus || 'unknown';
        const details = callHistory.details || {};
        const smsDetails = details.sms || {};

        const shouldRetrySms =
            callStatus === 'in-progress' &&
            smsDetails.retry_on_call_started === true &&
            Array.isArray(smsDetails.nums) &&
            smsDetails.nums.length > 0;

        if (shouldRetrySms) {
            try {
                const retryResponse = await N8nService.sendEmergencySmsPayload({
                    description: smsDetails.description,
                    nums: smsDetails.nums,
                });
                details.sms = { ...smsDetails, retry: { success: true, response: retryResponse }, retry_on_call_started: false };
                await emergency.update({ status: 'SMS_SENT' });
            } catch (error) {
                details.sms = { ...smsDetails, retry: { success: false, error: error.message }, retry_on_call_started: false };
            }
        }

        const terminalStatuses = ['completed', 'busy', 'failed', 'no-answer', 'canceled'];
        const retryableStatuses = ['no-answer', 'busy', 'failed'];
        const attempt = details.attempt || 1;
        const maxAttempts = integrations.twilio.maxCallAttempts();

        await callHistory.update({
            status: callStatus,
            ended_at: terminalStatuses.includes(callStatus) ? new Date() : callHistory.ended_at,
            details: { ...details, twilio_callback: payload },
        });

        if (terminalStatuses.includes(callStatus)) {
            if (callStatus === 'completed') {
                await emergency.update({ status: 'COMPLETED' });
            } else if (retryableStatuses.includes(callStatus) && attempt < maxAttempts) {
                // No se contestó o falló: reintenta tras un breve delay en vez de marcar FAILED.
                const retryDelayMs = integrations.twilio.callRetryDelayMs();
                setTimeout(() => {
                    this._retryCall(emergencyId, attempt + 1).catch((err) =>
                        console.error('Fallo al reintentar llamada:', err.message)
                    );
                }, retryDelayMs);
            } else {
                await emergency.update({ status: 'FAILED' });
            }
        }
    }

    // --- CONSULTA ---

    static async getEmergencyById(emergencyId, user) {
        const emergency = await Emergency.findByPk(emergencyId, {
            include: [
                { model: Triage, as: 'triage' },
                { model: CallHistory, as: 'callHistories' },
            ],
        });

        if (!emergency) return null;

        // Admin puede consultar cualquier emergencia; usuario solo las propias.
        if (user.userType !== 'admin' && emergency.user_id !== user.id) {
            return 'forbidden';
        }

        const plain = emergency.toJSON();
        plain.display_status = DISPLAY_STATUS[plain.status] || plain.status;
        return plain;
    }

    // --- BUILDERS DE DESCRIPCIÓN ---

    // Formatea coordenadas con 5 decimales (~1 m) para que el TTS las lea claras.
    static buildCoordinatesText(emergency) {
        if (emergency.latitude == null || emergency.longitude == null) {
            return `Coordenadas: NA.`;
        }
        const lat = Number(emergency.latitude).toFixed(5);
        const lng = Number(emergency.longitude).toFixed(5);
        return `Coordenadas: latitud ${lat}, longitud ${lng}.`;
    }

    // El geocoder a veces repite segmentos (ej. "San Salvador, ..., San Salvador").
    // Se eliminan duplicados manteniendo el orden para no leer la ubicación repetida.
    static buildLocationText(address) {
        if (!address || !String(address).trim()) return `Ubicación: NA.`;
        const seen = new Set();
        const parts = String(address)
            .split(',')
            .map((s) => s.trim())
            .filter((s) => s && !seen.has(s.toLowerCase()) && seen.add(s.toLowerCase()));
        return `Ubicación: ${parts.join(', ')}.`;
    }

    static buildUrgencyDescription({ emergency, medicalSummary }) {
        const name = emergency.user?.full_name || 'NA';
        const isMedical = emergency.type === 'medical';

        // Speech corto y directo para el operador del 911 (sin marca del proyecto).
        const parts = [
            `Llamada de emergencia.`,
            `La persona que reporta se llama ${name} y tiene discapacidad auditiva; no puede escuchar ni responder por voz.`,
            `Tipo de emergencia: ${isMedical ? 'médica' : 'general'}.`,
            this.buildLocationText(emergency.address),
            this.buildCoordinatesText(emergency),
            isMedical && medicalSummary ? `Información médica. ${medicalSummary}` : null,
            `Por favor envíe ayuda de inmediato.`,
        ].filter(Boolean);

        return parts.join(' ');
    }

    static buildContextualDescription({ emergency, triage, medicalSummary }) {
        const name = emergency.user?.full_name || 'NA';
        const isMedical = emergency.type === 'medical';
        const summary = triage.resumen || 'NA';

        const parts = [
            `Llamada de emergencia.`,
            `La persona que reporta se llama ${name} y tiene discapacidad auditiva; no puede escuchar ni responder por voz.`,
            `Tipo de emergencia: ${isMedical ? 'médica' : 'general'}.`,
            this.buildLocationText(emergency.address),
            this.buildCoordinatesText(emergency),
            emergency.context_text ? `Contexto del usuario: ${emergency.context_text}.` : null,
            `Situación observada: ${summary}`,
            medicalSummary ? `Información médica. ${medicalSummary}` : null,
            // Se conserva para reactivar el modo interactivo más adelante (hoy no se usa).
            emergency.call_mode === 'interactive'
                ? `El operador puede hacer preguntas de sí o no; el usuario responde con gestos en su teléfono.`
                : null,
            `Por favor envíe ayuda de inmediato.`,
        ].filter(Boolean);

        return parts.join(' ');
    }

    static shouldIncludeMedicalContext(type, triageData) {
        if (type === 'medical') return true;
        const severity = String(triageData?.gravedad || '').toLowerCase();
        const requiresAmbulance = Boolean(triageData?.requiere_ambulancia);
        return requiresAmbulance || ['grave', 'critica', 'critical', 'severe'].includes(severity);
    }

    // En emergencias médicas siempre se incluye este bloque; usa "NA" cuando falta el dato.
    static async buildMedicalSummary(userId) {
        const diseases = await this.medicalService.getUserDiseases(userId);
        const medications = await this.medicalService.getMedications(userId);
        const pending = await this.medicalService.getPendingMedicationsToday(userId);
        const consumedToday = await this.medicalService.getConsumedTodayCount(userId);

        const diseaseNames = diseases.map((d) => d?.diseaseCatalog?.name).filter(Boolean);
        const medicationNames = medications
            .flatMap((plan) => plan.versions || [])
            .filter((v) => v.is_current)
            .map((v) => `${v.name} ${v.dose}${v.unit ? ` ${v.unit}` : ''}`.trim())
            .filter(Boolean);
        const pendingCount = pending?.total_pending || 0;

        const parts = [
            `Padecimientos: ${diseaseNames.length > 0 ? diseaseNames.join(', ') : 'NA'}.`,
            `Medicamentos: ${medicationNames.length > 0 ? medicationNames.join(', ') : 'NA'}.`,
            `Dosis tomadas hoy: ${consumedToday > 0 ? consumedToday : 'NA'}.`,
            `Dosis pendientes hoy: ${pendingCount > 0 ? pendingCount : 'ninguna'}.`,
        ];

        return parts.join(' ');
    }

    static extractContactNumbers(contacts = []) {
        const unique = new Set(
            contacts.map((c) => String(c.cellphone || '').trim()).filter(Boolean)
        );
        return Array.from(unique);
    }
}

module.exports = EmergencyService;
