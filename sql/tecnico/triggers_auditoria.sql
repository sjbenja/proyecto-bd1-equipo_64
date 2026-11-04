-- =============================================================================
-- ESQUEMA: SkyTech Store - Etapa V
-- TEMA TÉCNICO: Triggers de Auditoría y Protección de Datos
-- ARCHIVO: sql/tecnico/triggers/triggers_auditoria.sql
-- AUTOR: Equipo SkyTech Store (Issue #31)
-- SGBD: Microsoft SQL Server (T-SQL)
-- =============================================================================

USE skytech_store;
GO

-- =============================================================================
-- PARTE 1: TABLA AUXILIAR DE AUDITORÍA PARA PRODUCTOS
-- =============================================================================
IF OBJECT_ID('dbo.AUDITORIA_PRODUCTOS', 'U') IS NOT NULL
    DROP TABLE dbo.AUDITORIA_PRODUCTOS;
GO

CREATE TABLE dbo.AUDITORIA_PRODUCTOS (
    auditoria_id INT IDENTITY(1,1) PRIMARY KEY,
    producto_id INT NOT NULL,
    sku_afectado VARCHAR(50),
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    stock_anterior INT,
    stock_nuevo INT,
    tipo_operacion VARCHAR(20) NOT NULL, -- 'UPDATE' o 'DELETE'
    usuario_db VARCHAR(100) NOT NULL,
    fecha_hora DATETIME2 DEFAULT SYSDATETIME()
);
GO


-- =============================================================================
-- PARTE 2: TRIGGER DE AUDITORÍA (UPDATE / DELETE)
-- Registra automáticamente los cambios de precio/stock o bajas de productos.
-- =============================================================================
IF OBJECT_ID('dbo.TR_AuditoriaProductos', 'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_AuditoriaProductos;
GO

CREATE TRIGGER dbo.TR_AuditoriaProductos
ON dbo.PRODUCTOS
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tipo_op VARCHAR(20);

    -- Determinar el tipo de operación ocurrida
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @tipo_op = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM deleted)
        SET @tipo_op = 'DELETE';
    ELSE
        RETURN; -- Salir si no hay registros afectados

    -- Insertar el registro de auditoría utilizando las tablas lógicas inserted y deleted
    IF @tipo_op = 'UPDATE'
    BEGIN
        INSERT INTO dbo.AUDITORIA_PRODUCTOS (
            producto_id, sku_afectado, precio_anterior, precio_nuevo, 
            stock_anterior, stock_nuevo, tipo_operacion, usuario_db, fecha_hora
        )
        SELECT 
            d.producto_id,
            d.sku,
            d.precio_actual,
            i.precio_actual,
            d.stock,
            i.stock,
            'UPDATE',
            ORIGINAL_LOGIN(),
            SYSDATETIME()
        FROM deleted d
        INNER JOIN inserted i ON d.producto_id = i.producto_id;
    END
    ELSE IF @tipo_op = 'DELETE'
    BEGIN
        INSERT INTO dbo.AUDITORIA_PRODUCTOS (
            producto_id, sku_afectado, precio_anterior, precio_nuevo, 
            stock_anterior, stock_nuevo, tipo_operacion, usuario_db, fecha_hora
        )
        SELECT 
            d.producto_id,
            d.sku,
            d.precio_actual,
            NULL,
            d.stock,
            NULL,
            'DELETE',
            ORIGINAL_LOGIN(),
            SYSDATETIME()
        FROM deleted d;
    END
END;
GO


-- =============================================================================
-- PARTE 3: TRIGGER PREVENTIVO / RESTRICTIVO (INSTEAD OF DELETE)
-- Evita el borrado físico directo sobre la tabla CATEGORIAS emitiendo un mensaje.
-- =============================================================================
IF OBJECT_ID('dbo.TR_PrevenirBorradoCategorias', 'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_PrevenirBorradoCategorias;
GO

CREATE TRIGGER dbo.TR_PrevenirBorradoCategorias
ON dbo.CATEGORIAS
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Emitir mensaje de error y cancelar la operación
    RAISERROR('ACCESO DENEGADO: El borrado físico de categorías está estrictamente prohibido por políticas de seguridad de SkyTech Store.', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO


-- =============================================================================
-- PARTE 4: PRUEBAS DE DEMOSTRACIÓN DE LOS TRIGGERS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- PRUEBA 4.1: Trigger de Auditoría (Actualización de Precio)
-- -----------------------------------------------------------------------------
PRINT '--- PRUEBA 4.1: Auditoría de UPDATE en PRODUCTOS ---';

-- Ver estado inicial del producto 1
SELECT producto_id, nombre, precio_actual, stock FROM PRODUCTOS WHERE producto_id = 1;

-- Modificar el precio de un producto
UPDATE PRODUCTOS 
SET precio_actual = precio_actual * 1.15 
WHERE producto_id = 1;

-- Verificar que el cambio se registró automáticamente en la tabla de auditoría
SELECT * FROM AUDITORIA_PRODUCTOS;
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 4.2: Trigger Preventivo (Intento de DELETE bloqueado)
-- -----------------------------------------------------------------------------
PRINT '--- PRUEBA 4.2: Trigger Preventivo INSTEAD OF DELETE ---';

-- Intentar eliminar una categoría (Debe fallar y mostrar el mensaje personalizado)
DELETE FROM CATEGORIAS WHERE categoria_id = 1;
GO