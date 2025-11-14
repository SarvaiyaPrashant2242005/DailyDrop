// controllers/customerProductController.js
const db = require('../models');
const CustomerProduct = db.customer_products;
const Customer = db.customers;
const User = db.users;
const v = require('../utils/validator');

// Helper: ensure ownership or admin
async function ensureAccess(req, customerId) {
  const customer = await Customer.findByPk(customerId);
  if (!customer) return { status: 404, message: 'Customer not found' };
  const requester = await User.findByPk(req.userId);
  const isAdmin = requester && requester.role === 'admin';
  if (!isAdmin && customer.user_id !== req.userId) {
    return { status: 403, message: 'Forbidden' };
  }
  return { ok: true, customer };
}

exports.create = async (req, res) => {
  try {
    const check = v.validateCustomerProductCreate(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });

    const access = await ensureAccess(req, req.body.customer_id);
    if (!access.ok) return res.status(access.status).send({ message: access.message });

    const payload = {
      customer_id: req.body.customer_id,
      product_id: req.body.product_id,
      quantity: req.body.quantity,
      price: req.body.price,
      unit: req.body.unit,
      frequency: req.body.frequency,
      alternate_day_start: req.body.alternate_day_start || null,
      weekly_day: req.body.weekly_day || null,
      monthly_date: req.body.monthly_date || null,
      custom_week_days: req.body.custom_week_days || null,
    };
    const row = await CustomerProduct.create(payload);
    res.status(201).send(row);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

exports.findByCustomer = async (req, res) => {
  try {
    const access = await ensureAccess(req, req.params.customer_id);
    if (!access.ok) return res.status(access.status).send({ message: access.message });

    const rows = await CustomerProduct.findAll({
      where: { customer_id: req.params.customer_id },
      include: [{ model: db.products, as: 'product', attributes: ['id','product_name','product_unit','product_price'] }],
    });
    res.send(rows);
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

exports.update = async (req, res) => {
  try {
    const cp = await CustomerProduct.findByPk(req.params.id);
    if (!cp) return res.status(404).send({ message: 'Record not found' });

    const access = await ensureAccess(req, cp.customer_id);
    if (!access.ok) return res.status(access.status).send({ message: access.message });

    const check = v.validateCustomerProductUpdate(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });

    await cp.update({
      quantity: req.body.quantity ?? cp.quantity,
      price: req.body.price ?? cp.price,
      unit: req.body.unit ?? cp.unit,
      frequency: req.body.frequency ?? cp.frequency,
      alternate_day_start: req.body.alternate_day_start ?? cp.alternate_day_start,
      weekly_day: req.body.weekly_day ?? cp.weekly_day,
      monthly_date: req.body.monthly_date ?? cp.monthly_date,
      custom_week_days: req.body.custom_week_days ?? cp.custom_week_days,
    });
    res.send({ message: 'Updated' });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};

exports.delete = async (req, res) => {
  try {
    const cp = await CustomerProduct.findByPk(req.params.id);
    if (!cp) return res.status(404).send({ message: 'Record not found' });

    const access = await ensureAccess(req, cp.customer_id);
    if (!access.ok) return res.status(access.status).send({ message: access.message });

    await cp.destroy();
    res.send({ message: 'Deleted' });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};