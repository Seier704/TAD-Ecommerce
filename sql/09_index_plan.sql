-- Indices priorizados en tabla_auditoria
-- Estos índices pueden estar duplicados si 07_optimizar_vistas.sql también los crea.
-- Si 07_optimizar_vistas.sql ya los crea, puedes eliminar estas líneas de aquí.
CREATE INDEX idx_auditoria_tabla ON tabla_auditoria(nombre_tabla);
CREATE INDEX idx_auditoria_tipo_operacion ON tabla_auditoria(tipo_operacion);
CREATE INDEX idx_auditoria_usuario_fecha ON tabla_auditoria(usuario_accion, fecha_accion);
CREATE INDEX idx_auditoria_fecha ON tabla_auditoria(fecha_accion);
CREATE INDEX idx_auditoria_registro ON tabla_auditoria(registro_id);
CREATE INDEX idx_auditoria_valores_antiguos ON tabla_auditoria(valores_antiguos) INDEXTYPE IS CTXSYS.CONTEXT;

-- Indices de apoyo en tablas claves
-- Estos índices pueden estar duplicados si 07_optimizar_vistas.sql también los crea.
-- Si 07_optimizar_vistas.sql ya los crea, puedes eliminar estas líneas de aquí.
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_fecha_registro ON usuarios(fecha_registro);
CREATE INDEX idx_productos_nombre ON productos(nombre);
CREATE INDEX idx_productos_precio ON productos(precio);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);

-- Indice para seguimiento de pedidos en rango de fechas.
-- CORREGIDO: 'estado' cambiado a 'estado_pedido'
CREATE INDEX idx_pedidos_usuario_estado ON pedidos(usuario_id, estado_pedido);

-- Indice de reportes por cliente y estado del pedido.
CREATE INDEX idx_pagos_metodo_estado ON pagos(metodo_pago, estado_pago);

-- Indice de pagos y deteccion de fallas.
CREATE INDEX idx_detalles_pedido_producto ON detalles_pedido(producto_id);

-- Indice productos mas vendidos o devoluciones.
CREATE INDEX idx_direcciones_ciudad ON direcciones(ciudad);


-- Explain Plan, se crearan 3 explain plan con las siguientes especificaciones(Resumen total de operaciones, Resumen total de ventas).
-- Primer Explain plan (Resumen total de Operaciones.)

EXPLAIN PLAN FOR
SELECT nombre_tabla, tipo_operacion, COUNT(*) AS total_operaciones
FROM tabla_auditoria
GROUP BY nombre_tabla, tipo_operacion
ORDER BY nombre_tabla, tipo_operacion;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Segundo Explain plan (Resumen total de ventas.)

EXPLAIN PLAN FOR
SELECT p.nombre, SUM(dp.cantidad) AS total_unidades, SUM(dp.cantidad * dp.precio_unitario) AS total_ventas
FROM detalles_pedido dp
JOIN productos p ON dp.producto_id = p.producto_id
GROUP BY p.nombre
ORDER BY total_ventas DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);