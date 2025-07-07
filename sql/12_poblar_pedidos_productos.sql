-- --------------------------------------------------------------------------
-- Script: 11_poblar_pedidos_productos.sql
-- Descripción: Inserta 30 pedidos aleatorios en la tabla PEDIDOS,
--              seleccionando clientes y tiendas existentes, y además
--              crea productos y detalles de pedido para cada uno.
--              Ahora el total del pedido se calcula correctamente,
--              y las cantidades de los detalles respetan el stock inicial.
-- Ejecutar como: ECOMMERCE_FRAMEWORK
-- --------------------------------------------------------------------------

SET SERVEROUTPUT ON
SET DEFINE OFF 

PROMPT Insertando 30 pedidos aleatorios, productos y detalles de pedido...

DECLARE
    TYPE t_usuario_ids IS TABLE OF ECOMMERCE_FRAMEWORK.usuarios.usuario_id%TYPE INDEX BY PLS_INTEGER;
    TYPE t_tienda_ids IS TABLE OF ECOMMERCE_FRAMEWORK.tiendas.tienda_id%TYPE INDEX BY PLS_INTEGER;
    -- Corregido: Declaración de tipo de colección para estados de pedido
    TYPE t_estados_pedido IS TABLE OF VARCHAR2(50);

    v_usuario_ids     t_usuario_ids;
    v_tienda_ids      t_tienda_ids;
    v_num_usuarios    PLS_INTEGER;
    v_num_tiendas     PLS_INTEGER;
    v_random_usuario_id NUMBER;
    v_random_tienda_id  NUMBER;
    v_random_direccion_id NUMBER;
    v_fecha_pedido    DATE;
    v_estado_pedido   VARCHAR2(50);
    v_pedido_id       NUMBER; -- Para capturar el ID del pedido recién insertado
    v_current_pedido_total NUMBER(12, 2); -- Para calcular el total real del pedido
    
    v_num_productos_en_pedido PLS_INTEGER;
    v_producto_id     NUMBER; -- Para capturar el ID del producto recién insertado
    v_nombre_producto VARCHAR2(200);
    v_descripcion_producto VARCHAR2(1000);
    v_precio_producto NUMBER(10, 2);
    v_stock_producto  NUMBER;
    v_cantidad_detalle PLS_INTEGER; -- Cambiado a PLS_INTEGER para consistencia

    -- Estados de pedido posibles (inicialización de la colección)
    v_estados_pedido t_estados_pedido := t_estados_pedido('PENDIENTE', 'PROCESANDO', 'ENVIADO', 'ENTREGADO', 'CANCELADO');

