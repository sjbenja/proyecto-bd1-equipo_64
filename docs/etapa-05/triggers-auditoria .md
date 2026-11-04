# Documentación Técnica: Triggers de Auditoría y Protección de Datos
**Etapa V — Temas Técnicos**  
**Sistema:** SkyTech Store  


---

## 1. Definición y Objetivo
Los **Triggers (Disparadores)** son procedimientos almacenados especiales que se ejecutan de manera automática en respuesta a eventos de manipulación de datos (`INSERT`, `UPDATE`, `DELETE`) sobre una tabla o vista específica[cite: 20, 23]. Su objetivo principal es garantizar la trazabilidad mediante registros de auditoría y aplicar reglas de validación complejas o restricciones de seguridad preventivas.

## 2. Ventajas y Aplicaciones
* **Trazabilidad Inalterable:** Responde de forma automática a preguntas críticas como: *¿Quién modificó un registro?*, *¿Cuándo ocurrió?* y *¿Cuáles eran los valores anteriores?*
* **Protección de Datos Sensibles:** Los triggers de tipo `INSTEAD OF` permiten interceptar operaciones destructivas (como el borrado físico de datos maestros) para cancelarlas o redirigirlas a procesos seguros.
* **Independencia de la Aplicación:** Al residir directamente en el motor de base de datos, la auditoría y control se ejecutan sin importar desde qué sistema o interfaz se envíe la consulta SQL.

## 3. Implementación en SQL Server Express
Se implementaron dos tipos de triggers sobre el esquema de **SkyTech Store**:
1. **Trigger `AFTER UPDATE, DELETE` (`dbo.TR_AuditoriaProductos`):** Captura los cambios a través de las tablas virtuales `inserted` y `deleted`, volcando la información del estado anterior, nuevo usuario (`ORIGINAL_LOGIN()`) y fecha exacta (`SYSDATETIME()`) en la tabla auxiliar `AUDITORIA_PRODUCTOS`.
2. **Trigger `INSTEAD OF DELETE` (`dbo.TR_PrevenirBorradoCategorias`):** Intercepta cualquier intento de borrado sobre la tabla `CATEGORIAS`, cancelando la transacción y emitiendo un mensaje de advertencia formal.

## 4. Casos de Prueba y Resultados Obtenidos

| Caso de Prueba | Acción Ejecutada | Comportamiento del Motor | Resultado Obtenido |
| :--- | :--- | :--- | :--- |
| **1. Auditoría de Modificación** | `UPDATE PRODUCTOS` (Cambio de precio) | Ejecución del trigger `AFTER UPDATE` | Registro automático insertado en `AUDITORIA_PRODUCTOS` con precio viejo, precio nuevo y usuario. |
| **2. Protección Restrictiva** | `DELETE FROM CATEGORIAS` | Activación del trigger `INSTEAD OF DELETE` | Operación cancelada, mensaje de error personalizado emitido. |

## 5. Conclusiones
La incorporación de triggers de auditoría y protección en **SkyTech Store** eleva significativamente el nivel de seguridad y cumplimiento normativo. Permite un monitoreo transparente de los cambios críticos de inventario y previene eliminaciones accidentales de información estructural clave.