# Plan de pruebas

> Versión 0.1 · 17-oct-2026 · Estado: borrador. Define cómo se comprobará que ContaNegocios cumple los requisitos (`01-analisis/02-requisitos.md`) y las reglas de negocio (`01-analisis/06-reglas-de-negocio.md`).

## 1. Objetivo

Demostrar que:
1. Los cálculos tributarios y laborales son correctos y reproducibles (RN-01 a RN-54).
2. Los permisos y la seguridad funcionan en el backend (RNF-01 a RNF-03).
3. Ninguna cifra normativa está escrita en el código (RNF-08): cambiar un parámetro cambia el resultado.
4. El flujo completo del contador funciona de punta a punta.

## 2. Alcance

| Dentro | Fuera |
|---|---|
| Backend (API y motor de reglas), base de datos, frontend, exportes, seguridad, accesibilidad básica | Pruebas de carga masiva, pruebas en otros sistemas operativos distintos de Windows, validación legal de las declaraciones frente a la DIAN |

Las pruebas verifican que el **sistema aplica correctamente los parámetros cargados**. No certifican que los parámetros coincidan con la norma vigente: eso se controla con el proceso de actualización anual (ver `05-despliegue/03-actualizacion-anual.md`).

## 3. Niveles y herramientas

Se usa el mismo enfoque que en FerreControl, para no introducir herramientas nuevas.

| Nivel | Qué prueba | Herramienta |
|---|---|---|
| Unitarias | Funciones puras del motor de reglas (topes, semáforo, GMF, nómina) | Jest |
| Integración de API | Endpoints con base de datos real de pruebas, roles y errores | Jest + Supertest |
| Exploratorias de API | Colecciones manuales de apoyo | Postman |
| Frontend | Componentes y formularios | Vitest + React Testing Library |
| Extremo a extremo | Recorrido completo del contador | Playwright |
| Accesibilidad | Reglas automáticas sobre las pantallas | Axe |
| Seguridad | Casos adicionales (ver `03-pruebas-de-seguridad.md`) | Postman, Supertest y revisión manual |

Las versiones exactas de cada herramienta se fijan en la guía de desarrollo al iniciar el código. ❓ No se registran aquí.

## 4. Entorno y datos de prueba

- Base de datos **separada** de la de uso diario, creada desde `database/schema.sql`.
- Datos de demostración (`database/seed-demo.sql`), todos ficticios (RNF-09):

| Cliente demo | Propósito |
|---|---|
| Cliente en rango | Semáforo verde en todos los topes |
| Cliente en atención | Un tope entre 70% y 99,99% |
| Cliente superado | Al menos un tope en 100% o más |
| Cliente asalariado | Prueba de RN-13 (criterios por tipo de contribuyente, pendiente de validar) |
| Cliente empleador con 3 empleados | Nómina, incluido un salario mayor a 2 SMMLV |

- Parámetros de prueba: dos años (2025 y 2026) con los valores verificados de `03-parametros-anuales-y-actualizacion.md`.
- Cada prueba de integración parte de un estado conocido (se reinicia la base de pruebas).

## 5. Estrategia por prioridad

| Prioridad | Qué se prueba | Meta propuesta |
|---|---|---|
| Crítica | Motor de reglas, vigencia de parámetros, activación del año, permisos, cifrado, bitácora | Todos los casos pasan antes de cada versión |
| Alta | Movimientos, anulación, semáforo, GMF, nómina, exportes | Todos los casos pasan |
| Media | Calendario, importación, interfaz | Los casos fallidos quedan registrados y con plan |

Meta de cobertura del motor de reglas: 90% de líneas o más (propuesta; se confirma al tener código).

## 6. Criterios

**Entrada:** requisitos y reglas del módulo en versión estable; base de pruebas creada; datos demo cargados.
**Salida de una fase de implementación:** 100% de los casos críticos y altos del módulo aprobados; sin incidencias abiertas de severidad alta.

## 7. Incidencias

Cada fallo se registra con: ID, caso asociado, descripción, pasos, resultado esperado y obtenido, severidad (alta, media, baja), estado (abierta, en corrección, verificada, cerrada) y evidencia (captura o salida de consola). Se siguen en el tablero de Trello del proyecto y se resumen en `02-casos-de-prueba.md` o en el informe de ejecución.

| Severidad | Criterio |
|---|---|
| Alta | Cálculo incorrecto, fuga de datos, falla de permisos, pérdida de datos |
| Media | Funcionalidad que no cumple el requisito pero tiene solución alterna |
| Baja | Texto, presentación o mejora menor |

## 8. Informe de ejecución

Después de cada ciclo se genera un informe: fecha, versión probada, casos ejecutados, aprobados, fallidos y bloqueados, incidencias abiertas y decisión (aprobar o no la fase). Se guardan en `04-pruebas/informes/`.

## 9. Trazabilidad

La matriz completa está en `02-casos-de-prueba.md` (columna **Ref.**). Cada requisito Must debe tener al menos un caso.

## 10. Riesgos de las pruebas

| Riesgo | Mitigación |
|---|---|
| Valores esperados calculados con la misma fórmula del código | Los resultados esperados se calculan **a mano** y se documentan en el caso |
| Parámetros de prueba que no reflejan la norma | Se marcan con su nivel de verificación y se revisan en cada actualización anual |
| Pruebas frágiles por datos compartidos | Base reiniciada por prueba y datos propios por caso |
