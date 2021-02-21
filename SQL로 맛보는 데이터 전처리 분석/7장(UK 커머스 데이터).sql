describe dataset3;
SELECT * FROM dataset3;
SELECT distinct(country)
FROM dataset3;

/*국가별, 상품별 구매자 수 및 매출액*/
SELECT country,
		stockcode,
        COUNT(DISTINCT(CustomerID)) AS BU,
        ROUND(SUM(quantity*unitprice),2) AS sales  -- 그룹별로 묶으니까, SUM해줘야!! 까먹지 말기!
FROM dataset3
GROUP BY 1,2
ORDER BY 3 DESC, 4 DESC;

/*특정 상품 구매자가 많이 구매한 상품은?*/
-- 1. 가장 많이 구매된 TOP2 상품 조회 (판매 상품 수 기준)
SELECT stockcode,
        SUM(quantity)
FROM dataset3
GROUP BY 1
ORDER BY 2 DESC
LIMIT 2;  -- 84077, 85123A

-- 2. 2개 상품을 모두 구매한 구매자
SELECT customerid
FROM dataset3
GROUP BY 1
HAVING SUM(CASE WHEN StockCode = '84077' THEN 1 ELSE 0 END) >= 1
AND SUM(CASE WHEN StockCode = '85123A' THEN 1 ELSE 0 END) >= 1;

CREATE TEMPORARY TABLE BU_LIST AS
SELECT customerid
FROM dataset3
GROUP BY 1
HAVING MAX(CASE WHEN StockCode = '84077' THEN 1 ELSE 0 END) = 1
AND MAX(CASE WHEN StockCode = '85123A' THEN 1 ELSE 0 END) = 1;

-- 3. 2가지 상품을 모두 구매한 구매자가 구매한 상품 LIST
SELECT DISTINCT(stockcode),
		description
FROM dataset3
WHERE CustomerID IN (SELECT * FROM BU_LIST)
AND StockCode NOT IN ('84077', '85123A');

/*국가별 재구매율 계산 (연도)*/
SELECT A.country,
		date_format(A.invoicedate, '%Y') year,
		COUNT(DISTINCT B.customerid) / COUNT(DISTINCT A.customerid) retention_rate
FROM (SELECT DISTINCT country,
						invoicedate,
						CustomerID
	FROM dataset3) A 
    LEFT JOIN (SELECT DISTINCT country,
								invoicedate,
								CustomerID
				FROM dataset3) B
	ON date_format(A.invoicedate, '%Y') = date_format(B.invoicedate, '%Y') - 1
    AND A.country = B.country
    AND A.CustomerID = B.CustomerID
GROUP BY 1,2
ORDER BY 1,2;

/*코호트 분석 ===============================================================================*/
-- 코호트 분석: 특정 기간에 구매한 or 가입한.. 고객들의, 이후 구매액, 리텐션, 구매/행동 패턴 등을 파악하는 데 사용함

/*'첫 구매월'을 기준으로 각 그룹간의 패턴 파악*/
-- 1. 고객별 첫 구매일(date) 구하기
SELECT * FROM dataset3;
SELECT customerid,
		MIN(InvoiceDate) MIN_DATE  -- 각 고객별 date MIN 값 = 첫 구매일
FROM dataset3
GROUP BY 1;

-- 2. 고객별 주문 일자, 구매액 조회  (고객의 구매내역)
SELECT customerid,
		invoicedate,
        Quantity*unitprice Sales
FROM dataset3;

-- 3. 고객별 첫 구매일 TABLE에 고객 구매내역 TABLE JOIN
SELECT *
FROM (SELECT customerid,
		MIN(InvoiceDate) MIN_DATE
	FROM dataset3
	GROUP BY 1) A
LEFT JOIN 
	(SELECT customerid,
		invoicedate,
        Quantity*unitprice Sales
	FROM dataset3) B
ON A.CustomerID = B.CustomerID;

-- 4. MNDT: 최초 구매 년.월, DATEDIFF: 최초구매월부터 몇개월 지난 뒤에 구매가 이뤄졌는지, SALES 해당기간 총 매출약
SELECT date_format(MIN_DATE, '%Y-%m') MNDT,
        timestampdiff(MONTH, MIN_DATE, invoicedate) DIFF,
        COUNT(DISTINCT A.CustomerID) BU,
        ROUND(SUM(Sales),2) AS SALES
FROM (SELECT customerid,
		MIN(InvoiceDate) MIN_DATE
	FROM dataset3
	GROUP BY 1) A
LEFT JOIN 
	(SELECT customerid,
		invoicedate,
        Quantity*unitprice Sales
	FROM dataset3) B
ON A.CustomerID = B.CustomerID
GROUP BY 1,2
ORDER BY 1,2;

