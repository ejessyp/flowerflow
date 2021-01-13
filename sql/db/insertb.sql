use eshop;
DELETE FROM product;
DELETE FROM order_tab;
DELETE FROM faktura;
DELETE FROM stock;
DELETE FROM logg;
DELETE FROM category;
DELETE FROM customer;
DELETE FROM fakturaDetail;
DELETE FROM orderDetail;
DELETE FROM stockShelf;


INSERT INTO category
    (type)
VALUES
    ('red tea'),
    ('green tea'),
    ('black tea'),
    ('coffee powder'),
    ('coffee beans'),
    ('tea mugg'),
    ('coffee mugg')
;

INSERT INTO customer VALUES
    (1, '7401011212', 'Arvid', 'Ericsson', 'M', 'a123@gmail.com', '1951-05-01', '0708 23 45 67', 'Motoroad 1, Karlskrona'),
    (2, '7401011213', 'Nelly', 'Petersson', 'W', 'n124@gmail.com', '1990-11-01', '0708 23 45 68', 'Motoroad 2, Karlskrona'),
    (3, '7401011214', 'Molly', 'Holly', 'W', 'm125@gmail.com', '1970-12-11', '0708 23 45 69', 'Motoroad 3, Karlskrona'),
    (4, '7401011215', 'Peter', 'Rosh', 'M', 'p123@gmail.com', '1981-07-01', '0708 23 45 70', 'Motoroad 4, Karlskrona')
;

INSERT INTO product VALUES
    ('1', 'lipton tea bag', 'this is a sample description of lipton', 20, 1),
    ('2', 'lanvaza coffe', 'this is a sample description of lanvaza', 40, 5),
    ('3', 'Iilly coffe', 'this is a sample description of Iilly', 60, 4)
;
