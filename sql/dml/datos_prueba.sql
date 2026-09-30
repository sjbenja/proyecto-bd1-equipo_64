-- =============================================================================
-- ESQUEMA DML: Poblamiento Inicial de Prueba (SkyTech Store)
-- Mínimo 10 Registros Coherentes por Tabla (Microsoft SQL Server)
-- =============================================================================

USE skytech_store;
GO

-- 1. POBLAMIENTO: USUARIOS (10 Registros)
INSERT INTO USUARIO (nombre, apellido, email, fecha_registro) VALUES
('Juan', 'Gómez', 'juan.gomez@email.com', '2026-01-10'),
('María', 'Fernández', 'maria.fernandez@email.com', '2026-01-15'),
('Carlos', 'López', 'carlos.lopez@email.com', '2026-02-01'),
('Ana', 'Martínez', 'ana.martinez@email.com', '2026-02-20'),
('Lucas', 'Rodríguez', 'lucas.rodriguez@email.com', '2026-03-05'),
('Laura', 'Sánchez', 'laura.sanchez@email.com', '2026-03-12'),
('Diego', 'Pérez', 'diego.perez@email.com', '2026-04-01'),
('Sofia', 'Díaz', 'sofia.diaz@email.com', '2026-04-18'),
('Martín', 'Romero', 'martin.romero@email.com', '2026-05-02'),
('Valentina', 'Torres', 'valentina.torres@email.com', '2026-05-25');
GO

-- 2. POBLAMIENTO: CATEGORIAS (10 Registros)
INSERT INTO CATEGORIA (nombre_categoria, descripcion_categoria) VALUES
('Procesadores', 'CPUs Intel y AMD de última generación'),
('Placas de Video', 'GPUs para gaming, renderizado e inteligencia artificial'),
('Memorias RAM', 'Módulos DDR4 y DDR5 de alta frecuencia'),
('Almacenamiento', 'Discos SSD NVMe M.2 y HDD de alta capacidad'),
('Placas Madre', 'Motherboards Socket AM4, AM5, LGA1700 y LGA1851'),
('Fuentes de Alimentación', 'Fuentes certificadas 80 Plus Bronze, Gold y Platinum'),
('Gabinetes', 'Chasis ATX, Micro-ATX y ITX con flujo de aire optimizado'),
('Refrigeración', 'Coolers por aire y sistemas de refrigeración líquida AIO'),
('Periféricos', 'Teclados mecánicos, mouses ópticos y auriculares'),
('Monitores', 'Pantallas IPS, OLED y VA de alta tasa de refresco');
GO

-- 3. POBLAMIENTO: PRODUCTOS (10 Registros)
INSERT INTO PRODUCTO (sku, nombre_producto, descripcion_producto, precio_actual, stock, categoria_id) VALUES
('CPU-AMD-5700G', 'AMD Ryzen 7 5700G', '8 núcleos, 16 hilos, Vega 8 Graphics', 245000.00, 15, 1),
('GPU-RX-550', 'AMD Radeon RX 550 4GB', 'GPU discreta 4GB GDDR5 Low Profile', 115000.00, 8, 2),
('RAM-DDR4-32GB', 'Kingston Fury Beast 32GB DDR4', 'Kit 2x16GB 3200MHz CL16', 98000.00, 25, 3),
('SSD-NVME-2TB', 'Kingston NV2 2TB NVMe M.2', 'Lectura hasta 3500 MB/s PCIe 4.0', 145000.00, 20, 4),
('MB-ASUS-B85M', 'ASUS B85M-E LGA1150', 'Motherboard Micro-ATX Dual Channel', 65000.00, 5, 5),
('PSU-80G-750W', 'Gigabyte UD750GM 750W 80+ Gold', 'Fuente full modular con condensadores japoneses', 132000.00, 12, 6),
('GAB-COR-4000D', 'Corsair 4000D Airflow', 'Gabinete Mid-Tower con panel de vidrio templado', 110000.00, 10, 7),
('COOL-AK620', 'DeepCool AK620 Dual Tower', 'Disipador por aire de doble torre TDP 260W', 85000.00, 18, 8),
('KEY-LOGI-GPRO', 'Logitech G PRO X Mechanical', 'Teclado mecánico para eSports con switches GX', 125000.00, 14, 9),
('MON-LG-27GP', 'LG UltraGear 27" 144Hz IPS', 'Monitor Gaming 1ms G-Sync Compatible', 310000.00, 7, 10);
GO

