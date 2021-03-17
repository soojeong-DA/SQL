/* [참고] 데이터 설명 및 파악
- 주문 정보 테이블
- 하나의 order_id에 여러정보(item_id, price, category 등)가 포함되어있음 */
SELECT *
FROM purchase_detail_log;

SELECT 
   column_name, 
   is_nullable,
   data_type
FROM 
   information_schema.columns
WHERE 
   table_name = 'purchase_detail_log';
   
/* 카테고리별 매출과 '소계' 계산 */
-- ROLLLUP 사용
SELECT COALESCE(category, 'all') AS category, -- ROLLUP으로 소계 계산 시, 레코드 집계 키가 NULL이 되므로 변환 필요
	COALESCE(sub_category, 'all') AS category,
	SUM(price) AS amount
FROM purchase_detail_log
GROUP BY ROLLUP(category, sub_category);

/* 'ABC 분석'으로 잘 팔리는 상품 판별 
- ABC 분석: 매출 중요도에 따라 상품의 등급을 나누고, 그에 맞게 전략을 만들 때 사용
- 매출이 어떻게 구성되어 있는지 파악할 때 효과적 */

-- 매출 누성비누계와 ABC 등급 계산
WITH category_amount AS (
	SELECT category,
		SUM(price) AS amount
	FROM purchase_detail_log
	GROUP BY category
),
sales_composition_ratio AS (
	SELECT category,
		amount,
		-- 구성비 (100.0 * 각 카테고리별 amount / amount 총계)
		100.0 * amount / SUM(amount) OVER() 		-- OVER()지정으로 전체 총계 구할 수 있게됨!
		AS composition_ratio,
		-- 구성비 누계 (100.0 * amount 누적 합 / amount 총계)
		100.0 * SUM(amount) OVER(ORDER BY amount DESC) / SUM(amount) OVER()
		AS cumulative_ratio
	FROM category_amount
)
SELECT *,
	CASE
		WHEN cumulative_ratio < 70 THEN 'A'
		WHEN cumulative_ratio < 90 THEN 'B'
		ELSE 'C'
	END AS abc_rank
FROM sales_composition_ratio
ORDER BY amount DESC
;

/* '팬 차트'로 상품의 매출 증가율 확인 
- 어떤 기준 시점을 100%로 두고, 이후의 변동을 백분율로 표시하여 확인
- 팬 차트로 작은 변화도 쉽게 인지하고 상황 판단 가능 */
WITH daily_category_amount AS (
	SELECT dt,
		category,
		-- 년월일 분리
		SUBSTRING(dt, 1, 4) AS year,
		SUBSTRING(dt, 6, 2) AS month,
		SUBSTRING(dt, 9, 2) AS date,
		SUM(price) AS amount
	FROM purchase_detail_log
	GROUP BY dt, category
),
monthly_category_amount AS (
	SELECT CONCAT(year, '-', month) AS year_month,
		category,
		SUM(amount) AS amount
	FROM daily_category_amount
	GROUP BY year_month, category
)
SELECT *,
	-- 기준 시점 매출
	FIRST_VALUE(amount) OVER(PARTITION BY category ORDER BY year_month, category
					  ROWS UNBOUNDED PRECEDING)
	AS base_amount,
	-- 기준 시점 대비 매출 비율 구하기
	100.0 * amount / FIRST_VALUE(amount) OVER(PARTITION BY category ORDER BY year_month, category
					  					ROWS UNBOUNDED PRECEDING)
	AS rate
FROM monthly_category_amount
ORDER BY year_month, category;

/* '히스토그램'으로 구매 가격대 집계 */
-- 임의의 계층 수로 히스토그램 만들기 - 1(히스토그램 함수 사용 X)
WITH stats AS (
	SELECT 
		MAX(price) AS max_price,
		MIN(price) AS min_price,
		MAX(price) - MIN(price) AS range_price,
		-- 계층 수 10개
		10 AS bucket_num
	FROM purchase_detail_log
)
SELECT price,
	min_price,
	-- 정규화 금액: 대상 금액에서 최소 금액을 뺀 것
	price - min_price AS diff,
	-- 계층 범위: 금액 범위를 계층 수로 나눈 것
	1.0 * range_price / bucket_num AS bucket_range,
	-- 계층 판정: FLOOR( 정규화 금액 / 계층 범위 )
	FLOOR(
		1.0 * (price - min_price)
		/ (1.0 * range_price / bucket_num)
	) + 1 -- 계층 1부터 시작하도록
	AS bucket
