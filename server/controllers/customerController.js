// controllers/customerController.js
const db = require('../models');
const Customer = db.customers;
const User = db.users;
const v = require('../utils/validator');

// Create customer
exports.create = async (req, res) => {
  try {
    const ownerId = req.userId;
    const { customer_name, customer_address, phone_no } = req.body;
    const check = v.validateCustomerCreate(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });

    const customer = await Customer.create({
      customer_name,
      customer_address,
      phone_no,
      user_id: ownerId,
    });

    res.status(201).send(customer);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Get all customers (admin: all, user: own)
exports.findAll = async (req, res) => {
  try {
    const user = await User.findByPk(req.userId);
    const where = user && user.role === 'admin' ? {} : { user_id: req.userId };

    const customers = await Customer.findAll({ where });
    res.send(customers);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Get single customer (owner or admin)
exports.findOne = async (req, res) => {
  try {
    const user = await User.findByPk(req.userId);
    const customer = await Customer.findByPk(req.params.id);
    if (!customer) return res.status(404).send({ message: 'Customer not found' });

    if (user.role !== 'admin' && customer.user_id !== req.userId) {
      return res.status(403).send({ message: 'Forbidden' });
    }

    res.send(customer);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Update customer (owner or admin)
exports.update = async (req, res) => {
  try {
    const user = await User.findByPk(req.userId);
    const customer = await Customer.findByPk(req.params.id);
    if (!customer) return res.status(404).send({ message: 'Customer not found' });

    if (user.role !== 'admin' && customer.user_id !== req.userId) {
      return res.status(403).send({ message: 'Forbidden' });
    }

    const check = v.validateCustomerUpdate(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });
    const { customer_name, customer_address, phone_no } = req.body;
    await customer.update({ customer_name, customer_address, phone_no });
    res.send({ message: 'Customer updated successfully' });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Delete customer (owner or admin)
exports.delete = async (req, res) => {
  try {
    const user = await User.findByPk(req.userId);
    const customer = await Customer.findByPk(req.params.id);
    if (!customer) return res.status(404).send({ message: 'Customer not found' });

    if (user.role !== 'admin' && customer.user_id !== req.userId) {
      return res.status(403).send({ message: 'Forbidden' });
    }

    await customer.destroy();
    res.send({ message: 'Customer deleted successfully' });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Get customers by user_id (admin or same user)
exports.findByUserId = async (req, res) => {
  try {
    const requester = await User.findByPk(req.userId);
    const isAdmin = requester && requester.role === 'admin';
    const targetUserId = parseInt(req.params.user_id, 10);

    if (!isAdmin && requester.id !== targetUserId) {
      return res.status(403).send({ message: 'Forbidden' });
    }

    const customers = await Customer.findAll({ where: { user_id: targetUserId } });
    res.send(customers);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};
