// Error de la aplicación con código estable y mensaje para el usuario.
// Formato de respuesta definido en docs/02-diseno/04-api.md.
class ErrorApp extends Error {
  constructor(estado, codigo, mensaje, detalles = []) {
    super(mensaje);
    this.name = 'ErrorApp';
    this.estado = estado;
    this.codigo = codigo;
    this.detalles = detalles;
  }
}

const noEncontrado = (mensaje = 'Recurso no encontrado.') =>
  new ErrorApp(404, 'NO_ENCONTRADO', mensaje);
const solicitudInvalida = (mensaje, detalles = []) =>
  new ErrorApp(400, 'SOLICITUD_INVALIDA', mensaje, detalles);
const noAutenticado = (mensaje = 'Se requiere iniciar sesión.') =>
  new ErrorApp(401, 'NO_AUTENTICADO', mensaje);
const sinPermiso = (mensaje = 'No tienes permiso para esta acción.') =>
  new ErrorApp(403, 'SIN_PERMISO', mensaje);
const conflicto = (codigo, mensaje) => new ErrorApp(409, codigo, mensaje);
const reglaDeNegocio = (codigo, mensaje, detalles = []) =>
  new ErrorApp(422, codigo, mensaje, detalles);

module.exports = {
  ErrorApp,
  noEncontrado,
  solicitudInvalida,
  noAutenticado,
  sinPermiso,
  conflicto,
  reglaDeNegocio,
};
