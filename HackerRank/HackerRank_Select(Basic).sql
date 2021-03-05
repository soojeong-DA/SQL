/*Basic Select*/
-- Weather Observation Station 3
SELECT DISTINCT name
FROM station
WHERE id % 2 = 0;

-- Weather Observation Station 5
-- -- 따로 출력
SELECT city, LENGTH(city) as name_length
FROM station
ORDER BY name_length, city
LIMIT 1;

SELECT city, LENGTH(city) as name_length
FROM station
ORDER BY name_length DESC, city
LIMIT 1;

-- -- 한번에 출력
SELECT city,
        length(city)
FROM (SELECT city,
            ROW_NUMBER() OVER(ORDER BY length(city), city) AS short_RNK,
            ROW_NUMBER() OVER(ORDER BY length(city) DESC, city) AS long_RNK
        FROM station
        GROUP BY 1) TMP
WHERE short_RNK = 1
OR long_RNK = 1;

-- Weather Observation Station 6
-- -- SUBSTR
SELECT DISTINCT city
FROM station
WHERE SUBSTR(city,1,1) IN ('i','o','u','e','a');

-- -- REGEXP
SELECT DISTINCT city
FROM station
WHERE city REGEXP '^[aeiou]';

-- Weather Observation Station 7
-- -- SUBSTR
SELECT DISTINCT city
FROM station
WHERE SUBSTR(city,-1,1) IN ('a','e','i','o','u');

-- -- REGEXP
SELECT DISTINCT city
FROM station
WHERE city REGEXP '[aeiou]$';

-- Weather Observation Station 9
-- -- SUBSTR
SELECT DISTINCT city
FROM station
WHERE SUBSTR(city,1,1) NOT IN ('a','e','i','o','u');

-- -- REGEXP
SELECT DISTINCT city
FROM station
WHERE city regexp '^[^aeiou]';

-- Weather Observation Station 10
-- -- REGEXP
SELECT DISTINCT city
FROM station
WHERE city regexp '[^aeiou]$';

-- Higher Than 75 Marks
SELECT name
FROM students
WHERE marks > 75
ORDER BY SUBSTR(name,-3), id;  -- 뒤에서 3번째부터 끝까지(생략가능)

