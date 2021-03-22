/* 데이터 집약, 가공
- 대량의 데이터를 집계하고, 몇 가지 지표를 사용해 데이터 전체의 특징을 파악할 수 있어야함*/

/* 그룹의 특징 잡기 (집약함수)*/
-- 테이블 전체의 특징량 계산
SELECT COUNT(*) AS total_count,
	COUNT(DISTINCT user_id) AS user_count,
	COUNT(DISTINCT product_id) AS product_count,
	SUM(score) AS sum,
	AVG(score) AS avg,
	MAX(score) AS max,
	MIN(score) AS min
FROM review;

-- 그루핑한 데이터의 특징량 계산
SELECT user_id, 
	COUNT(*) AS total_count,
	COUNT(DISTINCT user_id) AS user_count,
	COUNT(DISTINCT product_id) AS product_count,
	SUM(score) AS sum,
	ROUND(AVG(score),2) AS avg,
	MAX(score) AS max,
	MIN(score) AS min
FROM review
GROUP BY user_id;

-- 집약 함수 적용한 값과 집약 전의 값을 동시에 다루기 (윈도 함수 - PARTITION BY)
-- -- 개별 리뷰 점수와 사용자별 평균 리뷰 점수의 차이 구하기
SELECT user_id,
	product_id,
	-- 개별 리뷰 점수
	score,
	-- 전체 평균 리뷰 점수
	AVG(score) OVER() AS avg_score,
	-- 사용자별 평균 리뷰 점수
	AVG(score) OVER(PARTITION BY user_id) AS user_avg_score,
	-- 개별 리뷰 점수와 사용자별 평균 리뷰 점수 차이
	score - AVG(score) OVER(PARTITION BY user_id) AS user_avg_score_diff
FROM review;

/* 그룹 내부의 순서 */
-- ORDER BY 구문으로 순서 정의하기
SELECT product_id,
	score,
	-- 점수 순서로 유읠한 순위
	ROW_NUMBER() OVER(ORDER BY score DESC) AS row,
	-- 같은 순위 허용(뒤의 순위 번호 건너뜀)
	RANK() OVER(ORDER BY score DESC) AS rank,
	-- 같은 순위 허용(뒤의 순위 번호 건너뛰지 않음)
	DENSE_RANK() OVER(ORDER BY score DESC) AS dense_rank,
	
	-- 현재 행보다 앞에 있는 행의 값 추출
	LAG(product_id) OVER(ORDER BY score DESC) AS lag1,
	LAG(product_id,2) OVER(ORDER BY score DESC) AS lag2,
	
	-- 현재 행보다 뒤에 있는 행의 값 추출
	LEAD(product_id) OVER(ORDER BY score DESC) AS lead1,
	LEAD(product_id,2) OVER(ORDER BY score DESC) AS lead2
FROM popular_products
ORDER BY row;

