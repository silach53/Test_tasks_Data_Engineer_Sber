CREATE TABLE item_prices (
    item_id INT,
    item_name VARCHAR(150),
    item_price NUMERIC(12, 2),
    created_dttm TIMESTAMP
);

INSERT INTO item_prices (item_id, item_name, item_price, created_dttm) VALUES
    (1, 'Product A', 10.00, '2022-01-01'),
    (1, 'Product A', 12.00, '2022-02-01'),
    (2, 'Product B', 15.00, '2022-01-15'),
    (2, 'Product B', 16.00, '2022-02-15'),
    (2, 'Product B', 18.00, '2022-03-01');
    
SELECT
    ip1.item_id,
    ip1.item_name,
    ip1.item_price,
    ip1.created_dttm,
    ip1.created_dttm AS valid_from_dt,
    COALESCE(ip2.created_dttm::date - INTERVAL '1 DAY', '9999-12-31') AS valid_to_dt
FROM
    item_prices ip1
LEFT JOIN
    item_prices ip2 ON ip1.item_id = ip2.item_id AND ip1.created_dttm < ip2.created_dttm
WHERE
    ip2.created_dttm IS NULL OR ip2.created_dttm = (
        SELECT MIN(ip3.created_dttm)
        FROM item_prices ip3
        WHERE ip3.item_id = ip1.item_id AND ip3.created_dttm > ip1.created_dttm
    )
ORDER BY
    ip1.item_id, ip1.created_dttm;