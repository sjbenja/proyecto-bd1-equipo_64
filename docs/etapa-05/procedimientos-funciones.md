# Documentación Técnica: Procedimientos y Funciones Almacenadas
**Etapa V — Temas Técnicos**  
**Sistema:** SkyTech Store  
**Responsable:** Vallejos, Gustavo Oscar(Issue #29)  

---


## 1. Definición y Objetivo
Los **Procedimientos Almacenadas (Stored Procedures)** son conjuntos de sentencias T-SQL compiladas y almacenadas en el SGBD que ejecutan lógica de negocio compleja, permitiendo recibir parámetros de entrada y devolver valores. Las **Funciones Almacenadas (Functions)** son rutinas que reciben parámetros y retornan obligatoriamente un valor escalar o una estructura tabular.

## 2. Ventajas y Aplicaciones
* **Centralización de Reglas de Negocio:** Permite cambiar la lógica en la BD sin reestructurar las aplicaciones cliente.
* **Seguridad Avanzada:** Se pueden otorgar permisos de ejecución sobre el SP sin otorgar permisos directos sobre las tablas.
* **Reutilización y Reducción de Tráfico:** Minimiza el volumen de código enviado por la red y evita duplicaciones.

## 3. Implementación en SQL Server Express
Se desarrollaron 3 Stored Procedures de operaciones CRUD y 3 Funciones Almacenadas sobre las tablas `PRODUCTOS`, `USUARIOS` y `PEDIDOS`:

### Procedimientos Creados:
1. `dbo.sp_InsertarProducto`: Valida la categoría e inserta un nuevo registro.
2. `dbo.sp_ModificarProducto`: Actualiza precio y stock de un producto verificando su existencia.
3. `dbo.sp_EliminarProducto`: Controla que el producto no posea ventas previas antes de eliminarlo.

### Funciones Creadas:
1. `dbo.fn_CalcularDescuentoCliente`: Función escalar que retorna 0%, 5% o 10% de descuento según las compras acumuladas.
2. `dbo.fn_ObtenerValorInventarioTotal`: Función escalar que calcula el capital total inmovilizado en stock.
3. `dbo.fn_ObtenerHistorialCliente`: Función valuada en tabla que retorna los pedidos procesados por un usuario.

## 4. Comparación de Eficiencia: Inserción Directa vs. Stored Procedures
Se evaluó el tiempo de CPU y lecturas lógicas ejecutando `SET STATISTICS TIME ON` e `IO ON`

| Criterio | Inserción Directa SQL | Inserción mediante SP |
| :--- | :--- | :--- |
| **Tiempo CPU** | Menor en lotes pequeños estáticos | Optimizado para llamadas repetitivas (plan reutilizado) |
| **Validaciones** | Deben enviarse explícitas en cada query | Encapsuladas y seguras dentro del motor |
| **Seguridad** | Requiere permisos `INSERT` directos | Requiere solo permisos `EXECUTE` |

## 5. Conclusiones
El uso de Procedimientos y Funciones Almacenadas mejora significativamente la seguridad y mantenibilidad de la base de datos de SkyTech Store, garantizando que ninguna inserción o modificación se realice violando las reglas de negocio del e-commerce.