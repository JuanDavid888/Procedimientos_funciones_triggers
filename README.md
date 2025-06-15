# Ejercicios de **Procedimientos Almacenados**

1. **`ps_add_pizza_con_ingredientes`**
   Crea un procedimiento que inserte una nueva pizza en la tabla `pizza` junto con sus ingredientes en `pizza_ingrediente`.

   - Parámetros de entrada: `p_nombre_pizza`, `p_precio`, lista de `p_ids_ingredientes`.
   - Debe recorrer la lista de ingredientes (cursor o ciclo) y hacer los inserts correspondients.

2. **`ps_actualizar_precio_pizza`**
   Procedimiento que reciba `p_pizza_id` y `p_nuevo_precio` y actualice el precio.

   - Antes de actualizar, valide con un `IF` que el nuevo precio sea mayor que 0; de lo contrario, lance un `SIGNAL`.

3. **`ps_generar_pedido`** *(**usar TRANSACTION**)*
   Procedimiento que reciba:

   - `p_cliente_id`,
   - una lista de pizzas y cantidades (`p_items`),
   - `p_metodo_pago_id`.
     **Dentro de una transacción**:

   1. Inserta en `pedido`.
   2. Para cada ítem, inserta en `detalle_pedido` y en `detalle_pedido_pizza`.
   3. Si todo va bien, hace `COMMIT`; si falla, `ROLLBACK` y devuelve un mensaje de error.

4. **`ps_cancelar_pedido`**
   Recibe `p_pedido_id` y:

   - Marca el pedido como “cancelado” (p. ej. actualiza un campo `estado`),
   - Elimina todas sus líneas de detalle (`DELETE FROM detalle_pedido WHERE pedido_id = …`).
   - Devuelve el número de líneas eliminadas.

5. **`ps_facturar_pedido`**
   Crea la factura asociada a un pedido dado (`p_pedido_id`). Debe:

   - Calcular el total sumando precios de pizzas × cantidad,
   - Insertar en `factura`.
   - Devolver el `factura_id` generado.

------

## Ejercicios de **Funciones** 

1. **`fc_calcular_subtotal_pizza`**
   - Parámetro: `p_pizza_id`
   - Retorna el precio base de la pizza más la suma de precios de sus ingredientes.
2. **`fc_descuento_por_cantidad`**
   - Parámetros: `p_cantidad INT`, `p_precio_unitario DECIMAL`
   - Si `p_cantidad ≥ 5` aplica 10% de descuento, sino 0%. Retorna el monto de descuento.
3. **`fc_precio_final_pedido`**
   - Parámetros: `p_pedido_id INT`
   - Usa `calcular_subtotal_pizza` y `descuento_por_cantidad` para devolver el total a pagar.
4. **`fc_obtener_stock_ingrediente`**
   - Parámetro: `p_ingrediente_id INT`
   - Retorna el stock disponible del ingrediente.
5. **`fc_es_pizza_popular`**
   - Parámetro: `p_pizza_id INT`
   - Retorna `1` si la pizza ha sido pedida más de 50 veces (contando en `detalle_pedido_pizza`), sino `0`.

------

##  Ejercicios de **Triggers** 

1. **`tg_before_insert_detalle_pedido`**
   - `BEFORE INSERT` en `detalle_pedido`
   - Valida que la cantidad sea ≥ 1; si no, `SIGNAL` de error.
2. **`tg_after_insert_detalle_pedido_pizza`**
   - `AFTER INSERT` en `detalle_pedido_pizza`
   - Disminuye el `stock` correspondiente en `ingrediente` según la receta de la pizza.
3. **`tg_after_update_pizza_precio`**
   - `AFTER UPDATE` en `pizza`
   - Inserta en una tabla `auditoria_precios` la pizza_id, precio antiguo y nuevo, y timestamp.
4. **`tg_before_delete_pizza`**
   - `BEFORE DELETE` en `pizza`
   - Impide borrar si la pizza aparece en algún `detalle_pedido_pizza` (lanza `SIGNAL`).
5. **`tg_after_insert_factura`**
   - `AFTER INSERT` en `factura`
   - Actualiza el pedido asociado marcándolo como “facturado”.
6. **`tg_after_delete_detalle_pedido_pizza`**
   - `AFTER DELETE`
   - Restaura el stock de los ingredientes de la pizza eliminada en detalle.
7. **`tg_after_update_ingrediente_stock`**
   - `AFTER UPDATE` en `ingrediente`
   - Si el stock cae por debajo de 10 unidades, inserta una alerta en `notificacion_stock_bajo`.