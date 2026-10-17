# Respaldo y restauración

> Versión 0.1 · 17-oct-2026 · Estado: borrador. Cubre RNF-07. Valores como frecuencias y retención son **propuestas** que se ajustan según el uso real.

## 1. Qué se respalda

| Elemento | Dónde está | Importancia |
|---|---|---|
| Base de datos PostgreSQL | Servidor local | Crítica |
| Carpeta de soportes | `UPLOADS_DIR` | Alta |
| `ENCRYPTION_KEY` | Gestor de contraseñas o lugar seguro **separado** | **Crítica**: sin ella, los campos cifrados no se pueden leer |
| Archivo `.env` | Equipo | Alta (contiene las demás claves) |
| Código | GitHub | Ya respaldado por Git |

⚠️ Un respaldo de la base de datos **sin** la `ENCRYPTION_KEY` no permite recuperar documentos ni cuentas de los clientes. La clave se guarda aparte, nunca junto al respaldo.

## 2. Estrategia propuesta

| Tipo | Frecuencia | Retención |
|---|---|---|
| Diario | Cada noche | 7 días |
| Semanal | Un día fijo | 4 semanas |
| Mensual | Primer día del mes | 12 meses |
| Antes de activar el año nuevo | Manual | Permanente |
| Copia fuera del equipo | Semanal | Mínimo 4 copias |

Regla práctica: **al menos una copia en un lugar distinto del computador** (disco externo o almacenamiento en la nube con acceso restringido).

## 3. Hacer un respaldo

### 3.1 Base de datos

```powershell
pg_dump -U contanegocios_app -h localhost -F c -f C:\respaldos\contanegocios_2026-10-17.dump contanegocios
```

`-F c` genera el formato comprimido que luego lee `pg_restore`. Para no escribir la contraseña cada vez, usa el archivo `pgpass.conf` de PostgreSQL en tu perfil de usuario de Windows (en la carpeta `postgresql` dentro de `%APPDATA%`), con el formato `host:puerto:base:usuario:contraseña`, y restringe quién puede leerlo.

### 3.2 Soportes

```powershell
robocopy "C:\ruta\UPLOADS_DIR" "C:\respaldos\soportes" /MIR
```

⚠️ `/MIR` refleja el origen en el destino (si borras algo en origen, se borra en la copia). Para conservar historial, copia a una carpeta con fecha.

### 3.3 Script de respaldo (ejemplo)

`scripts\respaldo.ps1`:

```powershell
$fecha = Get-Date -Format "yyyy-MM-dd"
$destino = "C:\respaldos"
New-Item -ItemType Directory -Force -Path $destino | Out-Null

pg_dump -U contanegocios_app -h localhost -F c -f "$destino\contanegocios_$fecha.dump" contanegocios
robocopy "C:\ruta\UPLOADS_DIR" "$destino\soportes_$fecha" /E | Out-Null

# Borra respaldos diarios de más de 7 días
Get-ChildItem $destino -Filter "contanegocios_*.dump" |
  Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
  Remove-Item
```

⚠️ Este ejemplo borra **todos** los respaldos de más de 7 días, incluidos los que quieras conservar como semanales y mensuales. Antes de usarlo, copia los semanales y mensuales a otra carpeta o ajusta el filtro.

### 3.4 Programarlo en Windows

```powershell
schtasks /Create /SC DAILY /TN "Respaldo ContaNegocios" /TR "powershell -ExecutionPolicy Bypass -File C:\proyectos\ContaNegocios\scripts\respaldo.ps1" /ST 22:00
```

Revisa de vez en cuando que se estén generando los archivos: un respaldo que falla en silencio no sirve.

### 3.5 Protección del respaldo

- Guardarlo en una carpeta con acceso restringido.
- Los campos sensibles ya van cifrados dentro de la base, pero el resto de los datos (movimientos, nombres, patrimonio) no. Si el respaldo sale del equipo, cífralo con la herramienta que elijas (decisión pendiente, ❓).
- Nunca subirlo a GitHub.

## 4. Restaurar

**Antes de restaurar:** detén el backend y haz un respaldo del estado actual, aunque esté dañado.

### 4.1 Restaurar en la base existente

```powershell
pg_restore -U postgres -h localhost -d contanegocios --clean --if-exists C:\respaldos\contanegocios_2026-10-17.dump
```

`--clean --if-exists` elimina y vuelve a crear los objetos antes de cargarlos.

### 4.2 Restaurar en una base nueva (recomendado para verificar)

```powershell
psql -U postgres -c "CREATE DATABASE contanegocios_restauracion;"
pg_restore -U postgres -h localhost -d contanegocios_restauracion C:\respaldos\contanegocios_2026-10-17.dump
```

Si el respaldo se restaura con un usuario distinto de `contanegocios_app`, vuelve a aplicar `database\permisos.sql` para que el usuario de la aplicación conserve sus permisos y no pueda modificar la bitácora.

### 4.3 Restaurar soportes

```powershell
robocopy "C:\respaldos\soportes_2026-10-17" "C:\ruta\UPLOADS_DIR" /E
```

### 4.4 Comprobación después de restaurar

| Verificación | Cómo |
|---|---|
| Hay datos | Iniciar sesión y abrir un cliente |
| Los campos cifrados se leen | Abrir un cliente: el documento se muestra enmascarado, no con símbolos extraños |
| Soportes disponibles | Descargar uno |
| Parámetros vigentes | Conjunto activo del año actual presente |
| Bitácora intacta | Ver las últimas entradas |
| Permisos correctos | La bitácora no se puede modificar con el usuario de la aplicación |

## 5. Probar la restauración

**Un respaldo no probado es solo una esperanza.** Cada trimestre (propuesta), restaura el último respaldo en una base nueva (4.2) y completa la lista de 4.4. Anota la fecha y el resultado.

| Fecha | Respaldo probado | Resultado | Observaciones |
|---|---|---|---|
| | | | |

## 6. Rotación de la clave de cifrado

Si se sospecha que `ENCRYPTION_KEY` se filtró:
1. Hacer un respaldo completo.
2. Generar una clave nueva.
3. Ejecutar el script previsto de re-cifrado, que lee con la clave vieja y escribe con la nueva, dentro de una transacción.
4. Actualizar `.env`, guardar la nueva clave aparte y reiniciar el backend.
5. Verificar con 4.4 y destruir la clave vieja cuando se compruebe todo.

El script de re-cifrado se construye junto con el módulo de seguridad. ❓ Pendiente.
