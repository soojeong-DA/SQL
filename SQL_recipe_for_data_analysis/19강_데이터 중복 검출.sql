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

/* 19-2. 로그 중복 검출하기 
- 사용자가 버튼을 2회 연속으로 클릭하거나 페이지의 새로고침으로 인해 로그가 2회 동시 발생하는 경우 등 =============================== */

-- 1. 중복 데이터 확인
SELECT user_id,
	products,
	-- 데이터를 배열로 집약하고, 쉼표로 구분된 문자열로 변환
	string_agg(session, ',') AS session_list,
	string_agg(stamp,',') AS stamp_list
FROM dup_action_log
GROUP BY user_id, products
HAVING COUNT(*) > 1
;

-- 2. 중복 데이터 배제하기 (같은 session, user_id, action, proudcts일 경우)
-- 2-1. timestamp가 가장 오래된 데이터만 남기는 방법 (집약함수 사용)
SELECT session,
	user_id,
	action,
	products,
	MIN(stamp)
FROM dup_action_log
GROUP BY session, user_id, action, products
;

-- 2-2. ROW_NUMBER를 사용해 중복을 배제하는 방법
WITH
dup_action_log_with_order_num AS (
	SELECT *,
		-- 중복된 데이터에 순번 붙이기
		ROW_NUMBER() OVER(PARTITION BY session, user_id, action, products ORDER BY stamp) AS order_num
	FROM dup_action_log
)
SELECT session,
	user_id,
	action,
	products,
	stamp
FROM dup_action_log_with_order_num
WHERE order_num = 1  -- 순번이 1인 데이터(중복된 것 중에서 가장 앞의 것)만
;

-- 3. timestamp의 간격을 확인해, 일정 시간 이내의 로그를 중복으로 취급하는 방법 (session id 등을 사용할 수 없는 경우)
-- 3-1. 같은 user_id, action, products 조합에 대해, 이전 action으로부터의 경과 시간을 계산
WITH
dup_action_log_with_lag_seconds AS (
	SELECT user_id,
		action,
		products,
		stamp,
		-- 같은 사용자와 상품 조합에 대한 이전 액션으로부터의 경과 시간(초단위) 계산
		EXTRACT(epoch from stamp::timestamp - LAG(stamp::timestamp) OVER(PARTITION BY user_id, action, products
																		ORDER BY stamp)) AS lag_seconds
	FROM dup_action_log
)
SELECT *
FROM dup_action_log_with_lag_seconds
ORDER BY stamp
;

-- 3-2. 30분 이내의 같은 액션은 중복으로 보고 배제
WITH
dup_action_log_with_lag_seconds AS (
	SELECT user_id,
		action,
		products,
		stamp,
		-- 같은 사용자와 상품 조합에 대한 이전 액션으로부터의 경과 시간(초단위) 계산
		EXTRACT(epoch from stamp::timestamp - LAG(stamp::timestamp) OVER(PARTITION BY user_id, action, products
																		ORDER BY stamp)) AS lag_seconds
	FROM dup_action_log
)
SELECT user_id,
	action,
	products,
	stamp
FROM dup_action_log_with_lag_seconds
WHERE lag_seconds IS NULL 
OR lag_seconds >= 30*60
ORDER BY stamp
;
