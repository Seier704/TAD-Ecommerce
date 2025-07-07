/*Triggers de Validacion funcional*/

-- 1. creacion de trigger para validar stock, en caso de que un pedido se pase del stock que tengamos le dira directamente "Stock insuficiente"
CREATE OR REPLACE TRIGGER trg_validar_stock
BEFORE INSERT ON detalles_pedido
FOR EACH ROW
DECLARE
    v_stock productos.stock%TYPE;
BEGIN
    SELECT stock INTO v_stock
    FROM productos
    WHERE producto_id = :NEW.producto_id;

    IF :NEW.cantidad > v_stock THEN
        RAISE_APPLICATION_ERROR(-20001, 'Stock insuficiente');
    END IF;
END;
/

-- 2. este Trigger valida que las fechas de los pedidos funcionen correctamente y no posean fechas futuras al presente, este se activa cuando se inserta un pedido en la tabla pedidos
CREATE OR REPLACE TRIGGER trg_validar_fecha_pedido
BEFORE INSERT OR UPDATE ON pedidos
FOR EACH ROW
BEGIN
    IF :NEW.fecha_pedido > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'La fecha del pedido no puede ser futura');
    END IF;
END;
/

-- 3. Trigger para advertir sobre la falta de fondos, algo basico para hacerle saber al cliente que no se haga el weon y pague el precio correspondiente, se activa antes de registrar un pago
CREATE OR REPLACE TRIGGER trg_validar_monto_pago
BEFORE INSERT ON pagos
FOR EACH ROW
DECLARE
    v_total_pedido pedidos.total%TYPE;
BEGIN
    SELECT total INTO v_total_pedido
    FROM pedidos
    WHERE pedido_id = :NEW.pedido_id AND fecha_pedido = :NEW.fecha_pedido_fk; -- Usar PK compuesta
    
    -- Se asume que el monto del pago debe ser exacto o al menos no menor
    IF :NEW.monto < v_total_pedido THEN
        RAISE_APPLICATION_ERROR(-20003, 'El monto del pago no puede ser menor al total del pedido');
    END IF;
END;
/

-- 4. Validar que el estado del pedido sea uno permitido, en caso de que no lo sea, el trigger se dispara y lanza un error
CREATE OR REPLACE TRIGGER trg_validar_estado_pedido
BEFORE INSERT OR UPDATE ON pedidos
FOR EACH ROW
BEGIN
    -- Corregido: Usar :NEW.estado_pedido y alinear con los valores de la restricción CHECK de la tabla
    IF LOWER(:NEW.estado_pedido) NOT IN ('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Estado de pedido no válido. Valores permitidos: pendiente, procesando, enviado, entregado, cancelado.');
    END IF;
END;
/


-- 5. (peticion de gerencia) Disminuir stock al registrar una venta
CREATE OR REPLACE TRIGGER trg_disminuir_stock_venta
AFTER INSERT ON detalles_pedido
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - :NEW.cantidad
    WHERE producto_id = :NEW.producto_id;
END;
/

-- 6. Asegurarse que el trigger anterior no deje el stock negativo después de la venta
CREATE OR REPLACE TRIGGER trg_no_negativo
AFTER UPDATE OF stock ON productos
FOR EACH ROW
WHEN (NEW.stock < 0)
BEGIN
    RAISE_APPLICATION_ERROR(-20010, 'Error: Stock no puede quedar en negativo.');
END;
/

-- TRIGGERS DATA WAREHOUSE (ADAPTADOS Y CORREGIDOS)

CREATE OR REPLACE FUNCTION extraer_dim_tiempo(p_fecha DATE) RETURN NUMBER IS
    v_fecha_id NUMBER;
