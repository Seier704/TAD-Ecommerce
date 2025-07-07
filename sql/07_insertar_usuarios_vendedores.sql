-- --------------------------------------------------------------------------
-- Script: 06_insertar_usuarios_vendedores.sql
-- Descripción: Crea usuarios de base de datos Oracle para vendedores
--              y luego usa el procedimiento crear_usuario_aplicacion
--              para vincularlos a sus tiendas.
-- Ejecutar como: ECOMMERCE_FRAMEWORK
-- --------------------------------------------------------------------------

SET SERVEROUTPUT ON;

PROMPT Creando usuarios de base de datos Oracle y usuarios de aplicacion para vendedores...

-- --------------------------------------------------------------------------
-- Vendedor para la tienda 'Nike'
-- --------------------------------------------------------------------------

PROMPT Creando usuario de base de datos Oracle para Vendedor Nike (VENDEDOR_NIKE_USER)...
-- Crear el usuario de base de datos Oracle para el vendedor de Nike

CREATE USER VENDEDOR_NIKE_USER IDENTIFIED BY nike_123;
PROMPT Usuario VENDEDOR_NIKE_USER creado.

-- Otorgar permisos básicos y el rol de aplicacion al usuario de DB
GRANT CONNECT, RESOURCE TO VENDEDOR_NIKE_USER;
ALTER USER VENDEDOR_NIKE_USER QUOTA UNLIMITED ON users;
GRANT rol_vendedor TO VENDEDOR_NIKE_USER;
PROMPT Permisos otorgados a VENDEDOR_NIKE_USER.

-- Llamar al procedimiento para crear el usuario de aplicacion 'vendedor.nike@tienda.cl'
BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Nike',
        p_email_usuario      => 'vendedor.nike@tienda.cl',
        p_password_hash      => 'hash_nike_123', -- Reemplazar con hash real de 'nike123'
        p_nombre             => 'Juan',
        p_apellido           => 'Vendedor Nike',
        p_oracle_username    => 'VENDEDOR_NIKE_USER'
    );
END;
/
PROMPT Llamada a crear_usuario_aplicacion para vendedor.nike@tienda.cl finalizada.

-- --------------------------------------------------------------------------
-- Vendedor para la tienda 'Adidas'
-- --------------------------------------------------------------------------

PROMPT Creando usuario de base de datos Oracle para Vendedor Adidas (VENDEDOR_ADIDAS_USER)...
-- Crear el usuario de base de datos Oracle para el vendedor de Adidas

CREATE USER VENDEDOR_ADIDAS_USER IDENTIFIED BY adidas_123;
PROMPT Usuario VENDEDOR_ADIDAS_USER creado.

-- Otorgar permisos básicos y el rol de aplicacion al usuario de DB
GRANT CONNECT, RESOURCE TO VENDEDOR_ADIDAS_USER;
ALTER USER VENDEDOR_ADIDAS_USER QUOTA UNLIMITED ON users;
GRANT rol_vendedor TO VENDEDOR_ADIDAS_USER;
PROMPT Permisos otorgados a VENDEDOR_ADIDAS_USER.

-- Llamar al procedimiento para crear el usuario de aplicacion 'vendedor.adidas@tienda.cl'
BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Adidas',
        p_email_usuario      => 'vendedor.adidas@tienda.cl',
        p_password_hash      => 'hash_adidas_456', -- Reemplazar con hash real de 'adidas123'
        p_nombre             => 'Ana',
        p_apellido           => 'Vendedora Adidas',
        p_oracle_username    => 'VENDEDOR_ADIDAS_USER'
    );
END;
/
PROMPT Llamada a crear_usuario_aplicacion para vendedor.adidas@tienda.cl finalizada.

PROMPT Todos los usuarios vendedores han sido configurados con éxito.
