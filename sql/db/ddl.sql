use lab;

DROP TABLE IF EXISTS faktura_detail;
DROP TABLE IF EXISTS faktura;
DROP TABLE IF EXISTS stock;
DROP TABLE IF EXISTS logg;
DROP TABLE IF EXISTS order_detail;
DROP TABLE IF EXISTS reserve_detail;
DROP TABLE IF EXISTS stock_shelf;
DROP TABLE IF EXISTS devicet2cat;
DROP TABLE IF EXISTS device;
DROP TABLE IF EXISTS order_tab;
DROP TABLE IF EXISTS reserve_tab;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS category;


CREATE TABLE customer
(
    id INT AUTO_INCREMENT NOT NULL,
    username CHAR(40) UNIQUE,
    password CHAR(10),
    type CHAR(10) DEFAULT "user",
    firstname VARCHAR(20),
    lastname VARCHAR(20),
    email VARCHAR(20),
    telephone VARCHAR(20),
    postcode char(8),
    city char(10),
    country varchar(20),
    address VARCHAR(20),
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted DATETIME,

    PRIMARY KEY (id)
);

CREATE TABLE category
(
    type VARCHAR(10) NOT NULL,
    level INT,

    PRIMARY KEY (type)
);

CREATE TABLE device
(
    id char(10) NOT NULL,
    price FLOAT,
    name CHAR(60) NOT NULL,
    image VARCHAR(40),
    description VARCHAR(400),
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted DATETIME DEFAULT null,


    PRIMARY KEY (id),
    INDEX index_price (price),
    FULLTEXT full_description (description)
);

CREATE TABLE device2cat
(
    device_id CHAR(10),
    cat_type VARCHAR(10),

    FOREIGN KEY (device_id) REFERENCES device(id),
    FOREIGN KEY (cat_type) REFERENCES category(type),
    INDEX cat_type_index (cat_type)
);

CREATE TABLE order_tab
(
    id INT AUTO_INCREMENT,
    customer_id INT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated DATETIME DEFAULT NULL on UPDATE CURRENT_TIMESTAMP,
    deleted DATETIME DEFAULT NULL,
    ordered DATETIME DEFAULT NULL,
    delivered DATETIME DEFAULT NULL,
    returned DATETIME DEFAULT NULL,
    renewed DATETIME DEFAULT NULL,
    overdued INT,

    PRIMARY KEY (id),
    FOREIGN KEY (customer_id) REFERENCES customer(id)
);

CREATE TABLE reserve_tab
(
    id INT AUTO_INCREMENT,
    customer_id INT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated DATETIME DEFAULT NULL on UPDATE CURRENT_TIMESTAMP,
    deleted DATETIME DEFAULT NULL,
    ordered DATETIME DEFAULT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (customer_id) REFERENCES customer(id)
);


CREATE TABLE reserve_detail
(
    id INT AUTO_INCREMENT,
    reserve_id INT,
    device_id char(10),
    sellcount INT,

    PRIMARY KEY (id),
    FOREIGN KEY (device_id) REFERENCES device(id),
    FOREIGN KEY (reserve_id) REFERENCES reserve_tab(id)
);

CREATE TABLE order_detail
(
    id INT AUTO_INCREMENT,
    order_id INT,
    device_id char(10),
    sellcount INT,

    PRIMARY KEY (id),
    FOREIGN KEY (device_id) REFERENCES device(id),
    FOREIGN KEY (order_id) REFERENCES order_tab(id)
);

CREATE TABLE stock_shelf
(
    id char(6),
    description VARCHAR(40),

    PRIMARY KEY (id)
);

CREATE TABLE stock
(
    device_id char(10),
    items INT,
    shelf_id char(6),

    FOREIGN KEY (device_id) REFERENCES device(id),
    KEY device_id_index (device_id),
    FOREIGN KEY (shelf_id) REFERENCES stock_shelf(id)
);


CREATE TABLE faktura
(
    id INT AUTO_INCREMENT NOT NULL,
    order_id INT,
    customer_id INT,
    fakturadate DATETIME DEFAULT CURRENT_TIMESTAMP,
    paid DATETIME,

    PRIMARY KEY (id),
    FOREIGN KEY (customer_id) REFERENCES customer(id),
    FOREIGN KEY (order_id) REFERENCES order_tab(id)
);

