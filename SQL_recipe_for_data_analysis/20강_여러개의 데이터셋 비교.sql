/* 20-1. 데이터의 차이 추출 
- 같은 데이터라도 분석 시점에 따라 데이터의 내용이 달라짐
- 다른 시점 데이터 비교해서, 추가/변경이 없는지, 삭제/결손이 없는지 등 확인해야!============================================ */

-- 1. 추가된 마스터 데이터 추출
-- -- 한쪽에만 존재하는 레고드를 추출할 때 OUTER JOIN 사용해서, NULL인 레코드 추출하면 됨
SELECT new_mst.*
FROM mst_products_20170101 new_mst LEFT OUTER JOIN mst_products_20161201 old_mst
										ON new_mst.product_id = old_mst.product_id
WHERE old_mst.product_id IS NULL
;

-- 2. 제거된 마스터 데이터 추출
SELECT old_mst.*
FROM mst_products_20170101 new_mst RIGHT OUTER JOIN mst_products_20161201 old_mst
										ON new_mst.product_id = old_mst.product_id
WHERE new_mst.product_id IS NULL
;

-- 3. 갱신된 마스터 데이터 추출
-- -- 두 테이블에 모두 존재하고, 특정 컬럼의 값이 다른 레코드 추출하면 됨
-- -- 값이 변경될 때 timestamp 갱신이 일어난다는 것을 전제로 한 예제
SELECT new_mst.product_id,
	old_mst.name AS old_name,
	old_mst.price AS old_price,
	new_mst.name AS new_name,
	new_mst.price AS new_price,
	new_mst.updated_at
FROM mst_products_20170101 new_mst INNER JOIN mst_products_20161201 old_mst 
										ON new_mst.product_id = old_mst.product_id
WHERE new_mst.updated_at != old_mst.updated_at  -- 갱신 시점이 다른 레코드만 추출
;

-- 4. 변경된 마스터 데이터 모두 추출
-- -- 한쪽에만 NULL이 있는 레코드를 확인할 때는 'is distinct from'연산자 or COALESCE 함수로 NULL을 처리하고 비교
SELECT COALESCE(new_mst.product_id, old_mst.product_id) AS product_id,
	COALESCE(new_mst.name, old_mst.name) AS name,
	COALESCE(new_mst.price, old_mst.price) AS price,
	COALESCE(new_mst.updated_at, old_mst.updated_at) AS updated_at,
	CASE
		WHEN old_mst.updated_at IS NULL THEN 'added'
		WHEN new_mst.updated_at IS NULL THEN 'deleted'
		WHEN new_mst.updated_at != old_mst.updated_at THEN 'updated'
	END AS status
FROM mst_products_20170101 new_mst FULL OUTER JOIN mst_products_20161201 old_mst
										ON new_mst.product_id = old_mst.product_id
WHERE new_mst.updated_at IS DISTINCT FROM old_mst.updated_at
;

/* 20-2. 두 순위의 유사도 계산
- 순위들의 유사도를 계산하여, 순위를 정량적으로 평가하는 방법을 알아보자
- '방문 횟수', '방문자 수', '페이지 뷰' 3개 지표 각각의 순위를 구한 뒤, 두 지표의 순위의 연관성 정도 계산 ======================= */

-- 1. 3개 지표별 순위 집계
WITH
path_stat AS (
	-- path별 방문 횟수, 방문자 수, 페이지 뷰 계산
	SELECT path,
		COUNT(DISTINCT long_session) AS access_user,
		COUNT(DISTINCT short_session) AS access_count,
		COUNT(*) AS page_view
	FROM access_log
	GROUP BY path
),
path_ranking AS (
	-- 방문 횟수, 방문자 수, 페이지 뷰별로 순위 부여
	SELECT 'access_user' AS type, 
		path,
		RANK() OVER(ORDER BY access_user DESC) AS rank
	FROM path_stat
	UNION ALL
	SELECT 'access_count' AS type, 
		path,
		RANK() OVER(ORDER BY access_count DESC) AS rank
	FROM path_stat
	UNION ALL
	SELECT 'page_view' AS type, 
		path,
		RANK() OVER(ORDER BY page_view DESC) AS rank
	FROM path_stat
)
SELECT *
FROM path_ranking
ORDER BY type, rank
;

