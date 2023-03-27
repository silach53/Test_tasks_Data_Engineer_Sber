# Сбер

Тестовое задание
Примечание:

1. Можно использовать любой диалект SQL с его указанием при решении;
2. Краткость и форматирование кода приветствуются.

---

## Задача 1

Задание: необходимо найти 3-х самых молодых сотрудников в коллективе и выдать их имена,
предварительно отсортировав. Задачу требуется решить несколькими способами (чем больше, тем
лучше).
Можно использовать следующий ddl:

```cpp
create table test (id number, name varchar2(10),
 age number);
insert into test values (1, 'Вася', 23);
insert into test values (2, 'Петя', 40);
insert into test values (3, 'Маша', 19);
insert into test values (4, 'Марина', 23);
insert into test values (5, 'Сергей', 34);
```

Я предоставлю решения, использующие диалект PostgreSQL, поскольку он широко используется и поддерживается. Ниже приведены несколько способов найти 3-х самых молодых сотрудников в команде и вывести их имена в отсортированном виде.

Создадим таблицу на PostgreSQL

```sql
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
```

### Решение 1: Использующее **`LIMIT` и `ORDER BY`**

```sql
SELECT name
FROM test
ORDER BY age, name
LIMIT 3;
```

Этот запрос сортирует сотрудников по возрасту в порядке возрастания, а затем по имени. Он использует предложение **`LIMIT`** для возврата только первых 3 строк отсортированного результирующего набора.

### Решение 2: Использующее **`JOIN` и `GROUP BY`**

```sql
SELECT t1.name
FROM test t1
LEFT JOIN test t2 ON t1.age > t2.age
GROUP BY t1.id, t1.name, t1.age
HAVING COUNT(t2.id) < 3
ORDER BY t1.age, t1.name;
```

В этом альтернативном решении мы выполняем self JOIN на test таблице, объединяя строки, где возраст первой таблицы (t1) больше возраста второй таблицы (t2). Затем мы группируем результаты по столбцам id, name и age первой таблицы и используем HAVING для фильтрации групп с количеством строк меньше 3 из второй таблицы (t2). Это означает, что мы выбираем только 3 самых молодых сотрудников. Наконец, мы сортируем результаты по возрасту и имени.

### Решение 3: Использующее  **`RANK()`**

```sql
SELECT name
FROM (
  SELECT name, age, RANK() OVER (ORDER BY age, name) AS rank
  FROM test
) AS ranked_employees
WHERE rank <= 3;
```

В данном решении используется оконная функция RANK() для присвоения ранга каждому сотруднику на основе его возраста и имени. Затем набор результатов фильтруется, чтобы включить только сотрудников с рангом 3 или ниже.

Все эти решения приведут к одному и тому же результату - отсортированным именам 3-х самых молодых сотрудников. Первое решение является наиболее кратким и простым для понимания. Второе решение использует подзапрос, который может быть полезен, когда вам нужно дополнительно манипулировать результирующим набором. Третье решение демонстрирует использование оконных функций, которые могут быть полезны в более сложных сценариях.

### Результат всех команд

```
CREATE TABLE
INSERT 0 5
  name  
--------
 Маша
 Вася
 Марина
(3 rows)
```

---

## Задача 2

Есть таблица:

| abonent  | region_id | dttm |
| --- | --- | --- |
| 7072110988  | 32722 | 2021-08-18 13:15 |
| 7072110988 | 32722 | 2021-08-18 14:00 |
| 7072110988  | 21534 | 2021-08-18 14:15 |
| 7072110988 | 32722  | 2021-08-19 09:00 |
| 7071107101  | 12533  | 2021-08-19 09:15 |
| 7071107101  | 32722  | 2021-08-19 09:27 |

 Описание атрибутов:

1. abonent – номер абонента;
2. region_id – id региона в котором находится абонент;
3. dttm – день и время звонка.
4. Задание: нужно для каждого дня определить последнее местоположение абонента.
То есть нужно вывести:

