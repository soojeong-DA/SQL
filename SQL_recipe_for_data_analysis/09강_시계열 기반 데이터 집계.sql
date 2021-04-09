/* [참고] 데이터 설명 및 파악
- 2년(2014~2015)에 걸친 매출 데이터 샘플 */
SELECT *
FROM purchase_log;

SELECT 
   table_name, 
   column_name, 
   is_nullable,
   data_type
FROM 
   information_schema.columns
WHERE 
   table_name = 'purchase_log';


/* 날짜별 매출 집계 (추이 확인) */
SELECT dt,
	COUNT(*) AS purchase_count,
	SUM(purchase_amount) AS total_amount,
	ROUND(AVG(purchase_amount),2) AS avg_amount
FROM purchase_log
GROUP BY 1
ORDER BY 1;

/* 이동평균을 사용한 날짜별 추이 
- 일별 매출 경향으로는 전체적으로 매출이 상승 or 하락하는 경향이 있는지 판단하기 어려움
=> 7일 동안의 평균 매출을 사용한 '7일 이동평균'으로 표현해 파악하는 것이 좋음 */

-- 날짜별 매출과 7일 이동평균 집계 - 1
SELECT dt,
	SUM(purchase_amount) AS total_amount,
	AVG(SUM(purchase_amount)) OVER(ORDER BY dt
								  ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS seven_day_avg
FROM purchase_log
GROUP BY 1
ORDER BY 1; -- 이 쿼리의 경우 누적 7일 미만의 일수에 대한 평균도 구해짐 (ex. 첫째날 ~ 5일간의 평균)

-- 날짜별 매출과 7일 이동평균 집계 - 2 (7일의 데이터가 모두 있는 경우에만 집계!)
SELECT dt,
	SUM(purchase_amount) AS total_amount,
	CASE
		-- 7일이 채워지는 경우에만 계산하도록 조건 추가
		WHEN 7 = COUNT(*) OVER(ORDER BY dt
							  ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
		THEN AVG(SUM(purchase_amount)) OVER(ORDER BY dt
								  ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
	END AS seven_day_avg_strict
FROM purchase_log
GROUP BY 1
ORDER BY 1;

/* 당월 매출 누계 */
-- 날짜별 매출과 당월 누계 매출을 집계
SELECT dt,
	SUBSTRING(dt, 1,7) AS year_month,  -- SUBSTR 대체 가능
	SUM(purchase_amount) AS total_amount,
	SUM(SUM(purchase_amount)) OVER(PARTITION BY SUBSTRING(dt, 1,7) ORDER BY dt
							 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS agg_amount
FROM purchase_log
GROUP BY 1
ORDER BY 1;

-- with구문으로 임시 테이블 생성 후, 다시 '날짜별 매출과 당월 누계 매출 집계'
-- -- 가독성/이해/재사용성 더 높게
WITH daily_purchase AS (
SELECT dt,
	-- 년, 월, 일 각각 추출
	substring(dt, 1,4) AS year,
	substring(dt, 6,2) AS month,
	substring(dt, 9,2) AS date,
	-- 일별 매출 합계
	SUM(purchase_amount) AS purchase_amount
FROM purchase_log
GROUP BY dt
)
SELECT dt,
	CONCAT(year, '-', month) AS year_month,
	purchase_amount,
	SUM(purchase_amount) OVER(PARTITION BY year, month ORDER BY dt
							 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS agg_amount
FROM daily_purchase
ORDER BY dt
;

/* 작년의 해당 월별 매출과 비교 (작년 대비 증감 파악) */
-- 월별 매출과 작년 대비 비교
WITH daily_purchase AS (
SELECT dt,
	-- 년, 월, 일 각각 추출
	substring(dt, 1,4) AS year,
	substring(dt, 6,2) AS month,
	substring(dt, 9,2) AS date,
	-- 일별 매출 합계
	SUM(purchase_amount) AS purchase_amount
FROM purchase_log
GROUP BY dt
)
SELECT month,
	-- 2014, 2015의 월별 매출액 각각 다른 컬럼으로 출력
	SUM(CASE WHEN year = '2014' THEN purchase_amount END) AS amount_2014,
	SUM(CASE WHEN year = '2015' THEN purchase_amount END) AS amount_2015,
	-- 100.0*2015/2014 => 작년 대비 증감 파악(월별)
	100.0
	* SUM(CASE WHEN year = '2015' THEN purchase_amount END)
	/ SUM(CASE WHEN year = '2014' THEN purchase_amount END)
	AS rate
FROM daily_purchase
GROUP BY month
ORDER BY month;

/* Z차트로 업적의 추이 확인 
- 계절 변동의 영향을 배제하고, 트렌드(추이) 파악할 수 있는 방법
- '월차매출', '매출누계', '이동년계' 3가지 지표로 구성됨 */

-- 2015년 매출에 대한 Z차트 작성
WITH 
daily_purchase AS (
	SELECT dt,
		-- 년, 월, 일 각각 추출
		substring(dt, 1,4) AS year,
		substring(dt, 6,2) AS month,
		substring(dt, 9,2) AS date,
		-- 일별 매출 합계
		SUM(purchase_amount) AS purchase_amount
	FROM purchase_log
	GROUP BY dt
),
monthly_purchase AS (
	-- 월별 매출 집계
	SELECT year,
		month,
		SUM(purchase_amount) AS amount
	FROM daily_purchase
	GROUP BY year, month
),
calc_index AS (
	SELECT year,
		month,
		amount,
		-- 2015년의 누계 매출 집계 (월별)
		SUM(CASE WHEN year = '2015' THEN amount END) OVER(ORDER BY year, month
														 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS agg_amount,
		-- 이동년계 집계(11개월이전 ~ 당월)
		SUM(amount) OVER(ORDER BY year, month
						ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)
		AS year_avg_amount
FROM monthly_purchase
ORDER BY year, month
)
-- 2015년 데이터만 압축해서 출력
SELECT CONCAT(year, '-', month) AS year_month,
	amount,
	agg_amount,
	year_avg_amount
FROM calc_index
WHERE year = '2015'
ORDER BY year, month
;

/* 매출 파악 시, 주변 데이터를 고려해야 why?의 이유를 알 수 있음 */
-- 매출과 관련된 지표 집계 - 1 (중간에 월별 지표 미리 계산해 이용)
WITH 
daily_purchase AS (
	SELECT dt,
		-- 년, 월, 일 각각 추출
		substring(dt, 1,4) AS year,
		substring(dt, 6,2) AS month,
		substring(dt, 9,2) AS date,
		-- 일별 매출 합계
		SUM(purchase_amount) AS purchase_amount,
		-- 일별 주문 횟수
		COUNT(*) AS order_cnt
	FROM purchase_log
	GROUP BY dt
),
monthly_purchase AS (
	-- 월별 지표 미리 계산
	SELECT year,
		month,
		SUM(order_cnt) AS orders,
		AVG(purchase_amount) AS avg_amount,
		SUM(purchase_amount) AS monthly_amount
FROM daily_purchase
GROUP BY year, month
)
SELECT CONCAT(year, '-', month) AS year_month,
	orders,
	avg_amount,
	monthly_amount,
	-- 연도별 월별 매출 누계
	SUM(monthly_amount) OVER(PARTITION BY year ORDER BY month
							ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS agg_amount,
	-- 12개월 전의 매출 구하기
	LAG(monthly_amount, 12) OVER(ORDER BY year, month)
	AS last_year_amount,
	-- 12개월 전의 매출 대비 증/감율 파악
	100.0
	* monthly_amount
	/ LAG(monthly_amount, 12) OVER(ORDER BY year, month)
	AS rate
FROM monthly_purchase
ORDER BY year_month;


-- 매출과 관련된 지표 집계 - 2 (중간 집계 없이 구하기)
WITH 
daily_purchase AS (
	SELECT dt,
		-- 년, 월, 일 각각 추출
		substring(dt, 1,4) AS year,
		substring(dt, 6,2) AS month,
		substring(dt, 9,2) AS date,
		-- 일별 매출 합계
		SUM(purchase_amount) AS purchase_amount,
		-- 일별 주문 횟수
		COUNT(*) AS orders
	FROM purchase_log
	GROUP BY dt
)
SELECT year,
	month,
	SUM(orders),
	AVG(purchase_amount) AS avg_amount,
	SUM(purchase_amount) AS purchase_amount,
	-- 연도별 월별 매출 누계
	SUM(SUM(purchase_amount)) OVER(PARTITION BY year ORDER BY month
							ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS agg_amount,
	-- 12개월 전의 매출 구하기
	LAG(SUM(purchase_amount), 12) OVER(ORDER BY year, month)
	AS last_year_amount,
	-- 12개월 전의 매출 대비 증/감율 파악
	100.0
	* SUM(purchase_amount)
	/ LAG(SUM(purchase_amount), 12) OVER(ORDER BY year, month)
	AS rate
FROM daily_purchase
GROUP BY year, month
ORDER BY year, month;
