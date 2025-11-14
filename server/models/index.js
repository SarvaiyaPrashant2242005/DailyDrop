const { Sequelize, DataTypes } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: 'mysql',
    logging: false,
  }
);

const db = {};

db.Sequelize = Sequelize;
db.sequelize = sequelize;

db.users = require('./users')(sequelize, DataTypes);
db.products = require('./products')(sequelize, DataTypes);
db.customers = require('./customers')(sequelize, DataTypes);
db.deliveries = require('./deliveries')(sequelize, DataTypes);
db.payments = require('./payments')(sequelize, DataTypes);

// Associations
db.users.hasMany(db.products, { foreignKey: 'user_id', as: 'products' });
db.products.belongsTo(db.users, { foreignKey: 'user_id', as: 'user' });
db.users.hasMany(db.customers, { foreignKey: 'user_id', as: 'customers' });
db.customers.belongsTo(db.users, { foreignKey: 'user_id', as: 'user' });
db.customers.hasMany(db.deliveries, { foreignKey: 'customer_id', as: 'deliveries' });
db.products.hasMany(db.deliveries, { foreignKey: 'product_id', as: 'deliveries' });
db.deliveries.belongsTo(db.customers, { foreignKey: 'customer_id', as: 'customer' });
db.deliveries.belongsTo(db.products, { foreignKey: 'product_id', as: 'product' });
db.customers.hasMany(db.payments, { foreignKey: 'customer_id', as: 'payments' });
db.payments.belongsTo(db.customers, { foreignKey: 'customer_id', as: 'customer' });

module.exports = db;