| abonent  | region_id | dttm |
| --- | --- | --- |
| 7072110988  | 21534 | 2021-08-18 14:15 |
| 7072110988 | 32722  | 2021-08-19 09:00 |
| 7071107101  | 32722  | 2021-08-19 09:27 |

Вот код PostgreSQL для создания таблицы и вставки данных:

```sql
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
```

Теперь я предоставлю запрос для определения последнего местоположения подписчика за каждый день:

```sql
SELECT c1.abonent, c1.region_id, c1.dttm
FROM calls c1
LEFT JOIN calls c2 ON c1.abonent = c2.abonent AND DATE(c1.dttm) = DATE(c2.dttm) AND c1.dttm < c2.dttm
WHERE c2.abonent IS NULL
ORDER BY c1.abonent, c1.dttm;
```

Этот запрос использует self `LEFT JOIN` в таблице `calls` для объединения строк с тем же **`abonent`** и той же датой (**`DATE(c1.dttm) = DATE(c2.dttm)`**), но где `dttm` первой таблицы меньше, чем `dttm` второй таблицы. Предложение `WHERE` фильтрует результирующий набор так, чтобы он включал только строки, в которых значение второй таблицы равно NULL, что означает, что более поздней записи для того же значения и даты не существует. Наконец, запрос упорядочивает результаты по `abonent` и `dttm`.

Это решение эффективно определяет последнее местоположение подписчика за каждый день, используя автоматическое **`LEFT JOIN`** и фильтрацию на основе отсутствия более поздней записи.

### Результат всех команд

```
CREATE TABLE
INSERT 0 6
  abonent   | region_id |        dttm         
------------+-----------+---------------------
 7071107101 |     32722 | 2021-08-19 09:27:00
 7072110988 |     21534 | 2021-08-18 14:15:00
 7072110988 |     32722 | 2021-08-19 09:00:00
(3 rows)
```

---

### Задача 3

Есть таблица item_prices:

| Название столбца | Тип  | Описание |
| --- | --- | --- |
| item_id  | number(21,0)  | Идентификатор товара |
| item_name  |  varchar2(150) | Название товара |
| item_price | number(12,2) | Цена товара |
| created_dttm | created_dttm | Дата добавления записи |

Задание: необходимо сформировать таблицу следующего вида dict_item_prices.

Название столбца Тип Описание

| Название столбца | Тип  | Описание |
| --- | --- | --- |
| item_id  | Идентификатор  | Идентификатор товара |
| item_name  |  varchar2(150) | Название товара |
| item_price | number(12,2) | Цена товара |
| created_dttm | created_dttm | Дата добавления записи |
| valid_from_dt  | date |  Дата, с которой начала действовать данная цена (created_dttm
записи с ценой) |
| valid_to_dt  | date  | Дата, до которой действовала данная цена (created_dttm
следующей записи по данному товару «минус» один день) |

Примечание: для последней (действующей на данный момент) цены устанавливается дата 9999-12-31.

### Решение задачи 3

Сначала давайте создадим таблицу `item_prices` и вставим некоторые примеры данных:

```sql
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
```

Теперь давайте создадим запрос, который выведет таблицу `dict_item_prices`, как описано:

```sql
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
```

Этот запрос выполняет самостоятельное ЛЕВОЕ СОЕДИНЕНИЕ в таблице **`item_prices`** для объединения строк с тем же **`item_id`**, но где значение **`created_dttm`** первой таблицы меньше значения **`created_dttm`** второй таблицы. В предложении SELECT мы используем функцию **`COALESCE`** для отображения **`created_dttm`** следующей записи для этого продукта "минус" один день в качестве столбца **`valid_to_dt`**. Если следующей записи не существует, используется дата "9999-12-31".

Предложение WHERE фильтрует результирующий набор, чтобы включать только строки, в которых значение **`created_dttm`** второй таблицы равно нулю (более поздняя запись не существует) или минимальное значение **`created_dttm`** больше, чем значение **`created_dttm`** первой таблицы для того же **`item_id`**.

