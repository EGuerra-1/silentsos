const fs = require('fs');
const path = require('path');
const { randomUUID } = require('crypto');
const { S3Client, PutObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const { integrations, ensureLocalStorage, getLocalStoragePath } = require('../config/integrations');

class AwsS3Service {
    static isConfigured() {
        return integrations.awsS3.configured();
    }

    static getClient() {
        if (!this.isConfigured()) {
            return null;
        }

        return new S3Client({
            region: integrations.awsS3.region(),
            credentials: {
                accessKeyId: process.env.AWS_ACCESS_KEY_ID,
                secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
            },
        });
    }

    static saveLocal({ buffer, folder, filename, contentType }) {
        // Fallback local para desarrollo cuando aún no existe configuración AWS.
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
            publicPath: `/api/dev/media/${folder}/${safeFilename}`,
        };
    }

    static async upload({ buffer, folder = 'media', filename, contentType = 'application/octet-stream' }) {
        const safeFilename = filename || `${randomUUID()}`;
        const key = `${folder}/${safeFilename}`;

        if (!this.isConfigured()) {
            return this.saveLocal({ buffer, folder, filename: safeFilename, contentType });
        }

        // En producción sube a S3 y devuelve URL firmada temporal para consumo inmediato.
        const client = this.getClient();
        await client.send(new PutObjectCommand({
            Bucket: integrations.awsS3.bucket(),
            Key: key,
            Body: buffer,
            ContentType: contentType,
        }));

        const signedUrl = await getSignedUrl(
            client,
            new GetObjectCommand({
                Bucket: integrations.awsS3.bucket(),
                Key: key,
            }),
            { expiresIn: 3600 }
        );

        return {
            storage: 's3',
            key,
            bucket: integrations.awsS3.bucket(),
            contentType,
            url: signedUrl,
        };
    }

    static resolveLocalFile(folder, filename) {
        // Evita path traversal validando que el archivo quede dentro del storage local.
        const filePath = path.join(getLocalStoragePath(), folder, filename);

        if (!filePath.startsWith(getLocalStoragePath())) {
            throw new Error('Ruta de archivo invalida');
        }

        if (!fs.existsSync(filePath)) {
            throw new Error('Archivo no encontrado');
        }

        return filePath;
    }
}

module.exports = AwsS3Service;
