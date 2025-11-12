const dotenv = require("dotenv");
dotenv.config(); 
const express = require("express");
const cors = require("cors");
const mysqlConn = require("./config/db"); 
const db = require('./models');

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    status: "OK",
    message: "Server running",
  });
});

// Register routes
require('./routes/usersroutes')(app);
require('./routes/productRoutes')(app);
require('./routes/customerRoutes')(app);
require('./routes/deliveryRoutes')(app);
require('./routes/paymentRoutes')(app);

const PORT = process.env.PORT || 5000;

// Initialize Sequelize and start server
db.sequelize
  .sync()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Sequelize initialization failed:', err);
    process.exit(1);
  });