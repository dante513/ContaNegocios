const { Router } = require('express');

const router = Router();

// Cada módulo se monta aquí a medida que se construye (ver docs/03-desarrollo/02-plan-f1.md).
router.use('/salud', require('./modules/salud/salud.routes'));

module.exports = router;
