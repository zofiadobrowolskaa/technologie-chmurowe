const express = require('express');
const os = require('os');
const { Pool } = require('pg');
const { createClient } = require('redis');

const app = express();
app.use(express.json());

const pool = new Pool({
    user: process.env.POSTGRES_USER || 'user',
    host: process.env.DB_HOST || 'postgres',
    database: process.env.POSTGRES_DB || 'products',
    password: process.env.POSTGRES_PASSWORD || 'pass',
    port: 5432,
});

pool.query(`
    CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL
    )
`).catch(err => console.error('Błąd inicjalizacji DB:', err));

const redisClient = createClient({
    url: `redis://${process.env.REDIS_HOST || 'redis'}:6379`
});
redisClient.on('error', err => console.error('Błąd klienta Redis:', err));
redisClient.connect().catch(console.error);

let requestCount = 0;

app.use((req, res, next) => {
    requestCount++;
    next();
});

app.get('/health', async (req, res) => {
    let dbStatus = 'disconnected';
    let redisStatus = 'disconnected';
    
    try {
        await pool.query('SELECT 1');
        dbStatus = 'connected';
    } catch (e) {}

    if (redisClient.isReady) {
        redisStatus = 'connected';
    }

    res.json({ status: "ok", uptime: process.uptime(), db: dbStatus, redis: redisStatus });
});

app.get('/items', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM products ORDER BY id ASC');
        res.json({ items: result.rows });
    } catch (err) {
        res.status(500).json({ error: 'Błąd bazy danych' });
    }
});

app.post('/items', async (req, res) => {
    try {
        const { name } = req.body;
        const result = await pool.query(
            'INSERT INTO products (name) VALUES ($1) RETURNING *',
            [name]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Błąd bazy danych' });
    }
});

app.get('/stats', async (req, res) => {
    try {
        const cacheKey = 'api_stats';
        const cachedData = await redisClient.get(cacheKey);

        if (cachedData) {
            res.setHeader('X-Cache', 'HIT');
            return res.json(JSON.parse(cachedData));
        }

        const result = await pool.query('SELECT COUNT(*) FROM products');
        const totalProducts = parseInt(result.rows[0].count, 10);

        const stats = {
            totalProducts,
            instanceId: process.env.INSTANCE_ID || os.hostname(),
            currentTime: new Date().toISOString(),
            requestCount,
            uptime: process.uptime()
        };

        await redisClient.setEx(cacheKey, 10, JSON.stringify(stats));
        res.setHeader('X-Cache', 'MISS');
        res.json(stats);
    } catch (err) {
        res.status(500).json({ error: 'Błąd statystyk' });
    }
});

if (require.main === module) {
    app.listen(3000, () => console.log('Backend działa na porcie 3000'));
}

module.exports = app;