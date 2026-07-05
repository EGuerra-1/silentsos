// Mapeo de gestos detectados por MediaPipe/Flutter a texto para ElevenLabs.
const GESTURE_MAP = {
    yes: 'Sí, confirmo.',
    no: 'No, no confirmo.',
    help: 'Necesito ayuda urgente, por favor.',
    repeat: 'Por favor repita la pregunta.',
    ambulance: 'Necesito una ambulancia.',
    police: 'Necesito a la policía.',
    ok: 'Estoy bien, gracias.',
    pain: 'Tengo dolor.',
    breathing: 'Tengo dificultad para respirar.',
    alone: 'Estoy solo.',
};

class GestureService {
    static getText(gestureId) {
        return GESTURE_MAP[gestureId] || null;
    }

    static isValid(gestureId) {
        return Object.prototype.hasOwnProperty.call(GESTURE_MAP, gestureId);
    }

    static getAll() {
        return { ...GESTURE_MAP };
    }
}

module.exports = GestureService;
