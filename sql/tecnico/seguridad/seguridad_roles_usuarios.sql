-- =============================================================================
-- ESQUEMA: SkyTech Store - Etapa V
-- TEMA TÉCNICO: Seguridad, Usuarios, Roles y Permisos Granulares
-- ARCHIVO: sql/tecnico/seguridad/seguridad_roles_usuarios.sql
-- SGBD: Microsoft SQL Server (T-SQL) - Modo Mixto Requerido
-- =============================================================================

USE skytech_store;
GO

-- =============================================================================
-- PARTE 1: CREACIÓN DE LOGINS Y USUARIOS DE BASE DE DATOS
-- =============================================================================

-- 1.1 Creación de Inicios de Sesión (Logins) con Autenticación de SQL Server
CREATE LOGIN usuario_admin WITH PASSWORD = 'Admin123*';
CREATE LOGIN usuario_lector WITH PASSWORD = 'Lector123*';
GO

-- 1.2 Creación de Usuarios de Base de Datos asociados a los Logins
CREATE USER usuario_admin FOR LOGIN usuario_admin;
CREATE USER usuario_lector FOR LOGIN usuario_lector;
GO

-- =============================================================================
-- PARTE 2: ASIGNACIÓN DE PERMISOS (USUARIOS)
-- =============================================================================

-- 2.1 Asignación de privilegios administrativos al usuario administrador
ALTER ROLE db_owner ADD MEMBER usuario_admin;
GO

-- 2.2 Asignación de permisos de solo lectura al usuario lector sobre las tablas
GRANT SELECT ON dbo.USUARIOS TO usuario_lector;
GRANT SELECT ON dbo.PRODUCTO TO usuario_lector;
GRANT SELECT ON dbo.CATEGORIA TO usuario_lector;
GO

-- 2.3 Permiso específico de ejecución sobre un Procedimiento Almacenado de ventas
-- (Asumiendo que el SP de inserción se llama sp_RegistrarVentaSimple o equivalente)
-- GRANT EXECUTE ON dbo.sp_RegistrarVentaSimple TO usuario_lector;
-- GO


-- =============================================================================
-- PARTE 3: PRUEBAS DE COMPORTAMIENTO (USUARIOS)
-- =============================================================================

/*
-- PRUEBA 3.1: INSERT directo con usuario administrador (EJECUTAR CON USUARIO_ADMIN)
-- Resultado esperado: Éxito (cuenta con privilegios db_owner)
EXECUTE AS USER = 'usuario_admin';
INSERT INTO USUARIOS (nombre, apellido, email, telefono, password_hash)
VALUES ('Admin', 'Test', 'admin.test@skytech.online', '3794000000', 'hash_falso');
REVERT;
GO

-- PRUEBA 3.2: INSERT directo con usuario lector (EJECUTAR CON USUARIO_LECTOR)
-- Resultado esperado: RECHAZADO por SQL Server por falta de permisos de inserción.
EXECUTE AS USER = 'usuario_lector';
INSERT INTO USUARIOS (nombre, apellido, email, telefono, password_hash)
VALUES ('Lector', 'Test', 'lector.test@skytech.online', '3794111111', 'hash_falso');
REVERT;
GO
*/


-- =============================================================================
-- PARTE 4: PERMISOS A NIVEL DE ROLES PERSONALIZADOS DEL DBMS
-- =============================================================================

-- 4.1 Creación de Logins y Usuarios adicionales para la prueba de roles
CREATE LOGIN usuario_con_rol WITH PASSWORD = 'Rol123*';
CREATE LOGIN usuario_sin_rol WITH PASSWORD = 'Rol456*';
GO

CREATE USER usuario_con_rol FOR LOGIN usuario_con_rol;
CREATE USER usuario_sin_rol FOR LOGIN usuario_sin_rol;
GO

-- 4.2 Creación de un Rol de Base de Datos personalizado
CREATE ROLE rol_consulta_productos;
GO

-- 4.3 Asignación de permisos específicos al rol (ej. solo lectura sobre PRODUCTO)
GRANT SELECT ON dbo.PRODUCTO TO rol_consulta_productos;
GO

-- 4.4 Incorporación de usuario al rol personalizado
ALTER ROLE rol_consulta_productos ADD MEMBER usuario_con_rol;
GO


-- =============================================================================
-- PARTE 5: PRUEBAS DE COMPORTAMIENTO (ROLES)
-- =============================================================================

/*
-- PRUEBA 5.1: Consulta SELECT con usuario que POSEE el rol
-- Resultado esperado: Consulta exitosa
EXECUTE AS USER = 'usuario_con_rol';
SELECT SKU, nombre, precio_actual FROM dbo.PRODUCTO;
REVERT;
GO

-- PRUEBA 5.2: Consulta SELECT con usuario que NO POSEE el rol
-- Resultado esperado: Denegado / Error de permisos
EXECUTE AS USER = 'usuario_sin_rol';
SELECT SKU, nombre, precio_actual FROM dbo.PRODUCTO;
REVERT;
GO
