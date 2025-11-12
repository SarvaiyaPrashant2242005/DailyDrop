// models/deliveries.js
module.exports = (sequelize, DataTypes) => {
  const Delivery = sequelize.define('delivery', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
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
    product_quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    delivery_day: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  });

  return Delivery;
};
