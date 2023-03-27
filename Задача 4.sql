CREATE TABLE transaction_details (
    transaction_id INT,
    customer_id INT,
    item_id INT,
    item_number INT,
    transaction_dttm TIMESTAMP
);

INSERT INTO transaction_details (transaction_id, customer_id, item_id, item_number, transaction_dttm) VALUES
    (1, 100, 1, 2, '2022-08-10 10:00:00'),
    (2, 100, 2, 1, '2022-08-20 14:00:00'),
    (3, 100, 1, 3, '2022-09-01 09:00:00'),
    (4, 200, 2, 2, '2022-08-15 16:00:00'),
    (5, 200, 1, 1, '2022-08-25 11:00:00'),
    (6, 200, 2, 4, '2022-09-05 13:00:00'),
    (7, 300, 1, 2, '2023-03-05 10:00:00'),
    (8, 300, 2, 3, '2023-03-10 14:00:00'),
    (9, 300, 1, 4, '2023-03-15 09:00:00'),
    (10, 400, 2, 2, '2023-03-20 16:00:00'),
    (11, 400, 1, 3, '2023-03-25 11:00:00'),
    (12, 400, 2, 1, '2023-03-26 13:00:00');
    
CREATE TABLE item_prices (
    item_id INT,
    item_name VARCHAR(150),
    item_price NUMERIC(12, 2),
    valid_from_dt TIMESTAMP,
    valid_to_dt TIMESTAMP
);

INSERT INTO item_prices (item_id, item_name, item_price, valid_from_dt, valid_to_dt) VALUES
    (1, 'Product A', 10.00, '2022-01-01', '2022-02-01'),
    (1, 'Product A', 12.00, '2022-02-01', '9999-12-31'),
    (2, 'Product B', 15.00, '2022-01-15', '2022-02-15'),
    (2, 'Product B', 16.00, '2022-02-15', '2022-03-01'),
    (2, 'Product B', 18.00, '2022-03-01', '9999-12-31');
    
SELECT
    td.customer_id,
    SUM(td.item_number * ip.item_price) AS amount_spent_1m,
    ip.item_name AS top_item_1m
FROM
    transaction_details td
JOIN
    item_prices ip ON td.item_id = ip.item_id
WHERE
    td.transaction_dttm > CURRENT_DATE - INTERVAL '30 DAY'
    AND ip.valid_from_dt <= td.transaction_dttm
    AND ip.valid_to_dt >= td.transaction_dttm
GROUP BY
    td.customer_id, ip.item_name
HAVING
    SUM(td.item_number * ip.item_price) = (
        SELECT MAX(sub.item_number * sub_ip.item_price)
        FROM transaction_details sub
        JOIN item_prices sub_ip ON sub.item_id = sub_ip.item_id
        WHERE sub.customer_id = td.customer_id
            AND sub.transaction_dttm > CURRENT_DATE - INTERVAL '30 DAY'
            AND sub_ip.valid_from_dt <= sub.transaction_dttm
            AND sub_ip.valid_to_dt >= sub.transaction_dttm
    )
    AND td.customer_id IN (
        SELECT DISTINCT customer_id
        FROM transaction_details
        WHERE transaction_dttm > CURRENT_DATE - INTERVAL '30 DAY'
    )
ORDER BY
    td.customer_id;