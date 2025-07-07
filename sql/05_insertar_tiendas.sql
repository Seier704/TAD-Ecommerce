-- --------------------------------------------------------------------------
-- Script: 04_insertar_tiendas.sql
-- Descripción: Inserta las tiendas iniciales en la tabla TIENDAS.
-- Ejecutar como: ECOMMERCE_FRAMEWORK
-- --------------------------------------------------------------------------

PROMPT Insertando tiendas iniciales...

-- Insertar la tienda 'Nike'
INSERT INTO ECOMMERCE_FRAMEWORK.tiendas (nombre, url_dominio)
VALUES ('Nike', 'https://www.nike.com');
PROMPT Tienda 'Nike' insertada.

-- Insertar la tienda 'Adidas'
INSERT INTO ECOMMERCE_FRAMEWORK.tiendas (nombre, url_dominio)
VALUES ('Adidas', 'https://www.adidas.com');
PROMPT Tienda 'Adidas' insertada.

COMMIT;

PROMPT Todas las tiendas iniciales han sido insertadas con éxito.
