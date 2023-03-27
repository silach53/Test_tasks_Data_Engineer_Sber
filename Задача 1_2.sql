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

SELECT t1.name
FROM test t1
LEFT JOIN test t2 ON t1.age > t2.age
GROUP BY t1.id, t1.name, t1.age
HAVING COUNT(t2.id) < 3
ORDER BY t1.age, t1.name;