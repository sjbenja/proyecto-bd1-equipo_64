-- =============================================================================
-- ESQUEMA: SkyTech Store - Etapa IV
-- CASO DE USO: CU-01 Comprobante / Factura de Venta Consolidada
-- ARCHIVO: sql/consultas/comprobante_venta.sql
-- AUTOR: Equipo SkyTech Store
-- SGBD: Microsoft SQL Server (T-SQL)
-- =============================================================================

USE skytech_store;
GO

-- Parámetro de búsqueda para el comprobante
DECLARE @pedido_buscado INT = 1;

SELECT 
    p.pedido_id AS [Nro_Factura],
    p.fecha_pedido AS [Fecha_Emision],
    CONCAT(u.nombre, ' ', u.apellido) AS [Cliente],
    u.email AS [Email_Cliente],
    mp.nombre_metodo AS [Medio_Pago],
    p.estado_pedido AS [Estado_Pedido],
    pr.sku AS [SKU_Producto],
    pr.nombre AS [Producto],
    dp.cantidad AS [Cantidad],
    dp.precio_unitario_congelado AS [Precio_Unitario],
    (dp.cantidad * dp.precio_unitario_congelado) AS [Subtotal_Renglon],
    p.monto_total AS [Total_Factura_Cabecera]
FROM PEDIDOS p
INNER JOIN USUARIOS u 
    ON p.usuario_id = u.usuario_id
INNER JOIN METODOS_PAGO mp 
    ON p.metodo_pago_id = mp.metodo_id
INNER JOIN DETALLE_PEDIDO dp 
    ON p.pedido_id = dp.pedido_id
INNER JOIN PRODUCTOS pr 
    ON dp.producto_id = pr.producto_id
WHERE p.pedido_id = @pedido_buscado
ORDER BY pr.nombre ASC;
GO