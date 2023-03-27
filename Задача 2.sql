CREATE TABLE calls (
	abonent BIGINT,
	region_id INT,
	dttm TIMESTAMP
);

INSERT INTO calls (abonent, region_id, dttm) VALUES
(7072110988, 32722, '2021-08-18 13:15'),
(7072110988, 32722, '2021-08-18 14:00'),
(7072110988, 21534, '2021-08-18 14:15'),
(7072110988, 32722, '2021-08-19 09:00'),
(7071107101, 12533, '2021-08-19 09:15'),
(7071107101, 32722, '2021-08-19 09:27');

WITH last_location AS (
    SELECT 
        abonent,
        MAX(dttm) AS dttm
    FROM calls
    GROUP BY abonent, DATE(dttm)
)
SELECT 
    ll.abonent,
    c.region_id,
    ll.dttm
FROM last_location ll
JOIN calls c ON ll.abonent = c.abonent AND ll.dttm = c.dttm
ORDER BY ll.abonent, ll.dttm;
