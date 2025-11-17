// controllers/paymentController.js
const db = require('../models');
const Payment = db.payments;
const Customer = db.customers;
const User = db.users;
const v = require('../utils/validator');

async function isOwnerOrAdmin(userId, ownerId) {
  const user = await User.findByPk(userId);
  if (!user) return false;
  if (user.role === 'admin') return true;
  return userId === ownerId;
}

// Create payment
exports.create = async (req, res) => {
  try {
    const requesterId = req.userId;
    const { customer_id, total_amount, paid_amount } = req.body;
    const check = v.validatePaymentCreate(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });

    const customer = await Customer.findByPk(customer_id);
    if (!customer) return res.status(404).send({ message: 'Customer not found' });

    const allowed = await isOwnerOrAdmin(requesterId, customer.user_id);
    if (!allowed) return res.status(403).send({ message: 'Forbidden' });

    const payment = await Payment.create({ customer_id, total_amount, paid_amount });
    res.status(201).send(payment);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// List payments (admin: all, user: only own customers)
// List payments (admin: all, user: only own customers)
// List payments for the logged-in user's customers
exports.findAll = async (req, res) => {
  try {
    const payments = await Payment.findAll({
      include: [
        {
          model: Customer,
          as: 'customer',
          attributes: [],
          where: { user_id: req.userId },
        },
      ],
    });
    res.send(payments);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};
// Get one payment
exports.findOne = async (req, res) => {
  try {
    const payment = await Payment.findByPk(req.params.id, { include: [{ model: Customer, as: 'customer' }] });
    if (!payment) return res.status(404).send({ message: 'Payment not found' });

    const allowed = await isOwnerOrAdmin(req.userId, payment.customer.user_id);
    if (!allowed) return res.status(403).send({ message: 'Forbidden' });

    res.send(payment);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Update payment
exports.update = async (req, res) => {
  try {
    const payment = await Payment.findByPk(req.params.id, { include: [{ model: Customer, as: 'customer' }] });
    if (!payment) return res.status(404).send({ message: 'Payment not found' });

    const allowed = await isOwnerOrAdmin(req.userId, payment.customer.user_id);
    if (!allowed) return res.status(403).send({ message: 'Forbidden' });

    const { customer_id, total_amount, paid_amount } = req.body;

    if (customer_id) {
      const customer = await Customer.findByPk(customer_id);
      if (!customer) return res.status(404).send({ message: 'Customer not found' });
      const ok = await isOwnerOrAdmin(req.userId, customer.user_id);
      if (!ok) return res.status(403).send({ message: 'Forbidden' });
    }

    await payment.update({ customer_id, total_amount, paid_amount });
    res.send({ message: 'Payment updated successfully' });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Delete payment
exports.delete = async (req, res) => {
  try {
    const payment = await Payment.findByPk(req.params.id, { include: [{ model: Customer, as: 'customer' }] });
    if (!payment) return res.status(404).send({ message: 'Payment not found' });

    const allowed = await isOwnerOrAdmin(req.userId, payment.customer.user_id);
    if (!allowed) return res.status(403).send({ message: 'Forbidden' });

    await payment.destroy();
    res.send({ message: 'Payment deleted successfully' });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

// Get payments by customer_id (owner or admin)
exports.findByCustomerId = async (req, res) => {
  try {
    const customer = await Customer.findByPk(req.params.customer_id);
    if (!customer) return res.status(404).send({ message: 'Customer not found' });

    const requester = await User.findByPk(req.userId);
    const isAdmin = requester && requester.role === 'admin';
    if (!isAdmin && customer.user_id !== req.userId) {
      return res.status(403).send({ message: 'Forbidden' });
    }

    const payments = await Payment.findAll({ where: { customer_id: req.params.customer_id } });
    res.send(payments);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};