-- ORDER BY 구문과 집약 함수 조합
/* 구문
SUM(컬럼명) OVER(PARTITION BY [컬럼]
			 ORDER BY [컬럼] [ASC/DESC]
 			 ROWS BETWEEN UNBOUNDED PRECEDING / PRECEDING / CURRENT ROW
        			AND UNBOUNDED FOLLOWING / CURRENT ROW)
- ROW : 부분집합인 윈도우 크기를 물리적인 단위로 행 집합을 지정
- UNBOUNDED PRECEDING : 윈도우의 시작 위치가 첫번째 ROW
- UNBOUNDED FOLLOWING : 윈도우의 마지막 위치가 마지막 ROW
- CURRENT ROW : 윈도우의 시작 위치가 현재 ROW */
SELECT product_id,
		score,
		ROW_NUMBER() OVER(ORDER BY score DESC) AS row,
		-- 순위 상위부터의 누계 점수 계산하기
		SUM(score) OVER(ORDER BY score DESC
					   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_score,
		-- 현재 행과 앞/뒤의 행이 가진 값을 기반으로 평균 점수 계산
		AVG(score) OVER(ORDER BY score DESC
					   ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS local_avg,
		-- 가장 순위가 높은 상품 id 추출
		FIRST_VALUE(product_id) OVER(ORDER BY score DESC
									ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_value,
		-- 가장 순위가 낮은 상품 id 추출
		LAST_VALUE(product_id) OVER(ORDER BY score DESC
									ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_value
FROM popular_products
ORDER BY row;

-- 윈도 프레임 지정별 상품 id 집약 (프레임 지정별 범위 이해)
SELECT product_id,
		score,
		ROW_NUMBER() OVER(ORDER BY score DESC) AS row,
		-- 가장 앞 순위 ~ 가장 뒷 순위까지의 범위(즉, 전체 범위)를 대상으로 상품 id 집약
		array_agg(product_id) OVER(ORDER BY score DESC
								  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS whole_agg,
		-- 가장 앞 순위 ~ 현재 순위 까지의 범위를 대상으로 상품 id 집약
		array_agg(product_id) OVER(ORDER BY score DESC
								  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_agg,
		-- 현재 행(순위) 앞/뒤 범위를 대상으로 상품 id 집약
		array_agg(product_id) OVER(ORDER BY score DESC
								  ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS local_agg
FROM popular_products
WHERE category = 'action'
ORDER BY row;

-- PARTITION BY와 ORDER BY 조합하기(카테고리별 순위 계산)
SELECT category,
	product_id,
	score,
	-- 카테고리별로 점수에 따른 순위 부여
	ROW_NUMBER() OVER(PARTITION BY category ORDER BY score DESC) AS row,
	RANK() OVER(PARTITION BY category ORDER BY score DESC) AS rank,
	DENSE_RANK() OVER(PARTITION BY category ORDER BY score DESC) AS dense_rank
FROM popular_products
ORDER BY category, row;

-- 각 카테고리의 상위 n개 추출
-- -- 윈도 함수를 사용한 결과를 서브쿼리로 만들고, 외부에서 WHERE 구문 적용\
SELECT *
FROM (SELECT category,
	 		score,
	 		ROW_NUMBER() OVER(PARTITION BY category ORDER BY score DESC) AS rank
	 FROM popular_products) AS popular_products_with_rank
	-- 외부 쿼리에서 순위 활용해 압축
WHERE rank <= 2
ORDER BY category, rank;

-- 카테고리별 상위 1개 상품 id 추출 (FIRST_VALUE 사용하면, 서브쿼리 사용하지 않아도 됨) 
SELECT DISTINCT category,   -- 중복 제거
	FIRST_VALUE(product_id) OVER(PARTITION BY category ORDER BY score DESC
					  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS product_id
FROM popular_products;

/* 세로 기반 데이터를 가로 기반으로 변환하기 */
-- 행을 열로 변환(MAX(CASE ~) 이용해서 해당하는 레코드만 추출)
SELECT dt,
	MAX(CASE WHEN indicator = 'impressions' THEN val END) AS impressions,
	MAX(CASE WHEN indicator = 'sessions' THEN val END) AS sessions,
	MAX(CASE WHEN indicator = 'users' THEN val END) AS users
FROM daily_kpi
GROUP BY dt
ORDER BY dt;

-- 행을 쉼표로 구분한 문자열로 집약하기 (미리 열의 수를 정할 수 없는 경우)
-- -- string_agg 함수
SELECT purchase_id,
	-- 상품 id를 배열에 집약하고, 쉼표로 구분된 문자열로 변환
	string_agg(product_id, ',') AS product_ids
FROM purchase_detail_log
GROUP BY purchase_id
ORDER BY 1;

/* 가로 기반 데이터를 세로 기반으로 변환 */
-- 열로 표현된 값을 행으로 변환
-- -- 행으로 전개할 데이터 수가 고정되었다면, 데이터 수와 같은 수의 일련 번호를 가진 피벗 테이블을 만들고, CROSS JOIN
SELECT q.year,
	-- q1 ~ q4까지의 레이블 이름 출력
	CASE
		WHEN p.idx = 1 THEN 'q1'
		WHEN p.idx = 2 THEN 'q2'
		WHEN p.idx = 3 THEN 'q3'
		WHEN p.idx = 4 THEN 'q4'
	END AS quarter,
	-- q1 ~ q4까지의 매출 출력
	CASE
		WHEN p.idx = 1 THEN q.q1
		WHEN p.idx = 2 THEN q.q2
		WHEN p.idx = 3 THEN q.q3
		WHEN p.idx = 4 THEN q.q4
	END AS sales
FROM quarterly_sales AS q
	CROSS JOIN
	(
		SELECT 1 AS idx
	UNION ALL SELECT 2 AS idx
	UNION ALL SELECT 3 AS idx
	UNION ALL SELECT 4 AS idx
	) AS p;

-- 임의의 길이를 가진 배열을 행으로 전개 (데이터 길이가 고정되지 않은)
-- -- unnest 함수
SELECT unnest(ARRAY['A001','A002','A003']) AS product_id;

-- 쉼표로 구분된 문자열 데이터를 행으로 전개 - 1
SELECT purchase_id,
	product_id
FROM purchase_log AS p
	CROSS JOIN
	-- string_to_array 함수로 문자열을 배열로 변환한 후, unnest함수로 테이블로 변환
	unnest(string_to_array(product_ids, ',')) AS product_id;

-- 쉼표로 구분된 문자열 데이터를 행으로 전개 - 2
-- -- regexp_split_to_table함수: 문자열을 구분자로 분할해서 테이블화 해줌
SELECT purchase_id,
	-- 쉼표로 구분된 문자열을 한 번에 행으로 전개
	regexp_split_to_table(product_ids, ',') AS product_id
FROM purchase_log;
