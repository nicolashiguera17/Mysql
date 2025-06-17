# 🍕 Proyecto SQL - Pizzería "Pizza Fiesta"

Este repositorio contiene una serie de **ejercicios prácticos** enfocados en el uso de **procedimientos almacenados**, **funciones** y **triggers** en MySQL, aplicados al contexto de una base de datos de una pizzería.

---

## 📦 Estructura de la Base de Datos

La base de datos simula las operaciones de una pizzería real, permitiendo:

- Registrar clientes, pedidos y facturas.
- Manejar productos (pizzas, combos, bebidas).
- Controlar ingredientes y stock.
- Aplicar descuentos, auditar precios, y más.

> 📌 Incluye datos de prueba preinsertados para pruebas inmediatas.

Puedes ver el diagrama ER aquí:  
📷 *(Agrega una imagen del diagrama ER aquí si lo deseas)*

---

## 🛠️ Procedimientos Almacenados

| Procedimiento | Descripción |
|--------------|-------------|
| `ps_add_pizza_con_ingredientes` | Inserta una pizza junto con sus ingredientes. |
| `ps_actualizar_precio_pizza` | Actualiza el precio de una pizza validando que sea > 0. |
| `ps_generar_pedido` | Crea un pedido completo con detalles y método de pago (usa transacción). |
| `ps_cancelar_pedido` | Cancela un pedido y elimina los detalles relacionados. |
| `ps_facturar_pedido` | Genera la factura de un pedido y devuelve su ID. |

---

## 🧮 Funciones

| Función | Descripción |
|--------|-------------|
| `fc_calcular_subtotal_pizza` | Calcula el precio base + ingredientes. |
| `fc_descuento_por_cantidad` | Aplica descuento si la cantidad es ≥ 5. |
| `fc_precio_final_pedido` | Calcula el precio total considerando descuentos. |
| `fc_obtener_stock_ingrediente` | Devuelve el stock de un ingrediente. |
| `fc_es_pizza_popular` | Devuelve 1 si una pizza se ha pedido más de 50 veces. |

---

## 🧱 Tablas Principales

- `cliente`, `pedido`, `factura`
- `producto`, `producto_presentacion`, `ingrediente`
- `detalle_pedido`, `detalle_pedido_producto`, `detalle_pedido_combo`
- `combo`, `combo_producto`
- `ingredientes_extra`, `tipo_producto`, `presentacion`
- *(y más...)*

---

## ▶️ Cómo usar este proyecto

1. **Importa la base de datos**:  
   Ejecuta el script SQL incluido para crear todas las tablas y poblar datos.

2. **Ejecuta los ejercicios**:  
   Puedes probar los procedimientos y funciones usando `CALL`.

---



