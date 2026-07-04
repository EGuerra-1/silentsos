const express = require('express');
const {
  getAll,
  save,
  getById,
  update,
  destroy
} = require('../controllers/user.controller');
const {checkAuth, checkAuthAny} = require('../middlewares/checkAuth');
const validateRequest = require('../utils/validateRequest');
const {
  readUserRequestSchema,
  createUserRequestSchema,
  updateUserRequestSchema,
  deleteUserRequestSchema,
} = require('../validations/user.schema');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Users
 *   description: Endpoints related to user operations
 */

/**
 * @swagger
 * /users:
 *   get:
 *     summary: Retrieve all users (admin only)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: A list of users.
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: "#/components/schemas/User"
 */
router.get('/', checkAuth('admin'), getAll);

/**
 * @swagger
 * /users:
 *   post:
 *     summary: Create a new admin user (admin only, role is always 'admin')
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - full_name
 *               - email
 *               - cellphone
 *               - password
 *             properties:
 *               full_name:
 *                 type: string
 *                 example: "Admin User"
 *               email:
 *                 type: string
 *                 example: "admin@gmail.com"
 *               cellphone:
 *                 type: string
 *                 example: "1234567890"
 *               password:
 *                 type: string
 *                 example: "Clave123!"
 *     responses:
 *       201:
 *         description: Admin user created successfully.
 *       400:
 *         description: Email already exists or validation error.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/ErrorResponse"
 */
router.post('/', checkAuth('admin'), validateRequest(createUserRequestSchema), save);

/**
 * @swagger
 * /users/{id}:
 *   get:
 *     summary: Retrieve a user by ID (admin can see all, client only their own profile)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The user ID.
 *     responses:
 *       200:
 *         description: User details.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/User"
 *       403:
 *         description: Unauthorized - cannot view other users.
 *       404:
 *         description: User not found.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/ErrorResponse"
 */
router.get('/:id', checkAuthAny(), validateRequest(readUserRequestSchema), getById);

/**
 * @swagger
 * /users/{id}:
 *   put:
 *     summary: Update a user (admin can update anyone, client only their own, cannot change role)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The user ID.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               full_name:
 *                 type: string
 *                 example: "Daniel Morales"
 *               email:
 *                 type: string
 *                 example: "ale@gmail.com"
 *               cellphone:
 *                 type: string
 *                 example: "1234567890"
 *               password:
 *                 type: string
 *                 example: "Clave123!"
 *     responses:
 *       200:
 *         description: User updated successfully.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/User"
 *       403:
 *         description: Unauthorized - cannot update other users.
 *       404:
 *         description: User not found.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/ErrorResponse"
 */
router.put('/:id', checkAuthAny(), validateRequest(updateUserRequestSchema), update);

/**
 * @swagger
 * /users/{id}:
 *   delete:
 *     summary: Delete a user (admin only)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The user ID.
 *     responses:
 *       200:
 *         description: User deleted successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "User deleted successfully"
 *       404:
 *         description: User not found.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/ErrorResponse"
 */
router.delete('/:id', checkAuth('admin'), validateRequest(deleteUserRequestSchema), destroy);

module.exports = router;
