const { Router } = require('express');
const controlador = require('./salud.controller');

const router = Router();
router.get('/', controlador.obtenerSalud);

module.exports = router;
