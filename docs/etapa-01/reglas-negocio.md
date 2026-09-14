# Reglas de Negocio (RN) — SkyTech Store

* **RN 1: Registro de Clientes**
  * **Descripción:** Todo cliente debe identificarse de manera única en la plataforma[cite: 5].
  * **Invariante:** El campo `email` y el `documento_identidad` deben ser únicos (`UNIQUE`) e inalterables en el sistema[cite: 5].

* **RN 2: Gestión y Control de Stock**
  * **Descripción:** El inventario debe actualizarse con cada venta y no puede venderse sin disponibilidad[cite: 5].
  * **Invariante:** La columna `stock` de la tabla de productos debe ser un número entero no negativo (`stock >= 0`)[cite: 5]. La cantidad solicitada en una venta debe ser menor o igual al stock disponible (`cantidad <= stock_disponible`)[cite: 5].

* **RN 3: Congelamiento e Historial de Precios en Ventas**
  * **Descripción:** El precio del producto en una venta realizada no debe alterarse si el precio del catálogo cambia a futuro[cite: 5].
  * **Invariante:** La entidad `Detalle_Pedido` debe guardar explícitamente el `precio_unitario` pagado al instante exacto del cierre de la transacción, desacoplándolo de la tabla `Productos`[cite: 5].

* **RN 4: Persistencia y Exclusividad del Carrito**
  * **Descripción:** Un usuario interactúa con la tienda mediante un carrito de compras[cite: 5].
  * **Invariante:** Un cliente solo puede tener **un único carrito activo** en estado `'Pendiente'`[cite: 5]. Al confirmarse la compra, el carrito pasa a estado `'Procesado'` y se genera la orden de venta[cite: 5].

* **RN 5: Métodos de Pago**
  * **Descripción:** Todo pedido debe registrar de forma obligatoria el medio de pago seleccionado[cite: 5].
  * **Invariante:** Cada pedido debe vincularse a un `id_metodo_pago` válido y su estado de transacción debe ser inmutable una vez registrado como `'Completado'`[cite: 5].

* **RN 6: Integridad del Detalle de Pedido**
  * **Descripción:** Un pedido confirmado debe contener al menos un producto vendido[cite: 5].
  * **Invariante:** La cantidad de cada ítem en el detalle debe ser estricta y positivamente mayor a cero (`cantidad > 0`)[cite: 5].

* **RN 7: Categorización y SKU de Producto**
  * **Descripción:** Cada componente del catálogo debe pertenecer a una línea de productos y tener un identificador comercial[cite: 5].
  * **Invariante:** Cada producto debe tener asignada obligatoriamente una categoría válida (`NOT NULL`) y poseer un `SKU` único[cite: 5].