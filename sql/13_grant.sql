PROMPT >>> Asignando permisos a roles sobre tablas y vistas...

-- Permisos para ROL_ADMINISTRADOR (Acceso completo a todas las tablas del esquema)
GRANT ALL ON tiendas TO rol_administrador;
GRANT ALL ON roles TO rol_administrador;
GRANT ALL ON usuarios TO rol_administrador;
GRANT ALL ON productos TO rol_administrador;
GRANT ALL ON usuario_roles TO rol_administrador;
GRANT ALL ON categorias TO rol_administrador;
GRANT ALL ON producto_categorias TO rol_administrador;
GRANT ALL ON direcciones TO rol_administrador;
GRANT ALL ON pedidos TO rol_administrador;
GRANT ALL ON detalles_pedido TO rol_administrador;
GRANT ALL ON pagos TO rol_administrador;
GRANT ALL ON tabla_auditoria TO rol_administrador;
GRANT ALL ON Dim_Tiempo TO rol_administrador;
GRANT ALL ON Dim_Producto TO rol_administrador;
GRANT ALL ON Dim_Usuario TO rol_administrador;
GRANT ALL ON Dim_Tienda TO rol_administrador;
GRANT ALL ON Hecho_Ventas TO rol_administrador;

-- Permisos sobre las VISTAS DE RLS para ROL_ADMINISTRADOR
GRANT SELECT, INSERT, UPDATE, DELETE ON v_tiendas TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_usuarios TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_productos TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_pedidos TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_detalles_pedido TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_pagos TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_categorias TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_producto_categorias TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_direcciones TO rol_administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_usuario_roles TO rol_administrador;


-- Permisos para ROL_ADMINISTRADOR_TIENDA (Acceso a sus propias tiendas y datos relacionados)
GRANT SELECT, INSERT, UPDATE, DELETE ON tiendas TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON usuarios TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON productos TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON pedidos TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON detalles_pedido TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON pagos TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON categorias TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON producto_categorias TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON direcciones TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON usuario_roles TO rol_administrador_tienda;

-- Permisos sobre las VISTAS DE RLS para ROL_ADMINISTRADOR_TIENDA
GRANT SELECT, INSERT, UPDATE, DELETE ON v_tiendas TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_usuarios TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_productos TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_pedidos TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_detalles_pedido TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_pagos TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_categorias TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_producto_categorias TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_direcciones TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_usuario_roles TO rol_administrador_tienda;

-- Permisos sobre VISTAS DE AUDITORÍA (vw_) y VISTAS DE DW (Dim_, Hecho_) para ROL_ADMINISTRADOR_TIENDA
-- ¡NOMBRES DE VISTAS CORREGIDOS PARA COINCIDIR CON 08_OPTIMIZAR_VISTAS.SQL!
GRANT SELECT ON vw_auditoria_tiendas TO rol_administrador_tienda;
GRANT SELECT ON vw_auditoria_usuarios TO rol_administrador_tienda;
GRANT SELECT ON vw_auditoria_productos TO rol_administrador_tienda;
GRANT SELECT ON vw_auditoria_pedidos TO rol_administrador_tienda;
GRANT SELECT ON vw_auditoria_detalles_pedido TO rol_administrador_tienda;
GRANT SELECT ON vw_auditoria_pagos TO rol_administrador_tienda;
GRANT SELECT ON vw_auditoria_categorias TO rol_administrador_tienda;
GRANT SELECT ON vw_auditoria_producto_categorias TO rol_administrador_tienda;
GRANT SELECT ON vw_auditoria_direcciones TO rol_administrador_tienda;
GRANT SELECT ON vw_auditoria_usuario_roles TO rol_administrador_tienda;
GRANT SELECT ON vw_auditoria_roles TO rol_administrador_tienda;

GRANT SELECT, INSERT, UPDATE, DELETE ON Dim_Tiempo TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON Dim_Producto TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON Dim_Usuario TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON Dim_Tienda TO rol_administrador_tienda;
GRANT SELECT, INSERT, UPDATE, DELETE ON Hecho_Ventas TO rol_administrador_tienda;


-- Permisos para ROL_VENDEDOR
GRANT SELECT, INSERT, UPDATE ON v_pedidos TO rol_vendedor;
GRANT SELECT, INSERT ON v_detalles_pedido TO rol_vendedor;
GRANT SELECT, INSERT ON v_productos TO rol_vendedor;
GRANT SELECT ON v_usuarios TO rol_vendedor;


-- Permisos para ROL_BODEGUERO
GRANT SELECT ON v_pedidos TO rol_bodeguero;
GRANT SELECT ON v_productos TO rol_bodeguero;
GRANT UPDATE (stock, sku) ON v_productos TO rol_bodeguero;


-- Permisos para ROL_ANALISTA
GRANT SELECT ON Dim_Tiempo TO rol_analista;
GRANT SELECT ON Dim_Producto TO rol_analista;
GRANT SELECT ON Dim_Usuario TO rol_analista;
GRANT SELECT ON Dim_Tienda TO rol_analista;
GRANT SELECT ON Hecho_Ventas TO rol_analista;
GRANT SELECT ON tabla_auditoria TO rol_analista; -- Acceso directo a la tabla de auditoría, ya que no hay una vista RLS para ella.


-- Permisos para ROL_SOPORTE
GRANT SELECT ON v_usuarios TO rol_soporte;
GRANT SELECT ON v_pedidos TO rol_soporte;
GRANT SELECT ON v_pagos TO rol_soporte;
GRANT SELECT ON v_direcciones TO rol_soporte;
GRANT SELECT ON v_usuario_roles TO rol_soporte;

PROMPT >>> Permisos asignados exitosamente. ✅
