# Guía de desarrollo

> Versión 0.1 · 17-oct-2026 · Estado: borrador. Define cómo se escribe, prueba y sube el código de ContaNegocios.

## 1. Entorno y versiones

Las versiones exactas se anotan al iniciar el código, tomándolas del equipo real (no se escriben de memoria). Ejecuta estos comandos y registra el resultado:

```powershell
node -v
npm -v
git --version
psql --version
```

| Componente | Versión instalada | Fecha de registro |
|---|---|---|
| Node.js | v24.14.0 (informada por el autor) | 17-oct-2026 |
| npm | 11.9.0 (informada por el autor) | 17-oct-2026 |
| PostgreSQL | 18 (visto en pgAdmin 4; versión menor sin registrar ❓) | 17-oct-2026 |
| Git | ❓ por registrar (`git --version`) | |

El backend de F1-03 se probó también con Node 24.14.0 (7 pruebas aprobadas y respuesta correcta de `/api/v1/salud` con PostgreSQL real).

Las dependencias del proyecto se instalan con `npm install <paquete>`: npm anota en `package.json` la versión real que instaló, y `package-lock.json` la fija. **No se editan versiones a mano.** Ambos archivos se suben al repositorio.

## 2. Decisiones de desarrollo (ADR)

| ADR | Decisión | Estado |
|---|---|---|
| ADR-012 | Backend en JavaScript con módulos **CommonJS** (`require`), por simplicidad con Jest y coherencia con FerreControl | Propuesta |
| ADR-013 | Flujo de ramas simple: `main` siempre estable y una rama corta por tarea (`feat/...`, `fix/...`, `docs/...`) | Propuesta |
| ADR-014 | Commits con prefijo de tipo (ver sección 4) | Propuesta |
| ADR-015 | Las reglas de cálculo se escriben **primero como pruebas** (casos de `02-casos-de-prueba.md`) y luego como código | Propuesta |

## 3. Estructura del proyecto

Ver `02-diseno/01-arquitectura.md`, sección 3. Reglas:

- Un módulo por carpeta en `backend/src/modules/`, con `routes`, `controller`, `service`, `repository` y `schema`.
- El SQL vive **solo** en los repositorios.
- Las reglas de cálculo viven en `backend/src/rules/` como **funciones puras** (reciben datos y parámetros, devuelven resultados; no leen la base de datos ni `req`/`res`).
- Ninguna cifra tributaria o laboral en el código (RNF-08): todo sale de parámetros.

## 4. Git: ramas, commits y subida

### 4.1 Flujo por tarea

```powershell
git checkout main
git pull
git checkout -b feat/auth-login
# ... trabajar, probar ...
git status
git add <archivos>
git commit -m "feat: iniciar sesión con bloqueo por intentos"
git push -u origin feat/auth-login
```

Al terminar la tarea, se fusiona con `main`. Dos formas:
- **Desde GitHub:** abrir una *Pull Request* y fusionarla (deja historial y evidencia para el portafolio).
- **Desde la consola:**

```powershell
git checkout main
git merge feat/auth-login
git push
```

Después de fusionar, la rama se puede borrar: `git branch -d feat/auth-login`.

### 4.2 Prefijos de commit

| Prefijo | Uso |
|---|---|
| `feat:` | Función nueva |
| `fix:` | Corrección de un error |
| `docs:` | Documentación |
| `test:` | Pruebas |
| `refactor:` | Reorganización sin cambiar el comportamiento |
| `chore:` | Configuración, dependencias, scripts |

Mensaje corto, en infinitivo o descriptivo, y que diga **qué** cambia: `feat: registrar movimientos con anulación`.

### 4.3 Reglas

- **Nunca** se sube `.env`, claves, `node_modules/`, soportes ni respaldos (el `.gitignore` los excluye; revisa `git status` antes de `git add`).
- Un commit = un cambio con sentido, no "todo lo del día".
- Antes de subir: las pruebas del módulo pasan.
- Si te equivocas antes de hacer `push`, `git status` y `git diff` ayudan a revisar; si algo sale mal, pega el mensaje y lo resolvemos.

## 5. Estilo de código

| Tema | Regla |
|---|---|
| Nombres | Tablas y columnas en español `snake_case` (ADR-001); variables y funciones del código en el idioma que ya uses en el repositorio, de forma consistente |
| Funciones | Pequeñas y con una responsabilidad |
| Errores | El servicio lanza errores con `codigo` y `mensaje`; un middleware único los convierte al formato de `04-api.md` |
| Dinero | Texto decimal exacto hacia afuera, `NUMERIC` en la base; **nunca** `float` (ADR-004). Para cálculos en JavaScript se usará una librería de decimales (se define con el primer cálculo, ❓ pendiente) |
| Fechas | `YYYY-MM-DD` para fechas de hechos; no depender de la zona horaria del equipo |
| SQL | Consultas parametrizadas (`$1`, `$2`); nunca concatenar texto del usuario |
| Registros (logs) | Sin documentos, claves ni tokens |
| Comentarios | Explican el **porqué** o citan la regla (`// RN-12: frontera del tope`) |
| Secretos | Solo en `.env` |

## 6. Pruebas durante el desarrollo

- Cada regla de `06-reglas-de-negocio.md` implementada trae su prueba, con el resultado esperado **calculado a mano** (ADR-015).
- Las pruebas de integración usan una **base de pruebas separada**, reiniciada en cada ejecución.
- Antes de cerrar una tarea: pasan las pruebas del módulo y las anteriores.

## 7. Definición de "hecho" para una tarea

- Cumple su requisito o historia (se cita el ID).
- Tiene pruebas y pasan.
- Las rutas nuevas validan **sesión, rol y pertenencia al cliente** (`05-seguridad.md`).
- Las acciones relevantes escriben en la bitácora.
- Sin secretos ni datos reales en el commit.
- La documentación afectada se actualizó (por ejemplo, `04-api.md` si cambió un endpoint).
- La tarjeta de Trello se movió a **Hecho**.

## 8. Cuando el código y la documentación no coinciden

La documentación es la referencia, pero el código puede revelar que algo estaba mal diseñado. En ese caso: se corrige el **documento** primero (con su cambio en el historial de Git) y luego el código, para que nunca queden dos versiones de la verdad.
