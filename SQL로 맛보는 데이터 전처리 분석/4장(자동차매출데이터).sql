/*1. 매출액(일자별, 월별, 연도별)*/
-- 주문 일자(orderdate)는 orders table, 판매액(prcieEach*quantityOrdered)은 orderdetails에 존재
describe orders;
SELECT * FROM orders;
describe orderdetails;
SELECT * FROM orderdetails;
-- 1-1. 일별 매출액
SELECT A.orderDate,
		SUM(B.priceEach*B.quantityOrdered) AS sales    -- 일별 SUM
FROM orders A
		LEFT JOIN orderdetails B     -- LEFT JOIN 해야함!!!
        ON A.orderNumber = B.orderNumber
GROUP BY 1
ORDER BY 1;
-- 1-2. 월별 매출액 ver.1 SUBSTR()
SELECT SUBSTR(A.orderDate,1,7) AS Month,
		SUM(B.priceEach*B.quantityOrdered) AS Sales    -- 일별 SUM
FROM orders A
		LEFT JOIN orderdetails B     -- LEFT JOIN 해야함!!!
        ON A.orderNumber = B.orderNumber
GROUP BY 1
ORDER BY 1;

-- 1-2. 월별 매출액 ver.2 date_format()
SELECT date_format(A.orderDate, '%Y-%m') AS Month,
		SUM(B.priceEach*B.quantityOrdered) AS Sales    -- 일별 SUM
FROM orders A
		LEFT JOIN orderdetails B     -- LEFT JOIN 해야함!!!
        ON A.orderNumber = B.orderNumber
GROUP BY 1
ORDER BY 1;

-- 1-3. 연도별 매출액 ver.1 SUBSTR()
SELECT SUBSTR(A.orderDate,1,4) AS year,
		SUM(B.priceEach*B.quantityOrdered) AS Sales    -- 일별 SUM
FROM orders A
		LEFT JOIN orderdetails B     -- LEFT JOIN 해야함!!!
        ON A.orderNumber = B.orderNumber
GROUP BY 1
ORDER BY 1;

-- 1-3. 연도별 매출액 ver.2 date_format()
SELECT date_format(A.orderDate, '%Y') AS year,
		SUM(B.priceEach*B.quantityOrdered) AS Sales    -- 일별 SUM
FROM orders A
		LEFT JOIN orderdetails B     -- LEFT JOIN 해야함!!!
        ON A.orderNumber = B.orderNumber
GROUP BY 1
ORDER BY 1;


/*2. 구매자 수, 구매 건수 (일자별, 월별, 연도별)*/
describe orders;
-- 2-1. 일별 구매자 수, 구매 건수
SELECT orderDate,
		COUNT(DISTINCT(customerNumber)) AS n_purchaser, -- 한명이 여러번 구매 가능하기 때문에 카운트 전, 중복제거 필요!
        COUNT(orderNumber) AS n_orders   -- 주문 번호는 PK이며, unique하기 때문에 중복제거 필요 없음
FROM orders
GROUP BY orderDate
ORDER BY orderDate;

-- 2-2. 월별 구매자 수, 구매 건수
SELECT SUBSTR(orderDate,1,7) Month,
		COUNT(DISTINCT(customerNumber)) n_puchaser,
        COUNT(orderNumber) n_orders
FROM orders
GROUP BY 1
ORDER BY 1;

-- 2-3. 년도별  
SELECT DATE_FORMAT(orderDate, '%Y') Year,
		COUNT(DISTINCT(customerNumber)) n_purchaser,
        COUNT(orderNumber) n_orders
FROM orders
GROUP BY 1
ORDER BY 1;

/*3. 인당 매출액(AMV, Average Member Value)  (연도별)*/
DESCRIBE orders; -- orderDate -> year, customerNumber
-- on orderNumber
DESCRIBE orderdetails; -- sales(priceEach*quantityOrdered)

SELECT date_format(A.orderDate, '%Y') Year,
		SUM(B.priceEach*B.quantityOrdered) / COUNT(DISTINCT(A.customerNumber)) AMV  -- 구매자 수로 나눠주면 됨
FROM orders A
		LEFT JOIN orderdetails B
        ON A.orderNumber = B.orderNumber
GROUP BY 1
ORDER BY 1;

/*건당 구매 금액(ATV, Average Transaction Value) (연도별)*/
SELECT SUBSTR(A.orderDate,1,4) Year,
		SUM(B.priceEach*B.quantityOrdered) / COUNT(DISTINCT(A.orderNumber)) ATV -- 구매 건수로 나눠주면됨
FROM orders A
		LEFT JOIN orderdetails B
        ON A.orderNumber = B.orderNumber
GROUP BY 1
ORDER BY 1;


/*국가별, 도시별 매출액*/
SELECT A.country,
		A.city,
        SUM(C.priceEach*C.quantityOrdered) salse
