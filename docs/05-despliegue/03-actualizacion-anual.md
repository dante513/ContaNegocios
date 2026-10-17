# Actualización anual de parámetros (guía operativa)

> Versión 0.1 · 17-oct-2026 · Estado: borrador. Complementa `01-analisis/03-parametros-anuales-y-actualizacion.md` (qué es y por qué) y las historias HU-31 a HU-33. Esta guía dice **qué hacer y cuándo**.

## 1. Cuándo y quién

| Cuándo | Quién | Qué |
|---|---|---|
| Desde mediados de diciembre | Contador | Preparar el año siguiente (el sistema avisa si faltan parámetros) |
| A medida que se publican las normas | Contador | Cargar valores con su fuente |
| 1 o 2 de enero | Contador (y aprobador, si hay más de un usuario) | Revisar y activar |
| Después de activar | Contador | Verificación posterior |
| Durante el año | Contador | Registrar cambios de norma con su fecha de vigencia |

## 2. Fuentes que se consultan cada año

| Dato | Dónde se confirma |
|---|---|
| UVT del año | Resolución de la DIAN que la fija ⚠️ (por conocimiento general; confirmar el procedimiento vigente en dian.gov.co) |
| Salario mínimo y auxilio de transporte | Decretos del Gobierno nacional del año |
| Topes de renta y de exógena | Norma vigente en el Estatuto Tributario y resoluciones de la DIAN |
| Calendario de vencimientos | Decreto o resolución del calendario tributario |
| Formatos de exógena y sus versiones | Resolución anual de la DIAN y sus modificaciones |
| Aportes y prestaciones | Normas laborales y de seguridad social vigentes |

Regla: **fuente primaria siempre que sea posible**. Los blogs y la prensa sirven para ubicar la norma, no para reemplazarla. El nivel de verificación (✅ ⚠️ ❓) se registra en cada parámetro.

## 3. Procedimiento

### Paso 0 · Respaldo previo
Haz un respaldo completo (ver `02-respaldo-y-restauracion.md`) y guárdalo como "antes de activar el año X".

### Paso 1 · Preparar (diciembre)
1. Entra a **Parámetros → Actualizar año**.
2. Crea el conjunto del año siguiente: se copia el del año anterior en estado **borrador**.
3. Revisa la **lista de pendientes**: cada parámetro sin valor nuevo o sin fuente aparece marcado.

### Paso 2 · Cargar valores
Para **cada** parámetro:
1. Ingresa el valor nuevo.
2. Registra la **fuente**: norma (tipo, número y año) y enlace.
3. Elige el nivel de verificación: ✅ si lo confirmaste en la norma o en fuentes coincidentes; ⚠️ si tienes una sola fuente secundaria; ❓ si no está confirmado.
4. Revisa la fecha de **vigencia** (normalmente 1 de enero; en algunos casos otra fecha, y debe quedar tal cual dice la norma).

Si la norma aún no se ha publicado (por ejemplo, el decreto del salario mínimo), **deja el parámetro en borrador**. No lo llenes con una estimación ni con el valor del año anterior para "salir del paso".

### Paso 3 · Revisar
1. Pulsa **Enviar a revisión**.
2. Abre el **reporte de diferencias** y comprueba que cada cambio tenga sentido (por ejemplo, un aumento razonable frente al año anterior) y que no haya valores iguales por olvido.
3. Completa el **checklist de enero**:

| Verificación | Hecho |
|---|---|
| UVT del año | ☐ |
| Salario mínimo y auxilio de transporte | ☐ |
| Topes de renta (ingresos, patrimonio, tarjeta, compras, consignaciones) y su operador | ☐ |
| Topes de exógena | ☐ |
| Calendario tributario | ☐ |
| Formatos de exógena y versiones | ☐ |
| Aportes y prestaciones de nómina | ☐ |
| Tarifas de renta | ☐ |
| Todos los parámetros con fuente y nivel de verificación | ☐ |

Si hay un segundo usuario, él revisa y aprueba. El sistema no deja que quien cargó los valores sea quien los aprueba (RN-61).

### Paso 4 · Activar
1. Pulsa **Activar año**. El sistema, en una sola operación: pasa el conjunto anterior a histórico, cierra sus vigencias, activa los nuevos y escribe la bitácora.
2. Si hay un error, **no cambia nada** y el sistema indica el motivo.

### Paso 5 · Verificación posterior
| Verificación | Cómo |
|---|---|
| El año nuevo está activo | **Parámetros** muestra el conjunto como activo |
| El anterior quedó histórico | Aparece como histórico y sin edición |
| Un cálculo conocido da lo esperado | Calcular el semáforo y una nómina del cliente demo y compararlos con el cálculo a mano |
| Los años anteriores no cambiaron | Recalcular un caso del año anterior: mismo resultado |
| La bitácora registró la activación | Consultar la bitácora |

## 4. Cambios durante el año

Cuando una norma cambia a mitad de año (por ejemplo, una nueva tabla de valores a partir de una fecha):
1. Entra a **Parámetros → Registrar ajuste**.
2. Indica el código, el valor nuevo, la fecha `vigente_desde`, la fuente y el nivel de verificación.
3. El sistema cierra la vigencia anterior el día anterior y crea la nueva.
4. Los cálculos de fechas anteriores no cambian; los posteriores usan el valor nuevo (RN-01).

## 5. Corregir un error en un parámetro ya activo

**No se edita un parámetro activo ni histórico** (RN-62). Se corrige así:
1. Registrar un **ajuste** con el valor correcto.
2. Si el error afectó cálculos ya generados, se **regeneran** (los resultados anteriores quedan en el registro de cálculos, con los parámetros que usaron).
3. La bitácora conserva el valor erróneo y quién lo cargó.

## 6. Revertir una activación

No hay "deshacer". Opciones, de menor a mayor impacto:
1. **Ajuste correctivo** (sección 5), que resuelve casi todos los casos.
2. **Restaurar el respaldo** del paso 0 en una base nueva y verificar, y solo entonces reemplazar. Se pierden los cambios hechos después del respaldo.

## 7. Cuándo el cambio exige tocar el código

Los parámetros cubren valores y vigencias, pero **no estructuras nuevas**. Hace falta una versión nueva del sistema cuando:
- La DIAN agrega o cambia **formatos de exógena** con columnas distintas.
- Una norma crea un **tope o un concepto nuevo** que el modelo no tiene.
- Cambia la **fórmula** de un cálculo, no solo su valor.

En esos casos: registrar la necesidad como incidencia, actualizar `06-reglas-de-negocio.md` (nueva regla con fuente) y después el código y las pruebas.

## 8. Qué hacer si faltan parámetros

| Situación | Efecto en el sistema | Acción |
|---|---|---|
| No existe el conjunto del año | Alerta en el panel; los cálculos fallan con `PARAMETRO_FALTANTE` | Crear el conjunto |
| Existe, pero falta un parámetro | El cálculo que lo necesita falla indicando cuál | Cargarlo con fuente |
| La norma aún no se publica | El parámetro sigue en borrador | Esperar; no estimar |

## 9. Registro anual (plantilla)

| Año | Fecha de activación | Responsable | Respaldo previo | Observaciones |
|---|---|---|---|---|
| 2027 | | | | |
