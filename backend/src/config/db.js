// Conexión a PostgreSQL. Todo el SQL de la aplicación pasa por query()
// y siempre con parámetros ($1, $2...), nunca concatenando texto del usuario.
const { Pool } = require('pg');
const config = require('./env');

let pool = null;

function obtenerPool() {
  if (!pool) {
    pool = new Pool({ connectionString: config.databaseUrl() });
  }
  return pool;
}

function query(texto, parametros) {
  return obtenerPool().query(texto, parametros);
}

// Para operaciones que deben ser atómicas (por ejemplo, activar el año).
async function transaccion(trabajo) {
  const cliente = await obtenerPool().connect();
  try {
    await cliente.query('BEGIN');
    const resultado = await trabajo(cliente);
    await cliente.query('COMMIT');
    return resultado;
  } catch (error) {
    await cliente.query('ROLLBACK');
    throw error;
  } finally {
    cliente.release();
  }
}

async function cerrar() {
  if (pool) {
    await pool.end();
    pool = null;
  }
}

module.exports = { query, transaccion, cerrar };
