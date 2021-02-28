/*Aggregation =====*/
/* The Count Function */
SELECT COUNT(id)
FROM city
WHERE population > 100000;

/* The Sum Function */
SELECT SUM(population)
FROM city
WHERE district = 'California';

/* Averages */
SELECT AVG(population)
FROM city
WHERE district = 'California';

/* Average Population */
SELECT TRUNCATE(AVG(population),0)
FROM city;

/* Japan Population */
SELECT SUM(population)
FROM city
WHERE countrycode='JPN';

/* Population Density Difference */
SELECT MAX(population) - MIN(population)
FROM city;

/* The Blunder */
SELECT CEIL(AVG(salary) - AVG(REPLACE(salary,0,'')))
FROM employees;

/* Top Earners */
-- 풀이1 - ernings grouping, 정렬, limit 이용
SELECT salary*months AS earnings, COUNT(*)
FROM employee
GROUP BY 1
ORDER BY 1 DESC
LIMIT 1;

-- 풀이2 - 순위, 서브쿼리 이용
SELECT MAX(earning),
        COUNT(*)
FROM (SELECT MAX(months*salary) AS earning,
        RANK() OVER(ORDER BY MAX(months*salary) DESC) AS RNK
    FROM employee
    GROUP BY employee_id)T
WHERE RNK = 1;
