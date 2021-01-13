-- LOAD LOCAL INFILE can be closed on the server side, so set on it
--SET GLOBAL local_infile = 1;

--
-- Insert into customer
--
DELETE FROM customer;

LOAD DATA LOCAL INFILE 'customer.csv'
INTO TABLE customer
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
SET created = CURRENT_TIMESTAMP
;

--
-- Insert into category
--
DELETE FROM category;
LOAD DATA LOCAL INFILE 'category.csv'
INTO TABLE category
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
;

--
-- Insert into device
--
-- DELETE FROM device;
-- LOAD DATA LOCAL INFILE 'device.csv'
-- INTO TABLE device
-- CHARSET utf8
-- FIELDS
--     TERMINATED BY ','
--     ENCLOSED BY '"'
-- LINES
--     TERMINATED BY '\n'
-- IGNORE 1 LINES
-- ;

--
-- Insert into device
--
DELETE FROM device;
LOAD DATA LOCAL INFILE 'device.csv'
INTO TABLE device
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
SET created = CURRENT_TIMESTAMP
;


--
-- Insert into device2cat
--
DELETE FROM device2cat;
LOAD DATA LOCAL INFILE 'device2cat.csv'
INTO TABLE device2cat
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
;
--
-- Insert into stock_shelf
--
DELETE FROM stock_shelf;
LOAD DATA LOCAL INFILE 'stock_shelf.csv'
INTO TABLE stock_shelf
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
;
--
-- Insert into stock
--
DELETE FROM stock;
LOAD DATA LOCAL INFILE 'stock.csv'
INTO TABLE stock
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
(device_id, items, shelf_id)
;

-- --
-- -- Insert into userinfo
-- --
-- DELETE FROM userinfo;
-- LOAD DATA LOCAL INFILE 'userinfo.csv'
-- INTO TABLE userinfo
-- CHARSET utf8
-- FIELDS
--     TERMINATED BY ','
--     ENCLOSED BY '"'
-- LINES
--     TERMINATED BY '\n'
-- IGNORE 1 LINES
-- ;