/*고객 세그먼트(Segment) - 높은 가지를 가진 고객 구분/분류 ===========================================================*/
-- RFM: Recency, Frequency, Monetary 3가지 기준에 의해 계산됨
/* 1. Recency */
-- 제일 최근에 구입한 시기는 언제인가? -> 산출하는 시점 기준으로, 최근 구매일이 며칠 or 몇달 전인지 파악 (diff)
-- 1-2. 고객별 마지막 구매일 구하기
SELECT CustomerID,
		MAX(InvoiceDate) AS MXDT
FROM dataset3
GROUP BY 1;

-- 1-2. 기준일 '2011-12-02'로부터의 차이일수 구하기
SELECT CustomerID,
		DATEDIFF('2011-12-02', MXDT) AS Recency
FROM (SELECT CustomerID,
		MAX(InvoiceDate) AS MXDT
	FROM dataset3
	GROUP BY 1) TMP
;

/* 2. & 3. Frequency, Monetary */
-- Frequency: 얼마나 자주 구입했나?  -> 여기서는 구매 건수
-- Monetary: 구입한 총 금액은 얼마인가?
SELECT CustomerID,
		COUNT(DISTINCT InvoiceNo) Frequency,
        SUM(Quantity*UnitPrice) Monetary
FROM dataset3
GROUP BY 1;

/* 3가지를 하나의 쿼리로 구하기*/
SELECT CustomerID,
		DATEDIFF('2011-12-02', MXDT) AS Recency,
        Frequency,
        Monetary
FROM (SELECT CustomerID,
		MAX(InvoiceDate) MXDT,
		COUNT(DISTINCT InvoiceNo) Frequency,
        SUM(Quantity*UnitPrice) Monetary
	FROM dataset3
	GROUP BY 1) TMP
;  -- 이 data(RFM Score)를 R, Python으로 옮겨, K-Means 알고리즘과 같은 클러스터링 기법 적용!!!


/*고객 세그먼트(Segment) - 재구매 기준 고객 세그먼트 ===========================================================*/
-- 특정 상품을 2개 연도에 걸쳐서 구매한 고객 vs 특정 연도에만 구매한 고객 (그렇지 않은 고객)
-- 1. 고객별, 상품별 구매 연도 unique count
SELECT CustomerID,
		StockCode,
        COUNT(DISTINCT date_format(invoicedate, '%Y')) unique_yy
FROM dataset3
GROUP BY 1,2;

-- 2. unique_yy가 2 이상인 고객 vs 그렇지 않은 고객 나눠서 라벨링
SELECT CustomerID,
		CASE WHEN MAX(unique_yy) >= 2 THEN 1 ELSE 0 END AS repurchase_segment
FROM (SELECT CustomerID,
		StockCode,
        COUNT(DISTINCT date_format(invoicedate, '%Y')) unique_yy
	FROM dataset3
	GROUP BY 1,2) TMP
GROUP BY 1;

/*일자별 첫 구매자수*/
-- 1. 고객별 첫 구매일
SELECT CustomerID,
		MIN(InvoiceDate) MNDT
FROM dataset3
GROUP BY 1;

-- 2. 일자별 첫 구매 고객 수
SELECT MNDT,
		COUNT(DISTINCT CustomerID)
FROM (SELECT CustomerID,
		MIN(InvoiceDate) MNDT
	FROM dataset3
	GROUP BY 1) A
GROUP BY 1;

/*상품별 첫 구매 고객 수*/
-- 1. 고객별 구매와 기준 순위 생성
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY MNDT) RNK
FROM (SELECT CustomerID,
			StockCode,
			MIN(InvoiceDate) MNDT
	FROM dataset3
	GROUP BY 1,2) A
;

-- 2. 고객별 순위가 1인 것만 남기기 = 최초 구매 상품만 남기기
SELECT *
FROM (SELECT *,
			ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY MNDT) RNK
		FROM (SELECT CustomerID,
					StockCode,
					MIN(InvoiceDate) MNDT
			FROM dataset3
			GROUP BY 1,2) A) B
WHERE RNK = 1;

-- 3. 상품별 고객수 집계 - 1
SELECT B.StockCode,
	COUNT(DISTINCT B.CustomerID)
FROM (SELECT *,
			ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY MNDT) RNK
		FROM (SELECT CustomerID,
					StockCode,
					MIN(InvoiceDate) MNDT
			FROM dataset3
			GROUP BY 1,2) A) B
WHERE RNK = 1
GROUP BY 1
ORDER BY 2 DESC;

-- 3. 상품별 고객수 집계 - 2
SELECT StockCode,
	COUNT(distinct CustomerID) FIRST_BU
