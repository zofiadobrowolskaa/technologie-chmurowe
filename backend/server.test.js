const request = require('supertest');
const app = require('./server');

describe('Weryfikacja endpointów API', () => {
  it('GET /health powinien zwrócić status 200 i obiekt z polem status: "ok"', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('status', 'ok');
    expect(res.body).toHaveProperty('uptime');
  });

  it('GET /stats powinien poprawnie zwracać statystyki', async () => {
    const res = await request(app).get('/stats');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('totalProducts', 3);
    expect(res.body).toHaveProperty('requestCount');
    expect(res.body).toHaveProperty('currentTime');
  });
});