# Proceso de Normalización — SkyTech Store

## Justificación Paso a Paso (1FN a 3FN)

### 1. Primera Forma Normal (1FN) - Atomicidad y Grupos Repetitivos
* **Criterio:** Todos los atributos deben contener valores atómicos (indivisibles) y no deben existir grupos o listas repetitivas dentro de una misma celda.
* **Aplicación en el Modelo:**
  * Se separaron los nombres completos en atributos atómicos `nombre` y `apellido` dentro de `USUARIOS`.
  * Se eliminaron los grupos repetitivos de productos dentro de las compras mediante la creación de las tablas asociativas `ITEMS_CARRITO` y `DETALLE_PEDIDO`, donde cada renglón representa una única relación producto-cantidad.

### 2. Segunda Forma Normal (2FN) - Dependencia Funcional Total
* **Criterio:** El esquema debe estar en 1FN y todos los atributos no clave deben depender de la TOTALIDAD de la clave primaria (eliminando dependencias parciales sobre PKs compuestas).
* **Aplicación en el Modelo:**
  * Se adoptó el uso de Claves Primarias Simples / Subrogadas (`Surrogate Keys` autoincrementales como `item_carrito_id`, `detalle_id`, `producto_id`).
  * Al no utilizar claves primarias compuestas para definir las entidades relacionales, se garantiza matemáticamente la ausencia de dependencias funcionales parciales.

### 3. Tercera Forma Normal (3FN) - Ausencia de Dependencias Transitivas
* **Criterio:** El esquema debe estar en 2FN y ningún atributo no clave debe depender de otro atributo no clave ($A \rightarrow B \rightarrow C$).
* **Aplicación en el Modelo:**
  * Los datos descriptivos de las categorías se aislaron en la tabla `CATEGORIAS`, de modo que `PRODUCTOS` solo almacena la FK `categoria_id`.
  * Los detalles del medio de pago se aislaron en `METODOS_PAGO`, guardando únicamente la FK `metodo_pago_id` en la tabla `PEDIDOS`.
  * **Análisis de `precio_unitario_congelado`:** El almacenamiento de este campo en `DETALLE_PEDIDO` no representa una redundancia ni una dependencia transitiva del catálogo de `PRODUCTOS`. Corresponde a un atributo propio de la transacción histórica (auditoría e inmutabilidad de precios según RN 3), desacoplado del valor dinámico `precio_actual`[cite: 5].