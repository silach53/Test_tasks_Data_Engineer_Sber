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

SELECT c1.abonent, c1.region_id, c1.dttm
FROM calls c1
LEFT JOIN calls c2 ON c1.abonent = c2.abonent AND DATE(c1.dttm) = DATE(c2.dttm) AND c1.dttm < c2.dttm
WHERE c2.abonent IS NULL
ORDER BY c1.abonent, c1.dttm;