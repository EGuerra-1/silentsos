const express = require('express');
const { sequelize } = require('../models');
const ApiResponse = require('../utils/apiResponse');

const router = express.Router();

router.get('/', async (req, res) => {
    try {
        // Verificar conexión a la base de datos
        await sequelize.authenticate();
        
        return ApiResponse.success(res, {
            message: 'Server is healthy',
            route: '/api/health',
            data: {
                status: 'UP',
                database: 'CONNECTED',
                uptime: process.uptime(),
                timestamp: new Date().toISOString()
            }
        });
    } catch (error) {
        return ApiResponse.error(res, {
            error: error,
            message: 'Server is unhealthy',
            route: '/api/health',
            status: 500
        });
    }
});

module.exports = router;