FROM customers A LEFT JOIN orders B ON A.customerNumber = B.customerNumber
		LEFT JOIN orderdetails C ON B.orderNumber = C.orderNumber
GROUP BY 1,2
ORDER BY 1,2;

/*북미(USA, Canada) vs 비북미 매출액 비교*/
SELECT 
		CASE WHEN A.country IN ('USA','Canada') THEN '북미'
            ELSE '비북미' END AS compare,
        SUM(C.priceEach*C.quantityOrdered) salse
FROM customers A LEFT JOIN orders B ON A.customerNumber = B.customerNumber
		LEFT JOIN orderdetails C ON B.orderNumber = C.orderNumber
GROUP BY 1
ORDER BY 2 DESC;

/*매출 Top5 국가 및 매출*/
-- 1. 서브쿼리 사용하지 않고, LIMIT 조건 이용해서 행수 제한
SELECT A.country,
	SUM(C.priceEach*C.quantityOrdered) salse,
    RANK() OVER(ORDER BY SUM(C.priceEach*C.quantityOrdered) DESC) AS RNK
FROM customers A LEFT JOIN orders B ON A.customerNumber = B.customerNumber
	LEFT JOIN orderdetails C ON B.orderNumber = C.orderNumber
GROUP BY 1
LIMIT 5;
-- 2. 서브쿼리 이용해서, WHERE구에 조건 설정
SELECT *
FROM (SELECT A.country,
		SUM(C.priceEach*C.quantityOrdered) salse,
        RANK() OVER(ORDER BY SUM(C.priceEach*C.quantityOrdered) DESC) AS RNK
	FROM customers A LEFT JOIN orders B ON A.customerNumber = B.customerNumber
			LEFT JOIN orderdetails C ON B.orderNumber = C.orderNumber
	GROUP BY 1
	ORDER BY 3) TMP
WHERE RNK BETWEEN 1 AND 5;

-- 3. 서브쿼리 이용해서, LIMIT (순위 없이)
SELECT *
FROM (SELECT A.country,
		SUM(C.priceEach*C.quantityOrdered) salse        
	FROM customers A LEFT JOIN orders B ON A.customerNumber = B.customerNumber
			LEFT JOIN orderdetails C ON B.orderNumber = C.orderNumber
	GROUP BY 1
	ORDER BY 2 DESC) TMP
LIMIT 5;


/*재구매율*/
-- 1. 재구매율(연도별)
-- 특정 기간(ex.2018) 구매자 중 특정기간(ex. 2019)에 연달아 구매한 구매자의 비중
-- 연도별 -> 이전해에 구매한 이력이 있는 구매자가 다음해에도 구매한 경우
-- self join + 조건 '이전해 = 다음해-1'이 핵심! -> 이해하는 sql 구문
SELECT A.customerNumber,
		A.orderdate,
        B.customerNumber,
        B.orderdate
FROM orders A LEFT JOIN orders B ON A.customerNumber = B.customerNumber   -- self join
							AND SUBSTR(A.orderdate,1,4) = SUBSTR(B.orderdate,1,4) - 1;   -- 이전해 = 다음해-1
-- 연도별 재구매율 구하기  - 중복제거!! (한명의 구매자가 다음년도에 구매하면 된거니, 한명의 여러개의 구매 이력은 필요없으니 중복제거 필요)
SELECT date_format(A.orderdate, '%Y') year,
		COUNT(DISTINCT(B.customerNumber)) / COUNT(DISTINCT(A.customerNumber)) 'Retention Rate(%)'
FROM orders A LEFT JOIN orders B ON A.customerNumber = B.customerNumber
							AND SUBSTR(A.orderdate,1,4) = SUBSTR(B.orderdate,1,4) - 1
GROUP BY 1;

-- 2. 국가별 재구매율(Retention Rate(%))  - 중복제거!!
SELECT C.country,
		date_format(A.orderdate, '%Y'),
        COUNT(DISTINCT(A.customerNumber)) N_buy1,
        COUNT(DISTINCT(B.customerNumber)) N_buy2,
        COUNT(DISTINCT(B.customerNumber)) / COUNT(DISTINCT(A.customerNumber)) 'Rate'
FROM orders A LEFT JOIN orders B ON A.customerNumber = B.customerNumber
							AND SUBSTR(A.orderdate,1,4) = SUBSTR(B.orderdate,1,4) - 1
			LEFT JOIN customers C ON A.customerNumber = C.customerNumber
GROUP BY 1,2
ORDER BY 1,2;

