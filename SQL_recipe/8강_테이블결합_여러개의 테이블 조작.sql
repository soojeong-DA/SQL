/* 여러 개의 테이블을 세로로 결합 (UNION ALL) 
- 한번에 같은 처리를 적용해야할 때 주로 사용!
- 결합시 테이블의 컬럼이 완전히 일치해야함
  => 한쪽 테이블에만 존재하는 컬럼은 SELECT 구문에서 제외 or default값을 지정해야함 */
SELECT 'app1' AS app_name, -- 결합 후 데이터가 어떤 테이블의 데이터 였는지 식별할 수 있게 app_name열 추가
	user_id,
	name,
	email
FROM app1_mst_users
UNION ALL
SELECT 'app2' AS app_name,
	user_id,
	name,
	NULL AS email -- app2에는 email 데이터가 없어, default 값으로 NULL 지정해줌
FROM app2_mst_users;

/* 여러 개의 테이블을 가로로 정렬 (JOIN)
- 데이터를 비교하거나, 값을 조합하고 싶을 때 */

-- (INNER) JOIN 사용으로, (book 카테고리가 결합되지 못하여 사라짐 + 가격 중복 출력) 문제 발생하는 쿼리
SELECT m.category_id,
	m.name,
	s.sales,
	r.product_id AS sale_product
FROM mst_categories m 
		JOIN category_sales s ON m.category_id = s.category_id
		JOIN product_sale_ranking r ON m.category_id = r.category_id
;

-- LEFT JOIN 사용해서 결합 테이블에 조인 대상이 없더라도 레코드 유지 + 1위 상품만 결합하는 조건 추가해서 중복 피하기
SELECT m.category_id,
	m.name,
	s.sales,
	r.product_id AS top_sale_product
FROM mst_categories m 
		LEFT JOIN category_sales s 
		ON m.category_id = s.category_id
		LEFT JOIN product_sale_ranking r 
		ON m.category_id = r.category_id 
		AND r.rank = 1    -- 1위 상품만 결합
;

-- 상관 서브쿼리 사용해서 같은 결과를 내는 쿼리 작성
SELECT m.category_id,
	m.name,
	-- 상관 서브쿼리를 사용해 카테고리별 매출액 추출
	(SELECT s.sales
	FROM category_sales s
	WHERE m.category_id = s.category_id) AS sales,  -- 같은 category_id 조건 지정!
	-- 상관 서브쿼리를 사용해 카테고리별 최고 매출 상품 하나 추출(limit)
	(SELECT r.product_id
	FROM product_sale_ranking r
	WHERE m.category_id = r.category_id
	ORDER BY sales DESC
	LIMIT 1) AS top_sale_product
FROM mst_categories m;

/* 조건 플래그를 0과 1로 표현하기(CASE, SIGN) */
-- '신용카드 번호 등록 여부', '구매 이력 여부' 두 가지 조건을 0과 1로 표현
SELECT m.user_id,
	m.card_number,
	COUNT(p.user_id) AS purchase_count,
	-- 신용카드 등록 여부
	CASE WHEN m.card_number IS NOT NULL THEN 1 ELSE 0 END AS has_card,
	-- 구매 이력 여부 방법 1(CASE)
	CASE WHEN COUNT(p.purchase_id) != 0 THEN 1 ELSE 0 END AS has_purchased_1,
	-- 구매 이력 여부 방법 2(SIGN)
	SIGN(COUNT(p.purchase_id)) AS has_purchased_2
FROM mst_users_with_card_number m
		LEFT JOIN purchase_log p ON m.user_id = p.user_id
GROUP BY 1,2  -- GROUP BY로 묶어 마스터 테이블 레코드 수 그대로 유지
;

