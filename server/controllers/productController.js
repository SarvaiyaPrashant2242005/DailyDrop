// controllers/productController.js
const db = require('../models');
const Product = db.products;
const User = db.users;
const Customer = db.customers;
const v = require('../utils/validator');

// Create product
exports.create = async (req, res) => {
  try {
    const ownerId = req.userId;
    const { product_name, product_price, product_unit } = req.body;
    const check = v.validateProductCreate(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });

    const product = await Product.create({
      product_name,
      product_price,
      product_unit,
      user_id: ownerId,
    });

    res.status(201).send(product);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Get all products (admin: all, user: own)
exports.findAll = async (req, res) => {
  try {
    const user = await User.findByPk(req.userId);
    const where = user && user.role === 'admin' ? {} : { user_id: req.userId };

    const products = await Product.findAll({ where });
    res.send(products);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Get one product by id (owner or admin)
exports.findOne = async (req, res) => {
  try {
    const user = await User.findByPk(req.userId);
    const product = await Product.findByPk(req.params.id);

    if (!product) return res.status(404).send({ message: 'Product not found' });

    if (user.role !== 'admin' && product.user_id !== req.userId) {
      return res.status(403).send({ message: 'Forbidden' });
    }

    res.send(product);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Update product (owner or admin)
exports.update = async (req, res) => {
  try {
    const user = await User.findByPk(req.userId);
    const product = await Product.findByPk(req.params.id);
    if (!product) return res.status(404).send({ message: 'Product not found' });

    if (user.role !== 'admin' && product.user_id !== req.userId) {
      return res.status(403).send({ message: 'Forbidden' });
    }

    const check = v.validateProductUpdate(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });
    const { product_name, product_price, product_unit } = req.body;
    await product.update({ product_name, product_price, product_unit });
    res.send({ message: 'Product updated successfully' });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Delete product (owner or admin)
exports.delete = async (req, res) => {
  try {
    const user = await User.findByPk(req.userId);
    const product = await Product.findByPk(req.params.id);
    if (!product) return res.status(404).send({ message: 'Product not found' });

    if (user.role !== 'admin' && product.user_id !== req.userId) {
      return res.status(403).send({ message: 'Forbidden' });
    }

    await product.destroy();
    res.send({ message: 'Product deleted successfully' });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Get products by customer_id (owner or admin)
exports.findByCustomerId = async (req, res) => {
  try {
    const customer = await Customer.findByPk(req.params.customer_id);
    if (!customer) return res.status(404).send({ message: 'Customer not found' });

    const requester = await User.findByPk(req.userId);
    const isAdmin = requester && requester.role === 'admin';
    if (!isAdmin && customer.user_id !== req.userId) {
      return res.status(403).send({ message: 'Forbidden' });
    }

    const products = await Product.findAll({ where: { user_id: customer.user_id } });
    res.send(products);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};
