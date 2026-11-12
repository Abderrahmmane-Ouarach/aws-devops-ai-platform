import express from 'express';
import dotenv from 'dotenv';
import pool from './db.js';
import cache from './cache.js';
import urlRoutes from './routes/urls.js';
import path from 'path';
import { fileURLToPath } from 'url';
import { httpDuration, register } from './metrics.js';


dotenv.config();

const app = express();
app.use(express.json());

app.use((req, res, next) => {
  const end = httpDuration.startTimer();
  res.on('finish', () => {
    end({
      method: req.method,
      route: (req.baseUrl || '') + (req.route ? req.route.path : 'unmatched'),
      status: res.statusCode,
    });
  });
  next();
});

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


app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.use('/api', urlRoutes); // → POST /api/shorten
app.use('/', urlRoutes);    // → GET /:code (redirection)

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