FROM (SELECT *
	FROM (SELECT *,
				ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY MNDT) RNK
			FROM (SELECT CustomerID,
						StockCode,
						MIN(InvoiceDate) MNDT
				FROM dataset3
				GROUP BY 1,2) A) B
	WHERE RNK = 1) C
GROUP BY 1
ORDER BY 2 DESC;

/*첫 구매 후 이탈하는 고객의 비중*/
-- 1. 첫 구매 후 이탈하는 고객의 비중
SELECT SUM(CASE WHEN DATE_CNT = 1 THEN 1 ELSE 0 END) / COUNT(*) AS OUT_RATE
FROM (SELECT CustomerID,
		COUNT(DISTINCT InvoiceDate) AS DATE_CNT
	FROM dataset3
	GROUP BY 1) TMP
;

-- 2. 첫 구매 후 이탈하는 고객의 비중 (국가별) 
SELECT Country,
		SUM(CASE WHEN DATE_CNT = 1 THEN 1 ELSE 0 END) / COUNT(*) AS OUT_RATE
FROM (SELECT Country,
			CustomerID,
			COUNT(DISTINCT InvoiceDate) AS DATE_CNT
	FROM dataset3
	GROUP BY 1,2) TMP
GROUP BY 1;

/*전년도 대비 판매 수량이 20% 이상 증가한 상품 리스트*/
-- 1. 연도별 상품별 판매 수량 계산
SELECT date_format(invoiceDate, '%Y') year,
		stockcode,
        SUM(quantity) QTY
FROM dataset3
GROUP BY 1,2;

-- 2. 전년도 대비 판매 수량 증가율 계산 - 1
SELECT StockCode,
		SUM(CASE WHEN year = 2010 THEN QTY ELSE 0 END) AS QTY_2010,
        SUM(CASE WHEN year = 2011 THEN QTY ELSE 0 END) AS QTY_2011,
		SUM(CASE WHEN year = 2011 THEN QTY ELSE 0 END) / SUM(CASE WHEN year = 2010 THEN QTY ELSE 0 END) - 1 AS QTY_INCREASE_RATE
FROM (SELECT date_format(invoiceDate, '%Y') year,
		stockcode,
        SUM(quantity) QTY
	FROM dataset3
	GROUP BY 1,2) A 
GROUP BY 1;

-- 2. 전년도 대비 판매 수량 증가율 계산 - 2
SELECT A. StockCode,
		A.QTY AS QTY_2011,
        B.QTY AS QTY_2010,
        A.QTY / B.QTY - 1 AS QTY_INCREASE_RATE
FROM (SELECT Stockcode,
        SUM(quantity) QTY
	FROM dataset3
    WHERE date_format(invoiceDate, '%Y') = '2011'
	GROUP BY 1) A
    LEFT JOIN
    (SELECT Stockcode,
        SUM(quantity) QTY
	FROM dataset3
    WHERE date_format(invoiceDate, '%Y') = '2010'
	GROUP BY 1) B
    ON A.stockcode = B.stockcode
;

-- 3. 20(1.2)% 이상 증가한 상품만 남기기   (0.2 아님!!)
SELECT *
FROM (SELECT StockCode,
		SUM(CASE WHEN year = 2010 THEN QTY ELSE 0 END) AS QTY_2010,
        SUM(CASE WHEN year = 2011 THEN QTY ELSE 0 END) AS QTY_2011,
		SUM(CASE WHEN year = 2011 THEN QTY ELSE 0 END) / SUM(CASE WHEN year = 2010 THEN QTY ELSE 0 END) - 1 AS QTY_INCREASE_RATE
	FROM (SELECT date_format(invoiceDate, '%Y') year,
			stockcode,
			SUM(quantity) QTY
		FROM dataset3
		GROUP BY 1,2) A 
	GROUP BY 1) B
WHERE QTY_INCREASE_RATE >= 1.2;

/*주(WEEK)차 별 매출액   -  WEEKOFYEAR() 함수! */ 
-- 2011년도의 주차별 매출액
SELECT WEEKOFYEAR(InvoiceDate) AS WEEK,
		SUM(quantity*UnitPrice) AS SALES
FROM dataset3
WHERE date_format(InvoiceDate, '%Y') = '2011'
GROUP BY 1
ORDER BY 1;

/*신규/기존 고객의 2011년 월별 매출액 =================================*/
-- 1. 신규/기존 고객 분류  - 최초 구매일이 2011년도인 사람이 신규 고객!
SELECT CustomerID,
		CASE WHEN date_format(MNDT, '%Y') = '2011' THEN 'NEW' ELSE 'EXI' END AS NEW_EXI
FROM (SELECT CustomerID,
		MIN(InvoiceDate) MNDT
FROM dataset3
GROUP BY 1) A
;

-- 2. TABLE JOIN
SELECT NEW_EXI,
		date_format(InvoiceDate, '%Y-%m') YM,
        SUM(quantity*UnitPrice) AS Sales
