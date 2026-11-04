-- =============================================================================
-- ESQUEMA: SkyTech Store - Etapa V
-- TEMA TÉCNICO: Procedimientos Almacenados (CRUD) y Pruebas de Rendimiento
-- ARCHIVO: sql/tecnico/procedimientos/sp_crud_productos.sql
-- AUTOR: Equipo SkyTech Store (Issue #29)
-- SGBD: Microsoft SQL Server (T-SQL)
-- =============================================================================

USE skytech_store;
GO

-- -----------------------------------------------------------------------------
-- 1. SP INSERTAR: Registrar un nuevo producto con validación de categoría
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.sp_InsertarProducto', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_InsertarProducto;
GO

CREATE PROCEDURE dbo.sp_InsertarProducto
    @sku VARCHAR(50),
    @nombre VARCHAR(100),
    @descripcion VARCHAR(500),
    @precio_actual DECIMAL(10,2),
    @stock INT,
    @categoria_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que la categoría exista
    IF NOT EXISTS (SELECT 1 FROM CATEGORIAS WHERE categoria_id = @categoria_id)
    BEGIN
        RAISERROR('La categoría especificada no existe.', 16, 1);
        RETURN;
    END

    INSERT INTO PRODUCTOS (sku, nombre, descripcion, precio_actual, stock, categoria_id)
    VALUES (@sku, @nombre, @descripcion, @precio_actual, @stock, @categoria_id);
END;
GO

-- -----------------------------------------------------------------------------
-- 2. SP MODIFICAR: Actualizar precio y stock de un producto existente
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ModificarProducto', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ModificarProducto;
GO

CREATE PROCEDURE dbo.sp_ModificarProducto
    @producto_id INT,
    @nuevo_precio DECIMAL(10,2),
    @nuevo_stock INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM PRODUCTOS WHERE producto_id = @producto_id)
    BEGIN
        RAISERROR('El producto especificado no existe.', 16, 1);
        RETURN;
    END

    UPDATE PRODUCTOS
    SET precio_actual = @nuevo_precio,
        stock = @nuevo_stock
    WHERE producto_id = @producto_id;
END;
GO

-- -----------------------------------------------------------------------------
-- 3. SP ELIMINAR: Borrado controlado de producto (o deshabilitación)
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.sp_EliminarProducto', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_EliminarProducto;
GO

CREATE PROCEDURE dbo.sp_EliminarProducto
    @producto_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el producto posee detalle de ventas asociadas
    IF EXISTS (SELECT 1 FROM DETALLE_PEDIDO WHERE producto_id = @producto_id)
    BEGIN
        RAISERROR('No se puede eliminar el producto porque posee historial de ventas asociadas.', 16, 1);
        RETURN;
    END

    DELETE FROM PRODUCTOS
    WHERE producto_id = @producto_id;
END;
GO

-- -----------------------------------------------------------------------------
-- DEMOSTRACIÓN Y COMPARACIÓN DE EFICIENCIA: Lote Directo vs. SP
-- -----------------------------------------------------------------------------
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Prueba 1: Inserción directa en lote
PRINT '--- Prueba 1: Inserción Directa ---';
INSERT INTO PRODUCTOS (sku, nombre, descripcion, precio_actual, stock, categoria_id)
VALUES 
('TEST-001', 'Producto Test Directo 1', 'Desc', 1000.00, 10, 1),
('TEST-002', 'Producto Test Directo 2', 'Desc', 1500.00, 15, 1);

-- Prueba 2: Inserción invocando el Stored Procedure
PRINT '--- Prueba 2: Inserción vía Stored Procedure ---';
EXEC dbo.sp_InsertarProducto 'TEST-003', 'Producto Test SP 1', 'Desc', 2000.00, 20, 1;
EXEC dbo.sp_InsertarProducto 'TEST-004', 'Producto Test SP 2', 'Desc', 2500.00, 25, 1;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO