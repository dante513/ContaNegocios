# Requisitos

> Versión 0.1 · 13-oct-2026 · Prioridad: **M** Must, **S** Should, **C** Could · Fase según la visión (F1 a F5)

## 1. Requisitos funcionales

### Seguridad y usuarios
| ID | Requisito | Prior. | Fase |
|---|---|---|---|
| RF-01 | Inicio de sesión con usuario y contraseña (hash seguro) | M | F1 |
| RF-02 | Roles: contador, auxiliar y cliente, con permisos distintos | M | F1 |
| RF-03 | Cambio de contraseña con verificación de la actual | M | F1 |
| RF-04 | Bitácora de auditoría de acciones relevantes | S | F1 |

### Clientes
| ID | Requisito | Prior. | Fase |
|---|---|---|---|
| RF-10 | Crear, editar y consultar clientes personas naturales | M | F1 |
| RF-11 | Expediente por cliente: documento, régimen, empleador sí/no, cuentas bancarias | M | F1 |
| RF-12 | Subir y asociar soportes a movimientos | S | F1 |
| RF-13 | Modelo de datos preparado para personas jurídicas (sin implementarlas) | S | F1 |

### Movimientos
| ID | Requisito | Prior. | Fase |
|---|---|---|---|
| RF-20 | Registrar movimientos (ingreso, gasto, consignación, pago con tarjeta, GMF) por cliente y fecha | M | F1 |
| RF-21 | Clasificar movimientos por categoría y tipo de renta | M | F1 |
| RF-22 | Importar extractos desde Excel/CSV con reglas de categorización | S | F5 |
| RF-23 | Conciliación bancaria básica | C | F5 |

### Parámetros y actualización anual
| ID | Requisito | Prior. | Fase |
|---|---|---|---|
| RF-30 | Catálogo de parámetros con valor, unidad, vigencia, fuente y estado | M | F1 |
| RF-31 | Crear el conjunto de parámetros de un nuevo año en estado borrador | M | F1 |
| RF-32 | Aprobar y activar parámetros con fecha de vigencia | M | F1 |
| RF-33 | Mantener histórico inmutable de parámetros anteriores | M | F1 |
| RF-34 | Soportar cambios dentro del mismo año (vigente desde / hasta) | M | F1 |
| RF-35 | Alerta cuando faltan parámetros del año próximo a partir de diciembre | S | F1 |
| RF-36 | Checklist de actualización de enero y reporte de diferencias entre años | S | F1 |

### Obligaciones
| ID | Requisito | Prior. | Fase |
|---|---|---|---|
| RF-40 | Semáforo: avance del cliente frente a cada tope de renta | M | F2 |
| RF-41 | Semáforo de obligación de exógena | M | F2 |
| RF-42 | Módulo GMF: GMF pagado por cuenta, alerta de exención mensual excedida, deducción del 50% | M | F2 |
| RF-43 | Calendario de vencimientos por cliente según el documento | M | F2 |

### Renta y exógena
| ID | Requisito | Prior. | Fase |
|---|---|---|---|
| RF-50 | Borrador de renta por tipo de renta, con deducciones y soportes | M | F3 |
| RF-51 | Papel de trabajo de exógena por tercero y concepto | M | F3 |
| RF-52 | Exportar a Excel y PDF | M | F3 |
| RF-53 | Cada resultado muestra la regla aplicada y su fuente | M | F3 |
| RF-54 | Generar XML oficial de algún formato de exógena | C | Posterior |

### Nómina
| ID | Requisito | Prior. | Fase |
|---|---|---|---|
| RF-60 | Registro de empleados por cliente empleador | M | F4 |
| RF-61 | Liquidación mensual: salario, auxilio de transporte, deducciones y aportes | M | F4 |
| RF-62 | Provisiones de prestaciones sociales | S | F4 |
| RF-63 | Usar el salario mínimo y demás parámetros según la fecha de la liquidación | M | F4 |

## 2. Requisitos no funcionales

| ID | Requisito |
|---|---|
| RNF-01 | Seguridad: hash de contraseñas, token en cookie httpOnly con protección CSRF, límite de intentos |
| RNF-02 | Campos sensibles de clientes cifrados en base de datos |
| RNF-03 | Control de acceso aplicado en el backend, no solo en la interfaz |
| RNF-04 | Pruebas automatizadas del backend, con foco en reglas tributarias y de seguridad |
| RNF-05 | Interfaz accesible (etiquetas asociadas, foco visible, contraste) y modo claro/oscuro |
| RNF-06 | Funciona en Windows de forma local con instalación documentada |
| RNF-07 | Respaldo y restauración de la base de datos documentados |
| RNF-08 | Ninguna regla tributaria o laboral queda "quemada" en el código: todo sale de parámetros |
| RNF-09 | El repositorio contiene solo datos ficticios |

## 3. Trazabilidad (resumen)

| Objetivo de la visión | Requisitos |
|---|---|
| Ver avance frente a topes | RF-30 a RF-34, RF-40, RF-41 |
| Controlar el 4x1000 | RF-42 |
| Papeles de trabajo listos | RF-50 a RF-53 |
| Actualizar cada año sin tocar código | RF-30 a RF-36, RNF-08 |
