const repositorio = require('./salud.repository');

// Estado del servicio SIN datos sensibles (CP/RNF: solo "ok" o "error").
async function estadoDelServicio() {
  let baseDeDatos = 'ok';
  try {
    await repositorio.probarConexion();
  } catch (error) {
    baseDeDatos = 'error';
  }
  return {
    estado: baseDeDatos === 'ok' ? 'ok' : 'degradado',
    baseDeDatos,
    hora: new Date().toISOString(),
  };
}

module.exports = { estadoDelServicio };
