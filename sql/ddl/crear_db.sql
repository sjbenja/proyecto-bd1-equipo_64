-- =============================================================================
-- ESQUEMA DDL (Estructura Base): SkyTech Store
-- Equipo: 64
-- SGBD: Microsoft SQL Server (T-SQL)
-- =============================================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'skytech_store')
BEGIN
    ALTER DATABASE skytech_store SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE skytech_store;
END;
GO

CREATE DATABASE skytech_store;
GO

USE skytech_store;
GO

-- -----------------------------------------------------------------------------
-- 1. ESTRUCTURA BASE DE TABLAS
-- -----------------------------------------------------------------------------

CREATE TABLE USUARIO (
    usuario_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE)
);
GO

CREATE TABLE CATEGORIA (
    categoria_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion_catecgoria VARCHAR(MAX)
);
GO

CREATE TABLE PRODUCTO (
    producto_id INT IDENTITY(1,1) PRIMARY KEY,
    sku VARCHAR(50) NOT NULL,
    nombre_producto VARCHAR(255) NOT NULL,
    descripcion_producto VARCHAR(MAX),
    precio_actual DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    categoria_id INT NOT NULL
);
GO

CREATE TABLE CARRITO (
    carrito_id INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id INT NOT NULL,
    fecha_creacion DATETIME2 NOT NULL DEFAULT GETDATE(),
    estado_carrito VARCHAR(20) NOT NULL DEFAULT 'Pendiente'
);
GO

CREATE TABLE ITEMS_CARRITO (
    item_carrito_id INT IDENTITY(1,1) PRIMARY KEY,
    carrito_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad_ic INT NOT NULL
);
GO

CREATE TABLE METODOS_PAGO (
    metodo_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_metodo VARCHAR(50) NOT NULL,
    descripcion_mp VARCHAR(MAX)
);
GO

CREATE TABLE PEDIDO (
    pedido_id INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id INT NOT NULL,
    metodo_pago_id INT NOT NULL,
    fecha_pedido DATETIME2 NOT NULL DEFAULT GETDATE(),
    monto_total DECIMAL(10, 2) NOT NULL,
    estado_pedido VARCHAR(50) NOT NULL DEFAULT 'Completado'
);
GO

CREATE TABLE DETALLE_PEDIDO (
    detalle_id INT IDENTITY(1,1) PRIMARY KEY,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad_dp INT NOT NULL,
    precio_unitario_congelado DECIMAL(10, 2) NOT NULL
);
GO