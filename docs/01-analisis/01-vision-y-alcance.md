# Visión y alcance

> Versión 0.1 · 13-oct-2026 · Proyecto: ContaNegocios (nombre provisional)

## 1. Problema

Un contador independiente que lleva a varias personas naturales (por ejemplo, un abogado o un comerciante) recibe información dispersa: extractos, facturas, certificados, recibos. Al llegar la temporada de renta debe reconstruir todo, verificar si el cliente está obligado a declarar, preparar la información exógena y revisar el 4x1000 pagado. El trabajo es repetitivo, manual y propenso a errores.

## 2. Visión

> Que el contador abra el expediente de un cliente y vea, en un solo lugar, cuánto lleva acumulado en el año contra cada tope, qué obligaciones tiene y qué papeles de trabajo ya están listos para cargar.

## 3. Alcance de la versión 1

**Dentro:**
- Clientes personas naturales con expediente propio.
- Registro e importación de movimientos (ingresos, gastos, consignaciones, pagos con tarjeta, GMF).
- Parámetros tributarios y laborales **por año**, con módulo de actualización anual.
- Semáforo de obligaciones: avance de cada cliente frente a los topes de renta y de exógena.
- Módulo GMF (4x1000): control de la exención mensual y de la deducción en renta.
- Borrador de renta y papel de trabajo de exógena, exportables a Excel y PDF.
- Calendario de vencimientos por cliente.
- Nómina para clientes que son empleadores (núcleo: liquidación mensual y aportes; fase posterior al núcleo contable).
- Roles: contador, auxiliar, cliente (solo lectura).
- Bitácora de auditoría.

**Fuera (con razón):**
- Presentar declaraciones ante la DIAN: eso exige firma electrónica y el portal oficial. El sistema prepara los papeles de trabajo.
- Facturación electrónica.
- Personas jurídicas: el diseño las deja previstas, pero entran en una versión posterior.
- Generar los XML oficiales de exógena: fase avanzada opcional.

## 4. Posicionamiento

No pretende reemplazar a un ERP contable completo. Compite en **profundidad en un flujo**: cliente → movimientos del año → alertas → papeles de trabajo de renta y exógena. 💭 *Opinión del autor; es una decisión de producto, no un hecho verificable.*

## 5. Usuarios

| Rol | Qué necesita |
|---|---|
| Contador (administrador) | Ver todos sus clientes, aprobar parámetros anuales, generar papeles de trabajo |
| Auxiliar | Registrar y clasificar movimientos, sin cambiar parámetros ni borrar |
| Cliente | Consultar su resumen y subir soportes, solo lectura sobre lo contable |

## 6. Riesgos

| Riesgo | Mitigación |
|---|---|
| Las reglas tributarias y laborales cambian cada año (e incluso a mitad de año) | Parámetros con vigencia y fuente; módulo de actualización anual |
| Un cálculo erróneo se toma como verdad | Cada resultado muestra la regla y la fuente; aviso de que el sistema no reemplaza el criterio profesional |
| Datos personales sensibles (cédulas, patrimonio) | Solo datos ficticios en el repositorio; cifrado de campos sensibles; auditoría |
| Alcance que crece sin control | Fases con criterios de cierre; lo no incluido queda en el backlog |

## 7. Fases de implementación

| Fase | Contenido | Cierra cuando |
|---|---|---|
| F1 Núcleo | Autenticación, roles, clientes, movimientos, parámetros por año | Se puede registrar un año completo de un cliente |
| F2 Obligaciones | Semáforo de topes, GMF, calendario | El semáforo coincide con casos de prueba calculados a mano |
| F3 Renta y exógena | Borrador de renta, papel de trabajo de exógena, exportes | Se generan los Excel/PDF de un cliente demo |
| F4 Nómina | Liquidación mensual, aportes, provisiones | Una nómina demo cuadra con cálculo manual |
| F5 Importación y cierre | Importador de extractos, conciliación, pulido, despliegue | Documentación y pruebas completas |

## 8. Criterios de éxito del portafolio

- Un visitante entiende el proyecto leyendo el README en 2 minutos.
- La documentación cubre análisis, diseño, pruebas, despliegue y usuario.
- Las pruebas automatizadas pasan y hay evidencia (capturas, tablero de Trello).
- El módulo de actualización anual funciona con datos de dos años distintos.
