# Especificación Técnica: Control de Stock Crítico y Rotación de Inventario (CU-04)

## 1. Propósito y Contexto Operativo
La consulta de **Control de Stock Crítico y Rotación de Inventario** (CU-04) es una herramienta analítico-operativa orientada a la gestión de depósitos y compras en **SkyTech Store**. Permite monitorear el nivel de stock disponible, clasificar el estado de reabastecimiento en tiempo real e identificar productos que no registran ventas.

---

## 2. Requerimientos de Información y Reglas de Dominio
* **Atributos del Producto y Categoría:**
  - Código SKU del producto (`sku`).
  - Nombre del producto (`nombre`).
  - Categoría asociada (`nombre_categoria`).
  - Precio actual de lista (`precio_actual`).
  - Stock actual disponible (`stock`).
* **Métricas y Clasificación Dinámica (`CASE`):**
  - **Total Unidades Vendidas:** Suma de unidades comercializadas históricamente (`ISNULL(SUM(dp.cantidad), 0)`).
  - **Estado de Stock:** 
    - `CRÍTICO`: Stock $\le$ 3 unidades.
    - `BAJO`: Stock entre 4 y 8 unidades.
    - `NORMAL`: Stock mayor a 8 unidades.
  - **Alerta de Rotación:** Indica si el producto registra ventas o si representa capital inmovilizado sin salida (`SIN VENTAS`).

---

## 3. Código T-SQL de la Consulta

[Script de Consulta](/sql/consultas/inventario_critico.sql)

## 4. Análisis de Complejidad Técnica
1. Inclusión Total de Catálogo (LEFT JOIN): Permite listar productos incluso si jamás han sido incluidos en un pedido (DETALLE_PEDIDO), detectando ítems sin rotación comercial.

2. Lógica Condicional (CASE WHEN): Clasifica en tiempo de ejecución el estado de salud del inventario para la toma de decisiones del área de compras.

3. Manejo de Nulos (ISNULL / IS NULL): Reemplaza valores nulos por cero en métricas de agregación para evitar inconsistencias en la presentación de datos.