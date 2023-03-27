CREATE TABLE social_posts (
    id INT,
    created_at TIMESTAMP,
    header VARCHAR(255)
);

INSERT INTO social_posts (id, created_at, header) VALUES
		-- February
    (1, '2022-02-01 08:50:58', 'Post 1'),
    (2, '2022-02-02 18:36:41', 'Post 2'),
    (3, '2022-02-10 16:16:17', 'Post 3'),
    (4, '2022-02-15 18:01:00', 'Post 4'),
    (5, '2022-02-28 16:44:36', 'Post 5'),

		-- March
    (6, '2022-03-01 14:57:32', 'Post 6'),
    (7, '2022-03-02 09:30:20', 'Post 7'),
    (8, '2022-03-05 11:55:12', 'Post 8'),
    (9, '2022-03-08 13:05:43', 'Post 9'),
    (10, '2022-03-10 15:25:31', 'Post 10'),
    (11, '2022-03-12 17:40:55', 'Post 11'),
    (12, '2022-03-15 10:07:29', 'Post 12'),
    (13, '2022-03-18 12:33:46', 'Post 13'),
    (14, '2022-03-22 14:12:59', 'Post 14'),
    (15, '2022-03-25 16:23:17', 'Post 15'),
    (16, '2022-03-28 18:45:34', 'Post 16'),
    (17, '2022-03-30 09:15:41', 'Post 17'),
    (18, '2022-03-31 11:24:53', 'Post 18'),

		-- April
    (19, '2022-04-01 12:35:16', 'Post 19'),
    (20, '2022-04-04 14:46:58', 'Post 20'),
    (21, '2022-04-06 10:20:42', 'Post 21'),
    (22, '2022-04-09 12:55:30', 'Post 22'),
    (23, '2022-04-12 14:07:15', 'Post 23'),
    (24, '2022-04-15 15:22:49', 'Post 24'),
    (25, '2022-04-18 10:33:24', 'Post 25'),
    (26, '2022-04-20 12:45:38', 'Post 26'),
    (27, '2022-04-25 14:55:38', 'Post 27'),

		-- May
    (28, '2022-05-01 09:32:01', 'Post 28'),
    (29, '2022-05-06 10:20:42', 'Post 29'),
    (30, '2022-05-09 12:55:30', 'Post 30'),
    (31, '2022-05-12 14:07:15', 'Post 31'),
    (32, '2022-05-25 11:42:52', 'Post 32'),

    -- June
    (33, '2022-06-01 08:55:37', 'Post 33'),
    (34, '2022-06-01 09:32:01', 'Post 34'),
    (35, '2022-06-06 10:20:42', 'Post 35'),
    (36, '2022-06-09 12:55:30', 'Post 36'),
    (37, '2022-06-28 16:30:18', 'Post 37');
    
WITH monthly_counts AS (
    SELECT
        DATE_TRUNC('month', created_at) AS dt,
        COUNT(*) AS count
    FROM
        social_posts
    GROUP BY
        DATE_TRUNC('month', created_at)
),
percentage_growth AS (
    SELECT
        mc.dt,
        mc.count,
        ROUND(100 * (mc.count - LAG(mc.count) OVER (ORDER BY mc.dt)) / LAG(mc.count) OVER (ORDER BY mc.dt),1) AS prcnt_growth
    FROM
        monthly_counts mc
)
SELECT
    dt,
    count,
    COALESCE(CAST(prcnt_growth AS VARCHAR) || '%', 'zero') AS prcnt_growth
FROM
    percentage_growth
ORDER BY
    dt;