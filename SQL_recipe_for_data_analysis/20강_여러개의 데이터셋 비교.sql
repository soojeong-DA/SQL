/* 19-1. 데이터의 차이 추출 
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