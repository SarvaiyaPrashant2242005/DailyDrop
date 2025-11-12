const controller = require('../controllers/deliveryController');
const { verifyToken } = require('../middleware/auth');

module.exports = function(app) {
  app.post('/api/deliveries', [verifyToken], controller.create);
  app.get('/api/deliveries', [verifyToken], controller.findAll);
  app.get('/api/deliveries/:id', [verifyToken], controller.findOne);
  app.put('/api/deliveries/:id', [verifyToken], controller.update);
  app.delete('/api/deliveries/:id', [verifyToken], controller.delete);
};
