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

