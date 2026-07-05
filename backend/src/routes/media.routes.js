const express = require('express');
const path = require('path');
const LocalStorageService = require('../services/local-storage.service');

const router = express.Router();

// Endpoint público para servir archivos locales (audio para Twilio, imágenes para Vision).
router.get('/:folder/:filename', (req, res) => {
    try {
        const { folder, filename } = req.params;
        const filePath = LocalStorageService.resolveFile(folder, filename);

        const ext = path.extname(filename).toLowerCase();
        const contentTypes = {
            '.mp3': 'audio/mpeg',
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.png': 'image/png',
            '.wav': 'audio/wav',
        };

        const contentType = contentTypes[ext] || 'application/octet-stream';
        res.setHeader('Content-Type', contentType);
        res.sendFile(filePath);
    } catch {
        res.status(404).json({ success: false, message: 'Archivo no encontrado' });
    }
});

module.exports = router;