CREATE TABLE faktura_detail
(
    id INT AUTO_INCREMENT NOT NULL,
    faktura_id INT,
    device_id char(10),
    amount FLOAT,
    fakturadate DATETIME DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    FOREIGN KEY (faktura_id) REFERENCES faktura(id),
    FOREIGN KEY (device_id) REFERENCES device(id)
);

CREATE TABLE logg
(
    id INT AUTO_INCREMENT NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(100),

    PRIMARY KEY (id)
);



--
-- Trigger for logging insert device
--
DROP  TRIGGER  IF  EXISTS log_device_insert;
DELIMITER ;;
CREATE  TRIGGER log_device_insert
 AFTER  INSERT
ON  device  FOR  EACH  ROW
    INSERT  INTO logg (description)
         VALUES (CONCAT("New product is inserted with device id ", NEW.id, "."));
;;
DELIMITER ;

--
-- Trigger for logging update device
--
DROP  TRIGGER  IF  EXISTS log_device_update;
DELIMITER ;;
CREATE  TRIGGER log_device_update
 AFTER  UPDATE
ON  device  FOR  EACH  ROW
    INSERT  INTO logg (description)
         VALUES (CONCAT("Details of Device id ", NEW.id, " updated."));
;;
DELIMITER ;

--
-- Trigger for logging delete product
--
DROP  TRIGGER  IF  EXISTS log_device_delete;
DELIMITER ;;
CREATE  TRIGGER log_device_delete
AFTER UPDATE
on device FOR  EACH  ROW
BEGIN
    IF (NEW.deleted is not NULL) THEN
        INSERT  INTO logg(description)
            VALUES (CONCAT("Product with device id ", OLD.id, " soft deleted."));
    END IF;
END;
;;
DELIMITER ;
--
-- DROP view if exists v_device_cat;
-- CREATE VIEW v_device_cat
-- AS
-- SELECT
--      d.*,
--      GROUP_CONCAT(c.type) AS 'category'
-- FROM device AS d
--      JOIN device2cat AS d2c
--          ON d.id = d2c.device_id
--      JOIN category AS c
--          ON c.type = d2c.cat_type
-- GROUP BY
--     id
-- ;

--
-- procedure for show devices with the input type
--
DROP  PROCEDURE  IF  EXISTS show_device_type_items;
DELIMITER ;;
CREATE  PROCEDURE show_device_type_items(
    a_type varchar(10)
)
BEGIN
SELECT
    *
FROM device as d
    JOIN (select * from device2cat where cat_type=a_type) as t2
    on d.id = t2.device_id
    JOIN stock as s
    on s.device_id = t2.device_id;
END
;;
DELIMITER ;


DROP view if exists v_device_stock;
CREATE VIEW v_device_stock
AS
SELECT
    *
FROM stock AS s
    JOIN device AS d
        ON s.device_id = d.id
;
DELIMITER ;

--
-- procedure for show device with items in stock
--
DROP  PROCEDURE  IF  EXISTS show_device_stock;
DELIMITER ;;
CREATE  PROCEDURE show_device_stock()
BEGIN
    SELECT
         *
    FROM v_device_stock;
END
;;
DELIMITER ;


--
-- procedure for get amount of devices in stock
--
DROP  PROCEDURE  IF  EXISTS get_amount_device_stock;
DELIMITER ;;
CREATE  PROCEDURE get_amount_device_stock(
    a_deviceid char(10)
)
BEGIN
    SELECT
         items
    FROM v_device_stock where device_id=a_deviceid;
END
;;
DELIMITER ;

--
-- procedure for show device with items in stock with parameter
--
DROP  PROCEDURE  IF  EXISTS show_device_stock_search;
DELIMITER ;;
CREATE  PROCEDURE show_device_stock_search(
    a_search varchar(40)
)
BEGIN
    SELECT
         *
    FROM v_device_stock
    WHERE id LIKE a_search OR name LIKE a_search
    OR image LIKE a_search OR items LIKE a_search;
END
;;
DELIMITER ;


