const controller = require('../controllers/customerController');
const { verifyToken } = require('../middleware/auth');

module.exports = function(app) {
  app.post('/api/customers', [verifyToken], controller.create);
  app.get('/api/customers', [verifyToken], controller.findAll);
  app.get('/api/customers/:id', [verifyToken], controller.findOne);
  app.put('/api/customers/:id', [verifyToken], controller.update);
  app.delete('/api/customers/:id', [verifyToken], controller.delete);
  app.get('/api/customers/by-user/:user_id', [verifyToken], controller.findByUserId);
};
