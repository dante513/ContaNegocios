# Instalación local en Windows

> Versión 0.1 · 17-oct-2026 · Estado: borrador. **Guía prevista:** se escribe antes del código y se confirma con él. Los nombres de scripts (`npm run ...`) y de variables son propuestas; las versiones exactas ❓ se anotan al iniciar el desarrollo, tomándolas del equipo real.

## 1. Requisitos

| Componente | Detalle |
|---|---|
| Sistema | Windows 11 |
| Node.js y npm | Probado con Node.js v24.14.0 y npm 11.9.0 |
| PostgreSQL | 12 o superior (probado con la versión 18); incluir las herramientas de línea de comandos (`psql`, `pg_dump`, `pg_restore`) o usar pgAdmin |
| Git | Para clonar el repositorio |
| Editor | Visual Studio Code (opcional) |
| Espacio en disco | Para la base de datos, los soportes y los respaldos |

## 2. Resumen de pasos

1. Clonar el repositorio.
2. Crear la base de datos y sus usuarios.
3. Crear el archivo `.env`.
4. Cargar el esquema (y, si se desea, los datos de demostración).
5. Instalar dependencias.
6. Crear el primer usuario contador.
7. Arrancar y verificar.

## 3. Paso a paso

### 3.1 Clonar

```powershell
cd C:\proyectos
git clone https://github.com/dante513/ContaNegocios.git
cd ContaNegocios
```

### 3.2 Crear la base de datos y los usuarios

Abre `psql` como administrador de PostgreSQL:

```powershell
psql -U postgres
```

Dentro de `psql` (cambia las contraseñas por valores propios y fuertes):

```sql
CREATE DATABASE contanegocios;
CREATE ROLE contanegocios_app LOGIN PASSWORD 'CAMBIAR_ESTA_CLAVE';
GRANT CONNECT ON DATABASE contanegocios TO contanegocios_app;
\q
```

El usuario `contanegocios_app` es el que usará la aplicación. **No es administrador**: tendrá solo los permisos necesarios (ver 3.4).

### 3.2-bis Alternativa: crear la base de datos desde pgAdmin

Si `psql` no está en el `PATH` de Windows o da errores, se puede hacer todo desde pgAdmin 4:

1. Conéctate al servidor que **ya aparece** en el panel (no registres uno nuevo; el campo *Host* es `localhost`).
2. **Login/Group Roles → Create**: nombre `contanegocios_app`, contraseña propia (evita símbolos como `@ : / # %`), solo *Can login?* en *Yes*.
3. **Databases → Create → Database**: nombre `contanegocios`, propietario `postgres`.
4. Clic derecho en `contanegocios` → **Query Tool** → abrir `database\schema.sql` → ejecutar (F5). Repetir con `database\permisos.sql`.
5. Comprobar: `SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';` debe dar 12.

**Rutas con espacios en CMD:** van entre comillas, por ejemplo `cd /d "C:\Users\Nombre Apellido\Carpeta"`.

### 3.3 Variables de entorno

Copia el archivo de ejemplo y edítalo:

```powershell
copy .env.example .env
```

Variables previstas (nombres propuestos):

| Variable | Qué es |
|---|---|
| `PORT` | Puerto del backend |
| `DATABASE_URL` | Conexión a PostgreSQL con el usuario `contanegocios_app` |
| `SESSION_SECRET` | Clave para firmar las sesiones |
| `ENCRYPTION_KEY` | Clave para cifrar campos sensibles (ADR-006) |
| `FRONTEND_ORIGIN` | Origen permitido por CORS |
| `UPLOADS_DIR` | Carpeta de soportes, fuera de la parte pública |
| `NODE_ENV` | `development` o `production` |

Para generar una clave aleatoria de 32 bytes:

```powershell
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Genera una clave distinta para `SESSION_SECRET` y otra para `ENCRYPTION_KEY`.

⚠️ **Guarda `ENCRYPTION_KEY` en un lugar seguro, aparte del equipo** (por ejemplo, un gestor de contraseñas). Si se pierde, los documentos y cuentas cifrados **no se pueden recuperar**, ni siquiera con un respaldo de la base de datos.

⚠️ `.env` está en `.gitignore`. **Nunca lo subas a GitHub.**

### 3.4 Cargar el esquema y los permisos

Con el administrador de PostgreSQL (la extensión `btree_gist` requiere permisos de administrador):

```powershell
psql -U postgres -d contanegocios -f database\schema.sql
psql -U postgres -d contanegocios -f database\permisos.sql
```

`schema.sql` crea las tablas (incluida la restricción anti-solapamiento de `parametros`). `permisos.sql` da a `contanegocios_app` lo necesario y **quita `UPDATE` y `DELETE` sobre la bitácora**:

```sql
-- Ejemplo de lo que hará permisos.sql
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO contanegocios_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO contanegocios_app;
REVOKE UPDATE, DELETE ON bitacora FROM contanegocios_app;
```

Si se desea probar con datos ficticios:

```powershell
psql -U postgres -d contanegocios -f database\seed-demo.sql
```

⚠️ **Nunca cargues los datos de demostración en la base que usarás con clientes reales.**

### 3.5 Instalar dependencias

```powershell
cd backend
npm install
cd ..\frontend
npm install
cd ..
```

### 3.6 Crear el primer usuario contador

Script previsto, que pide correo y contraseña por consola y guarda solo el hash:

```powershell
cd backend
npm run crear-contador
```

### 3.7 Arrancar

Desarrollo (dos terminales):

```powershell
# Terminal 1
cd backend
npm run dev

# Terminal 2
cd frontend
npm run dev
```

Uso diario (frontend compilado y servido por el backend):

```powershell
cd frontend
npm run build
cd ..\backend
npm start
```

### 3.8 Verificar

1. Abre `http://localhost:PUERTO/api/v1/salud`: debe responder que el servicio está activo, sin datos sensibles.
2. Abre la aplicación en el navegador e inicia sesión con el usuario contador.
3. Ve a **Parámetros** y confirma que hay un conjunto activo del año actual. Si no, sigue `03-actualizacion-anual.md`.

## 4. Solución de problemas

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| `psql` no se reconoce | La carpeta de PostgreSQL no está en el `PATH` | Agregarla al `PATH` de Windows o ejecutar `psql` desde su carpeta |
| Error de conexión a la base | Servicio detenido, clave o puerto incorrectos | Revisar el servicio de PostgreSQL y `DATABASE_URL` |
| `extension "btree_gist" is not available` | La instalación no incluye los módulos adicionales | Reinstalar incluyendo los módulos contrib, o aplicar la validación de solapamiento en el servicio (ver `02-modelo-de-datos.md`) |
| `permission denied for table ...` | Falta ejecutar `permisos.sql` | Ejecutarlo con el administrador |
| El frontend no llega al backend | CORS o puerto | Revisar `FRONTEND_ORIGIN` y el puerto |
| No se ven los documentos de clientes | `ENCRYPTION_KEY` distinta a la usada al guardarlos | Restaurar la clave original |
| Error al subir soportes | `UPLOADS_DIR` no existe o sin permisos | Crear la carpeta y revisar permisos |

## 5. Desinstalar

1. Detener el backend.
2. Hacer un respaldo antes de borrar nada (ver `02-respaldo-y-restauracion.md`).
3. Eliminar la carpeta del proyecto, y la base y el usuario si ya no se necesitan:

```sql
DROP DATABASE contanegocios;
DROP ROLE contanegocios_app;
```