--
-- procedure for show device with items in stock with parameter
--
DROP  PROCEDURE  IF  EXISTS password_verify;
DELIMITER ;;
CREATE  PROCEDURE password_verify(
    a_user char(40),
    a_password char(10)
)
BEGIN
    SELECT
        *
    FROM customer
    WHERE username=a_user and password=a_password;
END
;;
DELIMITER ;


--
-- procedure for create a new order(booking)
--
DROP  PROCEDURE  IF  EXISTS create_order;
DELIMITER ;;
CREATE  PROCEDURE create_order(
    IN a_id INT,
    OUT temp_orderid INT
)
BEGIN
    INSERT into order_tab(customer_id) values(a_id);
    SELECT LAST_INSERT_ID() into temp_orderid;
END
;;
DELIMITER ;

--
-- procedure for add a device to order(booking)
--
DROP  PROCEDURE  IF  EXISTS add_device_2order;
DELIMITER ;;
CREATE  PROCEDURE add_device_2order(
    a_orderid INT,
    a_deviceid char(10)
)
BEGIN
    DECLARE a1 char(10);
    select device_id into a1 from order_detail where order_id = a_orderid and device_id = a_deviceid;
    IF a1 is null then
        insert into order_detail (order_id, device_id, sellcount)
            values(a_orderid, a_deviceid, 1);
    else
        update order_detail
            set sellcount = sellcount + 1
            where device_id = a_deviceid and order_id = a_orderid;
    END IF;
END
;;
DELIMITER ;

--
-- procedure for add a device to order(booking)
--
DROP  PROCEDURE  IF  EXISTS add_device_2reserve;
DELIMITER ;;
CREATE  PROCEDURE add_device_2reserve(
    a_reserveid INT,
    a_deviceid char(10)
)
BEGIN
    DECLARE a1 char(10);
    select device_id into a1 from reserve_detail where reserve_id = a_reserveid and device_id = a_deviceid;
    IF a1 is null then
        insert into reserve_detail (reserve_id, device_id, sellcount)
            values(a_reserveid, a_deviceid, 1);
    else
        update reserve_detail
            set sellcount = sellcount + 1
            where device_id = a_deviceid and reserve_id = a_reserveid;
    END IF;
END
;;
DELIMITER ;

--
-- view for show order detail
--
DROP view if exists  v_device_order;
CREATE VIEW v_device_order
AS
SELECT
    od.*, d.name, d.price, d.image
FROM order_detail AS od
    JOIN device AS d
        ON od.device_id = d.id
;

--
-- view for show reserve detail and devices
--
DROP view if exists  v_device_reserve;
CREATE VIEW v_device_reserve
AS
SELECT
    od.*, d.name, d.price, d.image
FROM reserve_detail AS od
    JOIN device AS d
        ON od.device_id = d.id
;

--
-- Function for order status
--
DROP FUNCTION IF EXISTS order_status;
DELIMITER ;;

CREATE FUNCTION order_status (
    a_id INT
)
RETURNS char(20)
DETERMINISTIC
BEGIN
    DECLARE a_created, a_deleted, a_ordered, a_delivered, a_returned, a_renewed DATETIME;
    DECLARE due_days INT;
    select created, deleted, ordered, delivered, returned, overdued, renewed
    into a_created, a_deleted, a_ordered, a_delivered, a_returned, due_days, a_renewed
    from order_tab where id = a_id;
    IF due_days is null THEN
        IF a_renewed is not null THEN
            SELECT DATEDIFF(DATE(now()), DATE(a_renewed)) into due_days from order_tab where id = a_id;
        ELSE
            SELECT DATEDIFF(DATE(now()), DATE(a_ordered)) into due_days from order_tab where id = a_id;
        END IF;
        -- IF due_days > 0 THEN
        --     UPDATE order_tab set overdued = due_days where id = a_id;
        -- END IF;
    END IF;
    IF a_delivered is not null THEN
        RETURN 'Sent';
    ELSEIF due_days > 0 THEN
        RETURN CONCAT("Overdued ", (due_days), "  days.");
    ELSEIF a_returned is not null THEN
        RETURN 'Returned';
    ELSEIF a_renewed is not null THEN
        RETURN 'Renewed';
    ELSEIF a_ordered is not null THEN
        RETURN 'Loaned';
    ELSEIF a_deleted is not null THEN
        RETURN 'Cancelled';
    ELSEIF a_created is not null THEN
        RETURN 'Created';
    END IF;
