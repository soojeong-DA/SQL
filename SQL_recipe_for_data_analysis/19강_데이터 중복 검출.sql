/* 19-1. 마스터 데이터의 중복 검출 ========================================================================= */

-- 1. key의 중복을 확인 (전체 레코드 수와 유니크한 키의 수 일치하나 확인)
SELECT COUNT(*) AS total_num,
	COUNT(DISTINCT id) AS key_num
FROM mst_categories
;

-- 2. key가 중복되는 레코드 확인
-- 2-1. 중복된 값을 배열로 집약하는 string_agg 함수 활용
SELECT id,
	COUNT(*) AS record_num,
	-- 데이터를 배열로 집약하고, 쉽표로 구분된 문자열로 변환
	string_agg(name, ',') AS name_list,
	string_agg(stamp, ',') AS stamp_list
FROM mst_categories
GROUP BY id
HAVING COUNT(*) > 1 -- 레코드가 수가 1보다 큰 = 중복되는 ID
;

-- 2-2. 원래 형식으로 중복 레코드 확인
WITH
mst_categories_with_key_num AS (
	SELECT *,
		-- ID 중복 세기
		COUNT(*) OVER(PARTITION BY id) AS key_num
	FROM mst_categories
)
SELECT *
FROM mst_categories_with_key_num
WHERE key_num > 1 -- ID가 중복되는 경우
;



