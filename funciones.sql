-- 6.`fc_calcular_subtotal_pizza` --

DELIMITER $$

DROP FUNCTION IF EXISTS fn_calcular_subtotal_pizza $$

CREATE FUNCTION fn_calcular_subtotal_pizza(
    p_pro_pre_id INT
)
RETURNS DECIMAL(10,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_producto_id INT;
    DECLARE v_precio_base DECIMAL(10,2);
    DECLARE v_precio_ingredientes DECIMAL(10,2) DEFAULT 0;

    IF NOT EXISTS (
        SELECT 1 FROM producto_presentacion WHERE id = p_pro_pre_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La presentación seleccionada no existe.';
    END IF;

    
    SELECT producto_id, precio
    INTO v_producto_id, v_precio_base
    FROM producto_presentacion
    WHERE id = p_pro_pre_id;

   
    SELECT IFNULL(SUM(i.precio), 0)
    INTO v_precio_ingredientes
    FROM ingrediente i
    JOIN ingrediente_producto ip ON i.id = ip.ingrediente_id
    WHERE ip.producto_id = v_producto_id;

    
    RETURN v_precio_base + v_precio_ingredientes;
END $$
DELIMITER ;


-- 7.fc_descuento_por_cantidad` --

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
    DECLARE v_total DECIMAL(10,2);

    
    IF p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor a 0.';
    END IF;

    IF p_precio_unitario <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser mayor a 0.';
    END IF;

   
    SET v_total = p_cantidad * p_precio_unitario;

    IF p_cantidad >= 5 THEN
        SET v_total = v_total * 0.90; 
    END IF;

    RETURN v_total;
END $$
DELIMITER ;

-- 8.`fc_precio_final_pedido`--

DELIMITER $$

DROP FUNCTION IF EXISTS fn_precio_final_pedido $$

CREATE FUNCTION fn_precio_final_pedido(
    p_pedido_id INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_pro_pre_id INT;
    DECLARE v_cantidad INT;
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_total_final DECIMAL(10,2);

    
    IF NOT EXISTS (SELECT 1 FROM pedido WHERE id = p_pedido_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El pedido seleccionado no existe.';
    END IF;

    
    SELECT producto_presentacion_id, cantidad
    INTO v_pro_pre_id, v_cantidad
    FROM detalle_pedido
    WHERE pedido_id = p_pedido_id
    LIMIT 1;

    
    SET v_subtotal = fn_calcular_subtotal_pizza(v_pro_pre_id);

    
    SET v_total_final = fn_descuento_por_cantidad(v_cantidad, v_subtotal);

    RETURN v_total_final;
END $$

DELIMITER ;


-- 9. `fc_obtener_stock_ingrediente` --
DELIMITER $$

DROP FUNCTION IF EXISTS fn_obtener_stock_ingrediente $$

CREATE FUNCTION fn_obtener_stock_ingrediente(
    p_ingrediente_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_stock INT;

    
    IF NOT EXISTS (
        SELECT 1 FROM ingrediente WHERE id = p_ingrediente_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El ingrediente no existe.';
    END IF;

    
    SELECT stock INTO v_stock
    FROM ingrediente
    WHERE id = p_ingrediente_id;

    RETURN v_stock;
END $$
DELIMITER ;

