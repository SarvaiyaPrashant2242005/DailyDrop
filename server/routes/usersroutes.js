// routes/user.routes.js
const controller = require('../controllers/userscontroller');
const { verifyToken, isAdmin } = require('../middleware/auth');

module.exports = function(app) {
  // --- Public Routes ---
  app.post('/api/auth/register', controller.register); // Register a new user
  app.post('/api/auth/login', controller.login);       // Log in

  // --- Protected Routes (Require valid token) ---
  
  // Get/Update a single user's info
  app.get('/api/users/:id', [verifyToken], controller.findOne);
  app.put('/api/users/:id', [verifyToken], controller.update);

  // --- Admin-Only Routes (Require admin role) ---
  
  // Get all users
  app.get('/api/users', [verifyToken, isAdmin], controller.findAll);
  
  // Delete a user
  app.delete('/api/users/:id', [verifyToken, isAdmin], controller.delete);
};