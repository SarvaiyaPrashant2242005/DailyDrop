const controller = require('../controllers/productController');
const { verifyToken } = require('../middleware/auth');
const uploadOptional = require('../middleware/uploadOptional');

module.exports = function(app) {
  app.post('/api/products', [verifyToken, uploadOptional], controller.create);
  app.get('/api/products', [verifyToken], controller.findAll);
  app.get('/api/products/:id', [verifyToken], controller.findOne);
  app.put('/api/products/:id', [verifyToken, uploadOptional], controller.update);
  app.delete('/api/products/:id', [verifyToken], controller.delete);
  app.get('/api/products/by-customer/:customer_id', [verifyToken], controller.findByCustomerId);
};
