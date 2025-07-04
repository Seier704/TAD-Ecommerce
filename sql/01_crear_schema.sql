-- --------------------------------------------------------------------------
-- Este script crea el usuario (esquema) principal para la aplicación
-- del framework de e-commerce. Debe ser ejecutado por un usuario con
-- privilegios de DBA, como SYSTEM.
-- --------------------------------------------------------------------------
-- NOTA: OJO PIOJO La siguiente línea es útil si necesitan borrar y volver a crear el usuario 🧐
-- DROP USER ECOMMERCE_FRAMEWORK CASCADE;

CREATE USER ECOMMERCE_FRAMEWORK
IDENTIFIED BY framework123
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp;

-- Otorgar los permisos básicos para que el nuevo usuario pueda conectarse,
-- crear tablas, procedimientos, y otros objetos.

GRANT CONNECT, RESOURCE TO ECOMMERCE_FRAMEWORK;
GRANT CREATE VIEW TO ECOMMERCE_FRAMEWORK;
GRANT CREATE ROLE TO ECOMMERCE_FRAMEWORK;
GRANT CREATE ANY CONTEXT TO ECOMMERCE_FRAMEWORK;
GRANT ADMINISTER DATABASE TRIGGER TO ECOMMERCE_FRAMEWORK;
GRANT EXECUTE ON DBMS_RLS TO ECOMMERCE_FRAMEWORK;
ALTER USER ECOMMERCE_FRAMEWORK QUOTA UNLIMITED ON USERS;
GRANT CREATE USER TO ECOMMERCE_FRAMEWORK;
GRANT ALTER USER TO ECOMMERCE_FRAMEWORK;
GRANT DROP USER TO ECOMMERCE_FRAMEWORK;

-- Otorgar permiso para que pueda asignar roles a otros usuarios
GRANT CONNECT, RESOURCE TO ECOMMERCE_FRAMEWORK WITH ADMIN OPTION;

-- Sal de la sesión de SYS
EXIT;

-- Le damos permiso para ocupar espacio en el tablespace 'users'.
ALTER USER ECOMMERCE_FRAMEWORK QUOTA UNLIMITED ON users;

-- Mensajinho de confirmación
PROMPT Usuario ECOMMERCE_FRAMEWORK creado y con permisos básicos otorgados.