import express from 'express';
import dotenv from 'dotenv';
import pool from './db.js';
import cache from './cache.js';
import urlRoutes from './routes/urls.js';

dotenv.config();

const app = express();
app.use(express.json());

// Health check — vérifie que DB et Redis répondent
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    await cache.ping();
    res.json({ status: 'ok' });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.use('/api', urlRoutes); // → POST /api/shorten
app.use('/', urlRoutes);    // → GET /:code (redirection)

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
