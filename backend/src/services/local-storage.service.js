const fs = require('fs');
const path = require('path');
const { randomUUID } = require('crypto');
const { ensureLocalStorage, getLocalStoragePath } = require('../config/integrations');

// Almacenamiento en disco local; no se usa AWS S3.
class LocalStorageService {
    static save({ buffer, folder = 'media', filename, contentType }) {
        const targetFolder = ensureLocalStorage(folder);
        const safeFilename = filename || `${randomUUID()}.bin`;
        const filePath = path.join(targetFolder, safeFilename);

        fs.writeFileSync(filePath, buffer);

        return {
            storage: 'local',
            key: path.join(folder, safeFilename).replace(/\\/g, '/'),
            filePath,
            filename: safeFilename,
            contentType,
            // URL pública para que Twilio y OpenAI Vision puedan acceder al archivo.
            publicPath: `/api/media/${folder}/${safeFilename}`,
        };
    }

    static resolveFile(folder, filename) {
        // Previene path traversal validando que el archivo esté dentro de storage/.
        const base = getLocalStoragePath();
        const filePath = path.join(base, folder, filename);

        if (!filePath.startsWith(base)) {
            throw new Error('Ruta de archivo invalida');
        }
        if (!fs.existsSync(filePath)) {
            throw new Error('Archivo no encontrado');
        }

        return filePath;
    }
}

module.exports = LocalStorageService;
