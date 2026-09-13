# Decisiones de Diseño — Etapa I: Requerimientos y Dominio de Negocio

**Proyecto:** SkyTech Store  
**Fecha:** 2026-09-09  

## 1. Selección del Dominio y Alcance
Se optó por un modelo de comercio electrónico (*e-commerce*) enfocado en la comercialización de componentes de hardware y tecnología. La decisión responde a la necesidad de contar con un dominio que permita modelar reglas de negocio estrictas, tales como control de inventario en tiempo real, variantes de productos y transacciones seguras con soporte multicanal de pagos.

Se delimitó explícitamente excluir integraciones externas complejas (como pasarelas de pago de terceros, facturación fiscal mediante AFIP o logística por GPS en tiempo real)[cite: 5] para concentrar el esfuerzo académico en la robustez y normalización de la estructura de datos relacional interna.

## 2. Definición y Justificación de las Reglas de Negocio (RN)
* **Inmutabilidad y Auditoría Comercial (RN 3):** Se priorizó la incorporación de una regla que exija congelar el precio unitario en el detalle de la venta. Esto garantiza que las modificaciones futuras en los precios del catálogo no alteren retrospectivamente los reportes financieros ni las auditorías de pedidos pasados.
* **Consistencia Operativa del Carrito (RN 4):** Se estableció que cada cliente mantenga un único carrito activo en estado `'Pendiente'`. Esta decisión simplifica la experiencia de navegación del usuario y asegura una transición limpia y directa hacia la tabla de pedidos al momento del *checkout*.