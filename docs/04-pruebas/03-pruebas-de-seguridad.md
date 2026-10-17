# Pruebas de seguridad

> Versión 0.1 · 17-oct-2026 · Estado: borrador. Desarrolla las pruebas previstas en `02-diseno/05-seguridad.md`, sección 9. Se ejecutan solo contra el **entorno de pruebas con datos demo**.

## 1. Reglas de la ejecución

- Nunca se ejecutan contra una base con datos reales.
- Cada caso guarda evidencia (captura o salida de la herramienta).
- Una falla de severidad alta bloquea la entrega de la fase.

## 2. Casos

| ID | Amenaza | Procedimiento | Resultado esperado | Herramienta | Ref. |
|---|---|---|---|---|---|
| PS-01 | Fuerza bruta | Enviar intentos repetidos de `POST /auth/login` con claves erróneas | Bloqueo temporal del usuario y respuesta 429 por IP; cuenta no revela existencia del correo | Postman / Supertest | HU-01 |
| PS-02 | IDOR (acceso a otro cliente) | Con el cliente A, pedir recursos del cliente B cambiando el `id` en movimientos, soportes, semáforo y exportes | Siempre 404; ningún dato del otro cliente | Supertest | ADR-010 |
| PS-03 | Escalamiento de rol | Con auxiliar y con cliente, llamar endpoints exclusivos del contador (parámetros, usuarios, bitácora, anular) | 403 en todos; nada cambia | Supertest | RF-02 |
| PS-04 | Manipulación del rol en la petición | Enviar un campo `rol` o `usuario_id` en el cuerpo de peticiones normales | El backend ignora esos campos; el rol sale de la sesión | Postman | RNF-03 |
| PS-05 | Inyección SQL | Enviar comillas, `;` y fragmentos SQL en filtros de búsqueda, orden y campos de texto | Se tratan como texto o se rechazan; la consulta no cambia | Postman / Supertest | RNF-01 |
| PS-06 | XSS almacenado | Registrar una descripción con código de script y verla en el listado | Se muestra como texto; no se ejecuta | Playwright | Seguridad §6 |
| PS-07 | CSRF | Enviar un POST autenticado por cookie sin `X-CSRF-Token` | Rechazo | Postman | RNF-01 |
| PS-08 | Sesión manipulada o vencida | Alterar el token, usar uno vencido, usarlo después de cerrar sesión | 401 en todos los casos | Postman | Seguridad §2 |
| PS-09 | Atributos de la cookie | Inspeccionar la cookie de sesión en el navegador | `httpOnly` presente; `SameSite` configurado; `Secure` cuando haya HTTPS | Navegador | Seguridad §2 |
| PS-10 | Subida de archivo no permitido | Subir un archivo con extensión engañosa, uno sobredimensionado y uno de tipo no permitido | Los tres rechazados | Postman | Seguridad §5 |
| PS-11 | Acceso directo a archivos | Pedir la ruta física de un soporte sin pasar por la API | No accesible; solo se descarga con sesión y permisos | Navegador | Seguridad §5 |
| PS-12 | Datos sensibles en la base | Leer `clientes` y `cuentas_bancarias` con una consulta directa | Campos cifrados; contraseñas solo como hash | psql | RNF-02 |
| PS-13 | Fuga en errores y logs | Provocar errores 400 y 500; revisar respuestas y archivos de registro | Sin trazas internas, documentos, claves ni tokens | Postman / revisión | Seguridad §4 |
| PS-14 | Bitácora inmutable | Con el usuario de la aplicación, `UPDATE` y `DELETE` sobre `bitacora` | Fallan por permisos | psql | RNF-03 |
| PS-15 | Cabeceras y CORS | Inspeccionar respuestas y probar una petición desde un origen no permitido | Cabeceras de seguridad presentes; origen ajeno rechazado | Navegador / Postman | Seguridad §6 |
| PS-16 | Secretos en el repositorio | Buscar `.env`, claves y contraseñas en archivos y en el historial de Git antes de publicar | Ninguno; solo `.env.example` | Revisión manual / búsqueda en el historial | Seguridad §8 |
| PS-17 | Dependencias vulnerables | Ejecutar la auditoría de dependencias del gestor de paquetes | Sin vulnerabilidades altas sin plan de corrección | Gestor de paquetes | Seguridad §8 |
| PS-18 | Respaldo cifrado | Revisar que el archivo de respaldo no contenga datos sensibles legibles | Campos sensibles siguen cifrados; el archivo se guarda con acceso restringido | psql / revisión | Seguridad §4 |

## 3. Informe de seguridad (plantilla)

| ID | Fecha | Resultado | Severidad si falló | Evidencia | Estado de la corrección |
|---|---|---|---|---|---|
| PS-01 | | | | | |

## 4. Límites

Estas pruebas son una verificación de buenas prácticas básicas dirigida por el autor. **No equivalen a una auditoría de seguridad profesional.** Si el sistema llegara a usarse con datos reales de terceros, conviene una revisión independiente.
