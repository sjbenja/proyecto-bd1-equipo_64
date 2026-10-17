# Especificación Técnica: Consulta de Negocio Avanzada — Clientes VIP (CU-03)

## 1. Propósito y Contexto Operativo
La **Consulta de Negocio Avanzada** (CU-03) responde a un requerimiento de inteligencia comercial y marketing estratégico para **SkyTech Store**. Su propósito es identificar y segmentar a los clientes de mayor valor (Clientes VIP), evaluando tanto la recurrencia de compra como el volumen total acumulado de facturación.

---

## 2. Requerimientos de Información y Filtrado Agregado (`HAVING`)
* **Métricas de Segmentación Comercial:**
  - Identificador único del usuario (`usuario_id`).
  - Nombre completo y correo electrónico corporativo/personal del cliente (`Cliente`, `Email`).
  - Cantidad total de órdenes de compra completadas exitosamente (`Total_Ordenes`).
  - Total de artículos físicos adquiridos históricamente (`Total_Productos_Comprados`).
  - Facturación total acumulada acumulada por el cliente en la plataforma (`Monto_Total_Invertido`).
* **Criterios de Filtrado Estratégico (Cláusula `HAVING` / Subconsultas):**
  - **Frecuencia Mínima:** El usuario debe registrar **más de 1 orden completada** (`COUNT(DISTINCT p.pedido_id) > 1`).
  - **Monto Mínimo Acumulado:** La inversión total del usuario debe ser estrictamente **superior a $200.000,00** (`SUM(p.monto_total) > 200000.00`).

---

## 3. Código T-SQL de la Consulta (`sql/consultas/consultas_etapa4.sql` - Parte 3)

```sql
-- =============================================================================
-- CU-03: CONSULTA AVANZADA DE NEGOCIO — CLIENTES VIP Y FRECUENCIA DE COMPRA
-- Requiere JOIN múltiple (3+ tablas), GROUP BY, HAVING y filtros condicionales
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
```
## 4. Análisis de Complejidad Téchnica y Agrupamiento
1. Combinación Múltiple (3 Tablas): La consulta entrelaza la entidad dimensional USUARIOS con la tabla transaccional de cabecera PEDIDOS y el desglose en DETALLE_PEDIDO, permitiendo cruzar atributos de cliente con métricas de comportamiento financiero.

2. Filtrado Post-Agregación (HAVING): A diferencia de la cláusula WHERE (que filtra filas individuales antes del agrupamiento), la cláusula HAVING evalúa los resultados de las funciones de agregación (COUNT y SUM), descartando aquellos clientes que no alcancen los umbrales de negocio definidos.

3. Escalabilidad y Performance: Todas las columnas del GROUP BY forman parte de la Clave Primaria o de índices candidatos de USUARIOS, optimizando el consumo de memoria en el plan de ejecución de SQL Server.