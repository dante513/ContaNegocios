# Casos de prueba

> Versión 0.1 · 17-oct-2026 · Prioridad: **C** crítica, **A** alta, **M** media. Los resultados esperados con cifras fueron **calculados a mano**. Nivel de verificación del dato base: ✅ verificado · ⚠️ probable · ❓ pendiente.
> UVT 2025 = $49.799 y UVT 2026 = $52.374 (`01-analisis/03-parametros-anuales-y-actualizacion.md`).

## 1. Autenticación y permisos

| ID | Caso | Pasos / datos | Resultado esperado | Ref. | Pr. |
|---|---|---|---|---|---|
| CP-01 | Inicio de sesión válido | Usuario contador con credenciales correctas | 200, cookie `httpOnly`, panel del contador | HU-01 | C |
| CP-02 | Contraseña incorrecta | Correo válido, clave errónea | 401 con mensaje genérico (no revela si el correo existe) | HU-01, RNF-01 | C |
| CP-03 | Bloqueo por intentos | Superar el máximo de intentos configurado | 429; usuario con `bloqueado_hasta`; entrada en bitácora | HU-01 | C |
| CP-04 | Cambio de clave | Enviar clave nueva sin la actual | 400/401; no cambia la clave | RF-03 | A |
| CP-05 | Auxiliar no activa parámetros | Auxiliar llama `POST /parametros/conjuntos/:id/activar` | 403; nada cambia | HU-02, RF-02 | C |
| CP-06 | Cliente ve solo lo suyo | Cliente A pide el expediente del cliente B | 404 (no 403) | HU-02, ADR-010 | C |
| CP-07 | Auxiliar no anula movimientos | Auxiliar llama `POST /movimientos/:id/anular` | 403 | HU-02 | A |

## 2. Clientes y movimientos

| ID | Caso | Pasos / datos | Resultado esperado | Ref. | Pr. |
|---|---|---|---|---|---|
| CP-08 | Crear cliente | Datos válidos | 201; aparece en el listado | HU-10 | A |
| CP-09 | Documento duplicado | Crear dos clientes con el mismo documento | 409 en el segundo | HU-10 | A |
| CP-10 | Documento cifrado | Consultar la tabla `clientes` directamente | `documento_cifrado` no legible; `documento_hash` presente | RNF-02 | C |
| CP-11 | Registrar movimiento | Ingreso de $4.200.000, 2025-03-14 | 201; `anio_gravable` = 2025; bitácora registrada | HU-20 | A |
| CP-12 | Valor no positivo | Movimiento con valor 0 o negativo | 400 | HU-20 | A |
| CP-13 | Anulación con motivo | Anular sin motivo / con motivo | Sin motivo: 400. Con motivo: movimiento anulado y bitácora | RF-04, ADR-011 | A |
| CP-14 | Anulado excluido de totales | Ingreso de $1.000.000 anulado | El total del año no lo suma | RN-21 | C |
| CP-15 | Frontera de año gravable | Movimientos del 2025-12-31 y 2026-01-01 | Quedan en años gravables distintos (2025 y 2026) | RN-01, RN-02 | C |

## 3. Parámetros y actualización anual

| ID | Caso | Pasos / datos | Resultado esperado | Ref. | Pr. |
|---|---|---|---|---|---|
| CP-16 | Parámetro vigente por fecha | `SMMLV` con vigencias distintas; consultar en dos fechas | Devuelve el valor de la vigencia correspondiente a cada fecha | RN-01, RF-34 | C |
| CP-17 | Vigencias solapadas | Activar dos valores del mismo código con fechas que se cruzan | 409; sin cambios | RN-62, ADR-005 | C |
| CP-18 | Activar sin fuente | Parámetro modificado sin `fuente_norma` | Rechazo (400 o 422) | RN-60 | C |
| CP-19 | Aprobador igual al creador (2 usuarios) | El mismo usuario crea y activa, existiendo otro usuario | 422 `APROBADOR_IGUAL_A_CREADOR` | RN-61, HU-32 | C |
| CP-20 | Un único usuario | Sistema con un solo usuario contador activa el año | Se permite | RN-61 | A |
| CP-21 | Activación atómica | Forzar un fallo a mitad de la activación | No cambia nada: conjunto anterior sigue activo | RF-32, HU-32 | C |
| CP-22 | Histórico inmutable | Intentar editar un parámetro histórico | Rechazo | RF-33, RN-62 | C |
| CP-23 | Faltan parámetros | Calcular semáforo de un año sin `UVT` activa | Error `PARAMETRO_FALTANTE`; alerta visible | RF-35 | C |
| CP-24 | Cambiar parámetro cambia el resultado | Cambiar el tope de ingresos y recalcular | El semáforo refleja el nuevo valor sin tocar código | RNF-08 | C |

## 4. Topes, semáforo y obligaciones

| ID | Caso | Datos | Resultado esperado | Ref. | Pr. |
|---|---|---|---|---|---|
| CP-25 | Tope de ingresos en pesos | 1.400 UVT × $49.799 | **$69.718.600** | RN-03 ✅ | C |
| CP-26 | Tope de patrimonio en pesos | 4.500 UVT × $49.799 | **$224.095.500** | RN-03 ✅ | C |
| CP-27 | Frontera con operador `>=` | Ingresos = $69.718.600 | Obligado (rojo) | RN-12 ⚠️ | C |
| CP-28 | Frontera con operador `>` | Ingresos = $69.718.600 | No obligado en ese tope | RN-12 ⚠️ | C |
| CP-29 | Avance y estado | Ingresos $58.400.000 / tope $69.718.600 | **83,77%**, estado amarillo | RN-20 | C |
| CP-30 | Umbrales del semáforo | 69,99% / 70% / 99,99% / 100% | Verde / amarillo / amarillo / rojo | RN-20 | A |
| CP-31 | Basta un tope | Cliente con solo consignaciones sobre el tope | Obligado a declarar | RN-11 ✅ | C |
| CP-32 | Tope por tipo de contribuyente | Cliente "otro" vs. "asalariado" | Muestra los topes que correspondan según la regla validada | RN-13 ⚠️ | A |
| CP-33 | Calendario por documento | Documento terminado en dos dígitos de un rango | Fecha según la tabla del calendario | RN-16 ⚠️ | A |
| CP-34 | Calendario editable | Cambiar una fecha en la tabla | El vencimiento mostrado cambia | RN-16 | M |

