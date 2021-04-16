/* 사이트 내의 사용자 행동 파악하기
- 웹사이트에서의 특징적인 지표(방문자 수, 방문 횟수, 직귀율, 이탈률 등)의 리포트 작성해보자! 
- sample data: 구인/구직 서비스 activity_log table */

/* 15-1. 입구(랜딩) 페이지와 출구(이탈) 페이지 파악 ==================================================*/

-- 1. 입구 페이지와 출구 페이지 집계
-- 1-1. 세션별 입구/출구 페이지 경로(url) 추출
WITH
activity_log_with_landing_exit AS (
	SELECT session,
		path,
		stamp,
		-- 입구(랜딩) 페이지 경로
		FIRST_VALUE(path) OVER(PARTITION BY session ORDER BY stamp ASC
							  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
		AS landing,
		-- 출구(이탈) 페이지 경로
		LAST_VALUE(path) OVER(PARTITION BY session ORDER BY stamp ASC
							 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
		AS exit
	FROM activity_log
)
SELECT *
FROM activity_log_with_landing_exit
;

-- 1-2. 세션별 입구/출구 페이지를 기반으로, 방문 횟수 추출
WITH
activity_log_with_landing_exit AS (
	SELECT session,
		path,
		stamp,
		-- 입구(랜딩) 페이지 경로
		FIRST_VALUE(path) OVER(PARTITION BY session ORDER BY stamp ASC
							  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
		AS landing,
		-- 출구(이탈) 페이지 경로
		LAST_VALUE(path) OVER(PARTITION BY session ORDER BY stamp ASC
							 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
		AS exit
	FROM activity_log
),
landing_count AS (
	-- 입구 페이지 방문 횟수 집계
	SELECT landing AS path,
		COUNT(DISTINCT session) AS count
	FROM activity_log_with_landing_exit
	GROUP BY 1
),
exit_count AS (
	-- 출구 페이지 방문 횟수 집계
	SELECT exit AS path,
		COUNT(DISTINCT session) AS count
	FROM activity_log_with_landing_exit
	GROUP BY 1
)
-- 입구/출구 페이지 방문 횟수 결과 한꺼번에 출력
SELECT 'landing' AS type, * FROM landing_count
UNION ALL
SELECT 'exit' AS type, * FROM exit_count
;

-- 2. 어디에서 조회를 시작하고, 어디에서 이탈하는지 집계
-- 입구/출구 페이지의 조합을 집계하면 됨
WITH
activity_log_with_landing_exit AS (
	SELECT session,
		path,
		stamp,
		-- 입구(랜딩) 페이지 경로
		FIRST_VALUE(path) OVER(PARTITION BY session ORDER BY stamp ASC
							  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
		AS landing,
		-- 출구(이탈) 페이지 경로
		LAST_VALUE(path) OVER(PARTITION BY session ORDER BY stamp ASC
							 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
		AS exit
	FROM activity_log
)
SELECT landing,
	exit,
	COUNT(DISTINCT session) AS count
FROM activity_log_with_landing_exit
GROUP BY 1,2
;

/* 15-2. 이탈률과 직귀율 계산 ==================================================================================
- 이탈률 = 출구 수 / 페이지 뷰
-- 단순하게 이탈률이 높은 페이지가 나쁜게 아님! (사용자가 만족해서 이탈하는 경우, 만족하지 못해서 중간 과정에서 이탈하는 경우 구분해야!)

- 직귀율 = 직귀 수 / 입구 수 = 직귀 수 / 방문 횟수
-- 직귀율이 높은 페이지는 성과로 이어지지 않을 가능성이 높음 -> 확인하고 대책 세워야  ===================================*/

-- 1. 경로별 이탈률 집계
WITH
activity_log_with_exit_flag AS (
	SELECT *,
		-- 출구 페이지 판정
		CASE
			WHEN ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp DESC) = 1 THEN 1 ELSE 0
		END AS is_exit
	FROM activity_log
)
SELECT path,
	SUM(is_exit) AS exit_count, -- 출구 수
	COUNT(*) AS page_view, -- 페이지 뷰
	AVG(100.0 * is_exit) AS exit_ratio  -- 이탈률
FROM activity_log_with_exit_flag
GROUP BY 1
ORDER BY exit_ratio DESC
;

-- 2. 경로별 직귀율 집계
-- 직귀 수 = 한 페이지만을 조회한 방문 횟수
WITH activity_log_with_landing_bounce_flag AS (
	SELECT *,
		-- 입구 페이지 판정
		CASE
			WHEN ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp ASC) = 1 THEN 1 ELSE 0
		END AS is_landing,
		-- 직귀 판정
		CASE
			WHEN COUNT(*) OVER(PARTITION BY session) = 1 THEN 1 ELSE 0
		END AS is_bounce
	FROM activity_log
)
SELECT path,
	SUM(is_bounce) AS bounce_count,
	SUM(is_landing) AS landing_count,
	AVG(100.0 * CASE WHEN is_landing = 1 THEN is_bounce END) AS bounce_ratio
FROM activity_log_with_landing_bounce_flag
GROUP BY 1
ORDER BY bounce_ratio DESC
;

