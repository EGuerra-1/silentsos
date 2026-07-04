const express = require('express');
const router = express.Router();
const { login } = require('../controllers/auth.controller');
const validateRequest = require('../utils/validateRequest');
const loginSchema = require('../validations/auth.schema.js');

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login to obtain a JWT token.
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: "#/components/schemas/Login"
 *     responses:
 *       200:
 *         description: Login successful, returns a JWT token and user info.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token:
 *                   type: string
 *                 user:
 *                   $ref: "#/components/schemas/User"
 *       401:
 *         description: Invalid credentials.
 */
router.post('/login', validateRequest(loginSchema), login);

module.exports = router;