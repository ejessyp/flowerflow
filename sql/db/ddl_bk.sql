use eshop;

DROP TABLE IF EXISTS faktura_detail;
DROP TABLE IF EXISTS faktura;
DROP TABLE IF EXISTS stock;
DROP TABLE IF EXISTS logg;
DROP TABLE IF EXISTS order_detail;
DROP TABLE IF EXISTS stock_shelf;
DROP TABLE IF EXISTS product2cat;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS order_tab;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS category;

CREATE TABLE customer
(
    id INT AUTO_INCREMENT NOT NULL,
    firstname VARCHAR(20),
    lastname VARCHAR(20),
    email VARCHAR(20),
    birth DATE,
    telephone VARCHAR(20),
    postcode char(8),
    city char(10),
    country varchar(20),
    address VARCHAR(20),

    PRIMARY KEY (id)
);

CREATE TABLE category
(
    type VARCHAR(10) NOT NULL,

    PRIMARY KEY (type)
);

CREATE TABLE device
(
    id char(10) NOT NULL,
    price FLOAT,
    name CHAR(40) NOT NULL,
    image VARCHAR(40),
    description VARCHAR(400),
    deleted TIMESTAMP DEFAULT null,

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
    reserved DATETIME DEFAULT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (customer_id) REFERENCES customer(id)
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

    FOREIGN KEY (prod_id) REFERENCES device(id),
    KEY prod_id_index (prod_id),
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
    prod_id char(10),
    amount FLOAT,
    fakturadate DATETIME DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    FOREIGN KEY (faktura_id) REFERENCES faktura(id),
    FOREIGN KEY (prod_id) REFERENCES product(id)
);

CREATE TABLE logg
(
    id INT AUTO_INCREMENT NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(100),

    PRIMARY KEY (id)
);
--
-- procedure for show_shelf
--
DROP  PROCEDURE  IF  EXISTS show_shelf;
DELIMITER ;;
CREATE  PROCEDURE show_shelf()
 BEGIN
    SELECT * FROM  stock_shelf;
END
;;
DELIMITER ;

DROP view if exists v_product_stock;
CREATE VIEW v_product_stock
AS
SELECT
    *
FROM stock AS s
    JOIN product AS p
        ON s.prod_id = p.id
;
--
-- procedure for show_product
--
DROP  PROCEDURE  IF  EXISTS show_product;
DELIMITER ;;
CREATE  PROCEDURE show_product()
 BEGIN
    SELECT prod_id, name, items, shelf_id FROM v_product_stock;
END
;;
DELIMITER ;

--
-- procedure for show product with parameter s
--
DROP  PROCEDURE  IF  EXISTS show_product1;
DELIMITER ;;
CREATE  PROCEDURE show_product1(
    s char(40)
)
 BEGIN
    SELECT prod_id, name, items, shelf_id FROM v_product_stock
    where prod_id like s or name like s or shelf_id like s;
END
;;
DELIMITER ;
--
-- procedure for add product to shelf
--
DROP  PROCEDURE  IF  EXISTS add_product;
DELIMITER ;;
CREATE  PROCEDURE add_product(
    a_id CHAR(10),
    a_shelfid CHAR(6),
    a_items INT
)
 BEGIN
    DECLARE p_id char(10);
    DECLARE s_id char(6);

    SELECT prod_id, shelf_id INTO p_id, s_id
    FROM stock
    WHERE prod_id = a_id;
    IF (p_id = a_id  and s_id = a_shelfid) THEN
        UPDATE stock
            SET
                items = items + a_items
        WHERE prod_id = a_id and shelf_id = a_shelfid;
    ELSEIF (p_id = a_id  and s_id != a_shelfid) THEN
        INSERT INTO stock values(a_id, a_items, a_shelfid);
    ELSE
        INSERT INTO stock values(a_id, a_items, a_shelfid);
    END IF;
END
;;
DELIMITER ;

--
-- procedure for del product from shelf
--
DROP  PROCEDURE  IF  EXISTS del_product;
DELIMITER ;;
CREATE  PROCEDURE del_product(
    a_id CHAR(10),
    a_shelfid CHAR(6),
    a_items INT
)
 BEGIN
    DECLARE items_stock INT;

    SELECT items INTO items_stock
    FROM stock
    WHERE prod_id = a_id;
    IF items_stock > a_items THEN
        UPDATE stock
            SET
                items = items - a_items
        WHERE prod_id = a_id and shelf_id = a_shelfid;
    ELSEIF items_stock = a_items THEN
        delete FROM stock where prod_id = a_id and shelf_id = a_shelfid;
    ELSEIF items_stock < a_items THEN
        select 'False';
    END IF;
