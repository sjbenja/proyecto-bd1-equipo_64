# Definición de Casos de Uso de Consultas SQL — SkyTech Store

## 1. Introducción y Marco de Trabajo
La presente especificación documenta los casos de uso principales orientados a la recuperación, agregación y análisis de información sobre la base de datos relacional 3FN **SkyTech Store**. 

El objetivo es traducir las necesidades operativas, contables y directivas del e-commerce de hardware informático en consultas estructuradas en dialecto **T-SQL** para **Microsoft SQL Server**, garantizando eficiencia en la ejecución, integridad en los resultados y aprovechamiento de los índices primarios y foráneos creados en la Etapa III.

---

## 2. Matriz General de Casos de Uso

| ID | Nombre del Caso de Uso | Categoría | Tablas Involucradas | Cláusulas Clave T-SQL |
| :--- | :--- | :--- | :--- | :--- |
| **CU-01** | Comprobante / Factura de Venta | Transaccional / Operativo | `USUARIOS`, `PEDIDOS`, `DETALLE_PEDIDO`, `PRODUCTOS`, `METODOS_PAGO` | `INNER JOIN`, Producto Escalar, Filtro por ID |
| **CU-02** | Informe Consolidado de Ventas por Categoría | Analítico / Gerencial | `CATEGORIAS`, `PRODUCTOS`, `DETALLE_PEDIDO`, `PEDIDOS` | `INNER JOIN`, `GROUP BY`, `SUM`, `COUNT`, `ORDER BY` |
| **CU-03** | Análisis de Clientes VIP y Segmentación | Estratégico / Comercial | `USUARIOS`, `PEDIDOS`, `DETALLE_PEDIDO` | `INNER JOIN`, `GROUP BY`, `HAVING`, Subconsultas / CTE |
| **CU-04** | Control de Stock Crítico y Rotación de Inventario | Operativo / Logística | `PRODUCTOS`, `CATEGORIAS`, `DETALLE_PEDIDO` | `LEFT JOIN`, `GROUP BY`, `CASE WHEN`, `ISNULL`, `HAVING` |

---

## 3. Descripción Detallada de los Casos de Uso

### CU-01: Emitir Comprobante / Factura de Venta Consolidada
* **Actor Principal:** Sistema de Facturación / Atención al Cliente.
* **Descripción:** Permite obtener de forma consolidada la cabecera de la transacción (datos del cliente, fecha, medio de pago) junto con la lista detallada de los artículos comprados, sus cantidades y los precios congelados al momento de la venta.
* **Criterio de Aceptación:**
  - El subtotal por línea debe ser el producto escalar de `cantidad * precio_unitario_congelado`.
  - La suma de los subtotales debe coincidir con el campo `monto_total` almacenado en la cabecera de `PEDIDOS`.

### CU-02: Generar Informe Agregado de Ventas por Categoría de Producto
* **Actor Principal:** Gerencia de Inventario / Administración.
* **Descripción:** Consolida el rendimiento comercial agrupando las ventas por categoría de hardware (Procesadores, Placas de Video, Almacenamiento, etc.) en un rango de fechas flexible.
* **Criterio de Aceptación:**
  - Debe calcular el total facturado, la cantidad total de unidades físicas vendidas y el número de pedidos distintos procesados por categoría.
  - Las categorías sin ventas registradas o fuera del rango deben ser gestionadas correctamente sin alterar los totales globales.

### CU-03: Consulta Avanzada — Identificación de Clientes de Alto Valor (VIP)
* **Actor Principal:** Departamento de Marketing / Ventas.
* **Descripción:** Identifica patrones de consumo mediante la detección de clientes que hayan superado un umbral de frecuencia de compra y volumen de facturación total acumulado.
* **Criterio de Aceptación:**
  - Debe filtrar grupos agregados utilizando la cláusula `HAVING` en T-SQL.
  - Ordena los resultados de mayor a menor según el monto acumulado invertido en la plataforma.

### CU-04: Control de Stock Crítico y Rotación de Inventario
* **Actor Principal:** Departamento de Logística / Compras y Depósito.
* **Descripción:** Monitorea en tiempo real el nivel de stock disponible del catálogo, clasificando la urgencia de reposición mediante lógica condicional y detectando aquellos productos que no registran ventas históricas (capital inmovilizado).
* **Criterio de Aceptación:**
  - Debe incluir la totalidad del catálogo mediante uniones externas (`LEFT JOIN`) para capturar artículos sin ventas previas.
  - Clasifica dinámicamente el estado del inventario (Crítico, Bajo, Normal, Agotado) y el estado de rotación.