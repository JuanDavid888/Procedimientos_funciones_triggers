-- Active: 1750195161481@@127.0.0.1@3307@pizzeria

SHOW TABLES;

-- 1
DELIMITER $$

DROP TRIGGER IF EXISTS fg_before_insert_detalle_pedido $$

CREATE TRIGGER fg_before_insert_detalle_pedido
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    IF NEW.cantidad < 1 THEN
        SIGNAL SQLSTATE '40001'
            SET MESSAGE_TEXT = 'La cantidad debe ser mayor a 0';
    END IF;

END $$

DELIMITER ;

INSERT INTO detalle_pedido (cantidad, pedido_id, producto_presentacion_id, tipo_combo)
VALUES (0, 1, 1, 'Producto individual');

-- 2
DELIMITER $$

DROP TRIGGER IF EXISTS tg_after_insert_detalle_pedido $$

CREATE TRIGGER tg_after_insert_detalle_pedido
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    DECLARE p_tipo INT;

    SELECT pro.tipo_producto_id INTO p_tipo
    FROM producto_presentacion pro_pre
    JOIN producto pro ON pro_pre.producto_id = pro.id
    WHERE pro_pre.id = NEW.producto_presentacion_id;

    IF p_tipo = 2 THEN
        -- Actualizar stock de ingredientes usados en esta pizza
        UPDATE ingrediente i
        JOIN ingrediente_producto i_pro ON i.id = i_pro.ingrediente_id
        SET i.stock = i.stock - NEW.cantidad
        WHERE i_pro.producto_id = (
            SELECT producto_id FROM producto_presentacion
            WHERE id = NEW.producto_presentacion_id
        );
    END IF;

END$$

DELIMITER ;

INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id, estado)
VALUES (NOW(), 35000, 3, 3, 'Pendiente');

INSERT INTO detalle_pedido (cantidad, pedido_id, producto_presentacion_id, tipo_combo)
VALUES (1, 4, 5, 'Producto individual');

-- 3
DELIMITER $$

DROP TRIGGER IF EXISTS tg_after_update_pizza_precio $$

CREATE TRIGGER tg_after_update_pizza_precio
AFTER UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN
    DECLARE p_tipo INT;

    SELECT tipo_producto_id INTO p_tipo
    FROM producto
    WHERE id = NEW.producto_id;

    IF p_tipo = 2 AND OLD.precio <> NEW.precio THEN
        INSERT INTO auditoria_precios
        (producto_id, presentacion_id, precio_anterior, precio_nuevo, fecha_cambio)
        VALUES(NEW.producto_id, NEW.presentacion_id, OLD.precio, NEW.precio, NOW());
    END IF;

END $$

DELIMITER ;

UPDATE producto_presentacion
SET precio = 20000
WHERE id = 4;

-- 4
DELIMITER $$

DROP TRIGGER IF EXISTS tg_before_delete_pizza $$

CREATE TRIGGER tg_before_delete_pizza
BEFORE DELETE ON producto
FOR EACH ROW
BEGIN
    DECLARE p_counter INT;

    -- Validar si el producto esta en algun detalle_pedido
    SELECT COUNT(*) INTO p_counter
    FROM detalle_pedido dp
    JOIN producto_presentacion pro_pre ON dp.producto_presentacion_id = pro_pre.id
    JOIN producto pro ON pro_pre.producto_id = pro.id
    WHERE pro_pre.producto_id = OLD.id AND pro.tipo_producto_id = 2;

    IF p_counter > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La pizza seleccionada esta en un pedido. No se puede eliminar.';
    END IF;
    

END$$

DELIMITER ;

DELETE FROM producto WHERE id = 2;