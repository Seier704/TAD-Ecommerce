
SET SERVEROUTPUT ON;
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';

PROMPT =========================================================================
PROMPT PASO 1, 2, 3: CREACIÓN DE ESTRUCTURA, VISTAS Y TRIGGERS
PROMPT =========================================================================
PROMPT Ejecutando scripts de creación de BBDD. Esto puede tomar un momento...
@/app/sql/02_crear_tablas.sql
@/app/sql/04_optimizacion_vistas.sql
@/app/sql/06_triggers.sql
PROMPT Estructura, vistas y triggers listos.
PAUSE Presione Enter para continuar...

PROMPT =========================================================================
PROMPT PASO 4: POBLACIÓN DE DATOS INICIALES
PROMPT =========================================================================
PROMPT Ejecutando '/app/sql/03_poblar_datos_prueba.sql' para cargar datos de demo.
@/app/sql/03_poblar_datos_prueba.sql

PROMPT Datos de prueba cargados. Verifiquemos el estado inicial.
PROMPT -------------------------------------------------------------------------
PROMPT Tienda creada:
SELECT * FROM tiendas WHERE tienda_id = 1;
PROMPT -------------------------------------------------------------------------
PROMPT Stock inicial del producto 'Zapatillas "El Rayo"':
PROMPT (El script de poblado ya vendió 1 unidad, por lo que el stock inicial es 19)
SELECT nombre, stock FROM productos WHERE producto_id = 1;

PAUSE Presione Enter para continuar...

PROMPT =========================================================================
PROMPT PASO 5: DEMO DE LÓGICA DE NEGOCIO - VENTA EXITOSA
PROMPT =========================================================================
PROMPT Se inserta un nuevo pedido (ID 2) y su detalle.
PROMPT El trigger 'trg_disminuir_stock_venta' DEBERIA reducir el stock de 19 a 18.
PROMPT -------------------------------------------------------------------------

-- El script de poblado ya creó el pedido con ID 1. Continuamos con el ID 2.
INSERT INTO pedidos (pedido_id, usuario_id, fecha_pedido, estado, total)
VALUES (2, 102, TO_DATE('30-06-2025', 'DD-MM-YYYY'), 'completado', 69990);

INSERT INTO detalles_pedido (pedido_id, fecha_pedido_fk, producto_id, cantidad, precio_unitario)
VALUES (2, TO_DATE('30-06-2025', 'DD-MM-YYYY'), 1, 1, 69990);

COMMIT;

PROMPT Venta registrada. Verificando el nuevo stock del producto:
SELECT nombre, stock FROM productos WHERE producto_id = 1;

PAUSE Presione Enter para continuar...

PROMPT =========================================================================
PROMPT PASO 6: VERIFICACIÓN DE LA AUDITORÍA
PROMPT =========================================================================
PROMPT El trigger de auditoría debió registrar el cambio. Verificando con una consulta simple:
PROMPT -------------------------------------------------------------------------
SELECT tipo_operacion, SUBSTR(valores_antiguos, 1, 80) AS antiguos, SUBSTR(valores_nuevos, 1, 80) AS nuevos
FROM vw_auditoria_productos
WHERE registro_id = 1 AND tipo_operacion = 'UPDATE'
ORDER BY fecha_accion DESC FETCH FIRST 1 ROWS ONLY;

PAUSE Presione Enter para continuar...

PROMPT =========================================================================
PROMPT PASO 7: DEMO DE LÓGICA DE NEGOCIO - TRANSACCIÓN FALLIDA
PROMPT =========================================================================
PROMPT Se intenta comprar más stock del disponible (18). Se espera un error ORA-20001
PROMPT lanzado por el trigger 'trg_validar_stock'.
PROMPT -------------------------------------------------------------------------
INSERT INTO detalles_pedido (pedido_id, fecha_pedido_fk, producto_id, cantidad, precio_unitario)
VALUES (2, TO_DATE('30-06-2025', 'DD-MM-YYYY'), 1, 100, 69990);

PROMPT Si vio el error ORA-20001, el trigger funcionó correctamente.
PAUSE Presione Enter para continuar...

PROMPT =========================================================================
PROMPT PASO 8: INTEGRACIÓN CON DATA WAREHOUSE (ETL)
PROMPT =========================================================================
PROMPT Se limpian los datos antiguos y se cargan TODAS las ventas (la del poblado y la de la demo)
PROMPT al Data Warehouse con una única consulta INSERT-SELECT.
PROMPT -------------------------------------------------------------------------
DELETE FROM Hecho_Ventas;

INSERT INTO Hecho_Ventas (id_venta, fecha_id, fecha, producto_id, usuario_id, tienda_id, cantidad, precio_unitario, total_venta)
SELECT
    dp.detalle_id,
    extraer_dim_tiempo(dp.fecha_pedido_fk),
    dp.fecha_pedido_fk,
    dp.producto_id,
    p.usuario_id,
    pr.tienda_id,
    dp.cantidad,
    dp.precio_unitario,
    dp.cantidad * dp.precio_unitario
FROM detalles_pedido dp
JOIN pedidos p ON dp.pedido_id = p.pedido_id AND dp.fecha_pedido_fk = p.fecha_pedido
JOIN productos pr ON dp.producto_id = pr.producto_id;

COMMIT;

PROMPT Datos cargados al DW. Verificando el contenido de la tabla de hechos:
SELECT id_venta, producto_id, usuario_id, cantidad, total_venta FROM Hecho_Ventas;

PAUSE Presione Enter para finalizar la demo...

PROMPT =========================================================================
PROMPT FIN DE LA DEMO.
PROMPT =========================================================================