FROM purchase_detail_log, stats
ORDER BY price;

-- 임의의 계층 수로 히스토그램 만들기 - 2(히스토그램 함수 사용)
WITH stats AS (
	SELECT 
		MAX(price) AS max_price,
		MIN(price) AS min_price,
		MAX(price) - MIN(price) AS range_price,
		-- 계층 수 10개
		10 AS bucket_num
	FROM purchase_detail_log
)
SELECT price,
	min_price,
	-- 정규화 금액: 대상 금액에서 최소 금액을 뺀 것
	price - min_price AS diff,
	-- 계층 범위: 금액 범위를 계층 수로 나눈 것
	1.0 * range_price / bucket_num AS bucket_range,
	width_bucket(price, min_price, max_price, bucket_num) AS bucket
FROM purchase_detail_log, stats
ORDER BY price;  
-- > 계급 범위를 10으로 지정했으나, 최댓값의 계급은 '11'로 판정됨

-- 계층 상한값 조정
-- -- 모든 레코드가 지정한 범위 내부에 들어가도록 '계급 상한 = 최댓값 + 1'로 지정해 다시 구하기
WITH stats AS (
	SELECT 
		MAX(price) + 1 AS max_price,
		MIN(price) AS min_price,
		MAX(price) + 1 - MIN(price) AS range_price,
		-- 계층 수 10개
		10 AS bucket_num
	FROM purchase_detail_log
)
SELECT price,
	min_price,
	-- 정규화 금액: 대상 금액에서 최소 금액을 뺀 것
	price - min_price AS diff,
	-- 계층 범위: 금액 범위를 계층 수로 나눈 것
	1.0 * range_price / bucket_num AS bucket_range,
	width_bucket(price, min_price, max_price, bucket_num) AS bucket
FROM purchase_detail_log, stats
ORDER BY price; 

-- 각 계층의 하한/상한 및 도수 계산
WITH stats AS (
	SELECT 
		MAX(price) + 1 AS max_price,
		MIN(price) AS min_price,
		MAX(price) + 1 - MIN(price) AS range_price,
		10 AS bucket_num
	FROM purchase_detail_log
),
purchase_log_with_bucket AS (
	SELECT price,
		min_price,
		price - min_price AS diff,
		1.0 * range_price / bucket_num AS bucket_range,
		width_bucket(price, min_price, max_price, bucket_num) AS bucket
	FROM purchase_detail_log, stats
)
SELECT bucket,
	-- 계층 하한/상한 계산
	min_price + bucket_range * (bucket - 1) AS lower_limit,
	min_price + bucket_range * bucket AS upper_limit,
	-- 도수 count
	COUNT(price) AS num_purchase,
	-- 금액 합
	SUM(price) AS total_amount
FROM purchase_log_with_bucket
GROUP BY bucket, min_price, bucket_range
ORDER BY bucket
;


-- 임의의 계층 너비로 히스토그램 작성
-- -- 최댓값, 최솟값, 금액 범위 등을 고정값을 기반으로 구분하기 (직관적인 이해가 가능하도록)
WITH stats AS (
	SELECT 
		50000 AS max_price,
		0 AS min_price,
		50000 AS range_price,
		10 AS bucket_num    -- 50,000 / 10 = 5,000원 단위로 구분 됨
	FROM purchase_detail_log
),
purchase_log_with_bucket AS (
	SELECT price,
		min_price,
		price - min_price AS diff,
		1.0 * range_price / bucket_num AS bucket_range,
		width_bucket(price, min_price, max_price, bucket_num) AS bucket
	FROM purchase_detail_log, stats
)
SELECT bucket,
	-- 계층 하한/상한 계산
	min_price + bucket_range * (bucket - 1) AS lower_limit,
	min_price + bucket_range * bucket AS upper_limit,
	-- 도수 count
	COUNT(price) AS num_purchase,
	-- 금액 합
	SUM(price) AS total_amount
FROM purchase_log_with_bucket
GROUP BY bucket, min_price, bucket_range
ORDER BY bucket
;






