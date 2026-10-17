# Parámetros anuales y actualización

> Versión 0.2 · 17-oct-2026 · Fecha de verificación de las fuentes: 13 y 17-oct-2026

## 1. Principio

Ninguna cifra tributaria o laboral vive en el código. Todo se guarda como **parámetro con vigencia, fuente y estado**. Así, el 1 o 2 de enero el contador carga los valores del nuevo año desde la pantalla de actualización, sin que haya que programar nada.

## 2. Modelo conceptual de un parámetro

| Campo | Descripción |
|---|---|
| `codigo` | Identificador estable, por ejemplo `UVT`, `SMMLV` |
| `valor` | Valor numérico o porcentaje |
| `unidad` | COP, UVT, %, días |
| `vigente_desde` / `vigente_hasta` | Fechas exactas (permite cambios a mitad de año) |
| `fuente_norma` | Decreto, resolución o artículo |
| `fuente_url` | Enlace de verificación |
| `nivel_verificacion` | Verificado, probable o no verificado |
| `estado` | Borrador, en revisión, activo, histórico |
| `creado_por` / `aprobado_por` | Quien lo cargó y quien lo aprobó (personas distintas) |

Un parámetro activo nunca se sobrescribe: se cierra con `vigente_hasta` y se crea uno nuevo.

## 3. Catálogo inicial

### 3.1 Tributarios

| Código | Valor de referencia | Fuente | Nivel |
|---|---|---|---|
| `UVT` 2025 | $49.799 | Siigo; Gerencie | ✅ |
| `UVT` 2026 | $52.374 | Siigo | ✅ |
| `RENTA_TOPE_INGRESOS` | 1.400 UVT ($69.718.600 con UVT 2025) | Publimetro, 30-jun-2026; Rankia | ✅ |
| `RENTA_TOPE_TARJETA` | 1.400 UVT | Publimetro, 30-jun-2026 | ✅ |
| `RENTA_TOPE_COMPRAS` | 1.400 UVT | Publimetro, 30-jun-2026 | ✅ |
| `RENTA_TOPE_PATRIMONIO` | 4.500 UVT ($224.095.500 con UVT 2025), a 31 de diciembre | Cronista (cita a la DIAN); Rankia; Accounter | ✅ |
| `RENTA_TOPE_CONSIGNACIONES` | 1.400 UVT ($69.718.600 con UVT 2025) | Cronista; Rankia; Accounter | ✅ |
| `RENTA_TOPE_OPERADOR` | Por tope: `>=` o `>` (las fuentes difieren en la frontera; ver RN-12 en `06`) | Estatuto Tributario | ⚠️ |
| `EXOGENA_TOPE_INGRESOS_PN` | 11.800 UVT de ingresos brutos | Gerencie, citando la Res. DIAN 227 de 2025 | ✅ |
| `EXOGENA_TOPE_RENTAS_CAPITAL_PN` | 2.400 UVT de rentas de capital o no laborales | Gerencie, citando la Res. DIAN 227 de 2025 | ✅ |
| `GMF_EXENCION_MENSUAL` | 350 UVT por mes | Art. 879 ET (según Tributi, Gerencie) | ✅ |
| `GMF_DEDUCCION_RENTA` | 50% del GMF pagado | Tributi (art. 115 ET) | ✅ |
| `RENTA_CALENDARIO` | 12-ago a 26-oct-2026, por los dos últimos dígitos del documento | Rankia; Publimetro | ⚠️ Siigo indica 23-oct como cierre; tabla editable, confirmar en la DIAN |
| `EXOGENA_FORMATOS` | Lista de formatos y versión por año gravable | Res. DIAN 227/2025 y sus modificaciones (ver nota) | ⚠️ |
| `RENTA_TARIFA` | Tabla de tarifas por rangos en UVT | Estatuto Tributario | ❓ |

*Nota sobre exógena:* las modificaciones citadas por las fuentes consultadas son la Res. 000233 de 2025, la Res. 000012 del 29-abr-2026 y la Res. 000021 del 17-jul-2026. Para el año gravable 2026 se suman formatos nuevos.

### 3.2 Laborales (nómina)

| Código | Valor de referencia | Fuente | Nivel |
|---|---|---|---|
| `SMMLV` 2025 | $1.423.500 | Decreto 1469 de 2025 (comparativo) | ✅ |
| `SMMLV` 2026 | $1.750.905 | Decreto 1469 del 29-dic-2025 | ✅ |
| `AUXILIO_TRANSPORTE` 2025 | $200.000 | Decreto 1470 de 2025 (comparativo) | ✅ |
| `AUXILIO_TRANSPORTE` 2026 | $249.095 | Decreto 1470 del 29-dic-2025 | ✅ |
| `AUXILIO_TOPE_SALARIO` | Hasta 2 SMMLV | El País (Cali), 12-abr-2026 | ✅ |
| `HORA_ORDINARIA_MINIMO` | $7.959 hasta el 14-jul-2026; $8.338 desde el 15-jul-2026 | Buk | ⚠️ Fuente única; refleja el cambio de jornada a mitad de año |
| `APORTE_SALUD_EMPLEADO`, `APORTE_PENSION_EMPLEADO` | 4% y 4% | Conocimiento general | ⚠️ Verificar en norma |
| `APORTE_SALUD_EMPLEADOR`, `APORTE_PENSION_EMPLEADOR`, `ARL`, `CAJA`, `SENA`, `ICBF` | Por confirmar, incluida la exoneración de aportes según salario | Norma laboral y tributaria | ❓ |
| `PRIMA`, `CESANTIAS`, `INTERESES_CESANTIAS`, `VACACIONES` | Por confirmar | Código Sustantivo del Trabajo | ❓ |

