const db = require('../../config/db');

// Consulta mínima para saber si la base responde.
async function probarConexion() {
  const resultado = await db.query('SELECT 1 AS ok');
  return resultado.rows[0].ok === 1;
}

module.exports = { probarConexion };
