const { ErrorApp } = require('../errors');

// Rutas que no existen -> 404 con el formato único de error.
function rutaNoEncontrada(req, res) {
  res.status(404).json({
    error: { codigo: 'RUTA_NO_ENCONTRADA', mensaje: 'La ruta solicitada no existe.', detalles: [] },
  });
}

// Convierte cualquier error al formato { error: { codigo, mensaje, detalles } }.
// Nunca expone trazas internas ni datos sensibles al cliente.
// eslint-disable-next-line no-unused-vars
function manejadorDeErrores(err, req, res, next) {
  if (err instanceof ErrorApp) {
    return res.status(err.estado).json({
      error: { codigo: err.codigo, mensaje: err.message, detalles: err.detalles },
    });
  }

  // JSON mal formado en el cuerpo de la petición.
  if (err && err.type === 'entity.parse.failed') {
    return res.status(400).json({
      error: { codigo: 'JSON_INVALIDO', mensaje: 'El cuerpo de la petición no es un JSON válido.', detalles: [] },
    });
  }

  // Cuerpo demasiado grande.
  if (err && err.type === 'entity.too.large') {
    return res.status(413).json({
      error: { codigo: 'CUERPO_DEMASIADO_GRANDE', mensaje: 'La petición supera el tamaño permitido.', detalles: [] },
    });
  }

  // Error inesperado: se registra solo lo necesario, sin datos del usuario.
  console.error('[error]', err && err.name, err && err.message);
  return res.status(500).json({
    error: { codigo: 'ERROR_INTERNO', mensaje: 'Ocurrió un error inesperado.', detalles: [] },
  });
}

module.exports = { rutaNoEncontrada, manejadorDeErrores };