END
;;
DELIMITER ;


--
-- Function for reserve status
--
DROP FUNCTION IF EXISTS reserve_status;
DELIMITER ;;

CREATE FUNCTION reserve_status (
    a_id INT
)
RETURNS char(20)
DETERMINISTIC
BEGIN
    DECLARE a_created, a_deleted, a_ordered DATETIME;
    select created, deleted, ordered
    into a_created, a_deleted, a_ordered
    from reserve_tab where id = a_id;
    IF a_deleted is not null THEN
        RETURN 'Cancelled';
    ELSEIF a_ordered is not null THEN
        RETURN 'Reserved';
    ELSEIF a_created is not null THEN
        RETURN 'Created';
    END IF;
END
;;
DELIMITER ;

--
-- procedure for show order detail
--
DROP  PROCEDURE  IF  EXISTS show_order_detail;
DELIMITER ;;
CREATE  PROCEDURE show_order_detail(
    a_id INT
)
BEGIN
    SELECT *, order_status(order_id) as status FROM  v_device_order as v
        left outer join order_tab as o
            ON v.order_id = o.id
        left outer join customer as c
            ON o.customer_id = c.id
        where order_id = a_id;
END
;;
DELIMITER ;


--
-- procedure for create a new order
--
DROP  PROCEDURE  IF  EXISTS confirm_order;
DELIMITER ;;
CREATE  PROCEDURE confirm_order(
    a_id INT
)
BEGIN
    update order_tab
        set
        ordered = now()
        where id = a_id;
END
;;
DELIMITER ;

--
-- view for picklist
--
DROP VIEW IF EXISTS v_picklist;
CREATE view v_picklist AS
SELECT
    o.id AS orderid,
    p.id AS deviceid,
    p.name AS devicename,
    d.sellcount AS amount,
    ss.id AS shelf,
    ss.description AS shelf_desc,
    s.items AS stock
FROM order_tab AS o
    inner join order_detail AS d
        on o.id = d.order_id
    inner join device AS p
        on p.id = d.device_id
    inner join stock AS s
        on s.device_id = p.id
    inner join  stock_shelf as ss
        on ss.id = s.shelf_id
ORDER BY
d.id;

--
-- procedure for update stock after shipping
--
DROP  PROCEDURE  IF  EXISTS update_stock;
DELIMITER ;;
CREATE  PROCEDURE update_stock(
    a_id char(10)
)
BEGIN
DECLARE finished INTEGER DEFAULT 0;
DECLARE a1 CHAR(10);
DECLARE a2 INT;
DECLARE YOUCURNAME CURSOR FOR SELECT deviceid, amount FROM v_picklist WHERE orderid = a_id;
DECLARE CONTINUE HANDLER
    FOR NOT FOUND SET finished = 1;
  OPEN YOUCURNAME;
  myloop: LOOP
    FETCH YOUCURNAME INTO  a1, a2;
    IF finished = 1 THEN
      LEAVE myloop;
    END IF;
    UPDATE stock SET items = items - a2 WHERE device_id = a1;
  END LOOP myloop;
  CLOSE YOUCURNAME;
END;
;;
DELIMITER ;

--
-- Procedure for picklist_order
--
DROP  PROCEDURE  IF  EXISTS picklist_order;
DELIMITER ;;
CREATE  PROCEDURE picklist_order(
    a_id INT
)
BEGIN
    select *, (stock-amount) as left_instock, IF((stock-amount>=0), "yes", "no") as instock from v_picklist where orderid = a_id;
END
;;
DELIMITER ;

--
-- procedure for soft delete order
--
DROP  PROCEDURE  IF  EXISTS delete_order;
DELIMITER ;;
CREATE  PROCEDURE delete_order(
    a_id char(10)
)
BEGIN
    UPDATE order_tab
        SET
            deleted = CURRENT_TIMESTAMP
    WHERE id = a_id;
END
;;
DELIMITER ;

