const jwt = require('jsonwebtoken');

class Auth {
    // Store the secrets for each user type as a static property.
    static secrets = {
        admin: process.env.JWT_SECRET_ADMIN,
        user: process.env.JWT_SECRET_USER,
    };

    /**
     * Validates that the provided user type is allowed.
     * @param {string} userType - The user type ("admin" or "user").
     * @throws {Error} If the user type is invalid.
     */
    static validateUserType(userType) {
        if (!Auth.secrets[userType]) {
            throw new Error(`Invalid user type: ${userType}`);
        }
    }

    /**
     * Generates a JWT token with the provided user data.
     * @param {Object} data - User data (e.g., id, name, etc.).
     * @param {string} userType - The user type ("admin" or "user").
     * @returns {string} A signed JWT token.
     */
    static generateToken(data, userType) {
        Auth.validateUserType(userType);
        const tokenData = { ...data, userType };

        let expiresIn;
        if (userType === 'user') {
            expiresIn = process.env.JWT_EXPIRES_IN_USER;
        } else if (userType === 'admin') {
            expiresIn = process.env.JWT_EXPIRES_IN_ADMIN;
        } else {
            expiresIn = '480m';
        }

        return jwt.sign(tokenData, Auth.secrets[userType], { expiresIn });
    }

    /**
     * Verifies and decodes a JWT token.
     * @param {string} token - The JWT token.
     * @param {string} userType - The expected user type ("admin" or "user").
     * @returns {Object} The decoded token data.
     * @throws {Error} If the token is invalid or expired.
     */
    static verifyToken(token, userType) {
        Auth.validateUserType(userType);
        try {
            return jwt.verify(token, Auth.secrets[userType]);
        } catch (error) {
            throw new Error('Invalid or expired token');
        }
    }
}

module.exports = Auth;