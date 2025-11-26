// migrations/add_image_url_to_products.js
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('products', 'image_url', {
      type: Sequelize.STRING,
      allowNull: true,
      after: 'product_unit'
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('products', 'image_url');
  }
};
