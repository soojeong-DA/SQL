/* 데이터 마이닝: 대량의 데이터에서 특정 패턴 or 규칙 등 유용한 지식을 추출하는 방법
	- 방법: 상관 규칙 추출, 클러스터링, 상관 분석 등  => 보통 R,python에 구현된 라이브러리를 활용해 분석 (SQL X) ================ */


/* 22-1. Association Rule =========================================================================================
- '상품 조합(A,B,C,...)을 구매한 사람의 n%는 상품 조합(x,y,z,...)도 구매한다'  
- 시간적 차이와 인과 관계를 가지는 상관 규칙 (단, 반대의 경우는 성립하지 않음)
- 분석에 사용되는 3가지 주요 지표
	1. 지지도(Support)
		- 상관 규칙이 어느 정도의 확률로 발생하는지 나타내는 값
	2. 신뢰도(Confidence)
		- 어떤 결과가 어느 정도의 확률로 발생하는지 의미하는 값
	3. 리프트(Lift)
		- '어떤 조건을 만족하는 경우의 확률(신뢰도)'을 '사전 조건 없이 해당 결과가 일어날 확률(특정 상품 구매 확률)'로 나눈 값
		- 보통 리프트 값이 1.0 이상이면 좋은 규칙이라 판단
		
	- ex) 100개의 구매 로그에 상품 X를 구매하는 로그가 50개, 상품 X,Y를 모두 구매하는 로그가 20개, 상품 Y만 구매하는 로그가 20개
		1) 지지도: 20(X,Y동시구매)/100 = 20%
		2) 신뢰도: 20(X,Y동시구매)/50(X구매) = 40%
		3) 리프트: 40%(신뢰도)/20%(상품 Y 구매 확률) = 2.0
====================================================================================================================== */

-- 1. 두 상품의 연관성을 association rule로 찾기 (필요 데이터: 구매 로그 총 수, 상품 A,B별 구매수, 동시 구매수)
-- -- sql구현 한계로, 여기서는 2개 상품 조합으로 단순화하여 실습

-- 1-1. 구매 로그 수와 상품별 구매 수 계산
WITH
purchase_id_count AS (
	-- 구매 상세 로그에서 unique한 구매 로그 수 계산
	SELECT COUNT(DISTINCT purchase_id) AS purchase_count  -- 구매 로그 총 수
	FROM purchase_detail_log
)
, purchase_detail_log_with_counts AS (
	SELECT d.purchase_id,
		p.purchase_count,
		d.product_id,
		-- 상품별 구매 수 계산
		COUNT(*) OVER(PARTITION BY d.product_id) AS product_count
	FROM purchase_detail_log d CROSS JOIN purchase_id_count p
)
SELECT *
FROM purchase_detail_log_with_counts
ORDER BY 1,3
;

-- 1-2. 동시 구매 상품 페어 생성 및 조합별 구매 수 계산
WITH
purchase_id_count AS (
	-- 구매 상세 로그에서 unique한 구매 로그 수 계산
	SELECT COUNT(DISTINCT purchase_id) AS purchase_count  -- 구매 로그 총 수
	FROM purchase_detail_log
)
, purchase_detail_log_with_counts AS (
	SELECT d.purchase_id,
		p.purchase_count,
		d.product_id,
		-- 상품별 구매 수 계산
		COUNT(*) OVER(PARTITION BY d.product_id) AS product_count
	FROM purchase_detail_log d CROSS JOIN purchase_id_count p
)
, product_pair_with_stat AS (
	SELECT l1.product_id AS p1,
		l2.product_id AS p2,
		-- 상품별 구매수
		l1.product_count AS p1_count,
		l2.product_count AS p2_count,
		-- 동시 구매수
		COUNT(*) AS p1_p2_count, 
		-- 구매 로그 총 수
		l1.purchase_count AS purchase_count
	FROM purchase_detail_log_with_counts l1 JOIN purchase_detail_log_with_counts l2 ON l1.purchase_id = l2.purchase_id
	WHERE l1.product_id != l2.product_id  -- 같은 상품 조합 제외
	GROUP BY 1,2,3,4,6
)
SELECT *
FROM product_pair_with_stat
ORDER BY p1, p2
;

-- 1-3. 지지도, 신뢰도, 리프트 계산
WITH
purchase_id_count AS (
	-- 구매 상세 로그에서 unique한 구매 로그 수 계산
	SELECT COUNT(DISTINCT purchase_id) AS purchase_count  -- 구매 로그 총 수
	FROM purchase_detail_log
)
, purchase_detail_log_with_counts AS (
	SELECT d.purchase_id,
		p.purchase_count,
		d.product_id,
		-- 상품별 구매 수 계산
		COUNT(*) OVER(PARTITION BY d.product_id) AS product_count
	FROM purchase_detail_log d CROSS JOIN purchase_id_count p
)
, product_pair_with_stat AS (
	SELECT l1.product_id AS p1,
		l2.product_id AS p2,
		-- 상품별 구매수
		l1.product_count AS p1_count,
		l2.product_count AS p2_count,
		-- 동시 구매수
		COUNT(*) AS p1_p2_count, 
		-- 구매 로그 총 수
		l1.purchase_count AS purchase_count
	FROM purchase_detail_log_with_counts l1 JOIN purchase_detail_log_with_counts l2 ON l1.purchase_id = l2.purchase_id
	WHERE l1.product_id != l2.product_id  -- 같은 상품 조합 제외
	GROUP BY 1,2,3,4,6
)
SELECT p1,
	p2,
	100.0 * p1_p2_count / purchase_count AS support,
	100.0 * p1_p2_count / p1_count AS confidence,
	(100.0 * p1_p2_count / p1_count) / (100.0 * p2_count / purchase_count) AS lift
FROM product_pair_with_stat
ORDER BY p1, p2
;
