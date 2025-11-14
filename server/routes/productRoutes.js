const controller = require('../controllers/productController');
const { verifyToken } = require('../middleware/auth');

module.exports = function(app) {
  app.post('/api/products', [verifyToken], controller.create);
  app.get('/api/products', [verifyToken], controller.findAll);
  app.get('/api/products/:id', [verifyToken], controller.findOne);
  app.put('/api/products/:id', [verifyToken], controller.update);
  app.delete('/api/products/:id', [verifyToken], controller.delete);
  app.get('/api/products/by-customer/:customer_id', [verifyToken], controller.findByCustomerId);
};
