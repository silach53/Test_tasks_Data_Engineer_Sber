CREATE TABLE test (
  id INT,
  name VARCHAR(10),
  age INT
);

INSERT INTO test VALUES 
(1, 'Вася', 23),
(2, 'Петя', 40),
(3, 'Маша', 19),
(4, 'Марина', 23),
(5, 'Сергей', 34);

SELECT name
FROM (
  SELECT name, age, RANK() OVER (ORDER BY age, name) AS rank
  FROM test
) AS ranked_employees
WHERE rank <= 3;