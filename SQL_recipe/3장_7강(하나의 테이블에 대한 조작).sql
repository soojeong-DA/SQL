-- # 그룹의 특징 잡기 - 집약 함수, GROUP BY, 윈도우 함수(분석 함수), OVER(...PARTITION BY~) ########################
-- 테이블 전체의 특징량 계산: 집약 함수
SELECT * FROM review;
SELECT
	COUNT(*) AS total_count
	, COUNT(DISTINCT user_id) AS user_count
	, COUNT(DISTINCT product_id) AS product_count
	, SUM(score) AS sum
	, ROUND(AVG(score),2) as avg
	, MAX(score) as max
	, MIN(score) as min
FROM review;

-- 그루핑한 데이터의 특징량 계산: GROUP BY
SELECT
	user_id
	, COUNT(*) AS total_count
	, COUNT(DISTINCT user_id) AS user_count
	, COUNT(DISTINCT product_id) AS product_count
	, SUM(score) AS sum
	, ROUND(AVG(score),2) as avg
	, MAX(score) as max
	, MIN(score) as min
FROM review
GROUP BY user_id
;

-- 집약 함수를 적용한 값과 집약 전 값을 동시에 다루기: 윈도우 함수
select
	user_id
	, product_id
	-- 개별 리뷰 점수
	, score
	-- 전체 평균 리뷰 점수
	, round(avg(score) OVER(),2) AS avg_score
	-- 사용자의 평균 리뷰 점수
	, round(avg(score) OVER(PARTITION BY user_id),2) AS user_avg_socre
	-- 개별 리뷰 점수와 사용자 평균 리뷰 점수의 차이
	, round(score - avg(score) OVER(PARTITION BY user_id),2) AS user_avg_socre_diff
from review
;

-- # 그룹 내부의 순서 (윈도우 함수 이용)#####################################################
select *from popular_products;
-- 윈도우 함수 내의 ORDER BY 구문으로 순서 정의: ORDER BY / ROW_NUMBER, RANK, DENSE_RANK / LAG(앞), LEAD(뒤)
SELECT
	product_id
	, score
	
	-- socre 순서로 유일한/고유한 순위
	, ROW_NUMBER()	OVER(ORDER BY score DESC) AS row
	-- 같은 순위 허용한 순위
	-- 1. RANK(): 같은 순위 다음 순위 건너뛰기
	, RANK()	OVER(ORDER BY score DESC) AS rank
	--2. DENSE_RANK(): 같은 순위 다음 순위 건너뛰지 않음
	, DENSE_RANK() OVER(ORDER BY score DESC) AS dense_rank
	
	-- LAG: 현재 행 기준으로, N번째 앞의 행의 값 추출
	, LAG(product_id)	OVER(ORDER BY score DESC) AS lag1
	, LAG(product_id,2)	OVER(ORDER BY score DESC) AS lag2
	
	-- LEAD: 현재 행 기준으로, N번째 뒤의 행의 값 추출
	, LEAD(product_id) OVER(ORDER BY score DESC) AS lead1
	, LEAD(product_id,2) OVER(ORDER BY score DESC) AS lead2
FROM popular_products
ORDER BY row;

-- ORDER BY 구문과 집약 함수 조합하기: ROWS 구문, FIRST_VALUE, LAST_VALUE
SELECT
	product_id
	, score
	 -- score 순서로 유일한 순위 부여
	, ROW_NUMBER() OVER(ORDER BY score DESC) AS row
	
	-- 순위 상위부터의 누계 점수 계산 (현재 행까지 더하기)
	, SUM(score)
		OVER(ORDER BY score DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS cum_score
	
	-- 현재 행과 앞 뒤의 행이 가진 값을 기반으로 평균 점수 계산
	, round(AVG(score)
		OVER(ORDER BY score DESC
			ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),2)
	AS local_avg
	
	-- 순위가 가장 높은 상품 ID 추출
	, FIRST_VALUE(product_id)
		OVER(ORDER BY score DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS first_value
	
	-- 순위가 가장 낮은 상품 ID 추출
	, LAST_VALUE(product_id)
		OVER(ORDER BY score DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS last_value
FROM popular_products
ORDER BY row
;

-- 윈도 프레임 지정별 상품 ID 집약
select
	product_id
	-- 점수 순서로 유일한 순위 부여
	, ROW_NUMBER() OVER(ORDER BY score DESC) AS row
	
	-- 가장 앞 순위부터 가장 뒷 순위까지의 범위 - 상품 ID 집약
	-- PostgreSQL - array_agg 사용
	, array_agg(product_id)
		OVER(ORDER BY score DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS whole_agg
	
	-- 가장 앞 ~ 현재 순위까지의 범위
	, array_agg(product_id)
		OVER(ORDER BY score DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS cum_agg
	
	-- 순위 1 앞 ~ 1뒤까지의 범위 (현재행 포함)
	, array_agg(product_id)
		OVER(ORDER BY score DESC
			ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
	AS local_agg
FROM popular_products
WHERE category = 'action'
ORDER BY row
;
	
-- PARITION BY와 ORDER BY 조합하기: 카테고리별 순위 계산
SELECT
	category
	, product_id
	, score
	
	-- 카테고리별로 점수 순서로 정렬 -> 유일한 순위 부여
	, ROW_NUMBER()
		OVER(PARTITION BY category ORDER BY score DESC)
	AS row
	
	-- 카테고리별로 점수 순서로 정렬 -> 동일 순위 허용
	, RANK()
		OVER(PARTITION BY category ORDER BY score DESC)
	AS rank
	
	-- 카테고리별로 점수 순서로 정렬 -> 동일 순위 허용, 순위 건너뛰지 않음
	, DENSE_RANK()
		OVER(PARTITION BY category ORDER BY score DESC)
	AS dense_rank
FROM popular_products
ORDER BY category, row
;

-- 각 카테고리별 상위 n개 추출
-- SQL 실행 순서 특성상 - select 구문에서 윈도 함수를 사용한 결과를 서브쿼리로 만들고, 외부에서 where 구분으로 잘라야함
select * 
from
	-- 서브 쿼리 내부에서 순위 계산
	(select
		category
		, product_id
		, score
		, ROW_NUMBER()
			OVER(PARTITION BY category ORDER BY score DESC) AS rank
	 from popular_products
	 ) AS popular_products_with_rank
	-- 외부 쿼리에서 순위 활용해 압축/잘라 내기
where rank <= 2
order by category, rank
;

-- 카테고리별 최상위 순위 상품 추출: FIRST_VALUE, DISTINCT 함수 사용해 서브쿼리 사용 X
SELECT DISTINCT
	category
	-- 카테고리별 최상위 순위 상품 ID 추출
	, FIRST_VALUE(product_id)
		OVER(PARTITION BY category ORDER BY score DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS product_id
FROM popular_products;
		
	