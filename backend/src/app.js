// Construye la aplicación Express SIN arrancar el servidor (así las pruebas la importan).
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const config = require('./config/env');
const rutas = require('./routes');
const { rutaNoEncontrada, manejadorDeErrores } = require('./middlewares/errorHandler');

function crearApp() {
  const app = express();

  app.use(helmet());
  app.use(
    cors({
      origin: config.frontendOrigin, // solo el frontend configurado (docs/05-seguridad §6)
      credentials: true,
    })
  );
  app.use(express.json({ limit: '100kb' }));

  app.use('/api/v1', rutas);

  app.use(rutaNoEncontrada);
  app.use(manejadorDeErrores);
  return app;
}

module.exports = { crearApp };
