-- Active: 1750013577539@@127.0.0.1@3307@pizzeria

SHOW TABLES;

-- 1
DELIMITER $$

DROP PROCEDURE IF EXISTS ps_add_pizza_con_ingredientes $$

CREATE PROCEDURE ps_add_pizza_con_ingredientes(
    IN p_nombre_pizza VARCHAR(100),
    IN p_precio DECIMAL(10, 2),
    IN p_ids_ingredientes TEXT
)
BEGIN
    DECLARE v_producto_id INT;
    DECLARE v_presentacion_id INT;
    DECLARE ingrediente_id INT;
    DECLARE i INT DEFAULT 1;
    DECLARE total INT;
    DECLARE ingrediente_str VARCHAR(10);

    -- Validar que haya ingredientes
    IF p_ids_ingredientes IS NULL OR p_ids_ingredientes = '' THEN
        SIGNAL SQLSTATE '40001' SET MESSAGE_TEXT = 'No hay ingredientes ingresados';
    END IF;

    -- Insersiones base
    INSERT INTO producto (nombre, tipo_producto_id)
    VALUES (p_nombre_pizza, 2);
    SET v_producto_id = LAST_INSERT_ID();

    INSERT INTO producto_presentacion (producto_id, presentacion_id, precio)
    VALUES (v_producto_id, 1, p_precio);
    SET v_presentacion_id = LAST_INSERT_ID();

    -- Calcular cantidad de ingredientes
    SET total = 1 + LENGTH(p_ids_ingredientes) - LENGTH(REPLACE(p_ids_ingredientes, ',', '')); -- numero total (5) - numero sin caracteres (3) = 2, + 1 del inicio = 3

    -- Recorrer ingredientes
    ingrediente_loop: LOOP
        -- Salir si ya hizo todas las conversiones
        IF i > total THEN
            LEAVE ingrediente_loop;
        END IF;

        -- Obtener el ingrediente en posición i
        SET ingrediente_str = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_ids_ingredientes, ',', i), ',', -1)); -- segun i trae n, luego n,n y asi, luego con -1 mantiene solo lo ultimo despues de la coma
        SET ingrediente_id = CAST(ingrediente_str AS UNSIGNED); -- convierte a entero

        -- Insertar solo si el ingrediente existe
        IF NOT EXISTS (SELECT 1 FROM ingrediente WHERE id = ingrediente_id) THEN
            SIGNAL SQLSTATE '40002' 
                SET MESSAGE_TEXT = 'El ingrediente seleccionado no existe.'; -- Verfica que exista en alguna fila, si no, lanza error
        ELSE
            INSERT INTO ingrediente_producto (producto_id, ingrediente_id)
            VALUES (v_producto_id, ingrediente_id);
        END IF;

        -- Aumentar contador
        SET i = i + 1;
    END LOOP ingrediente_loop;

    -- Mostrar resultados
    SELECT 
        pro.nombre AS Producto,
        pro_pre.precio AS Precio,
        GROUP_CONCAT(ing.nombre SEPARATOR ', ') AS Ingredientes
    FROM producto pro
    JOIN producto_presentacion pro_pre ON pro.id = pro_pre.producto_id
    JOIN ingrediente_producto ip ON pro.id = ip.producto_id
    JOIN ingrediente ing ON ip.ingrediente_id = ing.id
    WHERE pro.id = v_producto_id
    GROUP BY pro.nombre, pro_pre.precio;

END$$

DELIMITER ;

CALL ps_add_pizza_con_ingredientes('Pizza de pollo', '25000', '1,3,11,15');

SELECT pro.nombre AS Producto,
    pro_pre.precio AS Precio,
    GROUP_CONCAT(ing.nombre SEPARATOR ', ') AS ingredientes
FROM producto pro
JOIN producto_presentacion pro_pre ON pro_pre.producto_id = pro.id
JOIN ingrediente_producto ing_pro ON ing_pro.producto_id = pro.id
JOIN ingrediente ing ON ing.id = ing_pro.ingrediente_id
WHERE pro.id = 2
GROUP BY pro.id, pro.nombre, pro_pre.precio;

-- 2
DELIMITER $$

DROP PROCEDURE IF EXISTS ps_actualizar_precio_pizza $$

CREATE PROCEDURE ps_actualizar_precio_pizza(
    IN p_pizza_id INT,
    IN p_presentacion_id INT,
    IN p_nuevo_precio DECIMAL(10, 2)
)
BEGIN

    -- Validar que la pizza existe
    IF NOT EXISTS (SELECT 1 FROM producto WHERE id = p_pizza_id) THEN
        SIGNAL SQLSTATE '40002' 
            SET MESSAGE_TEXT = 'La pizza seleccionada no existe.'; -- Verfica que exista en alguna fila, si no, lanza error
    END IF;

    -- Validar que la presentacion existe
    IF NOT EXISTS (SELECT 1 FROM presentacion WHERE id = p_presentacion_id) THEN
        SIGNAL SQLSTATE '40002' 
            SET MESSAGE_TEXT = 'La presentacion seleccionada no existe.'; -- Verfica que exista en alguna fila, si no, lanza error
    END IF;

    IF p_nuevo_precio <= 0 THEN
        SIGNAL SQLSTATE '40001' 
            SET MESSAGE_TEXT = 'El precio debe ser mayor a 0.'; -- Verfica que el precio sea mayor a 0, si no, lanza error
    END IF;

    -- Actualizar precio
    UPDATE producto_presentacion SET precio = p_nuevo_precio
    WHERE producto_id = p_pizza_id AND
    presentacion_id = p_presentacion_id;

    -- Mostrar resultados
    SELECT 
    pro.nombre AS Producto,
    pro_pre.precio AS Precio
    FROM producto pro
    JOIN producto_presentacion pro_pre ON pro_pre.producto_id = pro.id
    WHERE pro.id = p_pizza_id AND pro_pre.presentacion_id = p_presentacion_id;

END$$

DELIMITER ;

CALL ps_actualizar_precio_pizza(1, 3, 14000);

SELECT 
    pro.nombre AS Producto,
    pro_pre.precio AS Precio
FROM producto pro
JOIN producto_presentacion pro_pre ON pro_pre.producto_id = pro.id
WHERE pro.id = 1 AND pro_pre.presentacion_id = 3;