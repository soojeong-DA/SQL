/* 23-1. 추천 시스템의 넓은 의미 =============================================================================================
- 추천 시스템의 종류
	1. Item to Item
		- 열람/구매 아이템을 기반으로 다른 아이템을 추천
		- ex. 이 상품을 본 사람들을 다음 상품도 보았습니다
		1) 열람 로그
			- 특정 아템과 유사한 다른 아이템을 추천해서, 사용자의 선택지를 늘릴 수 있음
		2) 구매 로그
			- 함께 구매 가능한 상품을 추천해서, 구매 단가를 끌어 올릴 수 있음
	2. User to Item
		- 사용자의 과거 행동 or 데모그래픽 정보를 기반으로 흥미와 기호를 유추하고, 아이템을 추천
		- ex. 당신만을 위한 추천 아이템
		
- 추천의 효과
	1. 다운셀
		- 가격이 높아 구매를 고민하는 사용자에게 더 저렴한 아이템을 제안해서 '구매 수'를 올리는 것
	2. 크로스셀
		- 관련 상품을 함께 구매하게 해서 '구매 단가'를 올리는 것
	3. 업셀
		- 상위 모델 or 고성능의 아이템을 제안해서 '구매 단가'를 올리는 것
		
- 이 외에도 다양한 목적, 효과, 모듈이 있으니, 추천 시스템의 정의를 확실하게 하고, 어떤 효과를 기대하는 지등을 구체화한 뒤, 시스템을 구축해야함
========================================================================================================================= */

/* 23-2. (Item to Item) 특정 아이템에 흥미가 있는 사람이 함께 찾아보는 아이템 검색 
- 사용자의 흥미와 관심은 시간에 따라 계속 변화하지만, 
- 아이템끼리의 연관성은 시간이 지나도 크게 변하지 않음 (아이템 자체가 뉴스 기사처럼 유동적이지 않을 경우) ============================== */

-- 1. 접근 로그를 사용해 아이템 유사도 계산
-- 1-1. 열람 수와 구매 수를 조합해 점수를 계산
WITH
ratings AS (
	SELECT user_id,
		product,
		-- 상품 열람 수 
		SUM(CASE WHEN action = 'view' THEN 1 ELSE 0 END) AS view_count,
		-- 상품 구매 수
		SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
		-- 열람 수와 구매 수에 3:7 비율의 가중치를 주어 평균 구하기
		0.3 * SUM(CASE WHEN action = 'view' THEN 1 ELSE 0 END)
		+ 0.7 * SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)
		AS score
	FROM action_log
	GROUP BY 1,2
)
SELECT *
FROM ratings
ORDER BY user_id, score DESC
;

-- 1-2. 아이템 사이의 유사도 계산 및 순위 생성
WITH
ratings AS (
	SELECT user_id,
		product,
		-- 상품 열람 수 
		SUM(CASE WHEN action = 'view' THEN 1 ELSE 0 END) AS view_count,
		-- 상품 구매 수
		SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
		-- 열람 수와 구매 수에 3:7 비율의 가중치를 주어 평균 구하기
		0.3 * SUM(CASE WHEN action = 'view' THEN 1 ELSE 0 END)
		+ 0.7 * SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)
		AS score
	FROM action_log
	GROUP BY 1,2
)
SELECT r1.product AS target,
	r2.product AS related,
	-- 모든 아이템을 열람/구매한 사용자 수
	COUNT(r1.user_id) AS users,
	-- score들을 곱하고 합계를 구해 유사도 계산
	SUM(r1.score * r2.score) AS score,
	-- 상품의 유사도 순위 구하기
	ROW_NUMBER() OVER(PARTITION BY r1.product ORDER BY SUM(r1.score * r2.score) DESC) AS rank
FROM ratings r1 INNER JOIN ratings r2 ON r1.user_id = r2.user_id
WHERE r1.product != r2.product  -- 같은 item인 경우는 조합에서 제외
GROUP BY r1.product, r2.product
ORDER BY target, rank
;

-- 2. 점수 정규화 진행 후, 아이템간 유사도 계산
/* ===============================================================================
- 단순한 벡터 내적을 사용한 유사도의 정밀도 문제
	1. 접근 수가 많은 아이템의 유사도가 상대적으로 높게 나옴
	2. 유사도 점수 값이 어느 정도의 유사도를 나타내는 지 점수만으로는 알기 어려움
- 해결 방법: 벡터 정규화
	- 벡터를 모두 같은 길이로 만듬
	- 노름(벡터의 크기)으로 벡터의 각 수치를 나누면, 벡터의 노름(벡터의 크기)을 1로 만들 수 있음
==================================================================================== */
-- 2-1. 아이템 벡터 L2 정규화
WITH
ratings AS (
	SELECT user_id,
		product,
		-- 상품 열람 수 
		SUM(CASE WHEN action = 'view' THEN 1 ELSE 0 END) AS view_count,
		-- 상품 구매 수
		SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
		-- 열람 수와 구매 수에 3:7 비율의 가중치를 주어 평균 구하기
		0.3 * SUM(CASE WHEN action = 'view' THEN 1 ELSE 0 END)
		+ 0.7 * SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)
		AS score
	FROM action_log
	GROUP BY 1,2
)
, product_base_normalized_ratings AS (
	-- 아이템 벡터 정규화
	SELECT user_id,
		product,
		score,
		SQRT(SUM(score * score) OVER(PARTITION BY product)) AS norm,
		score / SQRT(SUM(score * score) OVER(PARTITION BY product)) AS norm_score  -- 정규화: 각 score / norm
	FROM ratings
)
SELECT *
FROM product_base_normalized_ratings
;

-- 2-2. 정규화된 점수로 아이템의 유사도 계산
WITH
ratings AS (
	SELECT user_id,
		product,
		-- 상품 열람 수 
		SUM(CASE WHEN action = 'view' THEN 1 ELSE 0 END) AS view_count,
		-- 상품 구매 수
		SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
		-- 열람 수와 구매 수에 3:7 비율의 가중치를 주어 평균 구하기
		0.3 * SUM(CASE WHEN action = 'view' THEN 1 ELSE 0 END)
		+ 0.7 * SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)
		AS score
	FROM action_log
	GROUP BY 1,2
)
, product_base_normalized_ratings AS (
	-- 아이템 벡터 정규화
	SELECT user_id,
		product,
		score,
		SQRT(SUM(score * score) OVER(PARTITION BY product)) AS norm,
		score / SQRT(SUM(score * score) OVER(PARTITION BY product)) AS norm_score  -- 정규화: 각 score / norm
	FROM ratings
)
SELECT r1.product AS target,
	r2.product AS related,
	-- 모든 아이템을 열람/구매한 사용자 수
	COUNT(r1.user_id) AS users,
	-- score들을 곱하고 합계를 구해 유사도 계산
	SUM(r1.norm_score * r2.norm_score) AS score,
	-- 상품별 유사도 순위 생성
	ROW_NUMBER() OVER(PARTITION BY r1.product ORDER BY SUM(r1.norm_score * r2.norm_score) DESC) AS rank
FROM product_base_normalized_ratings r1 INNER JOIN product_base_normalized_ratings r2 
											ON r1.user_id = r2.user_id  -- 공통 사용자가 존재하는 것만 상품 pair 만들기
GROUP BY r1.product, r2.product
ORDER BY target, rank
; 

-- 벡터 정규화 score
--> 1: 완전 일치하는 아이템, 최댓값
--> 0: 전혀 유사성이 없는 아이템
