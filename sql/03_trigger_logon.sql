-- --------------------------------------------------------------------------
-- Script para crear y compilar el trigger de LOGON para la seguridad a nivel de fila.
-- DEBE EJECUTARSE COMO SYS (AS SYSDBA) Y DESPUÉS DE QUE LA TABLA USUARIOS EXISTA
-- Y EL GRANT SELECT SOBRE ELLA A SYS HAYA SIDO OTORGADO.
-- --------------------------------------------------------------------------

PROMPT Intentando crear/reemplazar el trigger sys.trg_set_identifier_on_logon...

CREATE OR REPLACE TRIGGER sys.trg_set_identifier_on_logon
AFTER LOGON ON DATABASE
DECLARE
    v_email         ECOMMERCE_FRAMEWORK.usuarios.email%TYPE;
    v_oracle_user   VARCHAR2(128) := SYS_CONTEXT('USERENV', 'SESSION_USER');
BEGIN
    -- No ejecutar esta lógica para usuarios del sistema
    IF v_oracle_user NOT IN ('SYS', 'SYSTEM', 'ECOMMERCE_FRAMEWORK') THEN
        BEGIN
            -- 1. Busca el email correspondiente al usuario de Oracle que inició sesión
            SELECT email INTO v_email
            FROM ECOMMERCE_FRAMEWORK.usuarios
            WHERE oracle_username = v_oracle_user;

            -- 2. Establece el identificador de sesión con el email encontrado
            IF v_email IS NOT NULL THEN
                DBMS_SESSION.SET_IDENTIFIER(v_email);
            END IF;
        EXCEPTION
            -- Si el usuario de Oracle no tiene un perfil en la tabla 'usuarios', no hagas nada.
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;
END;
/

PROMPT Trigger sys.trg_set_identifier_on_logon creado/reemplazado.

PROMPT Compilando el trigger sys.trg_set_identifier_on_logon para asegurar validez...
ALTER TRIGGER sys.trg_set_identifier_on_logon COMPILE;
PROMPT Verificando estado del trigger...
SELECT status FROM ALL_OBJECTS WHERE OBJECT_NAME = 'TRG_SET_IDENTIFIER_ON_LOGON' AND OWNER = 'SYS';

PROMPT Script 03_crear_sys_trigger.sql finalizado.