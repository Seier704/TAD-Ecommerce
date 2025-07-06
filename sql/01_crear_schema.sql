-- --------------------------------------------------------------------------
-- Script para crear el usuario principal del sistema de e-commerce
-- y otorgarle todos los permisos necesarios para administración posterior.
-- Ejecutar como SYS o SYSTEM con privilegios de DBA.
-- --------------------------------------------------------------------------

-- Si necesitas reiniciar desde cero, puedes usar:
-- DROP USER ECOMMERCE_FRAMEWORK CASCADE;

-- 1. Crear el usuario
CREATE USER ECOMMERCE_FRAMEWORK
IDENTIFIED BY framework123
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp;

-- 2. Otorgar permisos básicos para desarrollo
GRANT CONNECT, RESOURCE TO ECOMMERCE_FRAMEWORK;

-- 3. Permisos adicionales para vistas, procedimientos, funciones, triggers
GRANT CREATE VIEW TO ECOMMERCE_FRAMEWORK;
GRANT CREATE PROCEDURE TO ECOMMERCE_FRAMEWORK;
GRANT CREATE TRIGGER TO ECOMMERCE_FRAMEWORK;

-- 4. Cuota ilimitada en el tablespace
ALTER USER ECOMMERCE_FRAMEWORK QUOTA UNLIMITED ON users;

-- 5. Permisos administrativos adicionales para crear usuarios y roles
GRANT CREATE USER TO ECOMMERCE_FRAMEWORK;
GRANT CREATE ROLE TO ECOMMERCE_FRAMEWORK;
GRANT GRANT ANY ROLE TO ECOMMERCE_FRAMEWORK;
GRANT ALTER USER TO ECOMMERCE_FRAMEWORK;
GRANT CREATE ANY TRIGGER TO ECOMMERCE_FRAMEWORK;

-- Mensaje de confirmación
PROMPT Usuario ECOMMERCE_FRAMEWORK creado y con permisos completos otorgados.
