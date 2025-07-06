-- --------------------------------------------------------------------------
-- Script: 05_procedimientos.sql
-- Descripción: Contiene la creación de procedimientos almacenados para el esquema ECOMMERCE_FRAMEWORK.
-- Ejecutar como: ECOMMERCE_FRAMEWORK
-- --------------------------------------------------------------------------

SET SERVEROUTPUT ON;

PROMPT Creando procedimiento ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion...

-- --------------------------------------------------------------------------
-- Procedimiento Almacenado: ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion
-- --------------------------------------------------------------------------
-- Este procedimiento permite insertar un nuevo usuario de aplicación
-- en la tabla USUARIOS, vinculándolo a una tienda existente por su nombre
-- y asignándole un usuario de base de datos Oracle específico.
--
-- Parámetros:
--   p_nombre_tienda:      VARCHAR2 - Nombre de la tienda a la que pertenece el usuario.
--   p_email_usuario:      VARCHAR2 - Correo electrónico único del usuario de la aplicación.
--   p_password_hash:      VARCHAR2 - Hash seguro de la contraseña del usuario (NO la contraseña en texto plano).
--   p_nombre:             VARCHAR2 - Nombre del usuario.
--   p_apellido:           VARCHAR2 - Apellido del usuario.
--   p_oracle_username:    VARCHAR2 - Nombre del usuario de base de datos Oracle asociado (ej. 'VENDEDOR_ADIDAS_USER').
-- --------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion (
    p_nombre_tienda      IN VARCHAR2,
    p_email_usuario      IN VARCHAR2,
    p_password_hash      IN VARCHAR2,
    p_nombre             IN VARCHAR2,
    p_apellido           IN VARCHAR2,
    p_oracle_username    IN VARCHAR2
)
AS
    v_tienda_id NUMBER;
BEGIN
    -- 1. Obtener el ID de la tienda usando el nombre proporcionado
    -- Si la tienda no existe, se lanzará NO_DATA_FOUND.
    SELECT tienda_id INTO v_tienda_id
    FROM ECOMMERCE_FRAMEWORK.tiendas
    WHERE nombre = p_nombre_tienda;

    -- 2. Insertar el nuevo usuario de aplicación en la tabla USUARIOS
    INSERT INTO ECOMMERCE_FRAMEWORK.usuarios (tienda_id, email, password_hash, nombre, apellido, oracle_username)
    VALUES (v_tienda_id, p_email_usuario, p_password_hash, p_nombre, p_apellido, p_oracle_username);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Usuario ' || p_email_usuario || ' insertado y asociado a la tienda ' || p_nombre_tienda || ' (ID: ' || v_tienda_id || ').');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: La tienda con nombre "' || p_nombre_tienda || '" no fue encontrada. Asegúrate de que haya sido insertada correctamente.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Ya existe un usuario con el email "' || p_email_usuario || '" en la tienda "' || p_nombre_tienda || '", o el oracle_username "' || p_oracle_username || '" ya está en uso.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO al insertar el usuario: ' || SQLERRM);
END;
/

PROMPT Procedimiento ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion creado con éxito.
