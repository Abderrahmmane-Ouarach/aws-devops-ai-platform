import express from 'express';
import dotenv from 'dotenv';
import pool from './db.js';
import cache from './cache.js';
import urlRoutes from './routes/urls.js';
import path from 'path';
import { fileURLToPath } from 'url';

dotenv.config();

const app = express();
app.use(express.json());

// Health check — vérifie que DB et Redis répondent
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    await cache.ping();
    res.json({ status: 'okk' });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});
const __dirname = path.dirname(fileURLToPath(import.meta.url));
app.use(express.static(path.join(__dirname, '..', 'public')));

app.use('/api', urlRoutes); // → POST /api/shorten
app.use('/', urlRoutes);    // → GET /:code (redirection)

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
