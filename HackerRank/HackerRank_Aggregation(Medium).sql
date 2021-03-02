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
-- 1. 제공함수로 풀기 - Oracle
SELECT ROUND(MEDIAN(LAT_N),4)
FROM STATION;

-- 2. 함수 사용하지 않고, 순위 이용해 풀기 - MySQL
SELECT ROUND(LAT_N,4)
FROM (SELECT LAT_N,
            ROW_NUMBER() OVER(ORDER BY LAT_N DESC) AS RNK
     FROM STATION) T
WHERE RNK = (SELECT CASE WHEN MAX(RNK)%2=0 THEN MAX(RNK)/2
                    ELSE (MAX(RNK)+1)/2 END
            FROM (SELECT LAT_N,
                    ROW_NUMBER() OVER(ORDER BY LAT_N DESC) AS RNK
                FROM STATION) T);
                
-- 3. 함수 사용하지 않고, 개수(like 순위)이용해 풀기 - MySQL
SELECT ROUND(LAT_N, 4)
FROM STATION S
WHERE (SELECT COUNT(*) FROM STATION WHERE LAT_N < S.LAT_N)
		= (SELECT COUNT(*) FROM STATION WHERE LAT_N > S.LAT_N);