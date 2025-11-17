// controllers/deliveryController.js
const db = require('../models');
const Delivery = db.deliveries;
const Customer = db.customers;
const Product = db.products;
const User = db.users;
const v = require('../utils/validator');

// Helper: check ownership or admin
async function isOwnerOrAdmin(userId, resourceOwnerId) {
  const user = await User.findByPk(userId);
  if (!user) return false;
  if (user.role === 'admin') return true;
  return userId === resourceOwnerId;
}

// Create delivery
exports.create = async (req, res) => {
  try {
    const requesterId = req.userId;
    const { customer_id, product_id, product_quantity, delivery_day } = req.body;
    const check = v.validateDeliveryCreate(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });

    const customer = await Customer.findByPk(customer_id);
    const product = await Product.findByPk(product_id);
    if (!customer) return res.status(404).send({ message: 'Customer not found' });
    if (!product) return res.status(404).send({ message: 'Product not found' });

    const allowedForCustomer = await isOwnerOrAdmin(requesterId, customer.user_id);
    const allowedForProduct = await isOwnerOrAdmin(requesterId, product.user_id);
    if (!allowedForCustomer || !allowedForProduct) {
      return res.status(403).send({ message: 'Forbidden' });
    }

    const delivery = await Delivery.create({ customer_id, product_id, product_quantity, delivery_day });
    res.status(201).send(delivery);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// List deliveries (admin: all, user: only own via joins)
// List deliveries for the logged-in user's customers
exports.findAll = async (req, res) => {
  try {
    const include = [
      {
        model: Customer,
        as: 'customer',
        attributes: [],
        where: { user_id: req.userId },
      },
      { model: Product, as: 'product' },
    ];

    const deliveries = await Delivery.findAll({ include });
    res.send(deliveries);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Get one delivery
exports.findOne = async (req, res) => {
  try {
    const delivery = await Delivery.findByPk(req.params.id, { include: [ { model: Customer, as: 'customer' }, { model: Product, as: 'product' } ] });
    if (!delivery) return res.status(404).send({ message: 'Delivery not found' });

    const allowed = await isOwnerOrAdmin(req.userId, delivery.customer.user_id);
    if (!allowed) return res.status(403).send({ message: 'Forbidden' });

    res.send(delivery);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Update delivery
exports.update = async (req, res) => {
  try {
    const delivery = await Delivery.findByPk(req.params.id, { include: [{ model: Customer, as: 'customer' }] });
    if (!delivery) return res.status(404).send({ message: 'Delivery not found' });

    const allowed = await isOwnerOrAdmin(req.userId, delivery.customer.user_id);
    if (!allowed) return res.status(403).send({ message: 'Forbidden' });

    const { customer_id, product_id, product_quantity, delivery_day } = req.body;
    const check = v.validateDeliveryUpdate(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });

    if (customer_id) {
      const customer = await Customer.findByPk(customer_id);
      if (!customer) return res.status(404).send({ message: 'Customer not found' });
      const ok = await isOwnerOrAdmin(req.userId, customer.user_id);
      if (!ok) return res.status(403).send({ message: 'Forbidden' });
    }

    if (product_id) {
      const product = await Product.findByPk(product_id);
      if (!product) return res.status(404).send({ message: 'Product not found' });
      const ok = await isOwnerOrAdmin(req.userId, product.user_id);
      if (!ok) return res.status(403).send({ message: 'Forbidden' });
    }

    await delivery.update({ customer_id, product_id, product_quantity, delivery_day });
    res.send({ message: 'Delivery updated successfully' });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Delete delivery
exports.delete = async (req, res) => {
  try {
    const delivery = await Delivery.findByPk(req.params.id, { include: [{ model: Customer, as: 'customer' }] });
    if (!delivery) return res.status(404).send({ message: 'Delivery not found' });

    const allowed = await isOwnerOrAdmin(req.userId, delivery.customer.user_id);
    if (!allowed) return res.status(403).send({ message: 'Forbidden' });

    await delivery.destroy();
    res.send({ message: 'Delivery deleted successfully' });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};
