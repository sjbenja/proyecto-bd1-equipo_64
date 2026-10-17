# Especificación Técnica: Consulta de Comprobante / Factura de Venta (CU-01)

## 1. Propósito y Contexto Operativo
La consulta de **Comprobante de Venta** (CU-01) es la consulta transaccional central del sistema **SkyTech Store**. Permite reconstruir la factura o comprobante digital de cualquier orden procesada, unificando en una única salida los datos del comprador, los detalles del método de pago, la fecha exacta de emisión y el desglose de cada ítem con su precio inmutable.

---

## 2. Requerimientos de Información y Cálculo
* **Cabecera del Comprobante:**
  - Número de Pedido (`pedido_id`).
  - Nombre completo y correo electrónico del cliente (`nombre`, `apellido`, `email`).
  - Fecha y hora exacta de la compra (`fecha_pedido` en formato `DATETIME2`).
  - Método de pago utilizado (`nombre_metodo`).
  - Estado actual del pedido (`estado_pedido`).
* **Cuerpo / Detalle de la Venta:**
  - Código identificador del producto (`sku`).
  - Nombre descriptivo del producto (`nombre`).
  - Cantidad de unidades adquiridas (`cantidad`).
  - Precio unitario acordado en la transacción (`precio_unitario_congelado`).
* **Cálculos Financieros:**
  - **Subtotal por renglón:** Producto de `cantidad * precio_unitario_congelado`.
  - **Monto Total acumulado:** Suma de los subtotales de las líneas del pedido.

---

## 3. Código T-SQL de la Consulta (`sql/consultas/consultas_etapa4.sql` - Parte 1)

```sql
-- =============================================================================
-- CU-01: COMPROBANTE / FACTURA DE VENTA CONSOLIDADA
-- Parámetro de prueba: @pedido_id = 1
-- =============================================================================

USE skytech_store;
GO

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
```

## 4. Análisis de Rendimiento e Integridad Referencial
1. Inmutabilidad Financiera (RN 3): La consulta utiliza dp.precio_unitario_congelado extraído de DETALLE_PEDIDO en lugar de pr.precio_actual de la tabla PRODUCTOS. Esto garantiza que los comprobantes generados históricamente mantengan exactitud contable sin importar aumentos o cambios posteriores en la lista de precios del catálogo.

2. Optimización de Claves: Las uniones se realizan estrictamente a través de las Claves Primarias (IDENTITY) y Claves Foráneas (FK) indexadas nativamente en SQL Server, asegurando un plan de ejecución de alto rendimiento con costo O(log n).