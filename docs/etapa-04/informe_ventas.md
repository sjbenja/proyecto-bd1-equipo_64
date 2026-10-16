# Especificación Técnica: Informe Agregado de Ventas por Categoría (CU-02)

## 1. Propósito y Contexto Operativo
El **Informe Agregado de Ventas** (CU-02) es una consulta analítica de carácter gerencial. Permite evaluar el desempeño comercial del e-commerce **SkyTech Store** mediante la consolidación periódica de las ventas agrupadas por categoría de productos (Procesadores, Placas de Video, Almacenamiento, etc.) dentro de un rango de fechas parametrizable.

---

## 2. Requerimientos de Información y Métricas Agregadas
* **Dimensiones de Agrupamiento:**
  - Identificador de la Categoría (`categoria_id`).
  - Nombre de la Categoría (`nombre_categoria`).
* **Métricas Financieras y Operativas:**
  - **Cantidad de Órdenes Únicas:** Conteo de pedidos distintos procesados en la categoría (`COUNT(DISTINCT p.pedido_id)`).
  - **Unidades Físicas Vendidas:** Suma total de productos comercializados (`SUM(dp.cantidad)`).
  - **Facturación Total Acumulada:** Suma del valor monetario congelado por renglón (`SUM(dp.cantidad * dp.precio_unitario_congelado)`).
  - **Ticket Promedio por Renglón:** Promedio de venta por línea comercializada (`AVG(dp.cantidad * dp.precio_unitario_congelado)`).
* **Filtros de Parámetro Temporal:**
  - Rango de fechas de inicio (`@fecha_inicio`) y fin (`@fecha_fin`) aplicado sobre `PEDIDOS.fecha_pedido`.

---

## 3. Código T-SQL de la Consulta (`sql/consultas/consultas_etapa4.sql` - Parte 2)

```sql
-- =============================================================================
-- CU-02: INFORME AGREGADO DE VENTAS POR CATEGORÍA EN RANGO DE FECHAS
-- Parámetros de prueba: Rango amplio para cubrir registros DML
-- =============================================================================

USE skytech_store;
GO

DECLARE @fecha_inicio DATETIME2 = '2026-01-01 00:00:00';
DECLARE @fecha_fin DATETIME2 = '2026-12-31 23:59:59';

SELECT 
    c.categoria_id AS [ID_Categoria],
    c.nombre_categoria AS [Categoria],
    COUNT(DISTINCT p.pedido_id) AS [Total_Pedidos_Procesados],
    SUM(dp.cantidad) AS [Unidades_Vendidas],
    CAST(SUM(dp.cantidad * dp.precio_unitario_congelado) AS DECIMAL(10,2)) AS [Facturacion_Total],
    CAST(AVG(dp.cantidad * dp.precio_unitario_congelado) AS DECIMAL(10,2)) AS [Promedio_Por_Renglón]
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
```
## 4. Análisis de Agregación y Optimización
1. Agregación Precisa: El uso de COUNT(DISTINCT p.pedido_id) evita contar múltiples veces una misma orden cuando contiene varios productos pertenecientes a la misma categoría, garantizando métricas operativas exactas.

2. Filtrado por Estado Transaccional: Se aplica la condición p.estado_pedido = 'Completado' para asegurar que solo los pedidos cerrados y abonados impacten en los balances comerciales de la empresa.

3. Conversión de Tipos (CAST): Se redondea la salida monetaria a DECIMAL(10,2) para mantener coherencia en la presentación de datos analíticos en SQL Server.