BEGIN
    SELECT fecha_id INTO v_fecha_id
    FROM Dim_Tiempo
    WHERE fecha = TRUNC(p_fecha); -- Usar TRUNC para comparar solo la fecha
    RETURN v_fecha_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        v_fecha_id := TO_NUMBER(TO_CHAR(p_fecha, 'YYYYMMDD'));
        
        -- Corregido: 'año' a 'anio', y se añade 'es_fin_semana'
        INSERT INTO Dim_Tiempo (
            fecha_id, fecha, dia, mes, anio, trimestre, nombre_mes, dia_semana, es_fin_semana
        ) VALUES (
            v_fecha_id,
            TRUNC(p_fecha), -- Insertar solo la fecha sin hora
            EXTRACT(DAY FROM p_fecha),
            EXTRACT(MONTH FROM p_fecha),
            EXTRACT(YEAR FROM p_fecha),
            CEIL(EXTRACT(MONTH FROM p_fecha) / 3),
            TO_CHAR(p_fecha, 'Month', 'NLS_DATE_LANGUAGE=SPANISH'),
            TO_CHAR(p_fecha, 'Day', 'NLS_DATE_LANGUAGE=SPANISH'),
            CASE WHEN TO_CHAR(p_fecha, 'DY', 'NLS_DATE_LANGUAGE=SPANISH') IN ('SÁB', 'DOM') THEN 'Y' ELSE 'N' END -- Lógica para fin de semana
        );
        RETURN v_fecha_id;
END;
/

CREATE OR REPLACE TRIGGER trg_dim_producto
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    -- Corregido: Nombres de columnas de Dim_Producto alineados con 02_crear_tablas.sql
    -- 'sku' se mantiene ya que la tabla PRODUCTOS sí lo tiene.
    INSERT INTO Dim_Producto (
        producto_id, nombre_producto, descripcion_producto, precio_unitario_actual, sku
    ) VALUES (
        :NEW.producto_id, :NEW.nombre, :NEW.descripcion, :NEW.precio, :NEW.sku
    );
END;
/

CREATE OR REPLACE TRIGGER trg_dim_usuario
AFTER INSERT ON usuarios
FOR EACH ROW
DECLARE
    v_nombre_completo VARCHAR2(100);
BEGIN
    -- Concatenar nombre y apellido para nombre_completo_usuario
    v_nombre_completo := :NEW.nombre || ' ' || :NEW.apellido;

    -- Corregido: Nombres de columnas de Dim_Usuario alineados con 02_crear_tablas.sql
    -- 'tienda_id' se eliminó ya que Dim_Usuario no la tiene en 02_crear_tablas.sql
    INSERT INTO Dim_Usuario (
        usuario_id, email_usuario, nombre_completo_usuario
    ) VALUES (
        :NEW.usuario_id, :NEW.email, v_nombre_completo
    );
END;
/

CREATE OR REPLACE TRIGGER trg_dim_tienda
AFTER INSERT ON tiendas
FOR EACH ROW
BEGIN
    -- Corregido: Nombres de columnas de Dim_Tienda alineados con 02_crear_tablas.sql
    -- 'fecha_creacion' se eliminó ya que Dim_Tienda no la tiene en 02_crear_tablas.sql
    INSERT INTO Dim_Tienda (
        tienda_id, nombre_tienda, url_dominio_tienda
    ) VALUES (
        :NEW.tienda_id, :NEW.nombre, :NEW.url_dominio
    );
END;
/

CREATE OR REPLACE TRIGGER trg_hecho_ventas
AFTER INSERT ON detalles_pedido -- El trigger debe activarse en detalles_pedido
FOR EACH ROW
DECLARE
    v_fecha_id          NUMBER;
    v_producto_dim_id   NUMBER;
    v_usuario_dim_id    NUMBER;
    v_tienda_dim_id     NUMBER;
    v_usuario_id_oltp   NUMBER;
    v_tienda_id_oltp    NUMBER;
    v_fecha_pedido_oltp DATE;
    
    -- Variables para datos de OLTP si necesitamos insertarlos en la dimensión
    v_producto_nombre     productos.nombre%TYPE;
    v_producto_descripcion productos.descripcion%TYPE;
    v_producto_precio     productos.precio%TYPE;
    v_producto_sku        productos.sku%TYPE;

    v_usuario_email       usuarios.email%TYPE;
    v_usuario_nombre      usuarios.nombre%TYPE;
    v_usuario_apellido    usuarios.apellido%TYPE;

    v_tienda_nombre       tiendas.nombre%TYPE;
    v_tienda_url_dominio  tiendas.url_dominio%TYPE;

