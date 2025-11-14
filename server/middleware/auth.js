// middleware/auth.middleware.js
const jwt = require('jsonwebtoken');
const config = require('../config/authconfig.js');
const db = require('../models');
const User = db.users;

const verifyToken = (req, res, next) => {
  let token = req.headers['authorization']; // Get token from header

  if (!token) {
    return res.status(403).send({ message: 'No token provided!' });
  }

  // Check if token is in "Bearer <token>" format
  if (token.startsWith('Bearer ')) {
    token = token.slice(7, token.length); // Remove "Bearer " prefix
  }

  jwt.verify(token, config.secret, (err, decoded) => {
    if (err) {
      return res.status(401).send({ message: 'Unauthorized! Invalid Token.' });
    }
    // Add the user's ID to the request object for use in controllers
    req.userId = decoded.id; 
    next();
  });
};

// Optional: Middleware to check if the user is an admin
const isAdmin = async (req, res, next) => {
  try {
    const user = await User.findByPk(req.userId);
    if (user && user.role === 'admin') {
      next();
      return;
    }
    res.status(403).send({ message: 'Require Admin Role!' });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

module.exports = {
  verifyToken,
  isAdmin
};