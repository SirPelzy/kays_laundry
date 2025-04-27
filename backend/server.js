// backend/server.js

require('dotenv').config();
const express = require('express');
const cors = require('cors'); // Keep cors for potential future needs, but less critical now
const path = require('path'); // Import path module

const app = express();

// --- Middleware ---

// CORS might still be useful if you ever have other origins needing access
// For same-origin serving, it's less critical but doesn't hurt.
app.use(cors());

// Standard middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- API Routes (Prefix with /api) ---
// It's crucial that API routes are defined *before* the static file serving

// Placeholder Data
const placeholderServices = [
  { id: '1', name: 'Wash & Fold', description: 'Clothes washed, dried, and neatly folded.', pricePerUnit: 500, unit: 'kg' },
  { id: '2', name: 'Wash & Iron', description: 'Washed, dried, and professionally ironed.', pricePerUnit: 800, unit: 'kg' },
  { id: '3', name: 'Dry Cleaning', description: 'Special care for delicate garments.', pricePerUnit: 1500, unit: 'item' },
  { id: '4', name: 'Just Ironing', description: 'Get your clothes professionally pressed.', pricePerUnit: 300, unit: 'item' },
];

// GET endpoint to fetch all services
app.get('/api/services', (req, res) => {
  console.log(`Executing route handler for GET /api/services`);
  res.status(200).json(placeholderServices);
});

// --- TODO: Add more API routes here, always starting with /api ---
// Example: app.post('/api/orders', ...)


// --- Serve Static Files from Flutter Build ---
// Construct the path to the Flutter web build directory
// This assumes the backend folder is at the same level as the Flutter project root
const flutterBuildPath = path.resolve(__dirname, '..', 'build', 'web');
console.log(`Serving static files from: ${flutterBuildPath}`);

// Serve static files (HTML, JS, CSS, assets)
app.use(express.static(flutterBuildPath));

// --- Fallback for Single Page Applications (SPAs) ---
// For any request that doesn't match an API route or a static file,
// serve the main index.html file. This allows Flutter's routing to take over.
app.get('*', (req, res) => {
  console.log(`Fallback route hit for ${req.originalUrl}, serving index.html`);
  res.sendFile(path.resolve(flutterBuildPath, 'index.html'));
});


// --- Error Handling Middleware ---
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

// --- Start Server ---
const PORT = process.env.PORT || 3000; // Render provides PORT environment variable

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
