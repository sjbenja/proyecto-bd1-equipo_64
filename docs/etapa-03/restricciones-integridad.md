# Restricciones de Integridad y Reglas del Negocio — SkyTech Store

## 1. Políticas de Integridad Referencial (`FOREIGN KEY`)

Microsoft SQL Server aplica por defecto la regla `ON DELETE NO ACTION`, la cual actúa exactamente como `RESTRICT` en el estándar ANSI SQL, impidiendo la eliminación o actualización de una fila en la tabla padre si existen registros vinculados en las tablas hijas.

| Tabla Origen (Hija) | Clave Foránea (`FK`) | Tabla Destino (Padre) | Acción `ON DELETE` | Acción `ON UPDATE` | Justificación del Negocio |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `PRODUCTOS` | `categoria_id` | `CATEGORIAS` | `NO ACTION` | `CASCADE` | Impide eliminar categorías con productos activos. |
| `CARRITOS` | `usuario_id` | `USUARIOS` | `CASCADE` | `CASCADE` | Si se elimina el usuario, sus carritos temporales se borran. |
| `ITEMS_CARRITO` | `carrito_id` | `CARRITOS` | `CASCADE` | `CASCADE` | Si se cancela o elimina el carrito, se eliminan sus renglones. |
| `ITEMS_CARRITO` | `producto_id` | `PRODUCTOS` | `NO ACTION` | `CASCADE` | Impide borrar del catálogo un producto en el carrito activo. |
| `PEDIDOS` | `usuario_id` | `USUARIOS` | `NO ACTION` | `CASCADE` | Preserva el historial comercial aunque el usuario se dé de baja. |
| `PEDIDOS` | `metodo_pago_id` | `METODOS_PAGO` | `NO ACTION` | `CASCADE` | Conserva la contabilidad de pedidos cerrados. |
| `DETALLE_PEDIDO` | `pedido_id` | `PEDIDOS` | `CASCADE` | `CASCADE` | Eliminar una orden remueve sus renglones históricos. |
| `DETALLE_PEDIDO` | `producto_id` | `PRODUCTOS` | `NO ACTION` | `CASCADE` | Protege el registro de ventas frente a borrados de catálogo. |

## 2. Restricciones de Dominio (`CHECK` y `UNIQUE`)

* **`chk_email_formato`:** Valida la estructura básica del correo electrónico mediante el operador de coincidencia de patrones de T-SQL (`LIKE '%@%.%'`).
* **`chk_precio_actual`:** Garantiza que los productos no posean precios negativos (`precio_actual >= 0`).
* **`chk_stock`:** Evita que el inventario disponible tome valores negativos a nivel de motor (`stock >= 0`).
* **`chk_cantidad_item_carrito` / `chk_cantidad_detalle`:** Aseguran que la cantidad solicitada o comprada sea estrictamente mayor a cero (`cantidad > 0`).
* **`uk_carrito_producto`:** Clave candidata compuesta única (`UNIQUE(carrito_id, producto_id)`) para prevenir duplicación de filas del mismo ítem en un mismo carrito.