-- 4. POBLAMIENTO: METODOS_PAGO (10 Registros)
INSERT INTO METODO_PAGO (nombre_metodo, descripcion_mp) VALUES
('Tarjeta de Crédito', 'Pago en hasta 12 cuotas fijas vía pasarela bancaria'),
('Tarjeta de Débito', 'Débito inmediato de cuenta corriente o caja de ahorro'),
('Transferencia Bancaria', 'Transferencia CBU/CVU directa con 10% de descuento'),
('Mercado Pago', 'Pago con saldo en cuenta o tarjetas asociadas'),
('Efectivo / Rapipago', 'Abono en sucursal con comprobante impreso'),
('Efectivo / Pago Fácil', 'Pago presencial en red Pago Fácil'),
('Criptomonedas (USDT)', 'Transferencia mediante red TRC20 o BEP20'),
('Crédito de la Casa', 'Financiación directa previa evaluación crediticia'),
('Modo', 'Transferencia instantánea mediante código QR MODO'),
('Cuenta DNI', 'Abono con promociones del Banco Provincia');
GO

-- 5. POBLAMIENTO: CARRITOS (10 Registros)
INSERT INTO CARRITO (usuario_id, fecha_creacion, estado_carrito) VALUES
(1, '2026-09-01 10:15:00', 'Procesado'),
(2, '2026-09-02 11:30:00', 'Procesado'),
(3, '2026-09-05 14:20:00', 'Procesado'),
(4, '2026-09-10 16:45:00', 'Procesado'),
(5, '2026-09-12 09:10:00', 'Procesado'),
(6, '2026-09-15 18:00:00', 'Pendiente'),
(7, '2026-09-18 20:25:00', 'Pendiente'),
(8, '2026-09-20 12:40:00', 'Pendiente'),
(9, '2026-09-22 15:05:00', 'Cancelado'),
(10, '2026-09-25 17:50:00', 'Pendiente');
GO

-- 6. POBLAMIENTO: ITEMS_CARRITO (10 Registros)
INSERT INTO ITEM_CARRITO (carrito_id, producto_id, cantidad_ic) VALUES
(1, 1, 1),
(1, 3, 2),
(2, 4, 1),
(3, 2, 1),
(4, 6, 1),
(5, 7, 1),
(6, 9, 1),
(7, 10, 1),
(8, 8, 2),
(10, 5, 1);
GO

-- 7. POBLAMIENTO: PEDIDOS (10 Registros)
INSERT INTO PEDIDO (usuario_id, metodo_pago_id, fecha_pedido, monto_total, estado_pedido) VALUES
(1, 3, '2026-09-01 10:20:00', 441000.00, 'Completado'),
(2, 1, '2026-09-02 11:35:00', 145000.00, 'Completado'),
(3, 4, '2026-09-05 14:25:00', 115000.00, 'Completado'),
(4, 2, '2026-09-10 16:50:00', 132000.00, 'Completado'),
(5, 3, '2026-09-12 09:15:00', 110000.00, 'Completado'),
(1, 1, '2026-09-14 15:30:00', 310000.00, 'Completado'),
(2, 3, '2026-09-16 11:00:00', 250000.00, 'Completado'),
(3, 9, '2026-09-19 13:15:00', 245000.00, 'Completado'),
(4, 4, '2026-09-21 16:40:00', 170000.00, 'Completado'),
(5, 7, '2026-09-24 10:05:00', 264000.00, 'Completado');
GO

-- 8. POBLAMIENTO: DETALLE_PEDIDO (10 Registros)
INSERT INTO DETALLE_PEDIDO (pedido_id, producto_id, cantidad_dp, precio_unitario_congelado) VALUES
(1, 1, 1, 245000.00),
(1, 3, 2, 98000.00),
(2, 4, 1, 145000.00),
(3, 2, 1, 115000.00),
(4, 6, 1, 132000.00),
(5, 7, 1, 110000.00),
(6, 10, 1, 310000.00),
(7, 9, 2, 125000.00),
(8, 1, 1, 245000.00),
(9, 8, 2, 85000.00);
GO