END
;;
DELIMITER ;

--
-- procedure for show_category
--
DROP  PROCEDURE  IF  EXISTS show_category;
DELIMITER ;;
CREATE  PROCEDURE show_category()
 BEGIN
    SELECT * FROM category;
END
;;
DELIMITER ;

DROP view if exists v_product_cat;
CREATE VIEW v_product_cat
AS
SELECT
     p.*,
     GROUP_CONCAT(c.type) AS 'category'
FROM product AS p
     JOIN product2cat AS p2c
         ON p.id = p2c.prod_id
     JOIN category AS c
         ON c.type = p2c.cat_type
GROUP BY
    id
;
--
-- procedure for show product with category and items in stock
--
DROP  PROCEDURE  IF  EXISTS show_product_cat;
DELIMITER ;;
CREATE  PROCEDURE show_product_cat()
BEGIN
    SELECT
         p.id, p.name, p.price, p.image, p.category, IFNULL(sum(s.items), 0) AS items
    FROM v_product_cat AS p
        LEFT OUTER JOIN stock AS s
             ON p.id = s.prod_id
    group by name;

END
;;
DELIMITER ;

DROP  PROCEDURE  IF  EXISTS show_product_with_type;
DELIMITER ;;
CREATE  PROCEDURE show_product_with_type(
    a_type varchar(10)
)
BEGIN
SELECT
     *
FROM product AS p
     JOIN product2cat AS p2c
         ON p.id = p2c.prod_id
     JOIN category AS c
         ON c.type = p2c.cat_type
    where type = a_type;
END
;;
DELIMITER ;
--
-- procedure for show products
--
DROP  PROCEDURE  IF  EXISTS display_product;
DELIMITER ;;
CREATE  PROCEDURE display_product()
BEGIN
    SELECT  * FROM product WHERE deleted is null;
END
;;
DELIMITER ;

--
-- procedure for show products
--
DROP  PROCEDURE  IF  EXISTS show_one_product;
DELIMITER ;;
CREATE  PROCEDURE show_one_product(
    a_id char(10)
)
BEGIN
    SELECT  * FROM product
    WHERE id = a_id;
END
;;
DELIMITER ;

--
-- procedure for delete product
--
DROP  PROCEDURE  IF  EXISTS delete_product;
DELIMITER ;;
CREATE  PROCEDURE delete_product(
    a_id char(10)
)
BEGIN
    UPDATE  product
        SET
            deleted = CURRENT_TIMESTAMP
    WHERE id = a_id;
END
;;
DELIMITER ;

--
-- procedure for edit product
--
DROP  PROCEDURE  IF  EXISTS edit_product;
DELIMITER ;;
CREATE  PROCEDURE edit_product(
    a_id char(10),
    a_name CHAR(40),
    a_price FLOAT,
    a_description VARCHAR(400)
)
BEGIN
    UPDATE product
        SET
         price = a_price,
         name = a_name,
         description = a_description
    WHERE id = a_id;
END
;;
DELIMITER ;

--
-- procedure for add product
--
DROP  PROCEDURE  IF  EXISTS create_product;
DELIMITER ;;
CREATE  PROCEDURE create_product(
    a_id char(10),
    a_price FLOAT,
    a_name CHAR(40),
    a_image VARCHAR(40),
    a_description VARCHAR(400)
)
BEGIN
    INSERT INTO product(id, price, name, image, description)
    values (a_id, a_price, a_name, a_image, a_description);
END
;;
DELIMITER ;


--
-- procedure for show log
--
DROP  PROCEDURE  IF  EXISTS show_logg;
DELIMITER ;;
CREATE  PROCEDURE show_logg(
    a_number INT
)
BEGIN
    SELECT id, DATE_FORMAT(created, '%Y-%m-%d %H:%i') as date, description
     FROM logg ORDER BY created DESC limit a_number;
END
;;
DELIMITER ;

--
-- Trigger for logging insert product
--
DROP  TRIGGER  IF  EXISTS log_product_insert;
DELIMITER ;;
CREATE  TRIGGER log_product_insert
 AFTER  INSERT
