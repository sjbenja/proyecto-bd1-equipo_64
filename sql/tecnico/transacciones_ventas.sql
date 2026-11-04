-- =============================================================================
-- ESQUEMA: SkyTech Store - Etapa V
-- TEMA TÉCNICO: Manejo de Transacciones y Demostración de Atomicidad
-- ARCHIVO: sql/tecnico/transacciones/transacciones_ventas.sql
-- AUTOR: Equipo SkyTech Store (Issue #30)
-- SGBD: Microsoft SQL Server (T-SQL)
-- =============================================================================

USE skytech_store;
GO

-- -----------------------------------------------------------------------------
-- PROCEDIMIENTO ALMACENADO CON CONTROL TRANSACCIONAL COMPLETO
-- Registrar una venta compuesta: PEDIDOS -> DETALLE_PEDIDO -> UPDATE PRODUCTOS
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.sp_RegistrarVentaTransaccional', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RegistrarVentaTransaccional;
GO

CREATE PROCEDURE dbo.sp_RegistrarVentaTransaccional
    @usuario_id INT,
    @metodo_pago_id INT,
    @producto_id INT,
    @cantidad INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para control de la transacción
    DECLARE @precio_unitario DECIMAL(10,2);
    DECLARE @stock_actual INT;
    DECLARE @monto_total DECIMAL(10,2);
    DECLARE @nuevo_pedido_id INT;

    -- Iniciar bloque de control de errores
    BEGIN TRY
        -- Iniciar Transacción Explícita
        BEGIN TRANSACTION;

        -- 1. Obtener y verificar datos del producto
        SELECT 
            @precio_unitario = precio_actual,
            @stock_actual = stock
        FROM PRODUCTOS
        WHERE producto_id = @producto_id;

        IF @precio_unitario IS NULL
        BEGIN
            RAISERROR('El producto especificado no existe.', 16, 1);
        END

        -- Validar disponibilidad de stock suficiente
        IF @stock_actual < @cantidad
        BEGIN
            RAISERROR('Stock insuficiente para completar la venta. Operación cancelada.', 16, 1);
        END

        -- Calcular monto total acumulado
        SET @monto_total = @precio_unitario * @cantidad;

        -- 2. OPERACIÓN 1: Insertar Encabezado del Pedido
        INSERT INTO PEDIDOS (usuario_id, metodo_pago_id, fecha_pedido, monto_total, estado_pedido)
        VALUES (@usuario_id, @metodo_pago_id, SYSDATETIME(), @monto_total, 'Completado');

        -- Obtener el ID generado automáticamente
        SET @nuevo_pedido_id = SCOPE_IDENTITY();

        -- 3. OPERACIÓN 2: Insertar Detalle del Pedido (Precio Congelado)
        INSERT INTO DETALLE_PEDIDO (pedido_id, producto_id, cantidad, precio_unitario_congelado)
        VALUES (@nuevo_pedido_id, @producto_id, @cantidad, @precio_unitario);

        -- 4. OPERACIÓN 3: Actualizar el Stock Disponible en PRODUCTOS
        UPDATE PRODUCTOS
        SET stock = stock - @cantidad
        WHERE producto_id = @producto_id;

        -- Confirmar todas las operaciones si no hubo errores
        COMMIT TRANSACTION;
        PRINT 'SUCCESS: La venta se ha registrado exitosamente y los cambios han sido confirmados.';

    END TRY
    BEGIN CATCH
        -- Si existe una transacción activa en estado no ejecutable o abierta, deshacer
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'ROLLBACK: Transacción revertida completamente debido a un error.';
        END

        -- Re-emitir el mensaje de error capturado
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO


-- =============================================================================
-- PRUEBAS DE DEMOSTRACIÓN DE ATOMICIDAD (ACID)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- DEMOSTRACIÓN 1: Ejecución Correcta (COMMIT)
-- Se simula una compra de 2 unidades de un producto con stock suficiente.
-- -----------------------------------------------------------------------------
PRINT '==================================================';
PRINT 'DEMOSTRACIÓN 1: Caso Exitoso (COMMIT)';
PRINT '==================================================';

-- Consultar stock previo
SELECT producto_id, nombre, stock FROM PRODUCTOS WHERE producto_id = 1;

-- Ejecutar transacción
EXEC dbo.sp_RegistrarVentaTransaccional 
    @usuario_id = 1, 
    @metodo_pago_id = 1, 
    @producto_id = 1, 
    @cantidad = 2;

-- Verificar la consistencia final
SELECT producto_id, nombre, stock FROM PRODUCTOS WHERE producto_id = 1;
SELECT TOP 1 * FROM PEDIDOS ORDER BY pedido_id DESC;
SELECT TOP 1 * FROM DETALLE_PEDIDO ORDER BY detalle_id DESC;
GO

-- -----------------------------------------------------------------------------
-- DEMOSTRACIÓN 2: Error Provocado Intencionalmente (ROLLBACK)
-- Se solicita comprar 99999 unidades (supera el stock disponible).
-- La transacción debe deshacer el pedido, el detalle y la actualización de stock.
-- -----------------------------------------------------------------------------
PRINT '==================================================';
PRINT 'DEMOSTRACIÓN 2: Caso de Fallo Provocado (ROLLBACK)';
PRINT '==================================================';

-- Consultar cantidad de pedidos antes de la prueba
DECLARE @cant_pedidos_antes INT = (SELECT COUNT(*) FROM PEDIDOS);
PRINT 'Cantidad de pedidos antes de la prueba fallida: ' + CAST(@cant_pedidos_antes AS VARCHAR);

-- Intentar ejecutar transacción que fallará intencionalmente
EXEC dbo.sp_RegistrarVentaTransaccional 
    @usuario_id = 1, 
    @metodo_pago_id = 1, 
    @producto_id = 1, 
    @cantidad = 99999;

-- Verificar que NO se haya insertado ningún registro parcial (Atomicidad)
DECLARE @cant_pedidos_despues INT = (SELECT COUNT(*) FROM PEDIDOS);
PRINT 'Cantidad de pedidos después de la prueba fallida: ' + CAST(@cant_pedidos_despues AS VARCHAR);

IF @cant_pedidos_antes = @cant_pedidos_despues
    PRINT 'PRUEBA EXITOSA: No se guardaron registros parciales. Atomicidad garantizada.';
GO