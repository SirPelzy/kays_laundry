// backend/server.js

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const { Pool } = require('pg'); // Import the Pool class from pg

// --- Database Connection Setup ---
// Create a connection pool using the DATABASE_URL from .env
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // ** Enable SSL Configuration **
  // Render typically requires SSL for database connections.
  // `rejectUnauthorized: false` bypasses certificate verification.
  // Use this setting carefully; it's common for managed DBs on internal networks
  // but less secure if the network path isn't fully trusted.
  // Check Render's documentation for their recommended SSL settings if this causes issues.
  ssl: {
    rejectUnauthorized: false
  }
});

// Test the database connection
pool.connect((err, client, release) => {
  if (err) {
    // Log the specific error during connection attempt
    return console.error('Error acquiring client for DB connection test:', err.message, err.stack);
  }
  client.query('SELECT NOW()', (err, result) => {
    release(); // Release the client back to the pool
    if (err) {
      return console.error('Error executing DB connection test query:', err.stack);
    }
    console.log('Successfully connected to PostgreSQL database (via SSL) at:', result.rows[0].now);
  });
});
// --- End Database Connection Setup ---


const app = express();

// --- Middleware ---
// Configure CORS Explicitly (Simplified)
const frontendOrigin = process.env.FRONTEND_ORIGIN_URL || '*'; // Use env var or allow all if not set
console.log(`Configuring CORS to allow origin: ${frontendOrigin}`);
const corsOptions = {
  origin: frontendOrigin === '*' ? '*' : [frontendOrigin], // Allow specific or all
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false,
  optionsSuccessStatus: 204
};
app.use(cors(corsOptions));

// Optional: Log requests after CORS middleware
app.use((req, res, next) => {
  console.log(`Request received: ${req.method} ${req.originalUrl} from origin ${req.headers.origin}`);
  next();
});

// Other standard middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- API Routes (Prefix with /api) ---

// GET endpoint to fetch all services FROM DATABASE
app.get('/api/services', async (req, res) => { // Make the handler async
  console.log(`Executing route handler for GET /api/services`);
  let client; // Define client outside try block for finally block access
  try {
    client = await pool.connect(); // Get a client from the pool
    const result = await client.query('SELECT id, name, description, price_per_unit, unit FROM services ORDER BY id');

    const services = result.rows.map(service => ({
        ...service,
        // Convert price_per_unit from string/numeric to float if necessary
        // pg typically returns numeric types correctly, but explicit parsing is safe
        pricePerUnit: parseFloat(service.price_per_unit)
    }));

    console.log(`Successfully fetched ${services.length} services from DB.`);
    res.status(200).json(services);
  } catch (err) {
    console.error('Error fetching services from DB:', err.stack);
    res.status(500).json({ error: 'Failed to fetch services' });
  } finally {
     if (client) {
        client.release(); // Ensure client is released back to the pool
        console.log("DB client released for /api/services");
     }
  }
});

// --- Serve Static Files from Flutter Build ---
const flutterBuildPath = path.resolve(__dirname, '..', 'build', 'web');
console.log(`Serving static files from: ${flutterBuildPath}`);
app.use(express.static(flutterBuildPath));

// --- Fallback for SPAs ---
app.get('*', (req, res) => {
  if (!req.originalUrl.startsWith('/api') && !req.originalUrl.includes('.')) {
     console.log(`Fallback route hit for ${req.originalUrl}, serving index.html`);
  }
  res.sendFile(path.resolve(flutterBuildPath, 'index.html'), (err) => {
     if (err) {
        // Handle error if index.html can't be sent (e.g., file not found after build issues)
        console.error("Error sending index.html:", err);
        res.status(err.status || 500).end();
     }
  });
});


// --- Error Handling Middleware ---
app.use((err, req, res, next) => {
  console.error("Global Error Handler:", err.stack);
  if (!res.headersSent) {
     res.status(500).json({ error: 'Something broke!' });
  } else {
     next(err);
  }
});

// --- Start Server ---
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
