-- Active: 1750195161481@@127.0.0.1@3307@pizzeria

SHOW TABLES;

-- 1
DELIMITER $$

DROP FUNCTION IF EXISTS fn_calcular_subtotal_pizza $$

CREATE FUNCTION fn_calcular_subtotal_pizza(
    p_pro_pre_id INT
)
RETURNS DECIMAL(10,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE p_producto_id INT;
    DECLARE p_subtotal DECIMAL(10,2);
    DECLARE p_precio_base DECIMAL(10,2);
    DECLARE p_precio_ingredientes DECIMAL(10,2);

    IF NOT EXISTS (
        SELECT 1 FROM producto_presentacion 
        WHERE id = p_pro_pre_id) THEN
        SIGNAL SQLSTATE '40002'
            SET MESSAGE_TEXT = 'La presentacion seleccionada no existe.'; -- Verfica que exista en alguna fila, si no, lanza error
    END IF;    

    SET p_producto_id = (
        SELECT producto_id FROM producto_presentacion
        WHERE id = p_pro_pre_id
    );

    SET p_precio_base = (
        SELECT precio FROM producto_presentacion
        WHERE id = p_pro_pre_id
    );

    SET p_precio_ingredientes = (
        SELECT SUM(ing.precio) FROM ingrediente ing
        JOIN ingrediente_producto ing_pro ON ing.id = ing_pro.ingrediente_id
        WHERE ing_pro.producto_id = p_producto_id
    );

    SET p_subtotal = p_precio_base + p_precio_ingredientes;

    RETURN p_subtotal;
END $$

DELIMITER ;

SELECT fn_calcular_subtotal_pizza(4) AS subtotal;

SELECT 
    pro.nombre AS Producto,
    pre.nombre AS Presentacion,
    pro_pre.precio AS Precio_Producto,
    SUM(ing.precio) AS Precio_Ingrediente
FROM producto pro
JOIN producto_presentacion pro_pre ON pro_pre.producto_id = pro.id
JOIN presentacion pre ON pre.id = pro_pre.presentacion_id
JOIN ingrediente ing
JOIN ingrediente_producto ing_pro ON ing.id = ing_pro.ingrediente_id
WHERE pro.id = 2 AND pro_pre.id = 4
GROUP BY Producto, Presentacion, Precio_Producto;

-- 2
DELIMITER $$

DROP FUNCTION IF EXISTS fn_descuento_por_cantidad $$

CREATE FUNCTION fn_descuento_por_cantidad(
    p_cantidad INT,
    p_precio_unitario DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE descuento DECIMAL(10,2);
    DECLARE total_final DECIMAL(10,2);

    IF p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '40001'
            SET MESSAGE_TEXT = 'La cantidad debe ser mayor a 0'; -- Verifica que la cantidad este positiva, si no, muestra error
    END IF;

    IF p_precio_unitario <= 0 THEN
        SIGNAL SQLSTATE '40001'
            SET MESSAGE_TEXT = 'El precio debe ser mayor a 0'; -- Verifica que el precio este positivo, si no, muestra error
    END IF;

    SET total = p_cantidad * p_precio_unitario;

    IF p_cantidad >= 5 THEN
        SET descuento = total * 0.10;
    ELSE
        SET descuento = 0.00;
    END IF;

    SET total_final = total - descuento;

    RETURN total_final;

END $$

DELIMITER ;

SELECT fn_descuento_por_cantidad(6,5000) AS Total;

SELECT 6 * 5000 AS total -- Revisar valores totales sin descuento

-- 3
DELIMITER $$

DROP FUNCTION IF EXISTS fn_precio_final_pedido $$

CREATE FUNCTION fn_precio_final_pedido(
    p_pedido_id INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE p_producto INT;
    DECLARE p_precio DECIMAL(10,2);
    DECLARE descuento DECIMAL(10,2);
    DECLARE p_cantidad INT;

    IF NOT EXISTS (SELECT 1 FROM pedido WHERE id = p_pedido_id) THEN
        SIGNAL SQLSTATE '40002'
            SET MESSAGE_TEXT = 'El pedido seleccionado no existe'; -- Verfica que exista en alguna fila, si no, lanza error
    END IF;

    SET p_producto = (
        SELECT producto_presentacion_id FROM detalle_pedido
        WHERE pedido_id = p_pedido_id
    );

    SET p_cantidad = (
        SELECT cantidad FROM detalle_pedido
        WHERE pedido_id = p_pedido_id
    );

    SET p_precio = fn_calcular_subtotal_pizza(p_producto);

    SET descuento = fn_descuento_por_cantidad(p_cantidad, p_precio);

    RETURN descuento;

END $$

DELIMITER ;

SELECT fn_precio_final_pedido(3) AS Total;

-- 4
DELIMITER $$

DROP FUNCTION IF EXISTS fn_obtener_stock_ingrediente $$

CREATE FUNCTION fn_obtener_stock_ingrediente(
    p_ingrediente_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE p_stock INT;

    IF NOT EXISTS (SELECT 1 FROM ingrediente WHERE id = p_ingrediente_id) THEN
        SIGNAL SQLSTATE '40002'
            SET MESSAGE_TEXT = 'El pedido seleccionado no existe'; -- Verfica que exista en alguna fila, si no, lanza error
    END IF;

    SET p_stock = (
        SELECT stock FROM ingrediente
        WHERE id = p_ingrediente_id
    );

    RETURN p_stock;

END $$

DELIMITER ;

SELECT fn_obtener_stock_ingrediente(1) AS Stock_Ingrediente;

-- 5
DELIMITER $$

DROP FUNCTION IF EXISTS fn_es_pizza_popular $$

CREATE FUNCTION fn_es_pizza_popular(
    p_producto_id INT
)
RETURNS BIT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE p_popular BIT;

    IF NOT EXISTS (SELECT 1 FROM producto_presentacion WHERE id = p_producto_id) THEN
        SIGNAL SQLSTATE '40002'
            SET MESSAGE_TEXT = 'El producto seleccionado no existe'; -- Verfica que exista en alguna fila, si no, lanza error
    END IF;

    IF (
        SELECT SUM(LENGTH(pro_pre.producto_id)) * dp.cantidad AS Producto_Comprado
        FROM producto_presentacion pro_pre
        JOIN detalle_pedido dp ON pro_pre.id = dp.producto_presentacion_id
        WHERE pro_pre.producto_id = p_producto_id
        ) > 50 THEN
        SET p_popular = 1;
    ELSE
        SET p_popular = 0;
    END IF;

    RETURN p_popular;

END $$

DELIMITER ;

SELECT fn_es_pizza_popular(2) AS Pizza_Popular;

SELECT pro_pre.producto_id, SUM(LENGTH(pro_pre.producto_id) * dp.cantidad) AS Veces_Comprado 
FROM producto_presentacion pro_pre
JOIN detalle_pedido dp ON pro_pre.id = dp.producto_presentacion_id
WHERE pro_pre.producto_id = 2