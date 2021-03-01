/*Aggregation (Easy) =====*/

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
-- 풀이1 - ernings grouping, 정렬 후 limit로 자르기
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

/* Weather Observation Station 2 */
SELECT ROUND(SUM(LAT_N),2),
        ROUND(SUM(LONG_W),2)
FROM STATION;

/* Weather Observation Station 13 */
SELECT TRUNCATE(SUM(LAT_N),4)
FROM STATION
WHERE LAT_N BETWEEN 38.7880 AND 137.2345;

/* Weather Observation Station 14 */
SELECT TRUNCATE(MAX(LAT_N),4)
FROM STATION
WHERE LAT_N < 137.2345;

/* Weather Observation Station 15 */
-- 1. LIMIT으로 자르기
SELECT ROUND(LONG_W,4) 
FROM STATION 
WHERE LAT_N < 137.2345 
ORDER BY LAT_N DESC
LIMIT 1;

-- 2. 서브쿼리이용
SELECT ROUND(LONG_W,4)
FROM STATION
WHERE LAT_N = (SELECT MAX(LAT_N)
              FROM STATION
              WHERE LAT_N < 137.2345);

/* Weather Observation Station 16 */
SELECT ROUND(MIN(LAT_N),4)
FROM STATION
WHERE LAT_N > 38.7780;

/* Weather Observation Station 17 */
-- 1. LIMIT으로 자르기
SELECT ROUND(LONG_W,4) 
FROM STATION 
WHERE LAT_N > 38.7780 
ORDER BY LAT_N 
LIMIT 1;

-- 2. 서브쿼리이용
SELECT ROUND(LONG_W,4)
FROM STATION
WHERE LAT_N = (SELECT MIN(LAT_N)
              FROM STATION
              WHERE LAT_N > 38.7780);
