# Reporte de Pruebas y Validación de Integridad en Microsoft SQL Server

## 1. Verificación de Despliegue Limpio
Se ejecutó exitosamente el lote completo de scripts en SQL Server Management Studio (SSMS):
1. `sql/ddl/crear_bd.sql`: Generó la base de datos `skytech_store` y las 8 tablas sin advertencias ni errores.
2. `sql/dml/datos_prueba.sql`: Insertó exactamente 10 filas por tabla respetando el orden de dependencias.

## 2. Batería de Pruebas de Violación de Integridad

### Prueba 1: Rechazo de Stock Negativo (Cláusula `CHECK`)
* **Sentencia T-SQL ejecutada:**
  ```sql
  INSERT INTO PRODUCTOS (sku, nombre, precio_actual, stock, categoria_id)
  VALUES ('TEST-ERR-01', 'Producto Test Erróneo', 15000.00, -5, 1);

* **Resultado Esperado: Transacción rechazada por el motor.

* **Resultado Obtenido: Error de SQL Server Msg 547, Level 16, State 0.

* **Mensaje: The INSERT statement conflicted with the CHECK constraint "chk_stock".

## Prueba 2: Protección de Inmutabilidad de Ventas (ON DELETE NO ACTION)
* **Sentencia T-SQL ejecutada:
    ```sql
    DELETE FROM PRODUCTOS WHERE producto_id = 1; -- Producto vinculado al Pedido ID 1

* **Resultado Esperado: Rechazo del borrado debido al historial de venta registrado en DETALLE_PEDIDO.

* **Resultado Obtenido: Error de SQL Server Msg 547, Level 16, State 0.

* **Mensaje: The DELETE statement conflicted with the REFERENCE constraint "fk_detallepedido_productos".

### Prueba 3: Unicidad de Correo de Usuario (UNIQUE)
* **Sentencia T-SQL ejecutada:
    ```sql
    INSERT INTO USUARIOS (nombre, apellido, email)
    VALUES ('Juan', 'Pérez', 'juan.gomez@email.com'); -- Email existente

* **Resultado Esperado: Aborto por violación de restricción de clave única.

* **Resultado Obtenido: Error de SQL Server Msg 2627, Level 14, State 1.

* **Mensaje: Violation of UNIQUE KEY constraint. Cannot insert duplicate key in object 'dbo.USUARIOS'.
