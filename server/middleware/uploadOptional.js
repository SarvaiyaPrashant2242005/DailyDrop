// middleware/uploadOptional.js
const upload = require('../config/multer');

// Middleware that makes multer optional - handles both multipart and JSON
const uploadOptional = (req, res, next) => {
  const contentType = req.get('Content-Type') || '';
  
  // If it's multipart, use multer
  if (contentType.includes('multipart/form-data')) {
    return upload.single('image')(req, res, next);
  }
  
  // Otherwise, skip multer and continue
  next();
};

module.exports = uploadOptional;