/*미국의 연도별 top5 차량 모델*/
-- 방법1 서브쿼리
SELECT *
FROM (SELECT date_format(A.orderdate, '%Y') year,
		D.productName,
		SUM(C.priceEach*C.quantityOrdered) Sales,
        RANK() OVER(PARTITION BY date_format(A.orderdate, '%Y') ORDER BY SUM(C.priceEach*C.quantityOrdered) DESC) RNK
		FROM orders A LEFT JOIN customers B ON A.customerNumber = B.customerNumber
						LEFT JOIN orderdetails C ON A.orderNumber = C.orderNumber
						LEFT JOIN products D ON C.productCode = D.productCode
		WHERE B.country = 'USA'
		GROUP BY 1,2) TMP
WHERE RNK BETWEEN 1 AND 5;

-- 방법2 테이블 생성
CREATE TABLE PRODUCT_SALES_BY_YEAR AS
SELECT date_format(A.orderdate, '%Y') year,
		D.productName,
		SUM(C.priceEach*C.quantityOrdered) Sales,
        RANK() OVER(PARTITION BY date_format(A.orderdate, '%Y') ORDER BY SUM(C.priceEach*C.quantityOrdered) DESC) RNK
FROM orders A LEFT JOIN customers B ON A.customerNumber = B.customerNumber
				LEFT JOIN orderdetails C ON A.orderNumber = C.orderNumber
				LEFT JOIN products D ON C.productCode = D.productCode
WHERE B.country = 'USA'
GROUP BY 1,2;

SELECT * 
FROM product_sales_by_year
WHERE RNK <= 5;

-- 방법3 VIEW 생성
CREATE VIEW PRODUCT_SALES_BY_YEAR_2 AS
SELECT date_format(A.orderdate, '%Y') year,
		D.productName,
		SUM(C.priceEach*C.quantityOrdered) Sales,
        RANK() OVER(PARTITION BY date_format(A.orderdate, '%Y') ORDER BY SUM(C.priceEach*C.quantityOrdered) DESC) RNK
FROM orders A LEFT JOIN customers B ON A.customerNumber = B.customerNumber
				LEFT JOIN orderdetails C ON A.orderNumber = C.orderNumber
				LEFT JOIN products D ON C.productCode = D.productCode
WHERE B.country = 'USA'
GROUP BY 1,2;

SELECT * 
FROM PRODUCT_SALES_BY_YEAR_2
WHERE RNK <= 5;

/*Churn Rate(%)*/
-- 활동 고객 중 얼마나 많은 고객이 비활동 고객으로 전환되었는지를 의미하는 지표
-- Churn: 마지막 구매,접속일(max 구매,접속일)이 현재 시점 기준으로 3개월 이상 지난 고객
-- Churn Rate: 전체 고객 중에 Churn에 해당하는 고객의 비중
-- -- order table에서 마지막 구매일이 언제인지 확인
SELECT MAX(orderdate) MAX_ORDER
FROM orders;
-- -- '2005-06-01'일을 기준으로 각 고객의 마지막 구매일에서 며칠이 경과 됐는지 구하기
SELECT customerNumber,
		MAX(orderdate),
        '2005-06-01',
		DATEDIFF('2005-06-01', MAX(orderdate)) Diff
FROM orders
GROUP BY 1;
-- -- Diff가 90일 이상인 경우를 Churn이라 가정
SELECT 
		SUM(CASE WHEN Diff >= 90 THEN 1 ELSE 0 END) / COUNT(customerNumber) 'Churn Rate(%)'
FROM (SELECT customerNumber,
			DATEDIFF('2005-06-01', MAX(orderdate)) Diff
	FROM orders
	GROUP BY 1) TMP
;

-- 2. Churn/NON-Churn 고객이 가장 많이 구매한 Productline(상품 카테고리)
CREATE VIEW Churn_list AS
SELECT customerNumber,
		CASE WHEN Diff >= 90 THEN 'Churn' ELSE 'NON-Churn' END AS Churn_type
FROM (SELECT customerNumber,
			DATEDIFF('2005-06-01', MAX(orderdate)) Diff
	FROM orders
	GROUP BY 1) TMP
;

SELECT C.productLine,
		COUNT(DISTINCT A.customerNumber) N_productline
FROM orders A LEFT JOIN orderdetails B ON A.orderNumber = B.orderNumber
				LEFT JOIN products C ON B.productCode = C.productCode
GROUP BY 1;

-- 생성해둔 VIEW와 결합시켜, churn type에 따른 많이 구매한 상품 카테고리에 차이가 있는지 확인
SELECT D.Churn_type,
		C.productLine,
		COUNT(DISTINCT A.customerNumber) N_productline
FROM orders A LEFT JOIN orderdetails B ON A.orderNumber = B.orderNumber
				LEFT JOIN products C ON B.productCode = C.productCode
                LEFT JOIN Churn_list D ON A.customerNumber = D.customerNumber
GROUP BY 1,2
ORDER BY 1,3 DESC;
-- churn type에 따른 차이는 없는 것으로 보임
