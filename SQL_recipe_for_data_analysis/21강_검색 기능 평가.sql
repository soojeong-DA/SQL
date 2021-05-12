/* 21강. 검색 기능 평가하기
-  사용자가 무엇을 검색하고, 그 검색 결과에 어떤 행동(상세화면 이동, 이탈, 재검색 등)을 취하는지 파악해서, 검색기능 개선하기 ============= */

/* 21-1. NoMatch 비율과 키워드 집계 ======================================================================================= */

-- 1. NoMatch 바율 집계 (일별)
SELECT substring(stamp::text, 1, 10) AS dt,
	COUNT(*) AS search_count,
	SUM(CASE WHEN result_num = 0 THEN 1 ELSE 0 END) AS no_match_count,
	AVG(CASE WHEN result_num = 0 THEN 1.0 ELSE 0.0 END) AS no_match_rate
FROM access_log
WHERE action = 'search'
GROUP BY dt
;

-- 2. NoMatch 키워드 집계
WITH
search_keyword_stat AS (
	-- 검색 키워드 전체 집계 결과
	SELECT keyword,
		result_num,
		COUNT(*) AS search_count,
		100.0 * COUNT(*) / COUNT(*) OVER() AS search_share   -- 전체 검색에서 차지하는 비중
	FROM access_log
	WHERE action = 'search'
	GROUP BY keyword, result_num
)
-- nomatch keyword 집계 결과
SELECT keyword,
	search_count,
	search_share,
	100.0 * search_count / SUM(search_count) OVER() AS no_match_share  -- 전체 no match 검색에서 차지하는 비중
FROM search_keyword_stat
WHERE result_num = 0    -- no match만
;

/* 21-2. 재검색 비율과 키워드 집계 
- 검색 결과에 만족하지 못해서 새로운 키워드로 검색한 사용자의 행동은, 검색을 어떻게 개선하면 좋을지에 대한 좋은 지표가 됨 
- 재검색 키워드를 집계하면 '동의어 사전'이 흔들림을 잡기 못하는 범위를 쉽게 확인 후, 대처 할 수 있음 =============================== */

-- 1. 재검색 비율 집계 (검색 후 어떤 결과도 클릭하지 않고, 새로 검색을 실행한 비율)
-- 1-1. 검색 화면과 상세화면의 접근 로그에서 바로 다음 행의 액션 추출
WITH
access_log_with_next_action AS (
	SELECT stamp,
		session,
		action,
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action
	FROM access_log
)
SELECT *
FROM access_log_with_next_action
ORDER BY session, stamp
;

-- 1-2. '재검색 = action과 next_action 모두 search인 레코드' 비율 집계
WITH
access_log_with_next_action AS (
	SELECT stamp,
		session,
		action,
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action
	FROM access_log
)
SELECT substring(stamp::text, 1, 10) AS dt,
	COUNT(*) AS search_count,
	SUM(CASE WHEN next_action = 'search' THEN 1 ELSE 0 END) AS retry_count,
	AVG(CASE WHEN next_action = 'search' THEN 1.0 ELSE 0.0 END) AS retry_rate
FROM access_log_with_next_action
WHERE action = 'search'
GROUP BY dt
ORDER BY dt
;

-- 2. 재검색 키워드 집계
WITH
access_log_with_next_search AS (
	SELECT stamp,
		session,
		action,
		keyword,
		result_num,
		-- 다음 행의 액션, 키워드, 검색 결과 수 추출
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action,
		LEAD(keyword) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_keyword,
		LEAD(result_num) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_result_num
	FROM access_log
)
SELECT keyword,
	result_num,
	COUNT(*) AS retry_count,
	next_keyword,
	next_result_num
FROM access_log_with_next_search
WHERE action = 'search'
AND next_action = 'search'
GROUP BY keyword, result_num, next_keyword, next_result_num
ORDER BY retry_count DESC
;
