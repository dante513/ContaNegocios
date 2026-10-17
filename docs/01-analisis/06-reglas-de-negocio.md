# Reglas de negocio

> Versión 0.1 · 17-oct-2026 · Fuentes consultadas el 17-oct-2026. Cada regla indica fuente y nivel de verificación (✅ verificado · ⚠️ probable · ❓ no verificado). Las reglas internas de diseño se marcan como **(diseño)** y no son normativas.

Todos los valores numéricos salen de **parámetros** (ver `03`), nunca del código.

## 1. Reglas generales

| ID | Regla | Fuente / nivel |
|---|---|---|
| RN-01 | Un cálculo usa el parámetro vigente en la fecha del hecho (movimiento, nómina), no el del año completo. | (diseño) |
| RN-02 | Los topes para declarar renta de un año gravable se calculan con la UVT de ese año gravable (topes de la renta presentada en 2026: UVT 2025 = $49.799). | ✅ Rankia; Cronista (cita a la DIAN) |
| RN-03 | El tope en pesos es `tope_en_UVT × UVT` sin redondeo intermedio. Ejemplo: 1.400 × 49.799 = $69.718.600; 4.500 × 49.799 = $224.095.500. Algunas fuentes publican $69.719.000 por redondeo. | ✅ cálculo verificado contra Rankia y Accounter |
| RN-04 | Cada resultado debe mostrar el parámetro usado y su fuente. | (diseño) |

## 2. Obligación de declarar renta (año gravable 2025, presentación 2026)

| ID | Regla | Fuente / nivel |
|---|---|---|
| RN-10 | Existen cinco topes: ingresos brutos ≥ 1.400 UVT; patrimonio bruto a 31-dic ≥ 4.500 UVT; consumos con tarjeta de crédito ≥ 1.400 UVT; compras y consumos ≥ 1.400 UVT; consignaciones, depósitos o inversiones financieras acumuladas ≥ 1.400 UVT. | ✅ Rankia; Cronista; Accounter |
| RN-11 | Basta superar **uno** para quedar obligado a declarar. | ✅ Cronista; Accounter |
| RN-12 | **Frontera del tope:** las fuentes no coinciden en si "igual al tope" obliga. Rankia dice "iguales o superiores" en todos; Accounter usa "no exceda" para patrimonio, tarjeta, compras y consignaciones, e "inferiores a" para ingresos. El parámetro de cada tope debe incluir su operador (`>=` o `>`). | ⚠️ Verificar en el Estatuto Tributario (artículo 592, de conocimiento general, no verificado en esta búsqueda) |
| RN-13 | **Asalariados vs. otras personas naturales:** una fuente indica que los asalariados se evalúan con los cinco criterios y las otras personas naturales con tres (patrimonio, ingresos y consignaciones). Esto afecta qué topes debe mostrar el semáforo según el tipo de cliente. | ⚠️ Fuente única (Accounter); contrastar con la norma |
| RN-14 | Quien tuvo únicamente retenciones en la fuente puede presentar declaración voluntaria (por ejemplo, para pedir devolución de saldo a favor). | ⚠️ Fuente única (Accounter, citando el art. 6 ET) |
| RN-15 | Los ingresos se agrupan en cinco cédulas: rentas de trabajo, de pensiones, de capital, no laborales y otros. | ✅ Rankia |
| RN-16 | Plazo de presentación 2026: del 12 de agosto al 26 de octubre, según los dos últimos dígitos del NIT/documento. Siigo indica el 23 de octubre como cierre. El calendario es una tabla editable. | ⚠️ Rankia y Publimetro coinciden en el 26; Siigo difiere. Confirmar en la DIAN |

## 3. Semáforo de topes

| ID | Regla | Fuente / nivel |
|---|---|---|
| RN-20 | Estado verde: avance < 70% del tope; amarillo: entre 70% y 99,99%; rojo: ≥ 100%. Los umbrales 70% y 100% son configurables. | (diseño) 💭 Decisión de producto, no normativa |
| RN-21 | El avance se calcula con los movimientos del año gravable del cliente (patrimonio: saldo a 31 de diciembre). | (diseño) |

## 4. GMF (4x1000)

| ID | Regla | Fuente / nivel |
|---|---|---|
| RN-30 | La tarifa del GMF es 4 por mil (0,4%) sobre las transacciones gravadas. | ✅ Conocimiento general, consistente con las fuentes consultadas |
| RN-31 | Exención mensual de retiros: hasta 350 UVT por mes (≈ $18.330.900 con UVT 2026). | ✅ Tributi; Gerencie (art. 879 ET). Valor en pesos: ⚠️ calculadora web |
| RN-32 | El 50% del GMF efectivamente pagado es deducible en renta. | ✅ Tributi (art. 115 ET) |
| RN-33 | Si la exención exige o no una cuenta marcada es motivo de discrepancia entre fuentes (una cita el art. 881-1; otras indican que los bancos no lo han implementado del todo). La "cuenta marcada" es un campo opcional. | ⚠️ Confirmar en la norma y con el banco |

