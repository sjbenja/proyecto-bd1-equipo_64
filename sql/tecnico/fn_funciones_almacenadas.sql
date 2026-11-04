-- =============================================================================
-- ESQUEMA: SkyTech Store - Etapa V
-- TEMA TÉCNICO: Funciones Almacenadas (Escalares y Valuadas en Tabla)
-- ARCHIVO: sql/tecnico/funciones/fn_funciones_almacenadas.sql
-- AUTOR: Equipo SkyTech Store (Issue #29)
-- SGBD: Microsoft SQL Server (T-SQL)
-- =============================================================================

USE skytech_store;
GO

-- -----------------------------------------------------------------------------
-- 1. FUNCIÓN ESCALAR: Calcular porcentaje de descuento para clientes frecuentes
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.fn_CalcularDescuentoCliente', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CalcularDescuentoCliente;
GO

CREATE FUNCTION dbo.fn_CalcularDescuentoCliente(@usuario_id INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @monto_acumulado DECIMAL(12,2) = 0.00;
    DECLARE @descuento DECIMAL(5,2) = 0.00;

    SELECT @monto_acumulado = ISNULL(SUM(monto_total), 0.00)
    FROM PEDIDOS
    WHERE usuario_id = @usuario_id AND estado_pedido = 'Completado';

    IF @monto_acumulado >= 500000.00
        SET @descuento = 0.10; -- 10%
    ELSE IF @monto_acumulado >= 200000.00
        SET @descuento = 0.05; -- 5%
    ELSE
        SET @descuento = 0.00;

    RETURN @descuento;
END;
GO

-- -----------------------------------------------------------------------------
-- 2. FUNCIÓN ESCALAR: Obtener el valor total del inventario disponible
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.fn_ObtenerValorInventarioTotal', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_ObtenerValorInventarioTotal;
GO

CREATE FUNCTION dbo.fn_ObtenerValorInventarioTotal()
RETURNS DECIMAL(15,2)
AS
BEGIN
    DECLARE @valor_total DECIMAL(15,2);

    SELECT @valor_total = ISNULL(SUM(precio_actual * stock), 0.00)
    FROM PRODUCTOS;

    RETURN @valor_total;
END;
GO

-- -----------------------------------------------------------------------------
-- 3. FUNCIÓN VALUADA EN TABLA: Consultar historial de compras por cliente
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.fn_ObtenerHistorialCliente', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_ObtenerHistorialCliente;
GO

CREATE FUNCTION dbo.fn_ObtenerHistorialCliente(@usuario_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.pedido_id,
        p.fecha_pedido,
        p.monto_total,
        p.estado_pedido,
        mp.nombre_metodo AS metodo_pago
    FROM PEDIDOS p
    INNER JOIN METODOS_PAGO mp ON p.metodo_pago_id = mp.metodo_pago_id
    WHERE p.usuario_id = @usuario_id
);
GO

-- -----------------------------------------------------------------------------
-- DEMOSTRACIÓN DE USO DE LAS FUNCIONES
-- -----------------------------------------------------------------------------
-- Ejemplo 1: Uso de función de descuento escalar
SELECT 
    usuario_id, 
    nombre, 
    dbo.fn_CalcularDescuentoCliente(usuario_id) AS porcentaje_descuento
FROM USUARIOS;

-- Ejemplo 2: Uso de función de valor total de inventario
SELECT dbo.fn_ObtenerValorInventarioTotal() AS Valor_Total_Stock_USD;

-- Ejemplo 3: Uso de función de tabla inline
SELECT * FROM dbo.fn_ObtenerHistorialCliente(1);
GO