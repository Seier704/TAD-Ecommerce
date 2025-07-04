--Consulta con respecto a 10 usuarios con mayor venta, filtrado por tienda.

-- Top 10 usuarios con mayor venta para una tienda específica
SELECT *
FROM (
    SELECT 
        u.usuario_id,
        u.nombre,
        u.apellido,
        u.email,
        SUM(dp.cantidad * dp.precio_unitario) AS total_vendido
    FROM pedidos p
    JOIN usuarios u ON p.usuario_id = u.usuario_id
    JOIN detalles_pedido dp 
        ON dp.pedido_id = p.pedido_id 
       AND dp.fecha_pedido_fk = p.fecha_pedido
    WHERE u.tienda_id = :tienda_id  -- ← Aquí puedes reemplazar por un valor fijo o usar una variable de aplicación
      AND p.fecha_pedido >= TRUNC(ADD_MONTHS(SYSDATE, -1))
    GROUP BY u.usuario_id, u.nombre, u.apellido, u.email
    ORDER BY total_vendido DESC
)
WHERE ROWNUM <= 10;


-- Productos más vendidos por región para una tienda específica (último mes)
SELECT 
    p.nombre AS producto,
    d.region,
    SUM(dp.cantidad) AS total_vendido
FROM pedidos pe
JOIN usuarios u ON pe.usuario_id = u.usuario_id
JOIN direcciones d ON u.usuario_id = d.usuario_id
JOIN detalles_pedido dp 
    ON dp.pedido_id = pe.pedido_id 
   AND dp.fecha_pedido_fk = pe.fecha_pedido
JOIN productos p ON p.producto_id = dp.producto_id
WHERE u.tienda_id = :tienda_id  -- Reemplaza :tienda_id por el ID real de la tienda (por ejemplo, 3)
  AND pe.fecha_pedido >= TRUNC(ADD_MONTHS(SYSDATE, -1))
GROUP BY p.nombre, d.region
ORDER BY total_vendido DESC;
