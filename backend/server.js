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
  // Add SSL configuration if required by Render (often needed for external connections,
  // but internal connections might not need it. Check Render docs if connection fails)
  // ssl: {
  //   rejectUnauthorized: false // Use this carefully, check Render's recommended settings
  // }
});

// Test the database connection
pool.connect((err, client, release) => {
  if (err) {
    return console.error('Error acquiring client for DB connection test:', err.stack);
  }
  client.query('SELECT NOW()', (err, result) => {
    release(); // Release the client back to the pool
    if (err) {
      return console.error('Error executing DB connection test query:', err.stack);
    }
    console.log('Successfully connected to PostgreSQL database at:', result.rows[0].now);
  });
});
// --- End Database Connection Setup ---


const app = express();

// --- Middleware ---
app.use(cors()); // Keep CORS for flexibility
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- API Routes (Prefix with /api) ---

// GET endpoint to fetch all services FROM DATABASE
app.get('/api/services', async (req, res) => { // Make the handler async
  console.log(`Executing route handler for GET /api/services`);
  try {
    // Query the database
    const result = await pool.query('SELECT id, name, description, price_per_unit, unit FROM services ORDER BY id'); // Added ORDER BY

    // Ensure price_per_unit is treated as a number (float/double)
    const services = result.rows.map(service => ({
        ...service,
        pricePerUnit: parseFloat(service.price_per_unit) // Convert string from DB if needed, or ensure DB type is numeric
    }));

    console.log(`Successfully fetched ${services.length} services from DB.`);
    res.status(200).json(services); // Send database results
  } catch (err) {
    console.error('Error fetching services from DB:', err.stack);
    res.status(500).json({ error: 'Failed to fetch services' }); // Send JSON error
  }
});

// --- Serve Static Files from Flutter Build ---
const flutterBuildPath = path.resolve(__dirname, '..', 'build', 'web');
console.log(`Serving static files from: ${flutterBuildPath}`);
app.use(express.static(flutterBuildPath));

// --- Fallback for SPAs ---
app.get('*', (req, res) => {
  // Avoid logging every static file request if desired
  if (!req.originalUrl.startsWith('/api') && !req.originalUrl.includes('.')) {
     console.log(`Fallback route hit for ${req.originalUrl}, serving index.html`);
  }
  res.sendFile(path.resolve(flutterBuildPath, 'index.html'));
});


// --- Error Handling Middleware ---
app.use((err, req, res, next) => {
  console.error(err.stack);
  // Ensure response is JSON if API call failed mid-request
  if (!res.headersSent) {
     res.status(500).json({ error: 'Something broke!' });
  } else {
     next(err); // Default error handler if headers already sent
  }
});

// --- Start Server ---
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
