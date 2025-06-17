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


