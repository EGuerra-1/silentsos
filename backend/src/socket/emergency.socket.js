const { verifyToken } = require('../auth');
const TwilioStreamService = require('../services/twilio-stream.service');
const GestureService = require('../services/gesture.service');

// Mapa emergencyId → socket de Flutter para enviar eventos en tiempo real.
const emergencySocketMap = new Map();

function getSocketByEmergency(emergencyId) {
    return emergencySocketMap.get(emergencyId) || null;
}

function setupEmergencySocket(io) {
    io.on('connection', (socket) => {
        let joinedEmergencyId = null;

        // Flutter se une al canal de su emergencia enviando su token JWT.
        socket.on('join_emergency', ({ emergency_id, token }) => {
            try {
                const decoded = verifyToken(token, 'user');
                if (!decoded?.id) {
                    socket.emit('error', { message: 'Token inválido' });
                    return;
                }

                joinedEmergencyId = emergency_id;
                emergencySocketMap.set(emergency_id, socket);

                // Vincula este socket al stream de Twilio si ya está activo.
                TwilioStreamService.linkSocket(emergency_id, socket);

                socket.emit('joined', { emergency_id, user_id: decoded.id });
            } catch {
                socket.emit('error', { message: 'Autenticación fallida' });
            }
        });

        // Flutter envía gesto → backend lo convierte a voz y lo inyecta en Twilio.
        socket.on('gesture', async ({ gesture }) => {
            if (!joinedEmergencyId) {
                socket.emit('error', { message: 'No unido a ninguna emergencia' });
                return;
            }

            if (!GestureService.isValid(gesture)) {
                socket.emit('error', { message: `Gesto desconocido: ${gesture}` });
                return;
            }

            try {
                const result = await TwilioStreamService.handleGesture(joinedEmergencyId, gesture);
                socket.emit('gesture_sent', result);
            } catch (err) {
                socket.emit('error', { message: err.message });
            }
        });

        socket.on('disconnect', () => {
            if (joinedEmergencyId) {
                emergencySocketMap.delete(joinedEmergencyId);
            }
        });
    });
}

module.exports = { setupEmergencySocket, getSocketByEmergency };