BEGIN
    -- 1. Obtener todos los IDs de usuarios (clientes)
    SELECT usuario_id BULK COLLECT INTO v_usuario_ids
    FROM ECOMMERCE_FRAMEWORK.usuarios
    WHERE oracle_username IS NULL; -- Solo clientes comunes, no vendedores
    
    v_num_usuarios := v_usuario_ids.COUNT;

    IF v_num_usuarios = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ADVERTENCIA: No se encontraron usuarios clientes comunes para crear pedidos. Asegúrate de ejecutar 10_poblar_usuarios.sql primero.');
        RETURN;
    END IF;

    -- 2. Obtener todos los IDs de tiendas
    SELECT tienda_id BULK COLLECT INTO v_tienda_ids
    FROM ECOMMERCE_FRAMEWORK.tiendas;

    v_num_tiendas := v_tienda_ids.COUNT;

    IF v_num_tiendas = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ADVERTENCIA: No se encontraron tiendas para crear pedidos. Asegúrate de ejecutar 04_insertar_tiendas.sql primero.');
        RETURN;
    END IF;

    -- 3. Insertar 30 pedidos aleatorios
    FOR i IN 1..30 LOOP
        -- Seleccionar un usuario y una tienda aleatoria
        v_random_usuario_id := v_usuario_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_num_usuarios + 1)));
        v_random_tienda_id  := v_tienda_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_num_tiendas + 1)));

        -- Intentar obtener una dirección para el usuario seleccionado
        BEGIN
            SELECT direccion_id INTO v_random_direccion_id
            FROM ECOMMERCE_FRAMEWORK.direcciones
            WHERE usuario_id = v_random_usuario_id
            AND ROWNUM = 1; -- Tomar la primera dirección encontrada
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Si el usuario no tiene dirección, insertar una por defecto para él
                INSERT INTO ECOMMERCE_FRAMEWORK.direcciones (usuario_id, calle, numero, comuna, ciudad, pais)
                VALUES (v_random_usuario_id, 'Calle Aleatoria ' || DBMS_RANDOM.STRING('X', 5), TRUNC(DBMS_RANDOM.VALUE(1, 1000)), 'Comuna ' || TRUNC(DBMS_RANDOM.VALUE(1, 10)), 'Ciudad ' || TRUNC(DBMS_RANDOM.VALUE(1, 5)), 'Chile')
                RETURNING direccion_id INTO v_random_direccion_id;
                DBMS_OUTPUT.PUT_LINE('INFO: Se insertó una dirección para el usuario ID: ' || v_random_usuario_id);
        END;

        -- Generar datos aleatorios para el pedido (el total se calculará después)
        v_fecha_pedido := TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 365)); -- Fecha en el último año (últimos 365 días)
        v_estado_pedido := v_estados_pedido(TRUNC(DBMS_RANDOM.VALUE(1, v_estados_pedido.COUNT + 1)));

        -- Insertar el pedido con un total temporal (se actualizará al final del bucle interno)
        INSERT INTO ECOMMERCE_FRAMEWORK.pedidos (usuario_id, tienda_id, fecha_pedido, estado_pedido, total, direccion_envio_id)
        VALUES (v_random_usuario_id, v_random_tienda_id, v_fecha_pedido, v_estado_pedido, 0, v_random_direccion_id)
        RETURNING pedido_id INTO v_pedido_id; -- Captura el ID del pedido recién creado
        
        v_current_pedido_total := 0; -- Reiniciar el total para cada nuevo pedido

        -- Generar e insertar productos y detalles de pedido para este pedido
        v_num_productos_en_pedido := TRUNC(DBMS_RANDOM.VALUE(1, 4)); -- Entre 1 y 3 productos por pedido

        FOR j IN 1..v_num_productos_en_pedido LOOP
            -- Generar datos aleatorios para el producto
            v_nombre_producto := 'Producto ' || DBMS_RANDOM.STRING('A', 8);
            v_descripcion_producto := 'Descripción para ' || v_nombre_producto || ' de la tienda ' || v_random_tienda_id;
            v_precio_producto := ROUND(DBMS_RANDOM.VALUE(5, 200), 2); -- Precio entre 5 y 200
            v_stock_producto := TRUNC(DBMS_RANDOM.VALUE(10, 100)); -- Stock entre 10 y 100

            -- Insertar el producto y obtener su ID
            INSERT INTO ECOMMERCE_FRAMEWORK.productos (tienda_id, nombre, descripcion, precio, stock, fecha_creacion, fecha_actualizacion, sku)
            VALUES (v_random_tienda_id, v_nombre_producto, v_descripcion_producto, v_precio_producto, v_stock_producto, SYSDATE, SYSDATE, 'SKU-' || DBMS_RANDOM.STRING('X', 5))
            RETURNING producto_id INTO v_producto_id; -- Captura el ID del producto recién creado

            -- Generar cantidad para el detalle del pedido, respetando el stock
            -- La cantidad será entre 1 y el mínimo de (stock_producto, 4)
            v_cantidad_detalle := TRUNC(DBMS_RANDOM.VALUE(1, LEAST(v_stock_producto, 4) + 1));
            IF v_cantidad_detalle = 0 THEN v_cantidad_detalle := 1; END IF; -- Asegurar al menos 1 si LEAST devuelve 0

            -- Insertar el detalle del pedido
            INSERT INTO ECOMMERCE_FRAMEWORK.detalles_pedido (pedido_id, fecha_pedido_fk, producto_id, cantidad, precio_unitario)
            VALUES (v_pedido_id, v_fecha_pedido, v_producto_id, v_cantidad_detalle, v_precio_producto);

            -- Sumar al total del pedido
            v_current_pedido_total := v_current_pedido_total + (v_cantidad_detalle * v_precio_producto);
        END LOOP;

        -- Actualizar el total real del pedido una vez que todos los detalles han sido insertados
        UPDATE ECOMMERCE_FRAMEWORK.pedidos
        SET total = v_current_pedido_total
        WHERE pedido_id = v_pedido_id AND fecha_pedido = v_fecha_pedido; -- Usar PK compuesta
        
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('30 pedidos, productos y detalles de pedido aleatorios insertados con éxito.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO al insertar pedidos, productos o detalles: ' || SQLERRM);
END;
/

PROMPT Script 11_poblar_pedidos_productos.sql finalizado.
