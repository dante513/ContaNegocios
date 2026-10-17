const request = require('supertest');

// La base de datos se simula para que la prueba no dependa de PostgreSQL.
jest.mock('../src/config/db', () => ({
  query: jest.fn(),
  transaccion: jest.fn(),
  cerrar: jest.fn(),
}));
const db = require('../src/config/db');
const { crearApp } = require('../src/app');

const app = crearApp();

describe('GET /api/v1/salud', () => {
  test('responde 200 y "ok" cuando la base de datos responde', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ ok: 1 }] });
    const res = await request(app).get('/api/v1/salud');
    expect(res.status).toBe(200);
    expect(res.body.estado).toBe('ok');
    expect(res.body.baseDeDatos).toBe('ok');
  });

  test('responde 503 y "degradado" cuando la base de datos falla', async () => {
    db.query.mockRejectedValueOnce(new Error('sin conexión'));
    const res = await request(app).get('/api/v1/salud');
    expect(res.status).toBe(503);
    expect(res.body.estado).toBe('degradado');
    expect(res.body.baseDeDatos).toBe('error');
  });

  test('no expone datos sensibles ni detalles internos', async () => {
    db.query.mockRejectedValueOnce(new Error('password authentication failed for user "contanegocios_app"'));
    const res = await request(app).get('/api/v1/salud');
    const texto = JSON.stringify(res.body);
    expect(texto).not.toMatch(/password|contanegocios_app|postgres/i);
    expect(Object.keys(res.body).sort()).toEqual(['baseDeDatos', 'estado', 'hora']);
  });
});

describe('Manejo de errores y seguridad básica', () => {
  test('una ruta inexistente responde 404 con el formato único de error', async () => {
    const res = await request(app).get('/api/v1/no-existe');
    expect(res.status).toBe(404);
    expect(res.body).toEqual({
      error: { codigo: 'RUTA_NO_ENCONTRADA', mensaje: expect.any(String), detalles: [] },
    });
  });

  test('un JSON mal formado responde 400 sin trazas internas', async () => {
    const res = await request(app)
      .post('/api/v1/salud')
      .set('Content-Type', 'application/json')
      .send('{"mal": ');
    // POST /salud no existe: el cuerpo se interpreta antes y falla como JSON inválido.
    expect(res.status).toBe(400);
    expect(res.body.error.codigo).toBe('JSON_INVALIDO');
    expect(JSON.stringify(res.body)).not.toMatch(/at .*\.js/);
  });

  test('las respuestas incluyen cabeceras de seguridad y no revelan Express', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ ok: 1 }] });
    const res = await request(app).get('/api/v1/salud');
    expect(res.headers['x-powered-by']).toBeUndefined();
    expect(res.headers['x-content-type-options']).toBe('nosniff');
  });

  test('CORS solo permite el origen del frontend configurado', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ ok: 1 }] });
    const res = await request(app).get('/api/v1/salud').set('Origin', 'http://sitio-ajeno.example');
    expect(res.headers['access-control-allow-origin']).not.toBe('http://sitio-ajeno.example');
  });
});
