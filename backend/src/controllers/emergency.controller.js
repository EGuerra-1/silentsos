const multer = require('multer');
const path = require('path');
const sharp = require('sharp');
const catchErrors = require('../utils/tryCatch');
const ApiResponse = require('../utils/apiResponse');
const EmergencyService = require('../services/emergency.service');

// Multer guarda imágenes en memoria para pasarlas a LocalStorageService.
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB por imagen
    fileFilter(req, file, cb) {
        const allowed = ['.jpg', '.jpeg', '.png'];
        const ext = path.extname(file.originalname).toLowerCase();
        if (allowed.includes(ext)) {
            cb(null, true);
        } else {
            cb(new Error('Solo se aceptan imágenes JPG o PNG'));
        }
    },
});

// Middleware para las dos imágenes del flujo contextual.
const uploadContextualImages = upload.fields([
    { name: 'front_image', maxCount: 1 },
    { name: 'back_image', maxCount: 1 },
]);

class EmergencyController {
    static routes = '/emergencies';

    // Fotos de celular pueden pesar varios MB y tardar en subir a OpenAI, arriesgando el
    // timeout de Vision. Se redimensionan y comprimen antes de enviarlas (mismo formato JPEG).
    static async compressImageForVision(buffer) {
        try {
            return await sharp(buffer)
                .rotate() // corrige orientación EXIF de fotos tomadas con el celular en distintos ángulos
                .resize({ width: 1024, height: 1024, fit: 'inside', withoutEnlargement: true })
                .jpeg({ quality: 75 })
                .toBuffer();
        } catch (err) {
            console.error('No se pudo comprimir la imagen, se usa el original:', err.message);
            return buffer;
        }
    }

    static createUrgency = catchErrors(async (req, res) => {
        const emergency = await EmergencyService.createUrgency(req.user.id, req.body);
        return ApiResponse.success(res, {
            route: `${this.routes}/urgency`,
            message: 'Emergency accepted and processing in background',
            status: 202,
            data: emergency,
        });
    });

    static uploadContextualImages = uploadContextualImages;

    static createContextual = catchErrors(async (req, res) => {
        const files = req.files || {};

        if (!files.front_image?.[0] || !files.back_image?.[0]) {
            return ApiResponse.error(res, {
                route: `${this.routes}/contextual`,
                message: 'front_image y back_image son requeridas',
                error: 'Imágenes faltantes',
                status: 400,
            });
        }

        const frontFile = files.front_image[0];
        const backFile  = files.back_image[0];

        // Redimensiona/comprime en memoria antes de enviar a OpenAI: acelera el análisis
        // y evita que fotos pesadas de celular agoten el timeout de Vision.
        const [frontBuffer, backBuffer] = await Promise.all([
            this.compressImageForVision(frontFile.buffer),
            this.compressImageForVision(backFile.buffer),
        ]);

        // Las imágenes se convierten a base64 en memoria y se envían directo a OpenAI.
        // No se guarda nada en disco para conservar espacio.
        const payload = {
            ...req.body,
            front_image_base64: frontBuffer.toString('base64'),
            front_image_mime:   'image/jpeg',
            back_image_base64:  backBuffer.toString('base64'),
            back_image_mime:    'image/jpeg',
        };

        const emergency = await EmergencyService.createContextual(req.user.id, payload);
        return ApiResponse.success(res, {
            route: `${this.routes}/contextual`,
            message: 'Emergency accepted and processing in background',
            status: 202,
            data: emergency,
        });
    });

    static getById = catchErrors(async (req, res) => {
        const result = await EmergencyService.getEmergencyById(req.params.id, req.user);

        if (!result) {
            return ApiResponse.error(res, {
                route: `${this.routes}/${req.params.id}`,
                message: 'Emergency not found',
                error: 'Not found',
                status: 404,
            });
        }

        if (result === 'forbidden') {
            return ApiResponse.error(res, {
                route: `${this.routes}/${req.params.id}`,
                message: 'Unauthorized',
                error: 'Forbidden',
                status: 403,
            });
        }

        return ApiResponse.success(res, {
            route: `${this.routes}/${req.params.id}`,
            message: 'Emergency details',
            data: result,
        });
    });
}

module.exports = EmergencyController;
