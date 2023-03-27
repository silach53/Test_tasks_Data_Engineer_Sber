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
    ip.item_id,
    ip.item_name,
    ip.item_price,
    ip.created_dttm AS valid_from_dt,
    COALESCE((LEAD(ip.created_dttm) OVER (PARTITION BY ip.item_id ORDER BY ip.created_dttm))::date - INTERVAL '1 DAY', '9999-12-31') AS valid_to_dt
FROM
    item_prices ip
ORDER BY
    ip.item_id, ip.created_dttm;
