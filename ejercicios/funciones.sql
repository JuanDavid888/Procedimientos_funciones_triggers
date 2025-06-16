-- Active: 1750100490325@@127.0.0.1@3307@pizzeria

SHOW TABLES;

-- 1
DELIMITER $$

DROP FUNCTION IF EXISTS fn_calcular_subtotal_pizza $$

CREATE FUNCTION fn_calcular_subtotal_pizza(
    p_producto_id INT,
    p_presentacion_id INT
)
RETURNS DECIMAL(10,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE p_subtotal DECIMAL(10,2);
    DECLARE p_precio_base DECIMAL(10,2);
    DECLARE p_precio_ingredientes DECIMAL(10,2);
    
    IF NOT EXISTS (SELECT 1 FROM producto WHERE id = p_producto_id AND tipo_producto_id = 2) THEN
        SIGNAL SQLSTATE '40002'
            SET MESSAGE_TEXT = 'El producto seleccionado no existe o no es una pizza.'; -- Verfica que exista en alguna fila, si no, lanza error
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM producto_presentacion 
        WHERE producto_id = p_producto_id AND id = p_presentacion_id) THEN
        SIGNAL SQLSTATE '40002'
            SET MESSAGE_TEXT = 'La presentacion seleccionada no existe.'; -- Verfica que exista en alguna fila, si no, lanza error
    END IF;    

    SET p_precio_base = (
        SELECT precio FROM producto_presentacion
        WHERE id = p_presentacion_id
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

SELECT fn_calcular_subtotal_pizza(2, 4) AS subtotal;

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