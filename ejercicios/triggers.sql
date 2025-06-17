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