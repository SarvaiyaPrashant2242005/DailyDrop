# Soft Delete Implementation for Customers

## Overview
Customers are now soft-deleted instead of being permanently removed from the database. When a user deletes a customer, the customer is marked as inactive (`is_active = false`) but remains in the database.

## Changes Made

### Backend (Server)

1. **Database Model** (`server/models/customers.js`)
   - Added `is_active` field (BOOLEAN, default: true)
   - This field tracks whether a customer is active or deleted

2. **Controller** (`server/controllers/customerController.js`)
   - Updated `delete` method to set `is_active = false` instead of destroying the record
   - Updated `findAll` to only return active customers (`is_active = true`)
   - Updated `findByUserId` to only return active customers

3. **Migration** (`server/migrations/add_is_active_to_customers.js`)
   - Script to add the `is_active` column to existing databases
   - Sets all existing customers to `is_active = true`

### Frontend (Flutter)

1. **Controller** (`daily_drop/lib/controller/customer_controller.dart`)
   - Added confirmation dialog before deletion
   - Dialog warns user that "all customer data will be permanently removed"
   - User sees this message, but data is actually just marked as inactive

2. **UI** (`daily_drop/lib/widgets/customer_form_bottom_sheet.dart`)
   - Added delete button (trash icon) in edit mode header
   - Button is only visible when editing an existing customer

## How It Works

1. User clicks the delete button on a customer
2. A confirmation dialog appears warning about data deletion
3. If confirmed, the customer's `is_active` field is set to `false`
4. The customer disappears from the UI (filtered out by queries)
5. The customer data remains in the database for potential recovery or auditing

## Database Migration

If you have an existing database, run the migration:

```bash
cd server
node migrations/add_is_active_to_customers.js
```

Or simply restart your server - Sequelize will automatically add the column with `sync()`.

## Benefits

- **Data Preservation**: Customer data is never lost
- **Audit Trail**: Maintain history of all customers
- **Recovery**: Deleted customers can be restored if needed
- **Compliance**: Meets data retention requirements
- **User Experience**: Users see the expected "delete" behavior

## Future Enhancements

- Admin panel to view and restore deleted customers
- Automatic permanent deletion after X days
- Bulk restore functionality
- Deletion audit log with timestamps