BEGIN
    -- Obtener IDs de las tablas OLTP (usuario_id, tienda_id, fecha_pedido)
    SELECT p.usuario_id, p.tienda_id, p.fecha_pedido
    INTO v_usuario_id_oltp, v_tienda_id_oltp, v_fecha_pedido_oltp
    FROM pedidos p
    WHERE p.pedido_id = :NEW.pedido_id AND p.fecha_pedido = :NEW.fecha_pedido_fk;

    -- Insertar en dimensión de tiempo si no existe y obtener fecha_id
    v_fecha_id := extraer_dim_tiempo(v_fecha_pedido_oltp);

    -- Obtener producto_dim_id (o insertarlo si no existe)
    BEGIN
        SELECT producto_dim_id INTO v_producto_dim_id
        FROM Dim_Producto
        WHERE producto_id = :NEW.producto_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Si el producto no está en la dimensión, obtener sus datos OLTP e insertarlo
            SELECT nombre, descripcion, precio, sku
            INTO v_producto_nombre, v_producto_descripcion, v_producto_precio, v_producto_sku
            FROM productos
            WHERE producto_id = :NEW.producto_id;

            INSERT INTO Dim_Producto (producto_id, nombre_producto, descripcion_producto, precio_unitario_actual, sku)
            VALUES (:NEW.producto_id, v_producto_nombre, v_producto_descripcion, v_producto_precio, v_producto_sku)
            RETURNING producto_dim_id INTO v_producto_dim_id;
            -- ELIMINADO: COMMIT; -- No se permite COMMIT en un trigger
            DBMS_OUTPUT.PUT_LINE('INFO: Producto ID ' || :NEW.producto_id || ' insertado en Dim_Producto.');
    END;

    -- Obtener usuario_dim_id (o insertarlo si no existe)
    BEGIN
        SELECT usuario_dim_id INTO v_usuario_dim_id
        FROM Dim_Usuario
        WHERE usuario_id = v_usuario_id_oltp;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Si el usuario no está en la dimensión, obtener sus datos OLTP e insertarlo
            SELECT email, nombre, apellido
            INTO v_usuario_email, v_usuario_nombre, v_usuario_apellido
            FROM usuarios
            WHERE usuario_id = v_usuario_id_oltp;

            INSERT INTO Dim_Usuario (usuario_id, email_usuario, nombre_completo_usuario)
            VALUES (v_usuario_id_oltp, v_usuario_email, v_usuario_nombre || ' ' || v_usuario_apellido)
            RETURNING usuario_dim_id INTO v_usuario_dim_id;
            -- ELIMINADO: COMMIT; -- No se permite COMMIT en un trigger
            DBMS_OUTPUT.PUT_LINE('INFO: Usuario ID ' || v_usuario_id_oltp || ' insertado en Dim_Usuario.');
    END;

    -- Obtener tienda_dim_id (o insertarla si no existe)
    BEGIN
        SELECT tienda_dim_id INTO v_tienda_dim_id
        FROM Dim_Tienda
        WHERE tienda_id = v_tienda_id_oltp;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Si la tienda no está en la dimensión, obtener sus datos OLTP e insertarla
            SELECT nombre, url_dominio
            INTO v_tienda_nombre, v_tienda_url_dominio
            FROM tiendas
            WHERE tienda_id = v_tienda_id_oltp;

            INSERT INTO Dim_Tienda (tienda_id, nombre_tienda, url_dominio_tienda)
            VALUES (v_tienda_id_oltp, v_tienda_nombre, v_tienda_url_dominio)
            RETURNING tienda_dim_id INTO v_tienda_dim_id;
            -- ELIMINADO: COMMIT; -- No se permite COMMIT en un trigger
            DBMS_OUTPUT.PUT_LINE('INFO: Tienda ID ' || v_tienda_id_oltp || ' insertada en Dim_Tienda.');
    END;

    -- Insertar en la tabla de hechos
    INSERT INTO Hecho_Ventas (
        fecha_id, producto_dim_id, usuario_dim_id, tienda_dim_id,
        cantidad_vendida, monto_venta
    ) VALUES (
        v_fecha_id,
        v_producto_dim_id,
        v_usuario_dim_id,
        v_tienda_dim_id,
        :NEW.cantidad,
        :NEW.cantidad * :NEW.precio_unitario
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en trg_hecho_ventas para pedido_id ' || :NEW.pedido_id || ' y producto_id ' || :NEW.producto_id || ': ' || SQLERRM);
END;
/
