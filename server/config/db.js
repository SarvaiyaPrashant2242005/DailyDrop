
const mysql = require("mysql2"); // <-- 1. Use 'require'

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,       // <-- 2. These will now be loaded
  password: process.env.DB_PASSWORD, // <-- 3. This will now be loaded
  database: process.env.DB_NAME,
});

db.connect((err) => {
  if (err) {
    console.error("❌ Database connection failed:", err);
  } else {
    console.log("✅ Connected to MySQL Database: dailydrop");
  }
});

module.exports = db; 