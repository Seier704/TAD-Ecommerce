-- --------------------------------------------------------------------------
-- Script: 03_crear_roles.sql
-- Descripción: Crea los roles de usuario y asigna permisos sobre tablas y vistas.
-- Ejecutar como: ECOMMERCE_FRAMEWORK
-- --------------------------------------------------------------------------

PROMPT >>> Creando roles...

-- Roles de aplicación
CREATE ROLE rol_administrador;
CREATE ROLE rol_administrador_tienda;
CREATE ROLE rol_vendedor;
CREATE ROLE rol_bodeguero;
CREATE ROLE rol_analista;
CREATE ROLE rol_soporte;

PROMPT >>> Roles creados.

