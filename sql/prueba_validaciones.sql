-- =============================================================================
-- SCRIPT DE PRUEBAS Y VALIDACIÓN DE RESTRICCIONES (T-SQL)
-- Motor: Microsoft SQL Server
-- Archivo: sql/tests/pruebas_validaciones.sql
-- =============================================================================

USE skytech_store;
GO

PRINT '====================================================================';
PRINT 'INICIANDO PRUEBAS DE INTEGRIDAD EN SKYTECH STORE (SQL SERVER)';
PRINT '====================================================================';
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 1: Inserción con Stock Negativo (Debe fallar por chk_stock)
-- -----------------------------------------------------------------------------
BEGIN TRY
    PRINT '[PRUEBA 1] Intentando insertar producto con stock negativo...';
    INSERT INTO PRODUCTO (sku, nombre_producto, descripcion_producto, precio_actual, stock, categoria_id)
    VALUES ('TEST-STOCK-ERR', 'Producto Inválido', 'Test', 1000.00, -5, 1);
    PRINT '-> ERROR: La restricción chk_stock NO detuvo la inserción.';
END TRY
BEGIN CATCH
    PRINT '-> ÉXITO: Inserción rechazada correctamente por SQL Server.';
    PRINT '   Mensaje de error: ' + ERROR_MESSAGE();
    PRINT '   Código de error: Msg ' + CAST(ERROR_NUMBER() AS VARCHAR);
END CATCH;
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 2: Duplicación de Email (Debe fallar por restricción UNIQUE)
-- -----------------------------------------------------------------------------
BEGIN TRY
    PRINT '[PRUEBA 2] Intentando insertar usuario con e-mail duplicado...';
    INSERT INTO USUARIO (nombre, apellido, email)
    VALUES ('Juan', 'Pérez', 'juan.gomez@email.com'); -- Email de registro ID 1
    PRINT '-> ERROR: La restricción UNIQUE NO detuvo el correo duplicado.';
END TRY
BEGIN CATCH
    PRINT '-> ÉXITO: Duplicado rechazado correctamente por SQL Server.';
    PRINT '   Mensaje de error: ' + ERROR_MESSAGE();
    PRINT '   Código de error: Msg ' + CAST(ERROR_NUMBER() AS VARCHAR);
END CATCH;
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 3: Eliminación de Producto con Historial (Debe fallar por FK ON DELETE NO ACTION)
-- -----------------------------------------------------------------------------
BEGIN TRY
    PRINT '[PRUEBA 3] Intentando borrar un producto vinculado a un pedido...';
    DELETE FROM PRODUCTO WHERE producto_id = 1; -- Vinculado a DETALLE_PEDIDO
    PRINT '-> ERROR: Se eliminó el producto violando la integridad referencial.';
END TRY
BEGIN CATCH
    PRINT '-> ÉXITO: Borrado rechazado correctamente por SQL Server.';
    PRINT '   Mensaje de error: ' + ERROR_MESSAGE();
    PRINT '   Código de error: Msg ' + CAST(ERROR_NUMBER() AS VARCHAR);
END CATCH;
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 4: Inserción con Formato de Email Inválido (Debe fallar por chk_email_formato)
-- -----------------------------------------------------------------------------
BEGIN TRY
    PRINT '[PRUEBA 4] Intentando insertar usuario con e-mail sin formato correcto...';
    INSERT INTO USUARIO (nombre, apellido, email)
    VALUES ('Carlos', 'SinEmail', 'correo_sin_arroba_ni_dominio');
    PRINT '-> ERROR: La restricción chk_email_formato NO detuvo el email malformado.';
END TRY
BEGIN CATCH
    PRINT '-> ÉXITO: Formato rechazado correctamente por SQL Server.';
    PRINT '   Mensaje de error: ' + ERROR_MESSAGE();
    PRINT '   Código de error: Msg ' + CAST(ERROR_NUMBER() AS VARCHAR);
END CATCH;
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 5: Verificación de Inmutabilidad Financiera (RN 3)
-- -----------------------------------------------------------------------------
PRINT '[PRUEBA 5] Verificando inmutabilidad de precios históricos tras actualización del catálogo...';

-- 1. Consultar precio histórico del Pedido ID 1 para el Producto ID 1
DECLARE @precio_historico DECIMAL(10,2);
SELECT @precio_historico = precio_unitario_congelado 
FROM DETALLE_PEDIDO 
WHERE pedido_id = 1 AND producto_id = 1;

-- 2. Modificar el precio actual del producto en la tabla PRODUCTOS
UPDATE PRODUCTO SET precio_actual = 500000.00 WHERE producto_id = 1;

-- 3. Verificar que el precio en DETALLE_PEDIDO siga intacto
DECLARE @precio_post_update DECIMAL(10,2);
SELECT @precio_post_update = precio_unitario_congelado 
FROM DETALLE_PEDIDO 
WHERE pedido_id = 1 AND producto_id = 1;

IF @precio_historico = @precio_post_update
BEGIN
    PRINT '-> ÉXITO: El precio congelado en el pedido permaneció intacto ($' + CAST(@precio_post_update AS VARCHAR) + ').';
END
ELSE
BEGIN
    PRINT '-> ERROR: El precio en el detalle de pedido fue alterado.';
END;

-- Restablecer el precio del catálogo
UPDATE PRODUCTO SET precio_actual = 245000.00 WHERE producto_id = 1;
GO

PRINT '====================================================================';
PRINT 'PRUEBAS DE VALIDACIÓN FINALIZADAS CON ÉXITO';
PRINT '====================================================================';
GO