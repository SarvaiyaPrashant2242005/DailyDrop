// controllers/user.controller.js
const db = require('../models');
const config = require('../config/authconfig');
const User = db.users;

const jwt = require('jsonwebtoken');
const v = require('../utils/validator');

// --- CRUD Operations ---

// 1. CREATE a new User (Register)
exports.register = async (req, res) => {
  try {
    const check = v.validateRegister(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });
    const user = await User.create({
      name: req.body.name,
      email: req.body.email,
      password: req.body.password, // Hashing is handled by the model hook
      role: req.body.role || 'admin' // Use provided role or default
    });
    res.status(201).send({ message: 'User registered successfully!' });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

// 2. READ all Users (Protected, Admin-only)
exports.findAll = async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: ['id', 'name', 'email', 'role'] // Exclude password
    });
    res.status(200).send(users);
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

// 3. READ a single User by ID (Protected)
exports.findOne = async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id, {
      attributes: ['id', 'name', 'email', 'role'] // Exclude password
    });
    if (user) {
      res.status(200).send(user);
    } else {
      res.status(404).send({ message: 'User not found.' });
    }
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

// 4. UPDATE a User by ID (Protected)
exports.update = async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) {
      return res.status(404).send({ message: 'User not found.' });
    }

    // Update user fields
    // If a new password is provided, the 'beforeUpdate' hook will hash it
    await user.update(req.body); 
    
    res.send({ message: 'User updated successfully!' });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

// 5. DELETE a User by ID (Protected, Admin-only)
exports.delete = async (req, res) => {
  try {
    const rowsDeleted = await User.destroy({
      where: { id: req.params.id }
    });
    if (rowsDeleted === 1) {
      res.status(200).send({ message: 'User deleted successfully!' });
    } else {
      res.status(404).send({ message: 'User not found.' });
    }
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

// --- Authentication ---

exports.login = async (req, res) => {
  try {
    const check = v.validateLogin(req.body);
    if (!check.ok) return res.status(400).send({ message: 'Validation error', errors: check.errors });
    const user = await User.findOne({
      where: { email: req.body.email }
    });

    if (!user) {
      return res.status(404).send({ message: 'User not found.' });
    }

    // Use the model's custom method to compare passwords
    const passwordIsValid = await user.validPassword(req.body.password);

    if (!passwordIsValid) {
      return res.status(401).send({
        message: 'Invalid Password!',
        accessToken: null
      });
    }

    // Sign a token
    const token = jwt.sign(
      { id: user.id, role: user.role }, // Payload
      config.secret, // Secret key
      { expiresIn: '24h' } // Token expiration
    );

    res.status(200).send({
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      accessToken: token
    });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};