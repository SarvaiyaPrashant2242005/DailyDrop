// Migration script to add is_active column to customers table
// Run this manually if needed: node migrations/add_is_active_to_customers.js

const db = require('../models');
const Customer = db.customers;

async function migrate() {
  try {
    console.log('Starting migration: Adding is_active column to customers table...');
    
    // Sync the model to add the column
    await db.sequelize.sync({ alter: true });
    
    // Update all existing customers to be active
    await Customer.update(
      { is_active: true },
      { where: { is_active: null } }
    );
    
    console.log('Migration completed successfully!');
    console.log('All existing customers have been marked as active.');
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

migrate();