FROM dataset3 A LEFT JOIN (SELECT CustomerID,
									CASE WHEN date_format(MNDT, '%Y') = '2011' THEN 'NEW' ELSE 'EXI' END AS NEW_EXI
							FROM (SELECT CustomerID,
									MIN(InvoiceDate) MNDT
							FROM dataset3
							GROUP BY 1) A) B
				ON A.CustomerID = B.CustomerID
WHERE date_format(InvoiceDate, '%Y') = '2011'
GROUP BY 1,2
ORDER BY 2;

/*기존 고객의 2011년 월별 누적 리텐션*/
-- 2010년도에 구매한 고객(기존)의 2011년 월별 누적 리텐션
-- EX. 2010년에 구매한 고객 수: 100명 -> 그 100명 중 2011년 1월에 첫구매한 고객 00명, 2월까지(1+2월 누적) 첫구매한 고객 00명, ..
-- 1. 기존 고객(최초 구매 연도가 2010년인 고객) 리스트
SELECT CustomerID
FROM dataset3
GROUP BY 1
HAVING date_format(MIN(InvoiceDate), '%Y') = '2010';

-- 2. 2010년도에 구매한 고객(기존)의 2011년 월별 (누적 -> Excel로 계산) 리텐션
SELECT date_format(InvoiceDate, '%Y-%m') YM,
		COUNT(DISTINCT CustomerID) AS RETENTION
FROM dataset3
WHERE CustomerID IN (SELECT CustomerID
					FROM dataset3
					GROUP BY 1
					HAVING date_format(MIN(InvoiceDate), '%Y') = '2010')
AND date_format(InvoiceDate, '%Y') = '2011'
GROUP BY 1;

-- 3. 엑셀로 계산된 '월별 누적 기존 고객수'를 '기존 고객 수'로 나누면 = '월별 누적 리텐션'
-- 기존 고객 수 계산  --> 644명
SELECT COUNT(CustomerID)
FROM (SELECT CustomerID
					FROM dataset3
					GROUP BY 1
					HAVING date_format(MIN(InvoiceDate), '%Y') = '2010') A;

/*LTV(Life Time Value)*/
-- 고객과의 미래 관계를 고려해 귀속되는 순이익을 예측하는 지표
-- 고객의 Retention과 평균 거래 단가(AMV) 등을 고려해 2011년 구매자의 CLTV를 계산해보자
-- 1. Retention Rate - 2010년 구매자 중 2011년에 구매한 고객의 비율  : 0.3509
SELECT COUNT(B.CustomerID) / COUNT(A.CustomerID) AS Retention_Rate
FROM (SELECT DISTINCT CustomerID
	FROM dataset3
	WHERE date_format(InvoiceDate, '%Y') = '2010') A
LEFT JOIN
	(SELECT DISTINCT CustomerID
	FROM dataset3
	WHERE date_format(InvoiceDate, '%Y') = '2011') B
ON A.CustomerID = B.CustomerID ;

-- 2. 2011년 AMV(인당 평균 구매액)  : 690.8959607843396
SELECT SUM(quantity*unitprice) / COUNT(DISTINCT CustomerID) AS AMV
FROM dataset3
WHERE date_format(InvoiceDate, '%Y') = '2011';

-- 3. 2011년도 구매자 수 : 765
SELECT COUNT(DISTINCT CustomerID) AS N_BU
FROM dataset3
WHERE date_format(InvoiceDate, '%Y') = '2011'; 

-- 4. 2012년 예상 구매자 수 = 2011년 구매자 수 * Retention Rate(%)  : 약 268.4385명
SELECT 765*0.3509;

 -- 5. 2012년 예상 매출액 = 예상 구매자 수*AMV : 185463.07536900694571460원
 SELECT 268.4385*690.8959607843396;

-- 6. 2011년 구매자가 전체 기간 (2011~2012)에 발생시킬 매출의 합은? 2011년 매출액 + 2011년 구매자의 2012년 예상 매출액
-- : 713998.48536902674571460원
SELECT SUM(quantity*unitprice) AS SALES_2011
FROM dataset3
WHERE date_format(InvoiceDate, '%Y') = '2011';
SELECT 528535.4100000198 + 185463.07536900694571460;

-- 7. 2011년 구매자의 가치 LTV = 위 금액 / 2011년 구매자 수 : 933.331353423564373483137
SELECT 713998.48536902674571460 / 765;
-- => 2011년의 LTV는 약 933으로 계산됨
-- 고객 세그먼트(성별, 연령, 유입 채널 등)별로 LTV를 계산해본다면, 어떤 고객이 우리 서비스에서 가장 가치있는 고객인지 측정해 볼 수 있다.


