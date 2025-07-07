-- --------------------------------------------------------------------------
-- Script: 10_poblar_usuarios.sql
-- Descripción: Inserta 10 usuarios clientes comunes (sin usuario de DB Oracle asociado)
--              5 para Adidas y 5 para Nike, usando el procedimiento
--              ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion.
-- Ejecutar como: ECOMMERCE_FRAMEWORK
-- --------------------------------------------------------------------------

SET SERVEROUTPUT ON
SET DEFINE OFF 

PROMPT Insertando 10 clientes comunes (5 para Adidas, 5 para Nike)...

-- --------------------------------------------------------------------------
-- Clientes para la tienda 'Adidas'
-- --------------------------------------------------------------------------
PROMPT Insertando clientes para Adidas...

BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Adidas',
        p_email_usuario      => 'cliente1.adidas@email.com',
        p_password_hash      => 'hash_cliente1_adidas',
        p_nombre             => 'Ana',
        p_apellido           => 'Garcia'
        -- p_oracle_username se omite aquí, ya que es DEFAULT NULL en el procedimiento
    );
END;
/

BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Adidas',
        p_email_usuario      => 'cliente2.adidas@email.com',
        p_password_hash      => 'hash_cliente2_adidas',
        p_nombre             => 'Pedro',
        p_apellido           => 'Martinez'
    );
END;
/

BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Adidas',
        p_email_usuario      => 'cliente3.adidas@email.com',
        p_password_hash      => 'hash_cliente3_adidas',
        p_nombre             => 'Sofia',
        p_apellido           => 'Lopez'
    );
END;
/

BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Adidas',
        p_email_usuario      => 'cliente4.adidas@email.com',
        p_password_hash      => 'hash_cliente4_adidas',
        p_nombre             => 'Javier',
        p_apellido           => 'Perez'
    );
END;
/

BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Adidas',
        p_email_usuario      => 'cliente5.adidas@email.com',
        p_password_hash      => 'hash_cliente5_adidas',
        p_nombre             => 'Elena',
        p_apellido           => 'Rodriguez'
    );
END;
/

PROMPT 5 clientes para Adidas insertados.

-- --------------------------------------------------------------------------
-- Clientes para la tienda 'Nike'
-- --------------------------------------------------------------------------
PROMPT Insertando clientes para Nike...

BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Nike',
        p_email_usuario      => 'cliente1.nike@email.com',
        p_password_hash      => 'hash_cliente1_nike',
        p_nombre             => 'Miguel',
        p_apellido           => 'Sanchez'
    );
END;
/

BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Nike',
        p_email_usuario      => 'cliente2.nike@email.com',
        p_password_hash      => 'hash_cliente2_nike',
        p_nombre             => 'Laura',
        p_apellido           => 'Diaz'
    );
END;
/

BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Nike',
        p_email_usuario      => 'cliente3.nike@email.com',
        p_password_hash      => 'hash_cliente3_nike',
        p_nombre             => 'Pablo',
        p_apellido           => 'Fernandez'
    );
END;
/

BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Nike',
        p_email_usuario      => 'cliente4.nike@email.com',
        p_password_hash      => 'hash_cliente4_nike',
        p_nombre             => 'Isabel',
        p_apellido           => 'Gomez'
    );
END;
/

BEGIN
    ECOMMERCE_FRAMEWORK.crear_usuario_aplicacion(
        p_nombre_tienda      => 'Nike',
        p_email_usuario      => 'cliente5.nike@email.com',
        p_password_hash      => 'hash_cliente5_nike',
        p_nombre             => 'Ricardo',
        p_apellido           => 'Ruiz'
    );
END;
/

PROMPT 5 clientes para Nike insertados.
PROMPT Todos los 10 clientes comunes han sido insertados con éxito.