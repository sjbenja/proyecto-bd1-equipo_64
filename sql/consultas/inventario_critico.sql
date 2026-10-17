-- =============================================================================
-- ESQUEMA: SkyTech Store - Etapa IV
-- CASO DE USO: CU-04 Control de Stock Crítico y Productos sin Venta
-- ARCHIVO: sql/consultas/inventario_critico.sql
-- AUTOR: Equipo SkyTech Store
-- SGBD: Microsoft SQL Server (T-SQL)
-- =============================================================================

USE skytech_store;
GO

DECLARE @umbral_critico INT = 5;

SELECT 
    p.sku AS [SKU],
    p.nombre AS [Producto],
    c.nombre_categoria AS [Categoria],
    p.precio_actual AS [Precio_Actual],
    p.stock AS [Stock_Disponible],
    ISNULL(SUM(dp.cantidad), 0) AS [Total_Unidades_Vendidas],
    CASE 
        WHEN p.stock = 0 THEN 'AGOTADO - REPOSICIÓN URGENTE'
        WHEN p.stock <= @umbral_critico THEN 'STOCK CRÍTICO'
        WHEN p.stock BETWEEN (@umbral_critico + 1) AND 10 THEN 'STOCK BAJO'
        ELSE 'STOCK NORMAL'
    END AS [Estado_Inventario],
    CASE 
        WHEN SUM(dp.cantidad) IS NULL THEN 'SIN VENTAS (INMOVILIZADO)'
        ELSE 'CON ROTACIÓN'
    END AS [Estado_Rotacion]
FROM PRODUCTOS p
INNER JOIN CATEGORIAS c 
    ON p.categoria_id = c.categoria_id
LEFT JOIN DETALLE_PEDIDO dp 
    ON p.producto_id = dp.producto_id
GROUP BY 
    p.sku,
    p.nombre,
    c.nombre_categoria,
    p.precio_actual,
    p.stock
HAVING 
    p.stock <= @umbral_critico 
    OR SUM(dp.cantidad) IS NULL
ORDER BY 
    p.stock ASC, 
    Total_Unidades_Vendidas ASC;
GO