# Documentación Técnica: Control de Transacciones y Manejo de Errores

**Etapa V — Temas Técnicos**  
**Sistema:** SkyTech Store
**Responsable:** Integrante 2 (Issue #30)

\---

## 1\. Definición y Objetivo

Una **transacción** es una unidad lógica de trabajo que engloba una o múltiples sentencias SQL. El control explícito de transacciones asegura que todas las operaciones dentro del bloque se ejecuten de manera exitosa o que, ante cualquier falla, se deshagan en su totalidad (`ALL OR NOTHING`), garantizando los principios **ACID**:

* **Atomicidad:** la transacción se ejecuta completa o no se ejecuta en absoluto.
* **Consistencia:** la base de datos pasa de un estado válido a otro estado válido, respetando todas sus restricciones.
* **Aislamiento:** las transacciones que se ejecutan al mismo tiempo no se interfieren entre sí.
* **Durabilidad:** una vez confirmados los cambios con `COMMIT`, estos persisten aunque el servidor falle.

## 2\. Comandos y Tipos de Transacciones

Los comandos principales para controlar una transacción son:

* `BEGIN TRANSACTION`: marca el inicio de la transacción.
* `COMMIT TRANSACTION`: confirma los cambios y los hace permanentes.
* `ROLLBACK TRANSACTION`: deshace todos los cambios realizados desde el inicio.
* `SAVE TRANSACTION`: crea un punto de retorno que permite revertir solo una parte.

En SQL Server existen distintos modos de trabajo. En el modo **autocommit** (el predeterminado) cada sentencia se confirma automáticamente de forma individual. En las transacciones **explícitas**, el programador define el inicio y el fin, y es el modo utilizado en este trabajo. En el modo **implícito** el motor abre una transacción automáticamente al ejecutar ciertas sentencias, y esta debe cerrarse manualmente. Por último, las transacciones **anidadas** son aquellas que se inician dentro de otra, teniendo en cuenta que un `ROLLBACK` revierte siempre la transacción completa.

## 3\. Ventajas y Aplicaciones

* **Atomicidad:** Previene la persistencia de datos inconsistentes o parciales (ej. un pedido generado sin detalle de compra o sin descuento de stock).
* **Consistencia del Negocio:** Mantiene la integridad referencial y las restricciones de los datos ante errores imprevistos o picos de concurrencia.
* **Manejo Robusto de Excepciones:** Utiliza estructuras `TRY...CATCH` para interceptar errores de tiempo de ejecución y ejecutar un `ROLLBACK` seguro.
* **Aplicaciones típicas:** registro de ventas, transferencias bancarias, reservas y cualquier proceso donde varias operaciones dependan unas de otras.

## 4\. Manejo de Errores

Cuando se produce un error dentro del bloque `TRY`, la ejecución salta directamente al bloque `CATCH`. Allí se puede obtener información del problema mediante funciones como `ERROR\\\\\\\_NUMBER()`, `ERROR\\\\\\\_MESSAGE()`, `ERROR\\\\\\\_SEVERITY()` y `ERROR\\\\\\\_LINE()`.

Antes de revertir, se consulta `@@TRANCOUNT`, que indica cuántas transacciones hay abiertas, para asegurarse de que realmente exista una que deshacer. También existe `XACT\\\\\\\_STATE()`, que informa si la transacción todavía puede confirmarse o si quedó en un estado que obliga a revertirla. La opción `SET XACT\\\\\\\_ABORT ON` complementa este esquema, ya que hace que ante ciertos errores de ejecución la transacción se aborte automáticamente.

Para volver a lanzar el error luego del `ROLLBACK`, SQL Server ofrece `RAISERROR` y `THROW`; este último, disponible desde SQL Server 2012, conserva el número y la línea del error original y es el recomendado actualmente.

## 5\. Aislamiento y Bloqueos

Para cumplir con la propiedad de aislamiento, SQL Server utiliza **bloqueos (locks)** sobre los datos que una transacción está leyendo o modificando. De esta forma, otra sesión debe esperar hasta que la primera termine con `COMMIT` o `ROLLBACK`.

El comportamiento se regula con los **niveles de aislamiento**: `READ UNCOMMITTED`, `READ COMMITTED` (el predeterminado), `REPEATABLE READ`, `SERIALIZABLE` y `SNAPSHOT`. Cuanto mayor es el nivel, más problemas de concurrencia se evitan (lecturas sucias, lecturas no repetibles y lecturas fantasma), a cambio de mayor bloqueo y menor rendimiento.

Un **deadlock** ocurre cuando dos transacciones se bloquean mutuamente esperando recursos que la otra posee. En ese caso SQL Server elige a una de ellas como "víctima" y la revierte. Para prevenirlos se recomienda acceder a las tablas siempre en el mismo orden y mantener las transacciones lo más cortas posible.

## 6\. Implementación en SQL Server Express

Se desarrolló el procedimiento almacenado `dbo.sp\\\\\\\_RegistrarVentaTransaccional`, el cual recibe como parámetros el usuario, el método de pago, el producto y la cantidad, y encadena tres operaciones dependientes dentro de un mismo bloque transaccional:

1. **Operación 1 (`INSERT`):** Creación del encabezado en `PEDIDOS`.
2. **Operación 2 (`INSERT`):** Registro de las líneas de productos comprados en `DETALLE\\\\\\\_PEDIDO`, guardando el precio al momento de la compra (precio congelado), de modo que cambios posteriores en el catálogo no alteren pedidos históricos.
3. **Operación 3 (`UPDATE`):** Descuento del `stock` correspondiente en la tabla `PRODUCTOS`.

El procedimiento evalúa las condiciones antes y durante la ejecución; si el producto no existe, el stock es insuficiente o surge una violación de integridad, se activa el bloque `CATCH` invocando a `ROLLBACK TRANSACTION`. El identificador del pedido generado se obtiene con `SCOPE\\\\\\\_IDENTITY()`, que a diferencia de `@@IDENTITY` no se ve afectado por triggers. El script completo se presenta por separado.

## 7\. Caso Concreto y Demostración de Resultados

Se realizaron dos pruebas fundamentales para verificar la atomicidad, consultando el estado de las tablas antes y después de cada ejecución:

|Caso de Prueba|Escenario Ejecutado|Resultado Esperado|Resultado Obtenido|Estado Final de la BD|
|-|-|-|-|-|
|**Caso 1: Éxito**|Compra de 2 unidades con stock disponible|`COMMIT TRANSACTION`|✅ Transacción confirmada exitosamente|Pedido insertado, detalle creado y stock actualizado.|
|**Caso 2: Fallo Provocado**|Compra de 99,999 unidades (Stock insuficiente)|`ROLLBACK TRANSACTION`|✅ Interrupción y reversión automática|Ningún registro parcial en `PEDIDOS` ni en `DETALLE\\\\\\\_PEDIDO`. Stock inalterado.|

## 8\. Limitaciones y Mejoras Posibles

* **Concurrencia:** el stock se lee con una consulta común, por lo que dos sesiones simultáneas podrían ver el mismo valor. Se puede resolver bloqueando la fila al leerla (`UPDLOCK`) hasta el `COMMIT`.
* **`SET XACT\\\\\\\_ABORT ON`:** conviene activarlo para abortar automáticamente ante errores de ejecución.
* **Uso de `THROW`:** reemplazaría a `RAISERROR` para re-lanzar el error original.
* **Validaciones previas:** rechazar cantidades nulas, cero o negativas antes de abrir la transacción, ya que una cantidad negativa aumentaría el stock.
* **Restricción en la tabla:** agregar un `CHECK` que impida stock negativo como segunda defensa a nivel de base de datos.

## 9\. Buenas Prácticas

* Mantener las transacciones cortas para reducir bloqueos.
* No esperar interacción del usuario mientras una transacción está abierta.
* Verificar siempre `@@TRANCOUNT` antes de ejecutar un `ROLLBACK`.
* No dejar transacciones abiertas sin `COMMIT` ni `ROLLBACK`.
* Validar los datos antes de iniciar la transacción siempre que sea posible.

## 10\. Conclusiones

Las pruebas realizadas confirman la propiedad de **atomicidad** en el sistema **SkyTech Store**. La implementación de transacciones explícitas combinadas con `TRY...CATCH` garantiza que el motor de base de datos SQL Server nunca mantendrá pedidos huérfanos o incongruencias en el inventario. Las mejoras propuestas fortalecerían además el aislamiento y la consistencia ante escenarios de alta concurrencia.

## 

