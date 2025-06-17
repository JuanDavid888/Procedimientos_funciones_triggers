-- Active: 1749726759608@@127.0.0.1@3307@pizzeria

SHOW TABLES;

-- Inserciones

INSERT INTO cliente (nombre, telefono, direccion)
VALUES('Maria Lopez', '3001234567', 'Calle 10 #20-30, Bogota'),
('Juan Perez', '3107654321', 'Carrera 5 #45-67, Medellin'),
('Ana Gomez',  '3209876543', 'Av. Siempre Viva 742, Cali');

INSERT INTO tipo_producto (nombre)
VALUES('Bebida'),
('Pizza'),
('Otros');

INSERT INTO producto (nombre, tipo_producto_id)
VALUES('Coca-Cola', 1),
('Pizza Jamon Queso', 2),
('Papas Fritas', 3);

INSERT INTO combo (nombre, precio)
VALUES('Pack Pizzas & Papas', 26500),
('Pack Bebida & Pizza', 24000),
('Combo Familiar', 65000);

INSERT INTO producto_combo (producto_id, combo_id)
VALUES(1, 2), -- Coca-Cola mediana, Pack Bebida & Pizza
(1, 3), -- Coca-Cola grande, Combo Familiar
(2, 1), -- Pizza Jamon Queso grande, Pack Pizzas & Papas
(2, 3), -- Pizza Jamon Queso grande, Combo Familiar
(3, 1), -- Papas Fritas grande, Pack Pizzas & Papas
(3, 2), -- Papas Fritas pequena, Pack Bebida & Pizza
(3, 3); -- Papas Fritas mediana, Combo Familiar

INSERT INTO metodo_pago (nombre)
VALUES('Efectivo'),
('Tarjeta Credito'),
('Nequi');

INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id, estado)
VALUES('2025-06-10 12:00:00', 35000, 1, 1, 'Pendiente'),
('2025-06-09 13:30:00', 50000, 2, 2, 'Enviado'),
('2025-06-08 18:45:00', 20000, 3, 3, 'Enviado');

INSERT INTO presentacion (nombre)
VALUES('Pequena'),
('Mediana'),
('Grande');

INSERT INTO producto_presentacion (producto_id, presentacion_id, precio)
VALUES(1, 1, 5000),  
(1, 2, 7500),  
(1, 3, 13500),
(2, 1, 20000),  
(2, 2, 35000),  
(2, 3, 50000),
(3, 1, 10000),  
(3, 2, 14750),  
(3, 3, 20500);

INSERT INTO detalle_pedido (cantidad, pedido_id, producto_presentacion_id, tipo_combo)
VALUES(1, 1, 1, 'Producto individual'), -- Coca-Cola, Pequena
(1, 2, 6, 'Combo'), -- Jamon Queso, Grande
(1, 2, 9, 'Combo'),-- Papas Fritadas, Grande
(2, 3, 4, 'Producto individual'); -- Jamon Queso, Pequena

INSERT INTO factura (total, fecha, pedido_id, cliente_id)
VALUES(35000, '2025-06-10 12:05:00', 1, 1),
(50000, '2025-06-09 13:35:00', 2, 2),
(20000, '2025-06-08 18:50:00', 3, 3);

INSERT INTO ingrediente (nombre, stock, precio) -- Stock = Kg, precio = por Kg
VALUES('Queso Mozzarella', 20, 18500),
('Jamon', 15, 22000),
('Salsa de Tomate', 10, 9500),
('Aceite de Oliva', 8, 26000),
('Oregano', 2, 14000),
('Champinones', 6, 13500),
('Cebolla', 7, 2400),
('Pimenton', 6, 3000),
('Maiz Dulce', 5, 4200),
('Peperoni', 10, 24000),
('Carne Molida', 12, 18000),
('Pollo Desmechado', 10, 17000),
('Anchoas', 3, 29000),
('Albahaca', 2, 15000),
('Tocino', 6, 20000),
('Aceitunas Negras', 4, 19000);

INSERT INTO ingrediente_producto (producto_id, ingrediente_id)
VALUES(2, 1),
(2, 2),
(2, 3);

INSERT INTO ingrediente_extra (cantidad, detalle_pedido_id, ingrediente_id) -- Cantidad = libras
VALUES(2, 2, 1),
(2, 2, 2),
(1, 4, 1);