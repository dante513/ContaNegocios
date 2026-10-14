[README (2).md](https://github.com/user-attachments/files/33410341/README.2.md)
# ContaNegocios

> Plataforma web de apoyo para el **contador que lleva varios clientes personas naturales**: organiza los movimientos de cada cliente durante el año, avisa cuándo se superan los topes que obligan a declarar y prepara los papeles de trabajo de **renta**, **información exógena**, **GMF (4x1000)** y **nómina**.

**Estado:** 📝 en fase de documentación (análisis). Aún no hay código.
**Nombre:** provisional.

---

## ¿Qué problema resuelve?

Un contador independiente que lleva a varias personas naturales recibe la información dispersa: extractos, facturas, certificados, recibos. Al llegar la temporada de renta tiene que reconstruir todo, verificar si cada cliente está obligado a declarar, preparar la información exógena y revisar el 4x1000 pagado. Es un trabajo repetitivo y propenso a errores.

**Idea central:** que el contador abra el expediente de un cliente y vea, en un solo lugar, cuánto lleva acumulado en el año frente a cada tope, qué obligaciones tiene y qué papeles de trabajo ya están listos para cargar.

## Módulos previstos

| Módulo | Qué hace | Fase |
|---|---|---|
| Despacho multi-cliente | Expediente por cliente, roles (contador, auxiliar, cliente) | F1 |
| Parámetros por año | UVT, salario mínimo, topes y demás matrices con vigencia, fuente y módulo de actualización anual (1-2 de enero) | F1 |
| Semáforo de obligaciones | Avance de cada cliente frente a los topes de renta y exógena | F2 |
| GMF (4x1000) | Exención mensual y deducción en renta | F2 |
| Calendario | Vencimientos por cliente | F2 |
| Renta y exógena | Borradores y papeles de trabajo exportables a Excel y PDF | F3 |
| Nómina | Liquidación mensual, aportes y provisiones | F4 |
| Importación | Extractos en Excel/CSV, categorización y conciliación | F5 |

## Principios de diseño

- **Nada tributario o laboral queda "quemado" en el código.** Todo valor sale de un parámetro con vigencia y fuente.
- **Cada regla lleva su fuente y su nivel de verificación** (✅ verificado · ⚠️ probable · ❓ no verificado).
- **Soporta cambios a mitad de año:** un cálculo usa el valor vigente en la fecha del hecho.
- **Solo datos ficticios** en este repositorio.

## Alcance

**Dentro de la v1:** personas naturales, movimientos, parámetros anuales, semáforo de obligaciones, GMF, borradores de renta y exógena, nómina, auditoría de cambios.

**Fuera de la v1:** presentar declaraciones ante la DIAN (se prepara el papel de trabajo; la presentación oficial se hace por el portal con firma electrónica), facturación electrónica, personas jurídicas (el diseño las deja previstas).

## Stack previsto

React + Vite + Tailwind · Node.js / Express · PostgreSQL (decisión pendiente frente a SQLite) · Jest + Supertest

## Documentación

| Documento | Descripción |
|---|---|
| [Plan de documentación](docs/00-plan-de-documentacion.md) | Mapa de todos los documentos, convenciones y decisiones abiertas |
| [Visión y alcance](docs/01-analisis/01-vision-y-alcance.md) | Problema, visión, alcance, riesgos y fases |
| [Requisitos](docs/01-analisis/02-requisitos.md) | Requisitos funcionales y no funcionales |
| [Parámetros anuales y actualización](docs/01-analisis/03-parametros-anuales-y-actualizacion.md) | Catálogo de parámetros y procedimiento de actualización anual |

Próximos: historias de usuario, glosario contable, reglas de negocio, diseño (arquitectura, modelo de datos, UML, API, seguridad), pruebas y manuales de usuario.

## Hoja de ruta

1. **Documentación** (análisis, diseño, pruebas, despliegue) ← *estamos aquí*
2. **F1** Núcleo: usuarios, clientes, movimientos y parámetros por año
3. **F2** Obligaciones: semáforo, GMF y calendario
4. **F3** Renta y exógena
5. **F4** Nómina
6. **F5** Importación, conciliación y cierre

## Aviso

Este proyecto es una herramienta de apoyo y de portafolio. Los resultados son **papeles de trabajo** y no reemplazan el criterio profesional del contador ni la verificación contra la norma vigente (DIAN, decretos, Estatuto Tributario). Las cifras de ejemplo de la documentación corresponden a las fuentes citadas en cada documento, con su fecha de verificación.

## Autor

**Danny Dulcey** · [github.com/dante513](https://github.com/dante513)
