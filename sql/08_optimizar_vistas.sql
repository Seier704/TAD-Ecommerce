-- --------------------------------------------------------------------------
-- SCRIPT: 07_optimizar_vistas.sql
-- Descripción: Creación de la función f_get_tienda_id y todas las vistas
--              (RLS y Data Warehouse) para el esquema ECOMMERCE_FRAMEWORK.
-- Ejecutar como: ECOMMERCE_FRAMEWORK
-- --------------------------------------------------------------------------

PROMPT >>> Creando función f_get_tienda_id...
-- Función para obtener el ID de la tienda del usuario logueado
CREATE OR REPLACE FUNCTION f_get_tienda_id
RETURN NUMBER IS
  v_id NUMBER;
BEGIN
  SELECT tienda_id INTO v_id
  FROM usuarios
  WHERE email = SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER');
  RETURN v_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;
/
PROMPT >>> Función f_get_tienda_id creada.


PROMPT >>> Creando vistas de RLS (Seguridad a Nivel de Fila)...

-- PRODUCTOS: Solo los productos de la tienda del usuario logueado
CREATE OR REPLACE VIEW v_productos AS
SELECT *
FROM productos
WHERE tienda_id = f_get_tienda_id();

-- CATEGORIAS: Solo las categorías de la tienda del usuario logueado
CREATE OR REPLACE VIEW v_categorias AS
SELECT *
FROM categorias
WHERE tienda_id = f_get_tienda_id();

-- PEDIDOS: Solo los pedidos de usuarios de la tienda del usuario logueado
CREATE OR REPLACE VIEW v_pedidos AS
SELECT p.*
FROM pedidos p
JOIN usuarios u ON p.usuario_id = u.usuario_id
WHERE u.tienda_id = f_get_tienda_id();

-- DETALLES_PEDIDO: Detalles de pedidos de la tienda del usuario logueado
CREATE OR REPLACE VIEW v_detalles_pedido AS
SELECT dp.*
FROM detalles_pedido dp
JOIN pedidos p ON dp.pedido_id = p.pedido_id AND dp.fecha_pedido_fk = p.fecha_pedido
JOIN usuarios u ON p.usuario_id = u.usuario_id
WHERE u.tienda_id = f_get_tienda_id();

-- PAGOS: Pagos de pedidos de la tienda del usuario logueado
CREATE OR REPLACE VIEW v_pagos AS
SELECT pg.*
FROM pagos pg
JOIN pedidos p ON pg.pedido_id = p.pedido_id AND pg.fecha_pedido_fk = p.fecha_pedido
JOIN usuarios u ON p.usuario_id = u.usuario_id
WHERE u.tienda_id = f_get_tienda_id();

-- USUARIOS: Solo los usuarios de la tienda del usuario logueado
CREATE OR REPLACE VIEW v_usuarios AS
SELECT *
FROM usuarios
WHERE tienda_id = f_get_tienda_id();

-- DIRECCIONES: Direcciones de usuarios de la tienda del usuario logueado
CREATE OR REPLACE VIEW v_direcciones AS
SELECT d.*
FROM direcciones d
JOIN usuarios u ON d.usuario_id = u.usuario_id
WHERE u.tienda_id = f_get_tienda_id();

-- PRODUCTO_CATEGORIAS: Categorías de productos de la tienda del usuario logueado
CREATE OR REPLACE VIEW v_producto_categorias AS
SELECT pc.*
FROM producto_categorias pc
JOIN productos p ON pc.producto_id = p.producto_id
WHERE p.tienda_id = f_get_tienda_id();

-- USUARIO_ROLES: Roles de usuarios de la tienda del usuario logueado
CREATE OR REPLACE VIEW v_usuario_roles AS
SELECT ur.*
FROM usuario_roles ur
JOIN usuarios u ON ur.usuario_id = u.usuario_id
WHERE u.tienda_id = f_get_tienda_id();

-- TIENDAS: Solo la tienda del usuario logueado
CREATE OR REPLACE VIEW v_tiendas AS
SELECT *
FROM tiendas
WHERE tienda_id = f_get_tienda_id();

PROMPT >>> Vistas de RLS creadas exitosamente.


PROMPT >>> Creando vistas de Data Warehouse (DW)...

-- Dim_Tiempo: No necesita filtro por tienda, es global
CREATE OR REPLACE VIEW v_dim_tiempo AS
SELECT * FROM Dim_Tiempo;

-- Dim_Producto: Productos de la tienda del usuario logueado (a través de la tabla OLTP)
CREATE OR REPLACE VIEW v_dim_producto AS
SELECT dp.*
FROM Dim_Producto dp
JOIN productos p ON dp.producto_id = p.producto_id
WHERE p.tienda_id = f_get_tienda_id();

