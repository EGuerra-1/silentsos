const {verifyToken} = require('../auth');
const jwt = require('jsonwebtoken'); // Add this import
/**
 * Middleware to check and verify the JWT token for a specific user type.
 * @param {string} userType - The required user type ('admin' or 'user').
 * @returns {Function} Express middleware.
 */
function checkAuth(userType) {
  return (req, res, next) => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        return res.status(401).json({ error: 'Token not provided' });
      }
      // Expected format: "Bearer <token>"
      const token = authHeader.split(' ')[1];
      const decoded = verifyToken(token, userType);
      req.user = decoded;
      // Check if the token's userType matches the required type
      if (req.user.userType !== userType) {
        return res.status(403).json({ error: 'Unauthorized access' });
      }
      next();
    } catch (error) {
      return res.status(401).json({ error: error.message });
    }
  };
}

/**
 * Middleware to check and verify a JWT token for either user type (admin OR user).
 * Accepts any valid token and does not enforce a specific user type.
 * @returns {Function} Express middleware.
 */
function checkAuthAny() {
  return (req, res, next) => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        return res.status(401).json({ error: 'Token not provided' });
      }
      const token = authHeader.split(' ')[1];

      // Decode the token without verifying to extract the userType from the payload
      const payload = jwt.decode(token);
      if (!payload || !payload.userType) {
        return res.status(401).json({ error: 'Invalid token payload' });
      }

      // Now verify the token with the userType from the payload using Auth.verifyToken
      const decoded = verifyToken(token, payload.userType);
      req.user = decoded;
      // No specific role check, we accept any valid token
      next();
    } catch (error) {
      return res.status(401).json({ error: error.message });
    }
  };
}
module.exports = {checkAuthAny, checkAuth};