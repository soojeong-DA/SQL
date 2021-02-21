/*GROUP BY*/ 
SELECT *
FROM CUSTOMERS;
-- 국가, 도시별 고객수
SELECT country,
		city,
        COUNT(customernumber)
FROM CUSTOMERS
GROUP BY country, city;

/*집계 함수 내부에 CASE 구문 사용하기*/
-- USA 거주자 수 계산하고, 그 비중 구하기 (USA만!)
SELECT country,
		SUM(CASE WHEN country='USA' THEN 1 ELSE 0 END) AS 'N_USA',
        SUM(CASE WHEN country='USA' THEN 1 ELSE 0 END) / COUNT(*) AS 'USA_PORTION'
FROM CUSTOMERS;

/*LEFT JOIN(LEFT OUTER JOIN)*/
-- LEFT TABLE의 정보는 매칭되는 값이 없어도(NULL) 모두 출력됨 
DESCRIBE customers;
DESCRIBE orders;
-- customers, orders table 결합하고, ordernumber, country 출력 
SELECT O.ordernumber,
		C.country
FROM orders O
		LEFT JOIN  customers C
			ON O.customernumber = C.customernumber;
-- USA 거주자의 주문 번호, 국가 출력
SELECT O.ordernumber,
		C.country
FROM orders O
		LEFT JOIN  customers C
			ON O.customernumber = C.customernumber
WHERE C.country = 'USA';

/*INNER JOIN*/
-- 대상 테이블 모두에 공통으로 존재하는 값만 출력됨 
-- USA 거주자의 주문 번호, 국가 출력
SELECT O.ordernumber,
		C.country
FROM orders O
		INNER JOIN customers C 
        ON O.customernumber = C.customerNumber
WHERE C.country = 'USA';

/*CASE문*/
-- 조건에 따른 값을 다르게 출력하고 싶은 경우
-- 북미(Canada, USA), 비북미 출력
SELECT country,
	CASE WHEN country IN ('USA', 'Canada') THEN '북미'
	ELSE '비북미' END
FROM customers;
-- 북미, 비북미 출력 컬럼과 북미, 비북미 거주 고객의 수 계산 
SELECT 
	CASE WHEN country IN ('USA', 'Canada') THEN '북미'
			ELSE '비북미' END AS 'region',
    COUNT(*)
FROM customers
GROUP BY region;

SELECT 
	CASE WHEN country IN ('USA', 'Canada') THEN '북미'
			ELSE '비북미' END AS 'region',
    COUNT(*)
FROM customers
GROUP BY 1;

SELECT 
	CASE WHEN country IN ('USA', 'Canada') THEN '북미'
			ELSE '비북미' END AS 'region',
    COUNT(*)
FROM customers
GROUP BY CASE WHEN country IN ('USA', 'Canada') THEN '북미'
				ELSE '비북미' END;

/*순위: RANK, DENSE_RANK, ROW_NUMBER*/
-- products table - buyprice column으로 순위 매기기(오름차순, 3개 순위 모두 출력)
SELECT buyprice,
	RANK() OVER(ORDER BY buyprice) AS RNK,   -- 함수와 같은 이름으로 AS(별명) 지정 불가!!
    DENSE_RANK() OVER(ORDER BY buyprice) AS DENSE_RNK,
    ROW_NUMBER() OVER(ORDER BY buyprice) AS ROWNUMBER
FROM products;

-- products table - productline별 buyprice 순위 매기기(오름차순, 3개 순위 모두 출력)
SELECT buyprice,
		productline,
        RANK() OVER(PARTITION BY productline ORDER BY buyprice) RNK,
        DENSE_RANK() OVER(PARTITION BY productline ORDER BY buyprice) DENSE_RNK,
        ROW_NUMBER() OVER(PARTITION BY productline ORDER BY buyprice) ROWNUMBER
FROM products;

/*서브쿼리(SubQuery)*/
DESCRIBE orders;
-- NYC에 거주하는 고객들의 주문번호 
SELECT customerNumber, orderNumber
FROM orders
WHERE customernumber IN (SELECT customernumber
						FROM customers
						WHERE city='NYC');
					
SELECT customernumber
FROM (SELECT customernumber
		FROM customers
        WHERE city='NYC') A;