ON  product  FOR  EACH  ROW
    INSERT  INTO logg (description)
         VALUES (CONCAT("New product is inserted with product id ", NEW.id, "."));
;;
DELIMITER ;

--
-- Trigger for logging update product
--
DROP  TRIGGER  IF  EXISTS log_product_update;
DELIMITER ;;
CREATE  TRIGGER log_product_update
 AFTER  UPDATE
ON  product  FOR  EACH  ROW
    INSERT  INTO logg (description)
         VALUES (CONCAT("Details of product id ", NEW.id, " updated."));
;;
DELIMITER ;

--
-- Trigger for logging delete product
--
DROP  TRIGGER  IF  EXISTS log_product_delete;
DELIMITER ;;
CREATE  TRIGGER log_product_delete
AFTER UPDATE
on product FOR  EACH  ROW
BEGIN
    IF (NEW.deleted is not NULL) THEN
        INSERT  INTO logg(description)
            VALUES (CONCAT("Product with product id ", OLD.id, " soft deleted."));
    END IF;
END;
;;
DELIMITER ;

--
-- procedure for show_customer
--
DROP  PROCEDURE  IF  EXISTS show_customer;
DELIMITER ;;
CREATE  PROCEDURE show_customer()
 BEGIN
    SELECT id, CONCAT(firstname," ", lastname) as name, address, telephone, postcode FROM  customer;
END
;;
DELIMITER ;

--
-- View for customer, order_tab and order_detail
--
DROP view if exists  v_customer_order_od;
CREATE VIEW v_customer_order_od
AS
SELECT
    o.*, IFNULL(sum(sellcount), 0) as amount, c.firstname, c.lastname, c.email, c.birth,c.telephone,c.postcode,c.city,c.country, c.address
FROM customer AS c
    JOIN order_tab AS o
        ON c.id = o.customer_id
    left outer JOIN order_detail AS d
        ON o.id = d.order_id
    group by
    o.id
;

--
-- Function for order status
--
DROP FUNCTION IF EXISTS order_status;
DELIMITER ;;

CREATE FUNCTION order_status(
    a_id INT
)
RETURNS char(10)
DETERMINISTIC
BEGIN
    DECLARE a_created, a_deleted, a_ordered, a_delivered DATETIME;
    select created, deleted, ordered, delivered into a_created, a_deleted, a_ordered, a_delivered from order_tab where id = a_id;
    IF a_delivered is not null THEN
        RETURN 'sent';
    ELSEIF a_ordered is not null THEN
        RETURN 'ordered';
    ELSEIF a_deleted is not null THEN
        RETURN 'cancelled';
    ELSEIF a_created is not null THEN
        RETURN 'created';
    END IF;
END
;;
DELIMITER ;

--
-- procedure for show order for one customer
--
DROP  PROCEDURE  IF  EXISTS show_order_customer;
DELIMITER ;;
CREATE  PROCEDURE show_order_customer(
    a_id INT
)
 BEGIN
    SELECT id, city, address, postcode,
    customer_id, CONCAT(firstname, " ", lastname) as name,
    DATE_FORMAT(created, '%Y-%m-%d %H:%i') as cdate, amount,
    order_status(id) as status
    FROM  v_customer_order_od Where customer_id = a_id;
END
;;
DELIMITER ;

--
-- procedure for show order for one customer
--
DROP  PROCEDURE  IF  EXISTS show_order_customer;
DELIMITER ;;
CREATE  PROCEDURE show_order_customer(
    a_id INT
)
 BEGIN
    SELECT id, city, address, postcode,
    customer_id, CONCAT(firstname, " ", lastname) as name,
    DATE_FORMAT(created, '%Y-%m-%d %H:%i') as cdate, amount,
    order_status(id) as status
    FROM  v_customer_order_od Where customer_id = a_id;
END
;;
DELIMITER ;

--
-- procedure for getting info of customer with order id
--
DROP  PROCEDURE  IF  EXISTS show_customer_order;
DELIMITER ;;
CREATE  PROCEDURE show_customer_order(
    a_id INT
)
 BEGIN
    SELECT id, city, address, postcode,
    customer_id, CONCAT(firstname, " ", lastname) as name,
    DATE_FORMAT(created, '%Y-%m-%d %H:%i') as date, amount,
    order_status(id) as status
    FROM  v_customer_order_od Where id = a_id;
END
;;
DELIMITER ;

