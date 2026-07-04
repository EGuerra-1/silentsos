const bcrypt = require('bcrypt');

const saltRounds = 10;

/**
 * Encrypts (hashes) a plain text password.
 *
 * @param {string} plainPassword - The plain text password to encrypt.
 * @returns {Promise<string>} - The hashed password.
 * @throws {Error} If an error occurs during hashing.
 */
async function encryptPassword(plainPassword) {
    try {
        const hashedPassword = await bcrypt.hash(plainPassword, saltRounds);
        return hashedPassword;
    } catch (error) {
        throw new Error('Error encrypting password: ' + error.message);
    }
}

/**
 * Compares a plain text password with a hashed password.
 *
 * @param {string} plainPassword - The plain text password.
 * @param {string} hashedPassword - The hashed password.
 * @returns {Promise<boolean>} - True if they match, false otherwise.
 * @throws {Error} If an error occurs during comparison.
 */
async function comparePassword(plainPassword, hashedPassword) {
    try {
        return await bcrypt.compare(plainPassword, hashedPassword);
    } catch (error) {
        throw new Error('Error comparing passwords: ' + error.message);
    }
}

module.exports = { encryptPassword, comparePassword };