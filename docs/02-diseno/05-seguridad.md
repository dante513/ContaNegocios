# Seguridad

> Versión 0.1 · 17-oct-2026 · Estado: borrador. Cubre RNF-01 a RNF-03 y RNF-09. Las decisiones son propuestas de diseño; las referencias normativas externas están marcadas con su nivel de verificación.

## 1. Qué se protege y de quién

**Activos sensibles:** documentos de identidad de clientes, cuentas bancarias, movimientos, patrimonio, nóminas, parámetros tributarios (su integridad) y la bitácora.

| Amenaza | Ejemplo | Medida principal |
|---|---|---|
| Acceso no autorizado | Adivinar contraseñas, reutilizar sesiones | Hash lento, bloqueo temporal, cookie `httpOnly`, expiración |
| Ver datos de otro cliente | Cambiar el `id` en la URL (IDOR) | Verificar acceso al cliente en cada petición |
| Escalamiento de privilegios | Un auxiliar aprueba parámetros | Autorización por rol en el backend |
| Inyección | SQL en filtros de búsqueda | Consultas parametrizadas y validación de entradas |
| Robo de datos en la base | Copia del disco o de un respaldo | Cifrado de campos sensibles y respaldos protegidos |
| Alteración de cifras tributarias | Cambiar un tope sin dejar rastro | Estados, aprobación, histórico inmutable y bitácora |
| Archivos maliciosos | Subir un ejecutable como "soporte" | Lista de tipos permitidos, límite de tamaño, almacenamiento seguro |
| Falsificación de peticiones | Un sitio externo envía una acción del usuario | Token CSRF y `SameSite` |
| Fuga de secretos | Subir `.env` al repositorio | `.gitignore`, `.env.example`, revisión previa a cada push |

## 2. Autenticación

| Tema | Decisión (propuesta) |
|---|---|
| Contraseñas | Solo se guarda el hash (`clave_hash`). Algoritmo de hash lento (bcrypt, el mismo que usa el autor en otros proyectos); decisión formal en ADR-009 |
| Política de clave | Longitud mínima y rechazo de claves comunes; valores configurables |
| Intentos fallidos | Contador por usuario y bloqueo temporal (`bloqueado_hasta`), más límite por dirección IP (HTTP 429) |
| Sesión | Token en cookie `httpOnly`, `SameSite` y `Secure` cuando haya HTTPS; duración e inactividad configurables |
| Cierre de sesión | Invalida el token en el servidor |
| Mensajes de error | Genéricos ("credenciales inválidas"); no revelan si el correo existe |
| Cambio de clave | Exige la clave actual (RF-03) |

## 3. Autorización

Dos controles, ambos en el **backend** (RNF-03):

1. **Rol** (RBAC): contador, auxiliar, cliente. La matriz está en `04-api.md`, sección 2.
2. **Pertenencia al cliente:** además del rol, se consulta `usuarios_clientes`. Un usuario solo opera sobre los clientes que tiene asignados; el rol `cliente` solo sobre el suyo.

Regla de respuesta: si el recurso existe pero el usuario no tiene acceso, se responde **404** (no 403), para no confirmar que existe.

Reglas especiales:
- Aprobar o activar parámetros: solo contador, y quien carga no aprueba cuando hay más de un usuario (RN-61).
- Anular movimientos y eliminar soportes: solo contador.

## 4. Protección de datos

| Dato | Tratamiento |
|---|---|
| Documento del cliente y de empleados | Cifrado en la aplicación (módulo `crypto` de Node, ADR-006). Se guarda además un hash con clave secreta para unicidad y búsqueda sin descifrar |
| Número de cuenta bancaria | Cifrado; se muestra enmascarado (solo últimos 4) |
| Contraseñas | Hash, nunca reversible |
| Clave de cifrado y secretos | Variables de entorno, fuera del repositorio. Procedimiento de rotación documentado en `05-despliegue/` |
| Registros de la aplicación (logs) | Sin documentos, claves ni tokens |
| Respaldos | Contienen datos cifrados por campo; además se guardan en un lugar con acceso restringido |
| Datos de demostración | Únicos permitidos en el repositorio (RNF-09) |