Наконец, запрос упорядочивает результаты по **`item_id`** и **`created_dttm`**.

Это решение обеспечивает требуемый вывод, включая столбцы valid_from_dt и valid_to_dt, с помощью самостоятельного LEFT JOIN и фильтрации на основе минимального created_dttm следующей записи.

### Результат всех команд

```
CREATE TABLE
INSERT 0 5
 item_id | item_name | item_price |    created_dttm     |    valid_from_dt    |     valid_to_dt     
---------+-----------+------------+---------------------+---------------------+---------------------
       1 | Product A |      10.00 | 2022-01-01 00:00:00 | 2022-01-01 00:00:00 | 2022-01-31 00:00:00
       1 | Product A |      12.00 | 2022-02-01 00:00:00 | 2022-02-01 00:00:00 | 9999-12-31 00:00:00
       2 | Product B |      15.00 | 2022-01-15 00:00:00 | 2022-01-15 00:00:00 | 2022-02-14 00:00:00
       2 | Product B |      16.00 | 2022-02-15 00:00:00 | 2022-02-15 00:00:00 | 2022-02-28 00:00:00
       2 | Product B |      18.00 | 2022-03-01 00:00:00 | 2022-03-01 00:00:00 | 9999-12-31 00:00:00
(5 rows)
```

---

## Задача 4

Есть исходная таблица детализации по транзакциям transaction_details:

| Название столбца | Тип | Описание |
| --- | --- | --- |
| transaction_id | number(21,0) | Идентификатор транзакции |
| customer_id  | number(21,0) | Идентификатор клиента |
| item_id | number(21,0) | Идентификатор товара |
| item_number | number(8,0) | Количество купленных единиц товара |
| transaction_dttm | timestamp |  Дата-время транзакции |

Задание: необходимо сформировать таблицу следующего вида customer_aggr:

| Название столбца | Тип | Описание |
| --- | --- | --- |
| customer_id | number(21,0) | Идентификатор клиента |
| amount_spent_1m  | number(12,2)  | Потраченная клиентом сумма за последний месяц |
| top_item_1m | varchar2(150)  | Товар (item_name), на который за последний месяц клиент потратил больше всего |

 Примечание:
• при расчете необходимо учитывать актуальную цену на момент совершения транзакции (по
справочнику dict_item_prices из Задача 3);
• клиенты, не совершавшие покупок в последний месяц, в итоговую таблицу не попадают;
• последний месяц определяется как последние 30 дней на момент построения отчета.

### Решение задачи 4

Сначала давайте создадим таблицу `transaction_details` и вставим некоторые примеры данных:

```sql
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
```

А также таблицу **`item_prices`**

```sql
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
```

Теперь давайте создадим запрос, который выведет таблицу **`customer_aggr`**, как описано:

```sql
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
```

Этот запрос сначала фильтрует транзакции, совершенные за последние 30 дней, используя предложение `WHERE`. Затем он объединяет таблицу `transaction_details` с таблицей `item_prices` на основе `item_id` и `transaction_dttm`, находящихся в диапазоне `valid_from_dt` и `valid_to_dt`.

Запрос группирует результаты по `customer_id` и `item_name`, вычисляя сумму, потраченную на каждый товар, путем умножения `item_number` на `item_price`. Условие `HAVING` гарантирует возврат только максимальной суммы, потраченной клиентом на один товар.

Это решение учитывает текущую цену на момент транзакции с использованием каталога `dict_item_prices` из задачи 3 и фильтрует клиентов, которые не совершали покупок в течение последнего месяца.

### Результат всех команд

```
CREATE TABLE
INSERT 0 12
CREATE TABLE
INSERT 0 5
 customer_id | amount_spent_1m | top_item_1m 
-------------+-----------------+-------------
         300 |           54.00 | Product B
         400 |           36.00 | Product A
(2 rows)
```

---

## Задача 5

