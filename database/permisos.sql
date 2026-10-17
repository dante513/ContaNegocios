-- =====================================================================
-- ContaNegocios · Permisos del usuario de la aplicación
-- Ejecutar con un usuario administrador DESPUÉS de schema.sql y de cada migración:
--   psql -U postgres -d contanegocios -f database/permisos.sql
-- Supone que el rol contanegocios_app ya existe (ver 05-despliegue/01-instalacion-local.md).
-- =====================================================================

-- La aplicación no debe poder crear objetos en el esquema.
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO contanegocios_app;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO contanegocios_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO contanegocios_app;

-- La bitácora es de solo inserción y lectura (RNF-03, CP-48, PS-14).
REVOKE UPDATE, DELETE ON bitacora FROM contanegocios_app;
