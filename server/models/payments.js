// models/payments.js
module.exports = (sequelize, DataTypes) => {
  const Payment = sequelize.define('payment', {
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
    total_amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    paid_amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
  });

  return Payment;
};