Существует таблица публикаций posts в социальных сетях с указанием даты и названием публикации.
Задание: рассчитать количество публикаций в месяц с указанием первой даты месяца и долей
увеличения количества сообщений (публикаций) относительно предыдущего месяца.
Данные в результирующей таблице должны быть упорядочены в хронологическом порядке.
Примечание: доля увеличения количества сообщений может быть отрицательной, а результат должен
быть округлен до одного знака после запятой с добавлением знака %.

Table posts (пример)

| id | created_at | title |
| --- | --- | --- |
| 1 | 2022-01-17 08:50:58 | Sberbank is the best bank |
| 2 | 2022-01-17 18:36:41 | Visa vs Mastercard |
| 3 | 2022-01-17 16:16:17 | Visa vs UnionPay |
| 4 | 2022-01-17 18:01:00 | Mastercard vs UnionPay |
| 5 | 2022-01-16 16:44:36 | Hadoop or Greenplum: pros and cons |
| 6 | 2022-01-16 14:57:32 | NFC: wireless payment |

Table results (пример для наглядного результата, с таблицей posts не соотносится 1 к 1)

| dt  | count | prcnt_growth |
| --- | --- | --- |
| 2022-02-01 | 175 | null |
| 2022-03-01 | 338 | 93.1% |
| 2022-04-01  | 345  | 2.1% |
| 2022-05-01 | 295 | -14.5% |
| 2022-06-01 | 330  | 11.9% |

### Решение задачи 5

Сначала давайте создадим таблицу **`social_posts`** и вставим некоторые примеры данных:

```sql
CREATE TABLE social_posts (
    id INT,
    created_at TIMESTAMP,
    header VARCHAR(255)
);

INSERT INTO social_posts (id, created_at, header) VALUES
    (1, '2022-01-17 08:50:58', 'Sberbank is the best bank'),
    (2, '2022-01-17 18:36:41', 'Visa vs. Mastercard'),
    (3, '2022-01-17 16:16:17', 'Visa vs. UnionPay'),
    (4, '2022-01-17 18:01:00', 'Mastercard vs. UnionPay'),
    (5, '2022-01-16 16:44:36', 'Hadoop or Greenplum: Pros and cons'),
    (6, '2022-01-16 14:57:32', 'NFC: Wireless payment');
```

Теперь давайте создадим запрос, который выдаст желаемый результат:

```sql
WITH monthly_counts AS (
    SELECT
        DATE_TRUNC('month', created_at) AS dt,
        COUNT(*) AS quantity
    FROM
        social_posts
    GROUP BY
        DATE_TRUNC('month', created_at)
),
percentage_growth AS (
    SELECT
        mc.dt,
        mc.quantity,
        ROUND(100 * (mc.quantity - LAG(mc.quantity) OVER (ORDER BY mc.dt)) / LAG(mc.quantity) OVER (ORDER BY mc.dt),1) AS prcnt_growth
    FROM
        monthly_counts mc
)
SELECT
    dt,
    quantity,
    COALESCE(CAST(prcnt_growth AS VARCHAR) || '%', 'zero') AS prcnt_growth
FROM
    percentage_growth
ORDER BY
    dt;
```

Запрос использует два Common Table Expressions (CTE). Первый CTE, **`monthly_counts`**, вычисляет количество записей за каждый месяц путем усечения временной метки до уровня месяца, а затем группировки и подсчета записей. Второй CTE, **`percentage_growth`**, вычисляет процентный рост количества сообщений по сравнению с предыдущим месяцем, используя оконную функцию **`LAG()`**.

Наконец, основная инструкция SELECT извлекает столбцы **`dt`**, **`количество`** и **`prcnt_growth`**. Если **`prcnt_growth`** равно NULL, вместо него используется строка 'zero'. Результаты упорядочены по столбцу **`dt`** в порядке возрастания.

### Результат всех команд

```
CREATE TABLE
INSERT 0 6
         dt          | quantity | prcnt_growth 
---------------------+----------+--------------
 2022-01-01 00:00:00 |        6 | zero
(1 row)
```
