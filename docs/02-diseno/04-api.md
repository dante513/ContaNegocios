# API REST

> Versión 0.1 · 17-oct-2026 · Estado: borrador. Base: `/api/v1`. Depende de `01-arquitectura.md`, `02-modelo-de-datos.md` y `02-requisitos.md`.

## 1. Convenciones

| Tema | Decisión |
|---|---|
| Formato | JSON (`application/json`), salvo subida de soportes (`multipart/form-data`) y descargas |
| Autenticación | Cookie `httpOnly` de sesión + token CSRF en la cabecera `X-CSRF-Token` para métodos que modifican datos |
| Dinero | Texto decimal exacto, por ejemplo `"69718600.00"`. Nunca número flotante (ADR-004) |
| Fechas | ISO 8601: `2026-10-17` para fechas y `2026-10-17T14:30:00Z` para marcas de tiempo |
| Paginación | `?page=1&limit=25`; la respuesta incluye `total`, `page`, `limit` |
| Filtros | Parámetros de consulta (`?anio=2025&tipo=ingreso`) |
| Borrado | No hay borrado físico de datos contables. Los movimientos se **anulan** con motivo; los clientes se **desactivan** |
| Idioma | Rutas y campos en español, coherente con el modelo de datos (ADR-001) |

### Formato de error

```json
{
  "error": {
    "codigo": "PARAMETRO_FALTANTE",
    "mensaje": "No existe el parámetro RENTA_TOPE_INGRESOS vigente al 2025-12-31.",
    "detalles": []
  }
}
```

| HTTP | Uso |
|---|---|
| 200 / 201 / 204 | Éxito / creado / sin contenido |
| 400 | Datos inválidos (con `detalles` por campo) |
| 401 | Sin sesión o sesión vencida |
| 403 | Sin permiso para el rol o el cliente |
| 404 | No existe, o no es visible para el usuario |
| 409 | Conflicto (documento duplicado, vigencia solapada, nómina ya existente) |
| 422 | Regla de negocio violada (por ejemplo, aprobar el propio parámetro) |
| 429 | Demasiados intentos |

## 2. Permisos por rol (resumen)

| Módulo | Contador | Auxiliar | Cliente |
|---|---|---|---|
| Autenticación | Sí | Sí | Sí |
| Usuarios | Gestiona | — | — |
| Clientes | Crea, edita, desactiva | Consulta y edita datos básicos | Ve solo el suyo |
| Movimientos | Crea, edita, anula | Crea y edita; no anula | Solo lectura |
| Soportes | Sube, descarga, elimina | Sube, descarga | Sube y descarga los suyos |
| Parámetros | Crea, edita, aprueba y activa | Solo consulta | — |
| Obligaciones (semáforo, GMF, calendario) | Sí | Consulta | Consulta el suyo |
| Renta y exógena | Genera y exporta | Consulta | — |
| Nómina | Liquida y exporta | Prepara (borrador) | — |
| Bitácora | Consulta | — | — |

En todos los casos el backend valida, además del rol, que el usuario tenga acceso al **cliente** solicitado (ver `05-seguridad.md`).

## 3. Endpoints

Columna **Req.**: requisito o historia que lo origina. **Fase** según la visión.

### 3.1 Autenticación (F1)
| Método | Ruta | Roles | Descripción | Req. |
|---|---|---|---|---|
| POST | `/auth/login` | Público | Inicia sesión | RF-01, HU-01 |
| POST | `/auth/logout` | Autenticado | Cierra sesión | RF-01 |
| GET | `/auth/me` | Autenticado | Datos del usuario y su rol | RF-02 |
| GET | `/auth/csrf` | Autenticado | Entrega el token CSRF | RNF-01 |
| POST | `/auth/cambiar-clave` | Autenticado | Exige la clave actual | RF-03 |

### 3.2 Usuarios (F1)
| Método | Ruta | Roles | Descripción | Req. |
|---|---|---|---|---|
| GET | `/usuarios` | Contador | Lista usuarios | RF-02 |
| POST | `/usuarios` | Contador | Crea usuario con rol | RF-02 |
| PATCH | `/usuarios/:id` | Contador | Cambia rol, activa o desactiva | RF-02 |
| PUT | `/usuarios/:id/clientes` | Contador | Define a qué clientes accede | RF-02 |

