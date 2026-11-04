# Documentación Técnica: Seguridad y Control de Acceso
**Etapa V — Temas Técnicos**  
**Sistema:** SkyTech Store  

---

## 1. Definición y Objetivo
La seguridad en bases de datos comprende el conjunto de mecanismos destinados a proteger la información almacenada contra accesos no autorizados, modificaciones accidentales o revelaciones indebidas. En Microsoft SQL Server, esto se logra mediante la administración jerárquica de **Inicios de Sesión (Logins)**, **Usuarios de Base de Datos**, **Roles del Sistema/Personalizados** y el control granular de privilegios (`GRANT`, `DENY`, `REVOKE`), aplicando rigurosamente el **Principio de Menor Privilegio**.

## 2. Ventajas y Aplicaciones
* **Protección de Datos Sensibles:** Restringe la visibilidad de información crítica (datos de clientes, transacciones financieras) exclusivamente al personal autorizado.
* **Integridad Operativa:** Evita que usuarios con perfiles operativos realicen modificaciones directas sobre las tablas relacionales (`INSERT`, `UPDATE`, `DELETE`), forzando el uso de procedimientos almacenados que validan la lógica de negocio.
* **Mantenibilidad Simplificada:** La asignación de permisos mediante roles personalizados permite administrar grupos de usuarios de forma centralizada en lugar de gestionar privilegios de manera individual.

## 3. Implementación en SQL Server Express
El motor se configuró previamente en **Modo Mixto** (permitiendo tanto Autenticación de Windows como Autenticación de SQL Server). Se procedió a estructurar la seguridad en dos niveles:
1. **Nivel de Usuarios y Procedimientos:** Creación de `usuario_admin` (con control total mediante `db_owner`) y `usuario_lector` (con permisos de consulta restringidos y habilitación selectiva de ejecución sobre lógica de negocio mediante Stored Procedures).
2. **Nivel de Roles Personalizados:** Creación del rol `rol_consulta_productos` para otorgar acceso selectivo al catálogo de productos sin otorgar privilegios sobre el resto del esquema relacional.

## 4. Caso Concreto Aplicado a SkyTech Store
En el e-commerce de hardware, los clientes no deben tener acceso directo a la modificación de las tablas maestras de inventario ni de usuarios. Los administradores operan con control total, mientras que los perfiles de auditoría o consulta operan bajo restricciones estrictas de lectura y ejecución controlada.

## 5. Pruebas de Demostración y Resultados Obtenidos

| Prueba | Perfil / Usuario | Acción Ejecutada | Resultado Esperado | Resultado Obtenido |
| :--- | :--- | :--- | :--- | :--- |
| **1. Insert Directo** | `usuario_admin` | `INSERT` directo en `USUARIOS` | Operación exitosa (`db_owner`) | ✅ Exitoso |
| **2. Insert Directo** | `usuario_lector` | `INSERT` directo en `USUARIOS` | Rechazado por falta de permisos | ✅ Denegado (Error de permisos) |
| **3. Consulta con Rol** | `usuario_con_rol` | `SELECT` sobre `PRODUCTO` | Consulta exitosa (miembro del rol) | ✅ Exitoso |
| **4. Consulta sin Rol** | `usuario_sin_rol` | `SELECT` sobre `PRODUCTO` | Acceso denegado | ✅ Denegado (Error de permisos) |

## 6. Conclusiones
La implementación de esquemas de seguridad basados en usuarios, roles y privilegios granulares en SQL Server garantiza que la base de datos de **SkyTech Store** mantenga su consistencia y confidencialidad. El uso combinado de permisos sobre tablas y la delegación a través de Stored Procedures demuestra ser la estrategia más robusta para entornos de producción e-commerce.