-- 2. 경로별 순위 차이 계산 (diff: 두 순위 차이의 제곱)
WITH
path_stat AS (
	-- path별 방문 횟수, 방문자 수, 페이지 뷰 계산
	SELECT path,
		COUNT(DISTINCT long_session) AS access_user,
		COUNT(DISTINCT short_session) AS access_count,
		COUNT(*) AS page_view
	FROM access_log
	GROUP BY path
),
path_ranking AS (
	-- 방문 횟수, 방문자 수, 페이지 뷰별로 순위 부여
	SELECT 'access_user' AS type, 
		path,
		RANK() OVER(ORDER BY access_user DESC) AS rank
	FROM path_stat
	UNION ALL
	SELECT 'access_count' AS type, 
		path,
		RANK() OVER(ORDER BY access_count DESC) AS rank
	FROM path_stat
	UNION ALL
	SELECT 'page_view' AS type, 
		path,
		RANK() OVER(ORDER BY page_view DESC) AS rank
	FROM path_stat
),
pair_ranking AS (
	SELECT r1.path,
		r1.type AS type1,
		r1.rank AS rank1,
		r2.type AS type2,
		r2.rank AS rank2,
		-- 순위 차이 계산(차이의 제곱)
		POWER(r1.rank - r2.rank, 2) AS diff
	FROM path_ranking r1 INNER JOIN path_ranking r2 ON r1.path = r2.path  --- self join
)
SELECT *
FROM pair_ranking
ORDER BY type1, type2, rank1
;

-- 3. 스피어만 상관계수로 지표간 순위의 유사도 계산
-- --  1.0: 두 개의 순위가 완전히 일치할 경우, -1.0: 완전히 일치하지 않을 경우
--> 스피어만 상관계수 활용 일번적인 예시) 성적을 기반으로 과목의 유사성 측정할 때 ex. '수학 성적이 높은 학생은 영어 성적이 높을까?'  
--> 해당 예제 순위 기반으로 지표의 유사성 측정 ex. 'access_user 순위가 높으면, page_view 순위가 높을까?'
WITH
path_stat AS (
	-- path별 방문 횟수, 방문자 수, 페이지 뷰 계산
	SELECT path,
		COUNT(DISTINCT long_session) AS access_user,
		COUNT(DISTINCT short_session) AS access_count,
		COUNT(*) AS page_view
	FROM access_log
	GROUP BY path
),
path_ranking AS (
	-- 방문 횟수, 방문자 수, 페이지 뷰별로 순위 부여
	SELECT 'access_user' AS type, 
		path,
		RANK() OVER(ORDER BY access_user DESC) AS rank
	FROM path_stat
	UNION ALL
	SELECT 'access_count' AS type, 
		path,
		RANK() OVER(ORDER BY access_count DESC) AS rank
	FROM path_stat
	UNION ALL
	SELECT 'page_view' AS type, 
		path,
		RANK() OVER(ORDER BY page_view DESC) AS rank
	FROM path_stat
),
pair_ranking AS (
	SELECT r1.path,
		r1.type AS type1,
		r1.rank AS rank1,
		r2.type AS type2,
		r2.rank AS rank2,
		-- 순위 차이 계산(차이의 제곱)
		POWER(r1.rank - r2.rank, 2) AS diff
	FROM path_ranking r1 INNER JOIN path_ranking r2 ON r1.path = r2.path  --- self join
)
SELECT type1,
	type2,
	1 - (6.0 * SUM(diff) / (POWER(COUNT(1), 3) - COUNT(1))) AS spearman
FROM pair_ranking
GROUP BY type1, type2
ORDER BY type1, spearman DESC
;