⚠️ *Observación importante:* el salario mínimo de 2026 se fijó por decreto tras no haber acuerdo, y según las fuentes hubo una suspensión y un nuevo decreto (0159 de 2026) que mantuvo el mismo valor. Por eso cada parámetro guarda su norma de origen y puede reemplazarse con una nueva vigencia.

⚠️ *Dato descartado:* un medio publicó $1.746.882 y $253.000 como valores desagregados, pero contradicen los decretos y a las demás fuentes. No se usan.

## 4. Procedimiento de actualización anual

### 4.1 Preparación (diciembre)
1. El sistema muestra una alerta desde mediados de diciembre: "Faltan parámetros del año siguiente".
2. El contador crea el **conjunto del nuevo año** en estado *borrador*, copiado del año anterior para no partir de cero.
3. Carga los valores nuevos a medida que se publican los decretos (salario mínimo y auxilio suelen publicarse a finales de diciembre).

### 4.2 Revisión
4. Cada parámetro modificado exige **fuente** (norma y enlace).
5. El sistema genera un **reporte de diferencias** entre años (valor anterior, valor nuevo, variación %).
6. Una segunda persona (o el mismo contador en un segundo paso explícito) aprueba. El sistema impide que quien cargó el valor sea quien lo aprueba cuando hay más de un usuario.

### 4.3 Activación (1 o 2 de enero)
7. El contador abre la pantalla **Actualizar año** y activa el conjunto con fecha de vigencia 1 de enero.
8. El sistema cierra con `vigente_hasta = 31 de diciembre` los parámetros del año anterior.
9. Se ejecuta el **checklist de enero**:
   - [ ] UVT del año
   - [ ] Salario mínimo y auxilio de transporte
   - [ ] Topes de renta y de exógena del año gravable que corresponde
   - [ ] Calendario tributario del año
   - [ ] Formatos de exógena y sus versiones
   - [ ] Porcentajes de aportes de nómina y prestaciones
   - [ ] Tarifas de renta
10. Queda registro en la bitácora: quién activó, cuándo y qué cambió.

### 4.4 Cambios durante el año
Si una norma cambia a mitad de año, se crea un parámetro nuevo con `vigente_desde` en esa fecha. Los cálculos (por ejemplo, una nómina de julio) usan el valor vigente **en la fecha del hecho**, no el del año completo.

### 4.5 Qué NO hace la actualización
- No recalcula años cerrados.
- No borra histórico.
- No cambia movimientos ya registrados.

## 5. Año gravable y año de declaración

Hay que distinguir dos años: el **año gravable** (el que se declara) y el **año de presentación** (cuando se declara). Los topes de la renta que se presenta en 2026 se calculan con la UVT del año gravable 2025. Por eso cada cálculo guarda con qué año de parámetros se hizo.

## 6. Fuentes consultadas (13-oct-2026)

| Dato | Fuente | Enlace |
|---|---|---|
| UVT 2025 y 2026 | Siigo | https://www.siigo.com/blog/contador/declaracion-de-renta-todo-lo-que-debes-saber/ |
| Topes de renta, AG 2025 | Publimetro, 30-jun-2026; Rankia; Cronista; Accounter | https://www.publimetro.co/noticias/2026/06/30/esta-entre-los-7-millones-la-dian-confirma-las-fechas-y-topes-para-declarar-renta-este-ano/ |
| Topes de exógena para personas naturales | Gerencie | https://www.gerencie.com/contribuyentes-obligados-a-presentar-informacion-exogena.html |
| Modificaciones de exógena | INCP (jul-2026); Crowe (abr-2026); KPMG (14-nov-2025) | https://incp.org.co/publicaciones/infoincp-publicaciones/impuestos/2026/07/dian-ajusto-formatos-y-amplio-plazos-para-informacion-exogena-del-ano-gravable-2025/ |
| GMF y deducción del 50% | Tributi; Gerencie | https://www.tributi.com/blog/impuestos/posts/como-descontar-el-4x1-000-en-la-declaracion-de-renta |
| Salario mínimo y auxilio 2026 | ConsultorSalud (Decretos 1469 y 1470 de 2025) | https://consultorsalud.com/aumento-del-salario-minimo-en-colombia-2026/ |
| Tope del auxilio y decreto 0159 de 2026 | El País (Cali), 12-abr-2026 | https://www.elpais.com.co/economia/salario-minimo-2026-sin-auxilio-de-transporte-cuanto-queda-y-en-que-casos-no-se-paga-1108.html |
| Valor de la hora ordinaria | Buk | https://www.buk.co/blog/salario-minimo-colombia |

**Limitación:** casi todas son fuentes secundarias (prensa y blogs contables). Antes de programar cada regla debe contrastarse con la norma primaria en dian.gov.co o en la entidad que la expide.
