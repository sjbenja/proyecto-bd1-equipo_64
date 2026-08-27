# Proyecto BD1 Equipo 64

## Presentación y Contexto

El objetivo central del proyecto es diseñar, normalizar e implementar una base de datos relacional que soporte el ciclo completo de operaciones de venta, garantizando la integridad referencial, la consistencia y la no redundancia de la información.

## Alcance y Restricciones

- **Dominio del problema:** el sistema debe gestionar la venta de productos o servicios (indumentaria, electrónica, repuestos automotores, librería, etc.), pudiendo seleccionarse libremente el dominio específico siempre que satisfaga los requerimientos mínimos establecidos.
- **Límite de tablas:** el modelo debe tener complejidad suficiente para representar el dominio elegido. Como referencia, se espera un esquema de entre **6 y 10 relaciones**, pudiendo justificarse una cantidad diferente según las características del dominio.
- **Nivel de normalización:** el esquema debe alcanzar obligatoriamente la **Tercera Forma Normal (3FN)**.

## Etapas y Entregables

### Etapa I — Requerimientos y Dominio del Negocio
- Descripción del caso: breve introducción al rubro elegido y alcance del sistema.
- Reglas de Negocio (mínimo 6), incluyendo al menos:
  - Gestión de stock
  - Registro de clientes
  - Historial de precios unitarios en el detalle de compra (para evitar cambios retroactivos)
  - Métodos de pago

### Etapa II — Modelado Conceptual y Lógico
- **Diagrama Entidad-Relación (DER):** entidades, atributos, relaciones y cardinalidades (1:1, 1:N, N:M), con notación P. Chen, realizado en ERDPlus.
- **Transformación al Modelo Relacional:** notación de tablas con claves primarias (PK) y foráneas (FK).
- **Proceso de Normalización**, documentado paso a paso:
  - 1FN: eliminación de grupos repetitivos y garantía de atomicidad.
  - 2FN: eliminación de dependencias funcionales parciales en claves compuestas.
  - 3FN: eliminación de dependencias transitivas en atributos no clave.

### Etapa III — Implementación Física (Scripts SQL)
- **Script DDL:** creación de tablas e integridad referencial (`PRIMARY KEY`, `FOREIGN KEY` con reglas de borrado/modificación), definición correcta de tipos de datos (`VARCHAR`, `DECIMAL`, `DATETIME`, etc.) y restricciones (`NOT NULL`, `UNIQUE`, `CHECK`).
- **Script DML:** poblado inicial de la base de datos con al menos 8 a 10 registros coherentes por tabla para pruebas.

### Etapa IV — Consultas y Casos de Uso
- **Factura/Comprobante:** consulta que consolide encabezado y detalle de una venta, calculando sub-totales por renglón y el total acumulado.
- **Reporte Agregado:** total de ventas por vendedor o por categoría de producto en un rango de fechas (`GROUP BY`, `SUM`, `COUNT`).
- **Consulta de Negocio Avanzada:** consulta que combine al menos 3 tablas mediante `JOIN` y aplique filtros condicionales (`HAVING` o subconsultas).

### Etapa V — Implementación de Temas Técnicos
Investigación e implementación de componentes, mecanismos y estructuras que aportan valor crítico para que la base de datos sea robusta, rápida, segura y fácil de mantener a largo plazo.

Para cada tema técnico se debe incluir:
- Descripción breve y fundamentos de aplicación en el caso de estudio.
- Script SQL de implementación en el motor de bases de datos.
- Script SQL o resumen explicativo de demostración de uso.

**Temas técnicos:**
- Procedimientos y funciones almacenadas
- Manejo de transacciones
- Triggers de auditoría
- Seguridad
- Índices (optimización)

## Cronograma

| Etapa | Pregunta que responde | Producto | Fecha de entrega |
|---|---|---|---|
| I. Requerimientos | ¿Qué necesita el negocio? | Requerimientos + reglas | Viernes 04/09 |
| II. Modelado | ¿Cómo representamos la información? | DER + modelo relacional + 3FN | Viernes 11/09 |
| III. Implementación | ¿Cómo construimos la BD? | DDL + DML | Miércoles 30/09 |
| IV. Consultas | ¿Cómo obtenemos información? | SQL + casos de uso | — |
| V. Temas técnicos | ¿Cómo hacemos la solución más robusta? | Procedimientos, funciones, transacciones, triggers, seguridad e índices | — |

## Estructura del proyecto

```
├── README.md                    # Archivo de bienvenida
├── docs/                        # Documentación por etapas
│   ├── etapa-01/                # Etapa 1 - Requerimientos
│   ├── etapa-02/                # Etapa 2 - Modelado
│   ├── etapa-03/                # Etapa 3 - Implementación
│   ├── etapa-04/                # Etapa 4 - Consultas
│   └── etapa-05/                # Etapa 5 - Temas técnicos
├── sql/                         # Scripts SQL
│   ├── ddl/                     # Definición de estructuras
│   ├── dml/                     # Manipulación de datos
│   ├── consultas/               # Consultas SQL
│   └── técnico/                 # Documentación técnica
└── modelos/                     # Modelos de datos
    └── der/                     # Diagrama Entidad-Relación
```
