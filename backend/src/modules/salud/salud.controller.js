const servicio = require('./salud.service');

async function obtenerSalud(req, res) {
  const estado = await servicio.estadoDelServicio();
  res.status(estado.estado === 'ok' ? 200 : 503).json(estado);
}

module.exports = { obtenerSalud };
