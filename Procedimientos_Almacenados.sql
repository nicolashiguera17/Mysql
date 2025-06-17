-- Active: 1749574161226@@127.0.0.1@3307
--1.Crea un procedimiento que inserte una nueva pizza en la tabla `pizza` junto con sus ingredientes en `pizza_ingrediente`. --

DELIMITER $$

DROP PROCEDURE IF EXISTS ps_add_pizza_con_ingredientes $$
CREATE PROCEDURE ps_add_pizza_con_ingredientes(
    IN p_nombre_pizza VARCHAR(100),
    IN p_precio DECIMAL(10,2),
    IN p_ids_ingredientes TEXT
)
BEGIN
    DECLARE v_producto_id INT;
    DECLARE i INT DEFAULT 1;
    DECLARE total INT;
    DECLARE ingrediente_id INT;
    DECLARE ingrediente_str VARCHAR(10);

    
    IF p_ids_ingredientes IS NULL OR p_ids_ingredientes = '' THEN
        SIGNAL SQLSTATE '40001' SET MESSAGE_TEXT = 'No hay ingredientes ingresados';
    END IF;

    
    INSERT INTO producto (nombre, tipo_producto_id) VALUES (p_nombre_pizza, 2);
    SET v_producto_id = LAST_INSERT_ID();

    INSERT INTO producto_presentacion (producto_id, presentacion_id, precio)
    VALUES (v_producto_id, 1, p_precio);

    
    SET total = 1 + LENGTH(p_ids_ingredientes) - LENGTH(REPLACE(p_ids_ingredientes, ',', ''));

    
    WHILE i <= total DO
        SET ingrediente_str = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_ids_ingredientes, ',', i), ',', -1));
        SET ingrediente_id = CAST(ingrediente_str AS UNSIGNED);

        IF NOT EXISTS (SELECT 1 FROM ingrediente WHERE id = ingrediente_id) THEN
            SIGNAL SQLSTATE '40002' SET MESSAGE_TEXT = 'El ingrediente seleccionado no existe.';
        ELSE
            INSERT INTO ingrediente_producto (producto_id, ingrediente_id)
            VALUES (v_producto_id, ingrediente_id);
        END IF;

        SET i = i + 1;
    END WHILE;

    
    SELECT 
        pro.nombre AS Producto,
        pre.precio AS Precio,
        GROUP_CONCAT(ing.nombre SEPARATOR ', ') AS Ingredientes
    FROM producto pro
    JOIN producto_presentacion pre ON pre.producto_id = pro.id
    JOIN ingrediente_producto ip ON ip.producto_id = pro.id
    JOIN ingrediente ing ON ing.id = ip.ingrediente_id
    WHERE pro.id = v_producto_id
    GROUP BY pro.nombre, pre.precio;

END $$
DELIMITER ;

CALL ps_add_pizza_con_ingredientes('Pizza de pollo', '25000', '1,3,11,15');


-- 2. Procedimiento que reciba `p_pizza_id` y `p_nuevo_precio` y actualice el precio.--

DELIMITER $$

DROP PROCEDURE IF EXISTS ps_actualizar_precio_pizza $$

CREATE PROCEDURE ps_actualizar_precio_pizza(
    IN p_pizza_id INT,
    IN p_presentacion_id INT,
    IN p_nuevo_precio DECIMAL(10, 2)
)
BEGIN

    IF NOT EXISTS (SELECT 1 FROM producto WHERE id = p_pizza_id) THEN
        SIGNAL SQLSTATE '40002' SET MESSAGE_TEXT = 'La pizza no existe.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM presentacion WHERE id = p_presentacion_id) THEN
        SIGNAL SQLSTATE '40002' SET MESSAGE_TEXT = 'La presentación no existe.';
    END IF;

    IF p_nuevo_precio <= 0 THEN
        SIGNAL SQLSTATE '40001' SET MESSAGE_TEXT = 'El precio debe ser mayor a 0.';
    END IF;

   
    UPDATE producto_presentacion
    SET precio = p_nuevo_precio
    WHERE producto_id = p_pizza_id AND presentacion_id = p_presentacion_id;

    
    SELECT pro.nombre AS Producto, pre.precio AS Precio
    FROM producto pro
    JOIN producto_presentacion pre ON pre.producto_id = pro.id
    WHERE pro.id = p_pizza_id AND pre.presentacion_id = p_presentacion_id;
END$$

DELIMITER ;

CALL ps_actualizar_precio_pizza(1, 3, 14000);

-- 3.ps_generar_pedido`(usar TRANSACTION) --

DELIMITER $$

DROP PROCEDURE IF EXISTS ps_generar_pedido $$

CREATE PROCEDURE ps_generar_pedido(
    IN p_cliente_id INT,
    IN p_presentacion_id INT,
    IN p_metodo_pago_id INT
)
BEGIN
    DECLARE v_pedido_id INT;
    DECLARE v_precio DECIMAL(10,2);

    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al generar el pedido. Verifique los datos.';
    END;

    START TRANSACTION;

   
    SELECT precio INTO v_precio
    FROM producto_presentacion
    WHERE id = p_presentacion_id;

    IF v_precio IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró la presentación especificada.';
    END IF;

    
    INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id)
    VALUES (NOW(), v_precio, p_cliente_id, p_metodo_pago_id);
    SET v_pedido_id = LAST_INSERT_ID();

    
    INSERT INTO detalle_pedido (cantidad, pedido_id, producto_presentacion_id, tipo_combo)
    VALUES (1, v_pedido_id, p_presentacion_id, 'Producto individual');

    COMMIT;

   
    SELECT 
        cl.nombre AS Cliente,
        pro.nombre AS Producto,
        pp.precio AS Precio,
        mp.nombre AS Metodo_Pago
    FROM pedido p
    JOIN cliente cl ON cl.id = p.cliente_id
    JOIN detalle_pedido dp ON dp.pedido_id = p.id
    JOIN producto_presentacion pp ON pp.id = dp.producto_presentacion_id
    JOIN producto pro ON pro.id = pp.producto_id
    JOIN metodo_pago mp ON mp.id = p.metodo_pago_id
    WHERE p.id = v_pedido_id;

END$$

DELIMITER ;

CALL ps_generar_pedido(2, 3, 2);

-- 4. ps_cancelar_pedido --

DELIMITER $$

DROP PROCEDURE IF EXISTS ps_cancelar_pedido $$

CREATE PROCEDURE ps_cancelar_pedido(
    IN p_pedido_id INT
)
BEGIN
    -- Validación: verificar que el pedido exista
    IF NOT EXISTS (SELECT 1 FROM pedido WHERE id = p_pedido_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido no existe.';
    END IF;

    -- Cancelar pedido
    UPDATE pedido SET estado = 'Cancelado' WHERE id = p_pedido_id;

    -- Eliminar detalles y factura asociados
    DELETE FROM detalle_pedido WHERE pedido_id = p_pedido_id;
    DELETE FROM factura WHERE pedido_id = p_pedido_id;

    -- Mostrar resumen del pedido cancelado
    SELECT 
        cl.nombre AS Cliente,
        mp.nombre AS Metodo_Pago,
        pe.estado AS Estado
    FROM pedido pe
    JOIN cliente cl ON cl.id = pe.cliente_id
    JOIN metodo_pago mp ON mp.id = pe.metodo_pago_id
    WHERE pe.id = p_pedido_id;
END $$

DELIMITER ;

CALL ps_cancelar_pedido(1);

