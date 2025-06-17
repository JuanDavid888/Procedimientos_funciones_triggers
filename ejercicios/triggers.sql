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