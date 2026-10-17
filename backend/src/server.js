const config = require('./config/env');
const db = require('./config/db');
const { crearApp } = require('./app');

// Falla pronto y con un mensaje claro si falta la configuración.
try {
  config.databaseUrl();
} catch (error) {
  console.error(`\n[configuración] ${error.message}\n`);
  process.exit(1);
}

const app = crearApp();

const servidor = app.listen(config.puerto, () => {
  console.log(`ContaNegocios API escuchando en http://localhost:${config.puerto}/api/v1`);
});

// Cierre ordenado (Ctrl+C o parada del servicio).
function apagar() {
  servidor.close(async () => {
    await db.cerrar();
    process.exit(0);
  });
}
process.on('SIGINT', apagar);
process.on('SIGTERM', apagar);
