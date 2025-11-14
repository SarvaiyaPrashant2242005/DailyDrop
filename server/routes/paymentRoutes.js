const controller = require('../controllers/paymentController');
const { verifyToken } = require('../middleware/auth');

module.exports = function(app) {
  app.post('/api/payments', [verifyToken], controller.create);
  app.get('/api/payments', [verifyToken], controller.findAll);
  app.get('/api/payments/:id', [verifyToken], controller.findOne);
  app.put('/api/payments/:id', [verifyToken], controller.update);
  app.delete('/api/payments/:id', [verifyToken], controller.delete);
  app.get('/api/payments/by-customer/:customer_id', [verifyToken], controller.findByCustomerId);
};
