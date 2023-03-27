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
    
WITH last_month_transactions AS (
    SELECT
        td.customer_id,
        td.item_id,
        td.item_number,
        td.transaction_dttm
    FROM
        transaction_details td
    WHERE
        td.transaction_dttm > CURRENT_DATE - INTERVAL '30 DAY'
),
transaction_prices AS (
    SELECT
        lmt.customer_id,
        lmt.item_id,
        lmt.item_number,
        lmt.transaction_dttm,
        ip.item_name,
        ip.item_price
    FROM
        last_month_transactions lmt
    JOIN
        item_prices ip ON lmt.item_id = ip.item_id AND lmt.transaction_dttm BETWEEN ip.valid_from_dt AND ip.valid_to_dt
),
total_spent AS (
    SELECT
        customer_id,
        item_name,
        SUM(item_number * item_price) AS amount_spent
    FROM
        transaction_prices
    GROUP BY
        customer_id, item_name
),
max_spent AS (
    SELECT
        customer_id,
        MAX(amount_spent) AS max_amount_spent
    FROM
        total_spent
    GROUP BY
        customer_id
)
SELECT
    tp.customer_id,
    tp.amount_spent AS amount_spent_1m,
    tp.item_name AS top_item_1m
FROM
    total_spent tp
JOIN
    max_spent ms ON tp.customer_id = ms.customer_id AND tp.amount_spent = ms.max_amount_spent
ORDER BY
    tp.customer_id;
