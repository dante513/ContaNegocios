# Plan de documentación — ContaNegocios

> **Nombre provisional.** Versión 0.7 · 17 de octubre de 2026 · Autor: Danny Dulcey (GitHub: dante513)

## 1. Propósito

Plataforma web de apoyo para el **contador que lleva varios clientes personas naturales**: organiza los movimientos de cada cliente durante el año, avisa cuándo se superan los topes que obligan a declarar, y prepara los papeles de trabajo de **renta**, **información exógena**, **GMF (4x1000)** y **nómina**.

Este documento es el mapa de toda la documentación: qué se escribe, en qué orden y cuándo se considera terminado.

## 2. Estructura del repositorio

```
ContaNegocios/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── docs/
│   ├── 00-plan-de-documentacion.md      (este archivo)
│   ├── 01-analisis/
│   │   ├── 01-vision-y-alcance.md
│   │   ├── 02-requisitos.md
│   │   ├── 03-parametros-anuales-y-actualizacion.md
│   │   ├── 04-historias-de-usuario.md
│   │   ├── 05-glosario-contable.md
│   │   └── 06-reglas-de-negocio.md
│   ├── 02-diseno/
│   │   ├── 01-arquitectura.md
│   │   ├── 02-modelo-de-datos.md        (diagrama ER)
│   │   ├── 03-diagramas-uml.md          (casos de uso, secuencia, clases)
│   │   ├── 04-api.md
│   │   ├── 05-seguridad.md
│   │   └── 06-wireframes.md
│   ├── 03-desarrollo/
│   │   ├── 01-guia-de-desarrollo.md
│   │   └── 02-plan-f1.md
│   ├── 04-pruebas/
│   │   ├── 01-plan-de-pruebas.md
│   │   ├── 02-casos-de-prueba.md
│   │   └── 03-pruebas-de-seguridad.md
│   ├── 05-despliegue/
│   │   ├── 01-instalacion-local.md
│   │   ├── 02-respaldo-y-restauracion.md
│   │   └── 03-actualizacion-anual.md
│   ├── manual-usuario/
│   │   ├── 01-contador.md
│   │   ├── 02-auxiliar.md
│   │   └── 03-cliente.md
│   └── normativa/
│       └── fuentes-verificadas.md
├── backend/
├── frontend/
└── database/                             (esquema + datos de demostración)
```

## 3. Mapa de documentos

| Fase | Documento | Estado | Depende de |
|---|---|---|---|
| Análisis | Visión y alcance | ✏️ Borrador 0.1 | — |
| Análisis | Requisitos (RF/RNF) | ✏️ Borrador 0.1 | Visión |
| Análisis | Parámetros anuales y actualización | ✏️ Borrador 0.2 | Requisitos |
| Análisis | Historias de usuario | ✏️ Borrador 0.1 | Requisitos |
| Análisis | Glosario contable | ✏️ Borrador 0.1 | — |
| Análisis | Reglas de negocio (con fuente normativa) | ✏️ Borrador 0.1 | Parámetros |
| Diseño | Arquitectura | ✏️ Borrador 0.1 | Análisis |
| Diseño | Modelo de datos (ER) | ✏️ Borrador 0.2 | Análisis |
| Diseño | API | ✏️ Borrador 0.1 | Arquitectura, modelo de datos |
| Diseño | Seguridad | ✏️ Borrador 0.1 | Arquitectura, API |
| Diseño | Diagramas UML | ✏️ Borrador 0.1 | Arquitectura, modelo de datos |
| Diseño | Wireframes | ✏️ Borrador 0.1 | Requisitos, API |
| Desarrollo | Guía de desarrollo | ✏️ Borrador 0.1 | Diseño |
| Desarrollo | Plan de la fase F1 | ✏️ Borrador 0.1 | Guía de desarrollo |
| Pruebas | Plan de pruebas | ✏️ Borrador 0.1 | Requisitos, reglas |
| Pruebas | Casos de prueba | ✏️ Borrador 0.1 | Plan de pruebas |
| Pruebas | Pruebas de seguridad | ✏️ Borrador 0.1 | Seguridad |
| Despliegue | Instalación local | ✏️ Borrador 0.1 (se confirma con el código) | Arquitectura |
| Despliegue | Respaldo y restauración | ✏️ Borrador 0.1 | Instalación |
| Despliegue | Actualización anual | ✏️ Borrador 0.1 | Parámetros |
| Usuario | Manuales por rol | ⏳ Pendiente | Desarrollo |

## 4. Orden de trabajo

1. **Lote D1 — Análisis** (este lote): visión, requisitos, parámetros anuales. Después: historias de usuario, glosario y reglas de negocio.
2. **Lote D2 — Diseño:** arquitectura, ER, UML, API, seguridad, wireframes.
3. **Lote D3 — Calidad y operación:** plan de pruebas, instalación, respaldo.
4. **Código por fases** (ver visión y alcance, sección 7). Los manuales de usuario se escriben con capturas reales.

## 5. Convenciones

- **Idioma:** español. Nombres de código en inglés o español, pero consistentes (decisión pendiente, ver ADR-001).
- **Identificadores:** `RF-xx` requisito funcional, `RNF-xx` no funcional, `RN-xx` regla de negocio, `HU-xx` historia de usuario.
- **Verificabilidad de reglas tributarias y laborales.** Toda cifra o regla lleva fuente, fecha de verificación y uno de estos niveles:
  - ✅ **Verificado:** confirmado en fuente primaria o en varias secundarias coincidentes.
  - ⚠️ **Probable:** de conocimiento general o fuente única; verificar antes de programar.
  - ❓ **No verificado:** pendiente de confirmar.
- **Diagramas:** Mermaid dentro de Markdown (se ven directo en GitHub).
- **Datos:** el repositorio solo contiene datos ficticios. Nunca datos reales de clientes.
- **Versionado de documentos:** versión en el encabezado y entrada en `CHANGELOG.md`.

## 6. Definición de "documento terminado"

- Tiene encabezado con versión, fecha y autor.
- Cada afirmación normativa tiene fuente y nivel de verificación.
- Todos los IDs referenciados existen en otro documento.
- Fue releído contra el código (o contra el diseño, si aún no hay código).

## 7. Decisiones abiertas

| # | Decisión | Opciones | Estado |
|---|---|---|---|
| 1 | Nombre definitivo | Se mantiene ContaNegocios; el cambio, si se hace, será al final | Aplazada (17-oct-2026) |
| 2 | Base de datos | PostgreSQL (rigidez e integridad para datos contables; ya conocida) | Decidida (17-oct-2026) |
| 3 | Alcance de nómina en v1 | Núcleo desde la fase 4 (propuesto) | Propuesta |
| 4 | Empresas (personas jurídicas) | Fuera de v1, diseño preparado para agregarlas | Acordada |
