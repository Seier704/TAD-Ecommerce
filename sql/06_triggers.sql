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
    WHERE pedido_id = :NEW.pedido_id;

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
    IF LOWER(:NEW.estado) NOT IN ('pendiente', 'enviado', 'cancelado', 'completado') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Estado de pedido no válido. Valores permitidos: pendiente, enviado, cancelado, completado.');
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

--TRIGGERS DATA WAREHOUSE BY FERNANDO

CREATE OR REPLACE FUNCTION extraer_dim_tiempo(p_fecha DATE) RETURN NUMBER IS
    v_fecha_id NUMBER;
BEGIN
    SELECT fecha_id INTO v_fecha_id
    FROM Dim_Tiempo
    WHERE fecha = p_fecha;

    RETURN v_fecha_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        v_fecha_id := TO_NUMBER(TO_CHAR(p_fecha, 'YYYYMMDD'));

        INSERT INTO Dim_Tiempo (
            fecha_id, fecha, dia, mes, año, trimestre, nombre_mes, dia_semana
        ) VALUES (
            v_fecha_id,
            p_fecha,
            EXTRACT(DAY FROM p_fecha),
            EXTRACT(MONTH FROM p_fecha),
            EXTRACT(YEAR FROM p_fecha),
            CEIL(EXTRACT(MONTH FROM p_fecha) / 3),
            TO_CHAR(p_fecha, 'Month', 'NLS_DATE_LANGUAGE=SPANISH'),
            TO_CHAR(p_fecha, 'Day', 'NLS_DATE_LANGUAGE=SPANISH')
        );

        RETURN v_fecha_id;
END;
/

CREATE OR REPLACE TRIGGER trg_dim_producto
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    INSERT INTO Dim_Producto (
        producto_id, nombre, descripcion, precio, sku
    ) VALUES (
        :NEW.producto_id, :NEW.nombre, :NEW.descripcion, :NEW.precio, :NEW.sku
    );
END;
/

CREATE OR REPLACE TRIGGER trg_dim_usuario
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO Dim_Usuario (
        usuario_id, nombre, apellido, email, tienda_id
    ) VALUES (
        :NEW.usuario_id, :NEW.nombre, :NEW.apellido, :NEW.email, :NEW.tienda_id
    );
END;
/

CREATE OR REPLACE TRIGGER trg_dim_tienda
AFTER INSERT ON tiendas
FOR EACH ROW
BEGIN
    INSERT INTO Dim_Tienda (
        tienda_id, nombre, url_dominio, fecha_creacion
    ) VALUES (
        :NEW.tienda_id, :NEW.nombre, :NEW.url_dominio, :NEW.fecha_creacion
    );
END;
/


CREATE OR REPLACE TRIGGER trg_hecho_ventas
AFTER INSERT ON ventas
FOR EACH ROW
DECLARE
    v_fecha_id NUMBER;
BEGIN
    -- Insertar en dimensión de tiempo si no existe
    v_fecha_id := extraer_dim_tiempo(:NEW.fecha_venta);

    -- Insertar en la tabla de hechos
    INSERT INTO Hecho_Ventas (
        fecha_id, producto_id, usuario_id, tienda_id,
        cantidad, precio_unitario, total_venta
    ) VALUES (
        v_fecha_id,
        :NEW.producto_id,
        :NEW.usuario_id,
        :NEW.tienda_id,
        :NEW.cantidad,
        :NEW.precio_unitario,
        :NEW.cantidad * :NEW.precio_unitario
    );
END;
/

