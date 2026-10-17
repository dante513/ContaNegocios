// Configuración leída de variables de entorno (archivo .env en desarrollo).
// Las claves secretas NUNCA se escriben en el código (ver docs/02-diseno/05-seguridad.md).
const path = require('path');
// El archivo .env vive en la raíz del repositorio (ver docs/05-despliegue/01-instalacion-local.md).
require('dotenv').config({ path: path.resolve(__dirname, '../../../.env'), quiet: true });

function requerida(nombre) {
  const valor = process.env[nombre];
  if (!valor || valor.trim() === '') {
    throw new Error(
      `Falta la variable de entorno ${nombre}. Revisa tu archivo .env (usa .env.example como guía).`
    );
  }
  return valor;
}

const config = {
  entorno: process.env.NODE_ENV || 'development',
  puerto: Number(process.env.PORT) || 3000,
  frontendOrigin: process.env.FRONTEND_ORIGIN || 'http://localhost:5173',
  // Se exige al conectar; ver src/config/db.js
  databaseUrl: () => requerida('DATABASE_URL'),
};

module.exports = config;