## 5. Información exógena (personas naturales)

| ID | Regla | Fuente / nivel |
|---|---|---|
| RN-40 | Personas naturales con ingresos brutos superiores a 11.800 UVT y, además, más de 2.400 UVT en rentas de capital o no laborales deben reportar. | ✅ Gerencie (citando la Res. DIAN 227 de 2025) |
| RN-41 | La lista de formatos y sus versiones cambia por año gravable; es parámetro. Para el año gravable 2026 se suman formatos nuevos. | ✅ KPMG (14-nov-2025); INCP (jul-2026) |
| RN-42 | La resolución base fue modificada por las Res. 233 de 2025, 12 del 29-abr-2026 y 21 del 17-jul-2026. | ✅ KPMG; Crowe; INCP |
| RN-43 | El reporte se presenta virtualmente con firma electrónica. El sistema solo prepara el papel de trabajo. | ✅ INCP |
| RN-44 | Cuantías mínimas por concepto y formato para incluir un tercero. | ❓ Pendiente de verificar |

## 6. Nómina

| ID | Regla | Fuente / nivel |
|---|---|---|
| RN-50 | SMMLV 2026: $1.750.905 (Decreto 1469 de 2025). | ✅ ConsultorSalud |
| RN-51 | Auxilio de transporte 2026: $249.095 (Decreto 1470 de 2025), para quien devenga hasta 2 SMMLV. | ✅ ConsultorSalud; El País (Cali) |
| RN-52 | El valor de la hora ordinaria puede cambiar a mitad de año ($7.959 hasta el 14-jul-2026; $8.338 desde el 15-jul-2026). | ⚠️ Fuente única (Buk) |
| RN-53 | Aportes del trabajador: 4% salud y 4% pensión sobre el IBC. | ⚠️ Conocimiento general; verificar en norma |
| RN-54 | Aportes del empleador, parafiscales, exoneraciones y prestaciones sociales (prima, cesantías, intereses, vacaciones): porcentajes y condiciones. | ❓ Pendiente de verificar |

## 7. Gobierno de los parámetros (diseño)

| ID | Regla |
|---|---|
| RN-60 | Todo parámetro nuevo o modificado exige fuente (norma y enlace). |
| RN-61 | Con más de un usuario, quien carga un parámetro no puede ser quien lo aprueba. |
| RN-62 | Un parámetro activo no se sobrescribe: se cierra con `vigente_hasta` y se crea uno nuevo. |
| RN-63 | Toda activación o cambio queda en la bitácora. |

## 8. Fuentes

| Referencia | Enlace |
|---|---|
| Rankia, topes de renta | https://www.rankia.co/blog/dian/4179376-cuales-son-topes-para-declarar-renta |
| Rankia, formulario 210 y plazos | https://www.rankia.co/blog/dian/3097523-como-presentar-declaracion-renta-formulario-210 |
| El Cronista (cita a la DIAN) | https://www.cronista.com/colombia/finanzas-y-economia/ya-es-oficial-la-dian-obligara-a-declarar-renta-a-quienes-superen-alguno-de-estos-cinco-topes/ |
| Accounter | https://accounter.co/noticias/editorial/accounter-topes-declarante-de-renta-2026 |
| Publimetro, 30-jun-2026 | https://www.publimetro.co/noticias/2026/06/30/esta-entre-los-7-millones-la-dian-confirma-las-fechas-y-topes-para-declarar-renta-este-ano/ |
| Gerencie, exógena | https://www.gerencie.com/contribuyentes-obligados-a-presentar-informacion-exogena.html |
| INCP, jul-2026 | https://incp.org.co/publicaciones/infoincp-publicaciones/impuestos/2026/07/dian-ajusto-formatos-y-amplio-plazos-para-informacion-exogena-del-ano-gravable-2025/ |
| Crowe, abr-2026 | https://www.crowe.com/co/news/dian-amplia-plazos-y-modifica-reportes-de-informacion-exogena-medios-magneticos |
| KPMG, 14-nov-2025 | https://kpmg.com/co/es/home/insights/2025/11/flash-informativo-noviembre-14.html |
| Tributi, GMF | https://www.tributi.com/blog/impuestos/posts/como-descontar-el-4x1-000-en-la-declaracion-de-renta |
| ConsultorSalud, SMMLV 2026 | https://consultorsalud.com/aumento-del-salario-minimo-en-colombia-2026/ |
| El País (Cali), 12-abr-2026 | https://www.elpais.com.co/economia/salario-minimo-2026-sin-auxilio-de-transporte-cuanto-queda-y-en-que-casos-no-se-paga-1108.html |
| Buk, hora ordinaria | https://www.buk.co/blog/salario-minimo-colombia |

**Limitación:** casi todas son fuentes secundarias (prensa y blogs contables). Antes de programar cada regla debe contrastarse con la norma primaria.