### 3.3 Clientes (F1)
| Método | Ruta | Roles | Descripción | Req. |
|---|---|---|---|---|
| GET | `/clientes` | Contador, auxiliar | Lista con búsqueda por nombre o documento | RF-10 |
| POST | `/clientes` | Contador | Crea cliente | HU-10 |
| GET | `/clientes/:id` | Todos* | Ficha y resumen del expediente | HU-11 |
| PATCH | `/clientes/:id` | Contador, auxiliar | Edita; el contador también desactiva | RF-10 |
| GET/POST | `/clientes/:id/cuentas` | Contador, auxiliar | Cuentas bancarias | RF-11 |
| GET/POST | `/clientes/:id/terceros` | Contador, auxiliar | Terceros | RF-51 |
| GET/POST | `/clientes/:id/activos?anio=` | Contador, auxiliar | Activos a 31 de diciembre | RF-40 |

\* El cliente solo accede al suyo.

### 3.4 Movimientos y soportes (F1)
| Método | Ruta | Roles | Descripción | Req. |
|---|---|---|---|---|
| GET | `/clientes/:id/movimientos` | Todos* | Filtros: `anio`, `tipo`, `desde`, `hasta`, `categoria` | RF-20 |
| POST | `/clientes/:id/movimientos` | Contador, auxiliar | Registra un movimiento | HU-20 |
| PATCH | `/movimientos/:id` | Contador, auxiliar | Edita (queda en bitácora) | RF-20 |
| POST | `/movimientos/:id/anular` | Contador | Anula con motivo obligatorio | RF-04 |
| POST | `/movimientos/:id/soportes` | Todos* | Sube archivo (PDF, PNG o JPG) | HU-12 |
| GET | `/soportes/:id` | Todos* | Descarga | HU-12 |
| DELETE | `/soportes/:id` | Contador | Elimina el soporte | HU-12 |
| GET | `/categorias` | Autenticado | Catálogo de categorías | RF-21 |

### 3.5 Parámetros y actualización anual (F1)
| Método | Ruta | Roles | Descripción | Req. |
|---|---|---|---|---|
| GET | `/parametros?fecha=&codigo=` | Contador, auxiliar | Parámetros vigentes en una fecha | HU-30 |
| GET | `/parametros/conjuntos` | Contador | Lista los conjuntos por año y estado | RF-30 |
| POST | `/parametros/conjuntos` | Contador | Crea el año siguiente como borrador, copiado del anterior | HU-31 |
| PATCH | `/parametros/:id` | Contador | Edita un parámetro en borrador; exige fuente | RF-30, RN-60 |
| POST | `/parametros/conjuntos/:id/revision` | Contador | Pasa a revisión | RF-32 |
| GET | `/parametros/conjuntos/:id/diferencias?contra=` | Contador | Reporte de diferencias entre años | RF-36 |
| GET | `/parametros/checklist-enero?anio=` | Contador | Checklist de actualización | RF-36 |
| POST | `/parametros/conjuntos/:id/activar` | Contador | Activa en una transacción (RN-61, RN-62) | HU-32 |
| POST | `/parametros/ajustes` | Contador | Cambio dentro del año con `vigente_desde` | HU-33 |
| GET | `/parametros/alertas` | Contador | "Faltan parámetros del año siguiente" | RF-35 |
| GET/PUT | `/calendario-tributario?anio=` | Contador | Calendario editable | RN-16 |

### 3.6 Obligaciones (F2)
| Método | Ruta | Roles | Descripción | Req. |
|---|---|---|---|---|
| GET | `/clientes/:id/semaforo?anio=` | Todos* | Avance frente a cada tope | HU-40 |
| GET | `/clientes/:id/obligacion-exogena?anio=` | Contador, auxiliar | ¿Debe reportar? | HU-41 |
| GET | `/clientes/:id/calendario?anio=` | Todos* | Vencimientos del cliente | HU-42 |
| GET | `/clientes/:id/gmf?anio=` | Contador, auxiliar | GMF por cuenta y mes, alertas, deducción | HU-50 |

