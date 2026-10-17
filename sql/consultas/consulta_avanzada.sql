-- =============================================================================
-- ESQUEMA: SkyTech Store - Etapa IV
-- CASO DE USO: CU-03 Consulta Avanzada de Negocio - Clientes VIP
-- ARCHIVO: sql/consultas/consulta_avanzada.sql
-- AUTOR: Equipo SkyTech Store
-- SGBD: Microsoft SQL Server (T-SQL)
-- =============================================================================

USE skytech_store;
GO

-- Parámetros de umbral para segmentación
DECLARE @monto_minimo_acumulado DECIMAL(10,2) = 200000.00;
DECLARE @ordenes_minimas INT = 1;

SELECT 
    u.usuario_id AS [ID_Cliente],
    CONCAT(u.nombre, ' ', u.apellido) AS [Cliente],
    u.email AS [Email],
    u.fecha_registro AS [Fecha_Alta],
    COUNT(DISTINCT p.pedido_id) AS [Total_Ordenes],
    SUM(dp.cantidad) AS [Total_Productos_Comprados],
    CAST(SUM(dp.cantidad * dp.precio_unitario_congelado) AS DECIMAL(10,2)) AS [Monto_Total_Invertido]
FROM USUARIOS u
INNER JOIN PEDIDOS p 
    ON u.usuario_id = p.usuario_id
INNER JOIN DETALLE_PEDIDO dp 
    ON p.pedido_id = dp.pedido_id
WHERE p.estado_pedido = 'Completado'
GROUP BY 
    u.usuario_id,
    u.nombre,
    u.apellido,
    u.email,
    u.fecha_registro
HAVING 
    COUNT(DISTINCT p.pedido_id) >= @ordenes_minimas
    AND SUM(dp.cantidad * dp.precio_unitario_congelado) > @monto_minimo_acumulado
ORDER BY 
    Monto_Total_Invertido DESC;
GO