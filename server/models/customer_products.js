// models/customer_products.js
module.exports = (sequelize, DataTypes) => {
  const CustomerProduct = sequelize.define('customer_product', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },

    customer_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'customers', key: 'id' },
      onUpdate: 'CASCADE',
      onDelete: 'CASCADE',
    },
    product_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'products', key: 'id' },
      onUpdate: 'CASCADE',
      onDelete: 'CASCADE',
    },

    // Business fields
    quantity: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 1 },
    price: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
    unit: { type: DataTypes.STRING, allowNull: false },

    // Scheduling fields
    frequency: { type: DataTypes.STRING, allowNull: false }, // 'everyday','alternate','weekly','monthly','custom'
    alternate_day_start: { type: DataTypes.STRING, allowNull: true }, // 'today'|'tomorrow'
    weekly_day: { type: DataTypes.STRING, allowNull: true }, // 'monday'..'sunday'
    monthly_date: { type: DataTypes.INTEGER, allowNull: true },
    custom_week_days: { type: DataTypes.JSON, allowNull: true }, // array of strings
  });

  return CustomerProduct;
};