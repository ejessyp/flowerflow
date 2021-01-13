--produce the plocklist
DROP VIEW IF EXISTS v_plocklist;
CREATE view v_plocklist AS
SELECT
    o.id AS ordernumber,
    d.id AS orderDetail_id,
    d.sellCount AS sellCount,
    p.description AS description,
    ss.id AS shelf,
    ss.description AS shelf_desc,
    s.items AS itemsA
FROM order_tab AS o
    inner join orderDetail AS d
        on o.id = d.order_id
    inner join product AS p
        on d.prod_id = p.id
    inner join stock AS s
        on s.prod_id = p.id
    inner join  stockShelf as ss
        on ss.id = s.shelf_id
ORDER BY orderDetail_id;
