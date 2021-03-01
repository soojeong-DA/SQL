/*Aggregation (Medium)=====*/

/* Weather Observation Station 18 */
-- 두 지점간 거리 - 맨해튼 거리(Manhattan Distance)
SELECT ROUND((MAX(LAT_N) - MIN(LAT_N)) + (MAX(LONG_W) - MIN(LONG_W)), 4)
FROM STATION;

/* Weather Observation Station 19 */
-- 유클리드 거리(Euclidean Distance)
SELECT ROUND(SQRT(POW(MAX(LAT_N)-MIN(LAT_N),2) + POW(MAX(LONG_W)-MIN(LONG_W),2)) ,4)
FROM STATION;

/* Weather Observation Station 20 */
-- Oracle 사용
-- 1. 제공함수로 풀기
SELECT ROUND(MEDIAN(LAT_N),4)
FROM STATION;

-- 2. 함수 사용하지 않고, 순위를 이용해 풀기

