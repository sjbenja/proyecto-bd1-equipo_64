-- =============================================================================
-- ESQUEMA: SkyTech Store - Etapa IV
-- CASO DE USO: CU-02 Informe Agregado de Ventas por Categoría
-- ARCHIVO: sql/consultas/informe_ventas.sql
-- AUTOR: Equipo SkyTech Store
-- SGBD: Microsoft SQL Server (T-SQL)
-- =============================================================================

USE skytech_store;
GO

-- Parámetros del rango de fechas para el informe analítico
DECLARE @fecha_inicio DATETIME2 = '2026-01-01 00:00:00';
DECLARE @fecha_fin DATETIME2 = '2026-12-31 23:59:59';

SELECT 
    c.categoria_id AS [ID_Categoria],
    c.nombre_categoria AS [Categoria],
    COUNT(DISTINCT p.pedido_id) AS [Total_Pedidos_Procesados],
    SUM(dp.cantidad) AS [Unidades_Vendidas],
    CAST(SUM(dp.cantidad * dp.precio_unitario_congelado) AS DECIMAL(10,2)) AS [Facturacion_Total],
    CAST(AVG(dp.cantidad * dp.precio_unitario_congelado) AS DECIMAL(10,2)) AS [Promedio_Por_Renglon]
FROM CATEGORIAS c
INNER JOIN PRODUCTOS pr 
    ON c.categoria_id = pr.categoria_id
INNER JOIN DETALLE_PEDIDO dp 
    ON pr.producto_id = dp.producto_id
INNER JOIN PEDIDOS p 
    ON dp.pedido_id = p.pedido_id
WHERE p.fecha_pedido BETWEEN @fecha_inicio AND @fecha_fin
  AND p.estado_pedido = 'Completado'
GROUP BY 
    c.categoria_id, 
    c.nombre_categoria
ORDER BY 
    Facturacion_Total DESC;
GO