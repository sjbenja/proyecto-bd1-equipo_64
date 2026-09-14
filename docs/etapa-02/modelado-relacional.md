# Modelo Relacional — SkyTech Store

## 1. ESQUEMA DE TABLAS Y ATRIBUTOS (3FN)

### USUARIOS
* `usuario_id` (PK, INT)
* `nombre` (VARCHAR(100), NOT NULL)
* `apellido` (VARCHAR(100), NOT NULL)
* `email` (VARCHAR(100), UNIQUE, NOT NULL)
* `fecha_registro` (DATE, NOT NULL)

### CATEGORIAS
* `categoria_id` (PK, INT)
* `nombre_categoria` (VARCHAR(100), NOT NULL, UNIQUE)
* `descripcion` (TEXT)

### PRODUCTOS
* `producto_id` (PK, INT)
* `sku` (VARCHAR(50), UNIQUE, NOT NULL)
* `nombre` (VARCHAR(255), NOT NULL)
* `descripcion` (TEXT)
* `precio_actual` (DECIMAL(10, 2), NOT NULL)
* `stock` (INT, NOT NULL)
* `categoria_id` (FK a CATEGORIAS)

### CARRITOS
* `carrito_id` (PK, INT)
* `usuario_id` (FK a USUARIOS, NOT NULL)
* `fecha_creacion` (TIMESTAMP, NOT NULL)
* `estado` (VARCHAR(20), NOT NULL) -- Ejemplos: 'Pendiente', 'Procesado'

### ITEMS_CARRITO
* `item_carrito_id` (PK, INT)
* `carrito_id` (FK a CARRITOS, NOT NULL)
* `producto_id` (FK a PRODUCTOS, NOT NULL)
* `cantidad` (INT, NOT NULL)

### METODOS_PAGO
* `metodo_id` (PK, INT)
* `nombre_metodo` (VARCHAR(50), NOT NULL, UNIQUE)
* `descripcion` (TEXT)

### PEDIDOS
* `pedido_id` (PK, INT)
* `usuario_id` (FK a USUARIOS, NOT NULL)
* `metodo_pago_id` (FK a METODOS_PAGO, NOT NULL)
* `fecha_pedido` (TIMESTAMP, NOT NULL)
* `monto_total` (DECIMAL(10, 2), NOT NULL)
* `estado_pedido` (VARCHAR(50), NOT NULL)

### DETALLE_PEDIDO
* `detalle_id` (PK, INT)
* `pedido_id` (FK a PEDIDOS, NOT NULL)
* `producto_id` (FK a PRODUCTOS, NOT NULL)
* `cantidad` (INT, NOT NULL)
* `precio_unitario_congelado` (DECIMAL(10, 2), NOT NULL)

---

## 2. CARDINALIDADES Y RELACIONES

* **CATEGORIAS (1) ─── (0, N) PRODUCTOS:** Una categoría agrupa de cero a muchos productos.
* **USUARIOS (1) ─── (0, N) CARRITOS:** Un usuario puede tener varios carritos en el historial (pero solo uno en estado 'Pendiente').
* **CARRITOS (1) ─── (1, N) ITEMS_CARRITO:** Un carrito activo contiene uno o muchos ítems.
* **PRODUCTOS (1) ─── (0, N) ITEMS_CARRITO:** Un producto puede estar presente en múltiples carritos activos.
* **USUARIOS (1) ─── (0, N) PEDIDOS:** Un usuario realiza cero o muchos pedidos.
* **METODOS_PAGO (1) ─── (0, N) PEDIDOS:** Un método de pago es utilizado en cero o muchos pedidos.
* **PEDIDOS (1) ─── (1, N) DETALLE_PEDIDO:** Un pedido confirmado se compone de uno o más renglones de detalle.
* **PRODUCTOS (1) ─── (0, N) DETALLE_PEDIDO:** Un producto puede haber sido vendido en múltiples detalles de pedido.