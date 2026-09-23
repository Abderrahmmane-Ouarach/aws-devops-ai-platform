import { Router } from 'express';
import crypto from 'crypto';
import pool from '../db.js';
import cache from '../cache.js';

const router = Router();

// Génère un code court aléatoire, ex: "kQ3f9A"
function generateShortCode(length = 6) {
  return crypto.randomBytes(length)
    .toString('base64url') // alphabet URL-safe: A-Z a-z 0-9 - _
    .slice(0, length);
}

// POST /api/shorten  { "longUrl": "https://..." }
router.post('/shorten', async (req, res) => {
  const { longUrl } = req.body;

  if (!longUrl) {
    return res.status(400).json({ error: 'longUrl is required' });
  }

  let shortCode;
  let inserted = false;

  // On boucle car il y a (rarement) collision possible sur un code déjà pris
  while (!inserted) {
    shortCode = generateShortCode();
    try {
      await pool.query(
        'INSERT INTO urls (short_code, long_url) VALUES ($1, $2)',
        [shortCode, longUrl]
      );
      inserted = true;
    } catch (err) {
      if (err.code === '23505') continue; // 23505 = violation UNIQUE en Postgres → on réessaie avec un nouveau code
      throw err;
    }
  }

  res.status(201).json({ shortCode, shortUrl: `${req.protocol}://${req.get('host')}/${shortCode}` });
});

// GET /:code → redirection
router.get('/:code', async (req, res) => {
  const { code } = req.params;

  // 1. On check le cache d'abord
  const cachedUrl = await cache.get(code);
  if (cachedUrl) {
    // Fire-and-forget : on incrémente le compteur sans bloquer la redirection
    pool.query('UPDATE urls SET click_count = click_count + 1 WHERE short_code = $1', [code]).catch(console.error);
    return res.redirect(302, cachedUrl);
  }

  // 2. Sinon on va en DB
  const result = await pool.query('SELECT long_url FROM urls WHERE short_code = $1', [code]);
  if (result.rows.length === 0) {
    return res.status(404).json({ error: 'Short URL not found' });
  }

  const longUrl = result.rows[0].long_url;

  // 3. On remplit le cache pour la prochaine fois (TTL 1h)
  await cache.setEx(code, 3600, longUrl);

  pool.query('UPDATE urls SET click_count = click_count + 1 WHERE short_code = $1', [code]).catch(console.error);
  res.redirect(302, longUrl);
});

export default router;