--
-- procedure for show ones own loan(order)
--
DROP  PROCEDURE  IF  EXISTS show_myloan;
DELIMITER ;;
CREATE  PROCEDURE show_myloan(
    a_customerid INT
)
BEGIN
SELECT *, order_status(order_id) as status, sum(sellcount) as amount
FROM  v_device_order as vdo
    JOIN  (SELECT  * FROM order_tab  WHERE customer_id = a_customerid) as ot
    on vdo.order_id = ot.id
    GROUP by order_id;
END
;;
DELIMITER ;


--
-- procedure for create a new order(booking)
--
DROP  PROCEDURE  IF  EXISTS create_reserve;
DELIMITER ;;
CREATE  PROCEDURE create_reserve(
    IN a_id INT,
    OUT temp_reserveid INT
)
BEGIN
    INSERT into reserve_tab(customer_id) values(a_id);
    SELECT LAST_INSERT_ID() into temp_reserveid;
END
;;
DELIMITER ;

--
-- procedure for show ones own loan(order)
--
DROP  PROCEDURE  IF  EXISTS show_myreserve;
DELIMITER ;;
CREATE  PROCEDURE show_myreserve(
    a_customerid INT
)
BEGIN
SELECT *, reserve_status(reserve_id) as status, sum(sellcount) as amount
FROM  v_device_reserve as vdr
    JOIN  (SELECT  *  FROM reserve_tab  WHERE customer_id = a_customerid) as rt
    on vdr.reserve_id = rt.id
    GROUP By reserve_id;
END
;;
DELIMITER ;

--
-- procedure for return device
--
DROP  PROCEDURE  IF  EXISTS return_device;
DELIMITER ;;
CREATE  PROCEDURE return_device(
    a_orderid INT
)
BEGIN
UPDATE order_tab
    SET
        returned = CURRENT_TIMESTAMP
WHERE id = a_orderid;
END
;;
DELIMITER ;

--
-- procedure for return stock after return the devices
--
DROP  PROCEDURE  IF  EXISTS return_stock;
DELIMITER ;;
CREATE  PROCEDURE return_stock(
    a_id char(10)
)
BEGIN
DECLARE finished INTEGER DEFAULT 0;
DECLARE a1 CHAR(10);
DECLARE a2 INT;
DECLARE YOUCURNAME CURSOR FOR SELECT deviceid, amount FROM v_picklist WHERE orderid = a_id;
DECLARE CONTINUE HANDLER
    FOR NOT FOUND SET finished = 1;
  OPEN YOUCURNAME;
  myloop: LOOP
    FETCH YOUCURNAME INTO  a1, a2;
    IF finished = 1 THEN
      LEAVE myloop;
    END IF;
    UPDATE stock SET items = items + a2 WHERE device_id = a1;
  END LOOP myloop;
  CLOSE YOUCURNAME;
END;
;;
DELIMITER ;

--
-- procedure for renew device
--
DROP  PROCEDURE  IF  EXISTS renew_device;
DELIMITER ;;
CREATE  PROCEDURE renew_device(
    a_orderid INT
)
BEGIN
UPDATE order_tab
    SET
        renewed = CURRENT_TIMESTAMP
WHERE id = a_orderid;
END
;;
DELIMITER ;

--
-- procedure for show all loans
--
DROP  PROCEDURE  IF  EXISTS show_all_loan;
DELIMITER ;;
CREATE  PROCEDURE show_all_loan()
BEGIN
SELECT *, order_status(order_id) as status, sum(sellcount) as amount
FROM  v_device_order as vdo
    JOIN  order_tab as ot
    on vdo.order_id = ot.id
    JOIN customer as c
    on c.id = ot.customer_id
    GROUP by order_id;
END
;;
DELIMITER ;

--
-- procedure for create a new reserve
--
DROP  PROCEDURE  IF  EXISTS confirm_reserve;
DELIMITER ;;
CREATE  PROCEDURE confirm_reserve(
    a_id INT
)
BEGIN
    update reserve_tab
        set
        ordered = now()
        where id = a_id;
END
;;
DELIMITER ;

--
-- procedure for soft cancel the reserve
--
DROP  PROCEDURE  IF  EXISTS cancel_reserve;
DELIMITER ;;
CREATE  PROCEDURE cancel_reserve(
    a_id char(10)
)
BEGIN
    UPDATE reserve_tab
        SET
            deleted = CURRENT_TIMESTAMP
    WHERE id = a_id;
END
;;
DELIMITER ;
