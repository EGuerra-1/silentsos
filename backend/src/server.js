const http = require('http');
const { Server: SocketIOServer } = require('socket.io');
const { WebSocketServer } = require('ws');
const app = require('./app');
const dotenv = require('dotenv');
const { setupEmergencySocket } = require('./socket/emergency.socket');
const TwilioStreamService = require('./services/twilio-stream.service');

dotenv.config();

const PORT = process.env.API_PORT || 4000;

// Servidor HTTP base que comparte Socket.io y WebSocket de Twilio.
const server = http.createServer(app);

// Socket.io para comunicación en tiempo real con la app Flutter.
const io = new SocketIOServer(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] },
});
setupEmergencySocket(io);

// WebSocket nativo para Twilio Media Streams (requiere upgrade de protocolo).
const wss = new WebSocketServer({ noServer: true });

wss.on('connection', (ws, req) => {
    // Extrae el emergencyId de la URL: /api/twilio/stream/:emergency_id
    const emergencyId = req.url.split('/').pop();
    let streamSid = null;

    ws.on('message', (raw) => {
        let msg;
        try { msg = JSON.parse(raw); } catch { return; }

        if (msg.event === 'start') {
            streamSid = msg.start?.streamSid;
            TwilioStreamService.register({ emergencyId, ws, streamSid });

            // Vincula socket de Flutter si ya está conectado.
            const { getSocketByEmergency } = require('./socket/emergency.socket');
            const flutterSocket = getSocketByEmergency(emergencyId);
            if (flutterSocket) TwilioStreamService.linkSocket(emergencyId, flutterSocket);
        }

        if (msg.event === 'media' && msg.media?.payload) {
            // Acumula audio µ-law del operador para transcripción con ElevenLabs STT.
            TwilioStreamService.handleMediaChunk(emergencyId, msg.media.payload);
        }

        if (msg.event === 'stop') {
            TwilioStreamService.unregister(emergencyId);
        }
    });

    ws.on('close', () => TwilioStreamService.unregister(emergencyId));
    ws.on('error', () => TwilioStreamService.unregister(emergencyId));
});

// Redirige upgrades de WebSocket de Twilio al servidor ws.
server.on('upgrade', (req, socket, head) => {
    if (req.url?.startsWith('/api/twilio/stream/')) {
        wss.handleUpgrade(req, socket, head, (ws) => {
            wss.emit('connection', ws, req);
        });
    } else {
        socket.destroy();
    }
});

server.listen(PORT, () => {
    console.log(`Servidor HTTP + Socket.io + WS corriendo en http://localhost:${PORT}`);
});