**Marco legal:** el sistema trata datos personales de terceros. En Colombia aplica la normativa de protección de datos personales (Ley 1581 de 2012). ⚠️ Mencionada por conocimiento general; no se consultó en esta sesión. Antes de usar el sistema con clientes reales deben revisarse finalidad, autorización del titular, política de tratamiento y tiempo de conservación.

## 5. Validación de entradas y subida de archivos

- Todas las entradas se validan en el backend con esquemas por endpoint (la librería de esquemas se define en la guía de desarrollo).
- SQL siempre parametrizado; los filtros y el orden se aceptan solo desde listas blancas.
- Límite de tamaño de cuerpo de la petición.
- **Soportes:** tipos permitidos PDF, PNG y JPG; verificación del contenido real, no solo de la extensión; tamaño máximo configurable; nombre renombrado por el servidor; almacenamiento fuera de la carpeta pública; descarga solo a través de la API con permisos; hash del archivo guardado en `soportes`.

## 6. Protección del navegador

- **CSRF:** token en `X-CSRF-Token` para POST, PUT, PATCH y DELETE, más `SameSite` en la cookie.
- **CORS:** solo el origen del frontend configurado.
- **Cabeceras de seguridad** (política de contenido, `X-Content-Type-Options`, `X-Frame-Options` o equivalente, `Referrer-Policy`).
- **XSS:** el frontend escapa por defecto; prohibido insertar HTML sin sanear.

## 7. Auditoría

Se registra en `bitacora` (solo inserción; la cuenta de base de datos de la aplicación no tiene `UPDATE` ni `DELETE` sobre ella):

- Inicios y cierres de sesión, y bloqueos.
- Creación, edición, desactivación y consulta de clientes.
- Creación, edición y anulación de movimientos.
- **Todo cambio en parámetros**, incluidas aprobaciones y activaciones del año.
- Liquidaciones de nómina y generación de papeles de trabajo.
- Cambios de roles y de accesos a clientes.

Cada fila guarda usuario, acción, entidad, estado antes y después, IP y fecha.

## 8. Operación segura

- `.env` en `.gitignore`; el repositorio solo contiene `.env.example`.
- Usuario de base de datos con permisos mínimos (no el superusuario).
- Dependencias actualizadas y revisadas con la herramienta de auditoría del gestor de paquetes antes de cada versión.
- Respaldo periódico y restauración probada.

## 9. Pruebas de seguridad previstas

Estas pruebas alimentan `04-pruebas/03-pruebas-de-seguridad.md`.

| Prueba | Qué verifica |
|---|---|
| Fuerza bruta de inicio de sesión | Bloqueo temporal y límite por IP |
| Acceso a recurso de otro cliente | Respuesta 404 (IDOR) |
| Cambio de rol por petición manual | El auxiliar no puede activar parámetros |
| Inyección SQL en filtros | Las entradas maliciosas no alteran la consulta |
| XSS en descripciones de movimientos | Se muestran como texto |
| CSRF | Una petición sin token es rechazada |
| Subida de archivo no permitido | Rechazo por tipo y tamaño |
| Sesión vencida o token manipulado | 401 |
| Bitácora inmutable | Intentos de `UPDATE`/`DELETE` fallan |
| Secretos en el repositorio | Revisión del historial antes de publicar |

## 10. Referencias

- OWASP, en particular su lista de riesgos principales de aplicaciones web: usada como guía general. ⚠️ No consultada en esta sesión; verificar versión y enlace vigentes antes de citarla en el repositorio.
- Ley 1581 de 2012 (Colombia): ⚠️ ver sección 4.

## 11. Decisiones de seguridad (ADR)

| ADR | Decisión | Estado |
|---|---|---|
| ADR-006 | Cifrado de campos sensibles en la aplicación | Propuesta |
| ADR-009 | Hash de contraseñas con bcrypt | Propuesta |
| ADR-010 | Respuesta 404 en lugar de 403 para recursos de otros clientes | Propuesta |
| ADR-011 | Anulación en lugar de borrado de datos contables | Propuesta |
