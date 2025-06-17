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