### 3.7 Renta y exógena (F3)
| Método | Ruta | Roles | Descripción | Req. |
|---|---|---|---|---|
| POST | `/clientes/:id/renta/borrador` | Contador | Genera el borrador del año (`{ "anio": 2025 }`) | HU-60 |
| GET | `/clientes/:id/renta/borrador?anio=` | Contador, auxiliar | Último borrador | HU-60 |
| GET | `/clientes/:id/renta/borrador/exportar?anio=&formato=xlsx\|pdf` | Contador | Exporta | HU-62 |
| POST | `/clientes/:id/exogena/papel-trabajo` | Contador | Genera el acumulado por tercero y concepto | HU-61 |
| GET | `/clientes/:id/exogena/papel-trabajo/exportar?anio=&formato=` | Contador | Exporta | HU-62 |

### 3.8 Nómina (F4)
| Método | Ruta | Roles | Descripción | Req. |
|---|---|---|---|---|
| GET/POST | `/clientes/:id/empleados` | Contador, auxiliar | Empleados del cliente empleador | RF-60 |
| PATCH | `/empleados/:id` | Contador, auxiliar | Edita o retira | RF-60 |
| POST | `/clientes/:id/nominas` | Contador, auxiliar | Crea la nómina del mes (`anio`, `mes`) | RF-61 |
| POST | `/nominas/:id/liquidar` | Contador | Liquida con parámetros vigentes en la fecha | HU-70 |
| GET | `/nominas/:id` | Contador, auxiliar | Detalle | HU-70 |
| GET | `/nominas/:id/exportar?formato=` | Contador | Exporta | HU-70 |

### 3.9 Importación (F5)
| Método | Ruta | Roles | Descripción | Req. |
|---|---|---|---|---|
| POST | `/clientes/:id/importaciones` | Contador, auxiliar | Sube Excel o CSV y devuelve vista previa categorizada | RF-22 |
| POST | `/importaciones/:id/confirmar` | Contador, auxiliar | Registra los movimientos aprobados | RF-22 |

### 3.10 Auditoría y salud (F1)
| Método | Ruta | Roles | Descripción | Req. |
|---|---|---|---|---|
| GET | `/bitacora?entidad=&usuario=&desde=&hasta=` | Contador | Consulta de la bitácora | HU-81 |
| GET | `/salud` | Público | Estado del servicio (sin datos sensibles) | RNF-06 |

## 4. Ejemplos

### 4.1 Semáforo de un cliente

`GET /api/v1/clientes/12/semaforo?anio=2025`

```json
{
  "clienteId": 12,
  "anioGravable": 2025,
  "topes": [
    {
      "codigo": "RENTA_TOPE_INGRESOS",
      "acumulado": "58400000.00",
      "tope": "69718600.00",
      "topeEnUvt": "1400",
      "operador": ">=",
      "avance": "83.77",
      "estado": "amarillo",
      "parametro": {
        "id": 311,
        "fuente": "Publimetro, 30-jun-2026; Rankia",
        "nivel": "verificado"
      }
    }
  ],
  "calculoId": 958
}
```

*Los valores son ficticios (datos de demostración).*

### 4.2 Activar el año nuevo

`POST /api/v1/parametros/conjuntos/7/activar`

Respuesta `422` si el mismo usuario que cargó los parámetros intenta aprobarlos teniendo más de un usuario en el sistema:

```json
{
  "error": {
    "codigo": "APROBADOR_IGUAL_A_CREADOR",
    "mensaje": "Quien cargó los parámetros no puede aprobarlos.",
    "detalles": []
  }
}
```

## 5. Cambios que este documento exige en el modelo de datos

- `movimientos`: agregar `anulado_en`, `anulado_por`, `motivo_anulacion` (anulación en lugar de borrado). Los totales del semáforo excluyen movimientos anulados. Ya aplicado en `02-modelo-de-datos.md`.
- `importaciones` (F5): tabla temporal para la vista previa antes de confirmar. Se detallará al llegar a esa fase.
