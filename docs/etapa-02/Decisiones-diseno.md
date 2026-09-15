# Decisiones de Diseño — Etapa II: Modelado Conceptual, Lógico y Normalización

**Proyecto:** SkyTech Store  
**Fecha:** 2026-09-09  

## 1. Diseño Estructural y Claves Subrogadas (Surrogate Keys)
Para garantizar la independencia de los datos y simplificar las restricciones de integridad referencial, se decidió utilizar claves primarias artificiales de tipo entero autoincremental (`_id`) en lugar de claves naturales complejas. Excepcionalmente, se aplicó la restricción `UNIQUE` sobre campos comerciales clave como el `sku` en productos y el `email` en usuarios para mantener la unicidad del negocio sin afectar las relaciones lógicas.

## 2. Desacoplamiento del Carrito y el Proceso de Venta
Se estructuró el modelo separando claramente el flujo interactivo de compra en dos subdominios relacionales independientes:
* **Entorno Transitorio (`CARRITOS` e `ITEMS_CARRITO`):** Diseñado para altas, bajas y modificaciones dinámicas previas a la confirmación de la compra.
* **Entorno Histórico e Inalterable (`PEDIDOS` y `DETALLE_PEDIDO`):** Diseñado para almacenar la información definitiva de la transacción, incorporando el campo `precio_unitario_congelado`[cite: 6]. Esta decisión arquitectónica evita anomalías de actualización y asegura el cumplimiento estricto de la Tercera Forma Normal (3FN), aislando los datos operativos de los cambios en el catálogo de `PRODUCTOS`.

## 3. Resolución de Normalización
Se validó que el esquema resultante de 8 tablas cumple rigurosamente con la 3FN:
* **1FN:** Atomicidad total de atributos (separación de nombres y apellidos) y eliminación de grupos repetitivos mediante tablas asociativas[cite: 6].
* **2FN:** Ausencia de dependencias parciales gracias al uso de claves primarias simples[cite: 6].
* **3FN:** Eliminación de dependencias transitivas. Los atributos descriptivos (como categorías o métodos de pago) fueron aislados en tablas maestras independientes[cite: 6].