# Historias de usuario

> Versión 0.1 · 17-oct-2026 · Formato: *Como [rol] quiero [acción] para [beneficio]*. Prioridad M/S/C y fase según `02-requisitos.md`.

**Roles:** Contador (administrador), Auxiliar, Cliente (solo lectura sobre lo contable).

## Épica 1 · Acceso y seguridad

**HU-01 · Iniciar sesión** (RF-01 · M · F1)
Como usuario quiero entrar con mi usuario y contraseña para ver solo lo que mi rol permite.
- Dado un usuario válido, cuando ingresa sus credenciales correctas, entonces accede a su panel según su rol.
- Dadas credenciales erróneas repetidas, entonces el sistema bloquea temporalmente los intentos.

**HU-02 · Permisos por rol** (RF-02 · M · F1)
Como contador quiero que el auxiliar y el cliente tengan permisos distintos para proteger la información.
- El auxiliar no puede aprobar parámetros ni borrar clientes.
- El cliente solo ve su propio expediente y no puede modificar movimientos.
- Los permisos se validan en el backend, no solo ocultando botones.

## Épica 2 · Clientes

**HU-10 · Registrar un cliente** (RF-10, RF-11 · M · F1)
Como contador quiero crear la ficha de un cliente (documento, tipo de contribuyente, si es empleador, cuentas bancarias) para llevar su contabilidad.
- No permite dos clientes con el mismo documento.
- Los campos sensibles se guardan cifrados.

**HU-11 · Consultar el expediente** (RF-11 · M · F1)
Como contador quiero ver en una sola pantalla el resumen del año de un cliente para decidir qué falta.

**HU-12 · Adjuntar soportes** (RF-12 · S · F1)
Como auxiliar quiero asociar un soporte (PDF o imagen) a un movimiento para respaldar la información.

## Épica 3 · Movimientos

**HU-20 · Registrar un movimiento** (RF-20, RF-21 · M · F1)
Como auxiliar quiero registrar ingresos, gastos, consignaciones, pagos con tarjeta y GMF de un cliente, con categoría y fecha, para acumular la información del año.
- La fecha determina el año y, por tanto, los parámetros aplicables.
- Cada movimiento queda registrado con quién lo creó.

**HU-21 · Importar un extracto** (RF-22 · S · F5)
Como auxiliar quiero cargar un extracto en Excel o CSV y que se categorice con reglas para no digitar uno por uno.

## Épica 4 · Parámetros y actualización anual

**HU-30 · Ver parámetros vigentes** (RF-30 · M · F1)
Como contador quiero ver los parámetros activos (UVT, topes, salario mínimo) con su fuente para confiar en los cálculos.

**HU-31 · Preparar los parámetros del nuevo año** (RF-31, RF-35 · M · F1)
Como contador quiero crear el conjunto del año siguiente como borrador, copiado del anterior, para prepararlo en diciembre.
- Desde mediados de diciembre el sistema avisa si faltan parámetros del año siguiente.

**HU-32 · Activar el año el 1 o 2 de enero** (RF-32, RF-33, RF-36 · M · F1)
Como contador quiero activar el conjunto nuevo con fecha de vigencia, revisando un reporte de diferencias y un checklist, para que todo quede listo sin tocar código.
- Cada parámetro modificado exige fuente (norma y enlace).
- Quien carga el valor no es quien lo aprueba, cuando hay más de un usuario.
- Los parámetros del año anterior quedan como histórico, sin borrarse.

**HU-33 · Cambio durante el año** (RF-34 · M · F1)
Como contador quiero registrar un cambio de norma a mitad de año con su fecha de vigencia para que los cálculos usen el valor correcto en cada fecha.

## Épica 5 · Obligaciones

**HU-40 · Semáforo de topes de renta** (RF-40 · M · F2)
Como contador quiero ver, por cliente, cuánto lleva acumulado frente a cada tope (ingresos, patrimonio, tarjeta, compras, consignaciones) para saber si debe declarar.
- Muestra valor acumulado, tope en pesos, porcentaje y estado (verde, amarillo, rojo).
- Cada tope cita el parámetro y su fuente.

**HU-41 · Obligación de exógena** (RF-41 · M · F2)
Como contador quiero saber si un cliente está obligado a reportar información exógena para planear el trabajo.

**HU-42 · Calendario por cliente** (RF-43 · M · F2)
Como contador quiero ver los vencimientos de cada cliente según los últimos dígitos de su documento para no dejar pasar fechas.

## Épica 6 · GMF (4x1000)

**HU-50 · Controlar el 4x1000** (RF-42 · M · F2)
Como contador quiero registrar el GMF pagado por cuenta y recibir una alerta si los retiros mensuales superan la exención, para calcular la deducción en renta.
- Calcula el 50% del GMF pagado como deducible.
- Permite marcar la cuenta con exención como dato opcional.

## Épica 7 · Renta y exógena

**HU-60 · Borrador de renta** (RF-50, RF-53 · M · F3)
Como contador quiero un borrador de renta por tipo de renta, con deducciones y soportes, para cargarlo en el formulario oficial.
- Cada cifra muestra la regla y su fuente.

**HU-61 · Papel de trabajo de exógena** (RF-51 · M · F3)
Como contador quiero un acumulado por tercero y concepto para preparar el reporte.

**HU-62 · Exportar** (RF-52 · M · F3)
Como contador quiero exportar los resultados a Excel y PDF para compartirlos o archivarlos.

## Épica 8 · Nómina

**HU-70 · Liquidar la nómina del mes** (RF-60, RF-61, RF-63 · M · F4)
Como contador quiero liquidar la nómina de un cliente empleador usando el salario mínimo y el auxilio vigentes en la fecha, para obtener aportes y neto a pagar.

**HU-71 · Provisiones** (RF-62 · S · F4)
Como contador quiero ver las provisiones de prestaciones por empleado para anticipar pagos.

## Épica 9 · Cliente y auditoría

**HU-80 · Consulta del cliente** (RF-02 · S · F2)
Como cliente quiero ver mi resumen del año y subir soportes para colaborar con mi contador.

**HU-81 · Bitácora** (RF-04 · S · F1)
Como contador quiero un registro de quién cambió qué y cuándo para tener trazabilidad, especialmente de los parámetros.