## 5. GMF y exógena

| ID | Caso | Datos | Resultado esperado | Ref. | Pr. |
|---|---|---|---|---|---|
| CP-35 | Exención mensual en pesos | 350 UVT × $52.374 (2026) | **$18.330.900** | RN-31 ✅ | C |
| CP-36 | Exención con UVT 2025 | 350 UVT × $49.799 | **$17.429.650** | RN-31 ✅ | A |
| CP-37 | Alerta de exención excedida | Retiros del mes mayores a la exención | Alerta visible en ese mes | HU-50 | A |
| CP-38 | Deducción del 50% | GMF pagado $168.000 | Deducible **$84.000** | RN-32 ✅ | C |
| CP-39 | Obligado a exógena | Ingresos $600.000.000 y rentas de capital o no laborales $125.000.000 (UVT 2025: topes $587.628.200 y $119.517.600) | Obligado | RN-40 ✅ | A |
| CP-40 | No obligado a exógena | Ingresos $600.000.000 y rentas de capital o no laborales $100.000.000 | No obligado (no cumple el segundo criterio) | RN-40 ✅ | A |

## 6. Nómina

| ID | Caso | Datos | Resultado esperado | Ref. | Pr. |
|---|---|---|---|---|---|
| CP-41 | Salario mínimo 2026 | Salario $1.750.905; parámetros 2026 | Auxilio **$249.095**; descuentos de salud y pensión de 4% cada uno = $70.036,20 c/u; neto **$1.859.927,60** | RN-50, RN-51 ✅; RN-53 ⚠️ | C |
| CP-42 | Salario sobre 2 SMMLV | Salario $3.600.000 (mayor a 2 × $1.750.905 = $3.501.810) | Auxilio de transporte = $0 | RN-51 ✅ | C |
| CP-43 | Parámetros por fecha | Nómina de un mes antes y otro después de un cambio de parámetro | Cada una usa el valor vigente en su fecha | RN-01, HU-70 | C |
| CP-44 | Una nómina por cliente y mes | Crear dos para el mismo mes | 409 | RF-61 | A |

⚠️ Los resultados con descuentos de 4% dependen de que RN-53 se valide con la norma. La **regla de redondeo** de la nómina (centavos o pesos enteros) está pendiente (❓).

## 7. Exportes, bitácora e interfaz

| ID | Caso | Pasos | Resultado esperado | Ref. | Pr. |
|---|---|---|---|---|---|
| CP-45 | Excel coherente | Exportar el semáforo del cliente demo | Las cifras del archivo coinciden con la pantalla | HU-62 | A |
| CP-46 | PDF con aviso | Exportar el borrador de renta | Incluye el aviso de "papel de trabajo" y fuente de cada cifra | RF-53, HU-62 | A |
| CP-47 | Cambio de parámetro auditado | Editar un parámetro en borrador | Bitácora con valor anterior y nuevo, usuario y fecha | RF-04, RN-63 | C |
| CP-48 | Bitácora inmutable | `UPDATE` y `DELETE` sobre `bitacora` con el usuario de la aplicación | Ambos fallan por permisos | RNF-03 | C |
| CP-49 | Semáforo accesible | Revisar W-04 con Axe | Sin violaciones críticas; estado con texto e icono | RNF-05 | A |
| CP-50 | Formulario por teclado | Registrar un movimiento solo con teclado | Posible; foco visible; errores junto al campo | RNF-05 | M |

## 8. Recorrido extremo a extremo

| ID | Caso | Pasos | Resultado esperado | Pr. |
|---|---|---|---|---|
| CP-51 | Temporada de renta | Iniciar sesión como contador → crear cliente → registrar movimientos → ver semáforo → registrar GMF → generar borrador → exportar | Todo el recorrido funciona y los totales coinciden entre pantallas y archivos | C |
| CP-52 | Actualización anual | Preparar año nuevo → cargar con fuente → revisar diferencias → activar → verificar | Año activo, anterior histórico, bitácora completa | C |

## 9. Matriz de cobertura (resumen)

| Requisito | Casos |
|---|---|
| RF-01 a RF-04 | CP-01 a CP-07, CP-47 |
| RF-10, RF-20, RF-21 | CP-08 a CP-15 |
| RF-30 a RF-36 | CP-16 a CP-24, CP-52 |
| RF-40 a RF-43 | CP-25 a CP-34 |
| RF-42 | CP-35 a CP-38 |
| RF-41, RN-40 | CP-39, CP-40 |
| RF-50 a RF-53 | CP-45, CP-46, CP-51 |
| RF-60 a RF-63 | CP-41 a CP-44 |
| RNF-01 a RNF-03 | CP-02, CP-03, CP-10, CP-48 y `03-pruebas-de-seguridad.md` |
| RNF-05 | CP-49, CP-50 |
| RNF-08 | CP-24 |

## 10. Registro de ejecución (plantilla)

| Caso | Fecha | Versión | Resultado (aprobado / fallido / bloqueado) | Evidencia | Incidencia |
|---|---|---|---|---|---|
| CP-01 | | | | | |
