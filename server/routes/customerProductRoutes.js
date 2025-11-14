const controller = require('../controllers/customerProductController');
const { verifyToken } = require('../middleware/auth');

module.exports = function(app) {
  app.post('/api/customer-products', [verifyToken], controller.create);
  app.get('/api/customer-products/by-customer/:customer_id', [verifyToken], controller.findByCustomer);
  app.put('/api/customer-products/:id', [verifyToken], controller.update);
  app.delete('/api/customer-products/:id', [verifyToken], controller.delete);
};