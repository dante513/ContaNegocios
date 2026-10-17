-- =====================================================================
-- ContaNegocios · Esquema de la base de datos · Fase F1 (núcleo)
-- Motor: PostgreSQL (ADR-002). Convenciones: ver docs/02-diseno/02-modelo-de-datos.md
--   · tablas y columnas en español, snake_case
--   · dinero en NUMERIC(18,2); estados con TEXT + CHECK
-- Ejecutar con un usuario administrador (la extensión btree_gist lo exige):
--   psql -U postgres -d contanegocios -f database/schema.sql
-- Las tablas de fases posteriores (calendario, exógena, cálculos, nómina)
-- se agregan con migraciones en database/migrations/.
-- Requiere PostgreSQL 12 o superior por las columnas generadas.
-- =====================================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- ---------------------------------------------------------------------
-- Seguridad
-- ---------------------------------------------------------------------
CREATE TABLE usuarios (
    id                 BIGSERIAL PRIMARY KEY,
    nombre             TEXT        NOT NULL,
    correo             TEXT        NOT NULL,
    clave_hash         TEXT        NOT NULL,
    rol                TEXT        NOT NULL CHECK (rol IN ('contador', 'auxiliar', 'cliente')),
    activo             BOOLEAN     NOT NULL DEFAULT TRUE,
    intentos_fallidos  INTEGER     NOT NULL DEFAULT 0 CHECK (intentos_fallidos >= 0),
    bloqueado_hasta    TIMESTAMPTZ,
    creado_en          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX usuarios_correo_uk ON usuarios (lower(correo));

-- ---------------------------------------------------------------------
-- Clientes
-- ---------------------------------------------------------------------
CREATE TABLE clientes (
    id                  BIGSERIAL PRIMARY KEY,
    tipo_persona        TEXT        NOT NULL DEFAULT 'natural'
                        CHECK (tipo_persona IN ('natural', 'juridica')),
    tipo_documento      TEXT        NOT NULL,
    documento_cifrado   BYTEA       NOT NULL,
    documento_hash      TEXT        NOT NULL UNIQUE,
    ultimos_digitos     TEXT        NOT NULL CHECK (ultimos_digitos ~ '^[0-9]{2}$'),
    nombre              TEXT        NOT NULL,
    tipo_contribuyente  TEXT        NOT NULL DEFAULT 'otro'
                        CHECK (tipo_contribuyente IN ('asalariado', 'otro')),
    es_empleador        BOOLEAN     NOT NULL DEFAULT FALSE,
    activo              BOOLEAN     NOT NULL DEFAULT TRUE,
    creado_por          BIGINT      REFERENCES usuarios (id),
    creado_en           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE usuarios_clientes (
    usuario_id  BIGINT NOT NULL REFERENCES usuarios (id),
    cliente_id  BIGINT NOT NULL REFERENCES clientes (id),
    PRIMARY KEY (usuario_id, cliente_id)
);
CREATE INDEX usuarios_clientes_cliente_idx ON usuarios_clientes (cliente_id);

CREATE TABLE cuentas_bancarias (
    id              BIGSERIAL PRIMARY KEY,
    cliente_id      BIGINT  NOT NULL REFERENCES clientes (id),
    banco           TEXT    NOT NULL,
    numero_cifrado  BYTEA   NOT NULL,
    ultimos4        TEXT    NOT NULL CHECK (ultimos4 ~ '^[0-9]{4}$'),
    marcada_gmf     BOOLEAN,            -- NULL = no se sabe (RN-33)
    activa          BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX cuentas_bancarias_cliente_idx ON cuentas_bancarias (cliente_id);

CREATE TABLE terceros (
    id              BIGSERIAL PRIMARY KEY,
    cliente_id      BIGINT NOT NULL REFERENCES clientes (id),
    tipo_documento  TEXT   NOT NULL,
    documento       TEXT   NOT NULL,
    nombre          TEXT   NOT NULL,
    UNIQUE (cliente_id, tipo_documento, documento)
);

-- ---------------------------------------------------------------------
-- Movimientos y patrimonio
-- ---------------------------------------------------------------------
CREATE TABLE categorias (
    id                SERIAL PRIMARY KEY,
    nombre            TEXT NOT NULL,
    tipo_movimiento   TEXT NOT NULL
                      CHECK (tipo_movimiento IN
                             ('ingreso', 'gasto', 'consignacion', 'pago_tarjeta', 'compra', 'gmf')),
    cedula_renta      TEXT
                      CHECK (cedula_renta IS NULL OR cedula_renta IN
                             ('trabajo', 'pensiones', 'capital', 'no_laborales', 'otros')),
    concepto_exogena  TEXT,
    UNIQUE (nombre, tipo_movimiento)
);

CREATE TABLE movimientos (
    id                 BIGSERIAL PRIMARY KEY,
    cliente_id         BIGINT        NOT NULL REFERENCES clientes (id),
    fecha              DATE          NOT NULL,
    anio_gravable      SMALLINT      GENERATED ALWAYS AS (EXTRACT(YEAR FROM fecha)::smallint) STORED,
    tipo               TEXT          NOT NULL
                       CHECK (tipo IN
                              ('ingreso', 'gasto', 'consignacion', 'pago_tarjeta', 'compra', 'gmf')),
    valor              NUMERIC(18,2) NOT NULL CHECK (valor > 0),
    categoria_id       INTEGER       REFERENCES categorias (id),
    tercero_id         BIGINT        REFERENCES terceros (id),
    cuenta_id          BIGINT        REFERENCES cuentas_bancarias (id),
    descripcion        TEXT,
    creado_por         BIGINT        NOT NULL REFERENCES usuarios (id),
    creado_en          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    anulado_en         TIMESTAMPTZ,
    anulado_por        BIGINT        REFERENCES usuarios (id),
    motivo_anulacion   TEXT,
    -- Anulación completa o ninguna (ADR-011): con motivo no vacío.
    CONSTRAINT movimientos_anulacion_ck CHECK (
        (anulado_en IS NULL AND anulado_por IS NULL AND motivo_anulacion IS NULL)
        OR
        (anulado_en IS NOT NULL AND anulado_por IS NOT NULL
         AND motivo_anulacion IS NOT NULL AND length(btrim(motivo_anulacion)) > 0)
    )
);
-- Totales del semáforo: solo movimientos no anulados.
CREATE INDEX movimientos_totales_idx
    ON movimientos (cliente_id, anio_gravable, tipo)
    WHERE anulado_en IS NULL;

CREATE TABLE soportes (
    id              BIGSERIAL PRIMARY KEY,
    movimiento_id   BIGINT      NOT NULL REFERENCES movimientos (id),
    nombre_archivo  TEXT        NOT NULL,
    ruta            TEXT        NOT NULL,
    hash_archivo    TEXT        NOT NULL,
    subido_por      BIGINT      NOT NULL REFERENCES usuarios (id),
    subido_en       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX soportes_movimiento_idx ON soportes (movimiento_id);

CREATE TABLE activos (
    id             BIGSERIAL PRIMARY KEY,
    cliente_id     BIGINT        NOT NULL REFERENCES clientes (id),
    anio_gravable  SMALLINT      NOT NULL,
    descripcion    TEXT          NOT NULL,
    tipo           TEXT          NOT NULL,
    valor_31_dic   NUMERIC(18,2) NOT NULL CHECK (valor_31_dic >= 0)
);
CREATE INDEX activos_cliente_anio_idx ON activos (cliente_id, anio_gravable);

-- ---------------------------------------------------------------------
-- Parámetros por año, con vigencia, fuente y estado (pieza central)
-- ---------------------------------------------------------------------
CREATE TABLE conjuntos_parametros (
    id            BIGSERIAL PRIMARY KEY,
    anio          SMALLINT    NOT NULL UNIQUE,
    estado        TEXT        NOT NULL
                  CHECK (estado IN ('borrador', 'en_revision', 'activo', 'historico')),
    creado_por    BIGINT      NOT NULL REFERENCES usuarios (id),
    activado_por  BIGINT      REFERENCES usuarios (id),
    activado_en   TIMESTAMPTZ,
    creado_en     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE parametros (
    id                  BIGSERIAL PRIMARY KEY,
    conjunto_id         BIGINT REFERENCES conjuntos_parametros (id),
    codigo              TEXT          NOT NULL,   -- p. ej. 'UVT', 'RENTA_TOPE_INGRESOS'
    valor               NUMERIC(18,4) NOT NULL,
    unidad              TEXT          NOT NULL
                        CHECK (unidad IN ('COP', 'UVT', 'PORCENTAJE', 'DIAS')),
    operador            TEXT CHECK (operador IN ('>=', '>')),     -- RN-12
    vigente_desde       DATE          NOT NULL,
    vigente_hasta       DATE,                                     -- NULL = sin fin
    fuente_norma        TEXT          NOT NULL,
    fuente_url          TEXT,
    nivel_verificacion  TEXT          NOT NULL
                        CHECK (nivel_verificacion IN ('verificado', 'probable', 'no_verificado')),
    estado              TEXT          NOT NULL
                        CHECK (estado IN ('borrador', 'en_revision', 'activo', 'historico')),
    creado_por          BIGINT        NOT NULL REFERENCES usuarios (id),
    aprobado_por        BIGINT        REFERENCES usuarios (id),
    aprobado_en         TIMESTAMPTZ,
    creado_en           TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CONSTRAINT parametros_vigencia_ck CHECK (vigente_hasta IS NULL OR vigente_hasta >= vigente_desde),
    CONSTRAINT parametros_activo_aprobado_ck CHECK (estado <> 'activo' OR aprobado_por IS NOT NULL)
);
CREATE INDEX parametros_codigo_idx ON parametros (codigo, vigente_desde);

-- Un mismo código no puede tener dos vigencias activas que se solapen (ADR-005, RN-62).
ALTER TABLE parametros
    ADD CONSTRAINT parametros_sin_solape
    EXCLUDE USING gist (
        codigo WITH =,
        daterange(vigente_desde, vigente_hasta, '[]') WITH &&
    ) WHERE (estado = 'activo');

-- ---------------------------------------------------------------------
-- Trazabilidad: bitácora de solo inserción (los permisos lo garantizan)
-- ---------------------------------------------------------------------
CREATE TABLE bitacora (
    id          BIGSERIAL PRIMARY KEY,
    usuario_id  BIGINT      REFERENCES usuarios (id),   -- NULL en intentos con usuario inexistente
    accion      TEXT        NOT NULL,
    entidad     TEXT,
    entidad_id  BIGINT,
    antes       JSONB,
    despues     JSONB,
    ip          TEXT,
    creado_en   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX bitacora_entidad_idx ON bitacora (entidad, entidad_id);
CREATE INDEX bitacora_fecha_idx   ON bitacora (creado_en);

COMMIT;
