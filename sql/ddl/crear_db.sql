-- =============================================================================
-- ESQUEMA DDL (Completo con Restricciones): SkyTech Store
-- Equipo:64 (Restricciones e Integridad Referencial)
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

-- -----------------------------------------------------------------------------
-- 2. INCORPORACIÓN DE RESTRICCIONES (CONSTRAINTS) - INTEGRANTE 3
-- -----------------------------------------------------------------------------

-- Restricciones de Unicidad (UQ) y Formato (CHECK)
ALTER TABLE USUARIO 
    ADD CONSTRAINT uq_usuarios_email UNIQUE (email),
        CONSTRAINT chk_email_formato CHECK (email LIKE '%@%.%');

ALTER TABLE CATEGORIA 
    ADD CONSTRAINT uq_categorias_nombre UNIQUE (nombre_categoria);

ALTER TABLE PRODUCTO 
    ADD CONSTRAINT uq_productos_sku UNIQUE (sku),
        CONSTRAINT chk_precio_actual CHECK (precio_actual >= 0),
        CONSTRAINT chk_stock CHECK (stock >= 0);

ALTER TABLE METODOS_PAGO 
    ADD CONSTRAINT uq_metodospago_nombre UNIQUE (nombre_metodo);

ALTER TABLE CARRITO 
    ADD CONSTRAINT chk_estado_carrito CHECK (estado_carrito IN ('Pendiente', 'Procesado', 'Cancelado'));

ALTER TABLE ITEMS_CARRITO 
    ADD CONSTRAINT uk_carrito_producto UNIQUE (carrito_id, producto_id),
        CONSTRAINT chk_cantidad_item_carrito CHECK (cantidad > 0);

ALTER TABLE PEDIDO 
    ADD CONSTRAINT chk_monto_total CHECK (monto_total >= 0);

ALTER TABLE DETALLE_PEDIDO 
    ADD CONSTRAINT chk_cantidad_detalle CHECK (cantidad > 0),
        CONSTRAINT chk_precio_congelado CHECK (precio_unitario_congelado >= 0);
GO

-- Restricciones de Clave Foránea (FK) e Integridad Referencial
ALTER TABLE PRODUCTO 
    ADD CONSTRAINT fk_productos_categorias FOREIGN KEY (categoria_id) 
        REFERENCES CATEGORIAS(categoria_id) 
        ON DELETE NO ACTION ON UPDATE CASCADE;

ALTER TABLE CARRITO 
    ADD CONSTRAINT fk_carritos_usuarios FOREIGN KEY (usuario_id) 
        REFERENCES USUARIOS(usuario_id) 
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE ITEMS_CARRITO 
    ADD CONSTRAINT fk_itemscarrito_carritos FOREIGN KEY (carrito_id) 
        REFERENCES CARRITOS(carrito_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_itemscarrito_productos FOREIGN KEY (producto_id) 
        REFERENCES PRODUCTOS(producto_id) 
        ON DELETE NO ACTION ON UPDATE CASCADE;

ALTER TABLE PEDIDO 
    ADD CONSTRAINT fk_pedidos_usuarios FOREIGN KEY (usuario_id) 
        REFERENCES USUARIOS(usuario_id) 
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_pedidos_metodos_pago FOREIGN KEY (metodo_pago_id) 
        REFERENCES METODOS_PAGO(metodo_id) 
        ON DELETE NO ACTION ON UPDATE CASCADE;

ALTER TABLE DETALLE_PEDIDO 
    ADD CONSTRAINT fk_detallepedido_pedidos FOREIGN KEY (pedido_id) 
        REFERENCES PEDIDOS(pedido_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_detallepedido_productos FOREIGN KEY (producto_id) 
        REFERENCES PRODUCTOS(producto_id) 
        ON DELETE NO ACTION ON UPDATE CASCADE;
GO