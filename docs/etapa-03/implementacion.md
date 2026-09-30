# Especificación de Implementación Física (SQL Server / T-SQL)

## 1. Entorno de Ejecución y SGBD
- **SGBD:** Microsoft SQL Server (2019 / 2022 / Azure SQL)
- **Dialecto:** T-SQL (Transact-SQL)
- **Herramientas de Administración:** SQL Server Management Studio (SSMS) / Azure Data Studio / VS Code (SQL Server Extension)
- **Cotejo / Collation:** `Modern_Spanish_CI_AS` (Case-Insensitive, Accent-Sensitive)

## 2. Decisión de Tipos de Datos y Claves Primarias
* **Identificadores Autoincrementales:** Se utilizó el atributo `IDENTITY(1,1)` en todas las claves primarias numéricas simples para garantizar la generación automática de secuencia de IDs únicos.
* **Precios y Montos:** Se utilizó el tipo de dato `DECIMAL(10,2)` para evitar imprecisiones de redondeo asociadas a tipos de coma flotante (`FLOAT` / `REAL`), garantizando el control exacto de valores monetarios.
* **Campos de Texto Libre:** Se configuraron tipos `VARCHAR(MAX)` para descripciones extensas (`CATEGORIAS`, `PRODUCTOS`, `METODOS_PAGO`) y `VARCHAR(n)` con límites estrictos para identificadores como SKU y direcciones de e-mail.
* **Fechas y Tiempos de Auditoría:** Se implementó `DATETIME2` para registros con marca temporal exacta (`CARRITOS`, `PEDIDOS`) y `DATE` con valor por defecto `CAST(GETDATE() AS DATE)` para la fecha de registro de usuarios.

## 3. Estructura de Capas e Inmutabilidad Financiera (RN 3)
El esquema físico modela explícitamente la separación entre la intención de compra transitoria (`CARRITOS` e `ITEMS_CARRITO`) y la transacción comercial en firme (`PEDIDOS` y `DETALLE_PEDIDO`). 

En la tabla `DETALLE_PEDIDO`, la columna `precio_unitario_congelado DECIMAL(10,2)` almacena una copia del precio del producto al momento exacto de la confirmación del pedido. Esto asegura que futuras modificaciones en `PRODUCTOS.precio_actual` no alteren retroactivamente el monto histórico devengado.