--
-- procedure for show all orders
--
DROP  PROCEDURE  IF  EXISTS show_orders;
DELIMITER ;;
CREATE  PROCEDURE show_orders()
BEGIN
    SELECT id, customer_id, CONCAT(firstname, " ", lastname) as name,
    DATE_FORMAT(created, '%Y-%m-%d %H:%i') as date, amount,
    order_status(id) as status
    FROM  v_customer_order_od;
END
;;
DELIMITER ;

--
-- procedure for show order with <search>
--
DROP  PROCEDURE  IF  EXISTS order_search;
DELIMITER ;;
CREATE  PROCEDURE order_search(
    search char(10)
)
 BEGIN
    SELECT id, customer_id, CONCAT(firstname, " ", lastname) as name,
    DATE_FORMAT(created, '%Y-%m-%d %H:%i') as date,
    amount,
    order_status(id) as status
    FROM  v_customer_order_od
    Where customer_id like search or id like search;
END
;;
DELIMITER ;
--
-- view for show order detail
--
DROP view if exists  v_product_order;
CREATE VIEW v_product_order
AS
SELECT
    d.*, p.name, p.price, p.image
FROM order_detail AS d
    JOIN product AS p
        ON d.prod_id = p.id
;
--
-- procedure for show order detail
--
DROP  PROCEDURE  IF  EXISTS show_order_detail;
DELIMITER ;;
CREATE  PROCEDURE show_order_detail(
    a_id INT
)
BEGIN
    SELECT *, order_status(order_id) as status FROM  v_product_order as v
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
DROP  PROCEDURE  IF  EXISTS create_order;
DELIMITER ;;
CREATE  PROCEDURE create_order(
    a_id INT
)
BEGIN
    insert into order_tab (customer_id)
        values(a_id);
END
;;
DELIMITER ;

--
-- procedure for add product 2 order
--
DROP  PROCEDURE  IF  EXISTS add_product2_order;
DELIMITER ;;
CREATE  PROCEDURE add_product2_order(
    a_orderid INT,
    a_productid char(10),
    a_sellcount INT
)
BEGIN
    DECLARE a1 char(10);
    select prod_id into a1 from order_detail where order_id = a_orderid and prod_id = a_productid;
    IF a1 is null then
        insert into order_detail (order_id, prod_id, sellcount)
            values(a_orderid, a_productid, a_sellcount);
    else
        update order_detail
            set sellcount = sellcount + a_sellcount
            where prod_id = a_productid and order_id = a_orderid;
    END IF;
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

DROP VIEW IF EXISTS v_picklist;
CREATE view v_picklist AS
SELECT
    o.id AS orderid,
    p.id AS productid,
    p.name AS productname,
    d.sellcount AS amount,
    ss.id AS shelf,
    ss.description AS shelf_desc,
    s.items AS stock
FROM order_tab AS o
    inner join order_detail AS d
        on o.id = d.order_id
    inner join product AS p
        on p.id = d.prod_id
    inner join stock AS s
        on s.prod_id = p.id
    inner join  stock_shelf as ss
        on ss.id = s.shelf_id
ORDER BY
d.id;
--
-- Procedure for picklist_order
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
-- procedure for ship an order
--
DROP  PROCEDURE  IF  EXISTS ship_order;
DELIMITER ;;
CREATE  PROCEDURE ship_order(
    a_id char(10)
)
BEGIN
    UPDATE  order_tab
        SET
            delivered = CURRENT_TIMESTAMP
    WHERE id = a_id and ordered is not null;
END
;;
DELIMITER ;

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
DECLARE YOUCURNAME CURSOR FOR SELECT productid, amount FROM v_picklist WHERE orderid = a_id;
DECLARE CONTINUE HANDLER
    FOR NOT FOUND SET finished = 1;
  OPEN YOUCURNAME;
  myloop: LOOP
    FETCH YOUCURNAME INTO  a1, a2;
    IF finished = 1 THEN
      LEAVE myloop;
    END IF;
    UPDATE stock SET items = items - a2 WHERE prod_id = a1;
  END LOOP myloop;
  CLOSE YOUCURNAME;
END;
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
-- procedure for undo delete order
--
DROP  PROCEDURE  IF  EXISTS undelete_order;
DELIMITER ;;
CREATE  PROCEDURE undelete_order(
    a_id char(10)
)
BEGIN
    UPDATE order_tab
        SET
            deleted = null
    WHERE id = a_id;
END
;;
DELIMITER ;