-- Dim_Usuario: Usuarios de la tienda del usuario logueado (a través de la tabla OLTP)
CREATE OR REPLACE VIEW v_dim_usuario AS
SELECT du.*
FROM Dim_Usuario du
JOIN usuarios u ON du.usuario_id = u.usuario_id
WHERE u.tienda_id = f_get_tienda_id();

-- Dim_Tienda: Solo la tienda del usuario logueado
CREATE OR REPLACE VIEW v_dim_tienda AS
SELECT *
FROM Dim_Tienda
WHERE tienda_id = f_get_tienda_id();

-- Hecho_Ventas: Ventas de la tienda del usuario logueado (a través de Dim_Tienda)
CREATE OR REPLACE VIEW v_hecho_ventas AS
SELECT hv.*
FROM Hecho_Ventas hv
JOIN Dim_Tienda dt ON hv.tienda_dim_id = dt.tienda_dim_id
WHERE dt.tienda_id = f_get_tienda_id();

-- Tabla de auditoría: Solo auditorías de usuarios de la tienda logueada
CREATE OR REPLACE VIEW v_tabla_auditoria AS
SELECT a.*
FROM tabla_auditoria a
JOIN usuarios u ON u.email = a.usuario_accion -- Asume que usuario_accion es el email del usuario de la aplicación
WHERE u.tienda_id = f_get_tienda_id();

PROMPT >>> Vistas de Data Warehouse creadas exitosamente.

PROMPT >>> Creando vistas de auditoría por tabla...

-- Vista: Auditoría de tiendas
CREATE OR REPLACE VIEW vw_auditoria_tiendas AS
SELECT auditoria_id, tipo_operacion, registro_id AS tienda_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'tiendas';
PROMPT Vista vw_auditoria_tiendas creada.

-- Vista: Auditoría de usuarios
CREATE OR REPLACE VIEW vw_auditoria_usuarios AS
SELECT auditoria_id, tipo_operacion, registro_id AS usuario_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'usuarios';
PROMPT Vista vw_auditoria_usuarios creada.

-- Vista: Auditoría de productos
CREATE OR REPLACE VIEW vw_auditoria_productos AS
SELECT auditoria_id, tipo_operacion, registro_id AS producto_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'productos';
PROMPT Vista vw_auditoria_productos creada.

-- Vista: Auditoría de pedidos
CREATE OR REPLACE VIEW vw_auditoria_pedidos AS
SELECT auditoria_id, tipo_operacion, registro_id AS pedido_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'pedidos';
PROMPT Vista vw_auditoria_pedidos creada.

-- Vista: Auditoría de detalles_pedido
CREATE OR REPLACE VIEW vw_auditoria_detalles_pedido AS
SELECT auditoria_id, tipo_operacion, registro_id AS detalle_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'detalles_pedido';
PROMPT Vista vw_auditoria_detalles_pedido creada.

-- Vista: Auditoría de pagos
CREATE OR REPLACE VIEW vw_auditoria_pagos AS
SELECT auditoria_id, tipo_operacion, registro_id AS pago_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'pagos';
PROMPT Vista vw_auditoria_pagos creada.

-- Vista: Auditoría de categorías
CREATE OR REPLACE VIEW vw_auditoria_categorias AS
SELECT auditoria_id, tipo_operacion, registro_id AS categoria_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'categorias';
PROMPT Vista vw_auditoria_categorias creada.

-- Vista: Auditoría de producto_categorias
CREATE OR REPLACE VIEW vw_auditoria_producto_categorias AS
SELECT auditoria_id, tipo_operacion, registro_id AS producto_categoria_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'producto_categorias';
PROMPT Vista vw_auditoria_producto_categorias creada.

-- Vista: Auditoría de direcciones
CREATE OR REPLACE VIEW vw_auditoria_direcciones AS
SELECT auditoria_id, tipo_operacion, registro_id AS direccion_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'direcciones';
PROMPT Vista vw_auditoria_direcciones creada.

-- Vista: Auditoría de usuario_roles
CREATE OR REPLACE VIEW vw_auditoria_usuario_roles AS
SELECT auditoria_id, tipo_operacion, registro_id AS usuario_rol_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'usuario_roles';
PROMPT Vista vw_auditoria_usuario_roles creada.

-- Vista: Auditoría de roles
CREATE OR REPLACE VIEW vw_auditoria_roles AS
SELECT auditoria_id, tipo_operacion, registro_id AS rol_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'roles';
PROMPT Vista vw_auditoria_roles creada.

PROMPT >>> Todas las vistas de auditoría han sido creadas.


PROMPT >>> Optimización y Vistas completadas correctamente. ✅