--
-- procedure for undo delete order
--
DROP  PROCEDURE  IF  EXISTS search_log;
DELIMITER ;;
CREATE  PROCEDURE search_log(
    searchstring VARCHAR(100)
)
BEGIN
    select id, DATE_FORMAT(created, '%Y-%m-%d %H:%i') as date, description
    from logg
    where id like searchstring or created like searchstring or description like searchstring;
END
;;
DELIMITER ;

--
-- procedure for undo delete order
--
DROP  PROCEDURE  IF  EXISTS add_product_2cat;
DELIMITER ;;
CREATE  PROCEDURE add_product_2cat(
    a_id char(10),
    a_category varchar(10)
)
BEGIN
    insert into product2cat  values(a_id, a_category);
END
;;
DELIMITER ;

--
-- procedure for create en faktura
--
DROP  PROCEDURE  IF  EXISTS create_faktura;
DELIMITER ;;
CREATE  PROCEDURE create_faktura(
    a_id int
)
BEGIN
    DECLARE a1 int;
    DECLARE a2 int;
    select customer_id into a1 from order_tab where id = a_id;
    select order_id into a2 from faktura where order_id = a_id;
    IF a2 is null THEN
    insert into faktura(order_id, customer_id)
        values(a_id, a1);
    END IF;
END
;;
DELIMITER ;

--
-- procedure for create  faktura detail
--
DROP  PROCEDURE  IF  EXISTS create_faktura_detail;
DELIMITER ;;
CREATE  PROCEDURE create_faktura_detail(
    a_id int
)
BEGIN
DECLARE finished INTEGER DEFAULT 0;
DECLARE a1 INT;
DECLARE a2 char(10);
DECLARE a3 FLOAT;
DECLARE YOUCURNAME CURSOR FOR SELECT f.id, v.productid, v.amount
FROM v_picklist as v
join faktura as f
on orderid = f.id
where orderid = a_id;
DECLARE CONTINUE HANDLER
    FOR NOT FOUND SET finished = 1;
  OPEN YOUCURNAME;
  myloop: LOOP
    FETCH YOUCURNAME INTO  a1, a2, a3;
    IF finished = 1 THEN
      LEAVE myloop;
    END IF;
    Insert into faktura_detail (faktura_id, prod_id, amount)
     values(a1, a2, a3);
  END LOOP myloop;
  CLOSE YOUCURNAME;
END;
;;
DELIMITER ;

--
-- View for customer, faktura and faktura_detail
--
DROP view if exists  v_customer_faktura_fd;
CREATE VIEW v_customer_faktura_fd
AS
SELECT
    f.*, d.prod_id, d.amount, p.price, p.name, p.image,
     c.firstname, c.lastname, c.email, c.birth,
     c.telephone,c.postcode,c.city,c.country, c.address
FROM customer AS c
    JOIN faktura AS f
        ON c.id = f.customer_id
    JOIN faktura_detail AS d
        ON f.id = d.faktura_id
    join product as p
        ON d.prod_id = p.id
    order by
    f.id
;

--
-- procedure for show all faktura
--
DROP  PROCEDURE  IF  EXISTS show_faktura;
DELIMITER ;;
CREATE  PROCEDURE show_faktura()
BEGIN
    SELECT *, IFNULL(sum(amount), 0) as amount,
    DATE_FORMAT(fakturadate, '%Y-%m-%d %H:%i') as date,
    order_status(order_id) as status,
    IF(paid, "yes", "no") as paid_status
    FROM  v_customer_faktura_fd
    group by
    id;
END
;;
DELIMITER ;

--
-- procedure for show faktura detail with fakturaId
--
DROP  PROCEDURE  IF  EXISTS show_faktura_detail;
DELIMITER ;;
CREATE  PROCEDURE show_faktura_detail(
    a_id int
)
BEGIN
    SELECT *, amount,
    DATE_FORMAT(fakturadate, '%Y-%m-%d %H:%i') as date,
    order_status(order_id) as status, IF(paid, "yes", "no") as paid_status
    FROM  v_customer_faktura_fd
    where id = a_id;
END
;;
DELIMITER ;

--
-- procedure for change faktura to paid
--
DROP  PROCEDURE  IF  EXISTS payed;
DELIMITER ;;
CREATE  PROCEDURE payed(
    a_id int
)
BEGIN
    update faktura
        set paid = CURRENT_TIMESTAMP
    where id = a_id;
END
;;
DELIMITER ;
