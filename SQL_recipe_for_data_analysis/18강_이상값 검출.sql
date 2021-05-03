/* 18. 이상값 검출하기 
- 웹사이트의 접근 로그를 기반으로 노이즈 등의 이상값을 검출해서 데이터 클렌징 하기 */

/* 18-1. 데이터 분산 계산 =================================================================================
- 분산에서 많이 벗어난 값 찾기  
-- 특정 세션의 페이지 조회 수가 극단적으로 많다면, 크롤러일 가능성 높음
-- 반대로 특정 세션의 접근이 적다면 존재하지 않는 URL에 잘못 접근했을 가능성이 있음 ===============================*/

-- 1. 세션별로 페이지 열람 수 랭킹 비율 구하기 (조회 수가 많은 상위 n%의 데이터 확인)
WITH
session_count AS (
	SELECT session,
		COUNT(*) AS count
	FROM action_log_with_noise
	GROUP BY session
)
SELECT session,
	count,
	RANK() OVER(ORDER BY count DESC) AS rank,
	PERCENT_RANK() OVER(ORDER BY count DESC) AS percent_rank
FROM session_count
;

-- 2. URL 접근 수 worst 랭킹 비율 구하기
WITH
url_count AS (
	SELECT url,
		COUNT(*) AS count
	FROM action_log_with_noise
	GROUP BY url
)
SELECT url,
	count,
	RANK() OVER(ORDER BY count ASC) AS rank,
	PERCENT_RANK() OVER(ORDER BY count ASC) AS percent_rank
FROM url_count
;

/* 18-2. 크롤러 제외 ============================================================================================= */

-- 1. 규칙 기반으로 제외 (user agent 특징 이용)
SELECT *
FROM action_log_with_noise
WHERE NOT
	-- 크롤러 판정 조건
	(	user_agent LIKE '%bot%'
	 OR user_agent LIKE '%crawler%'
	 OR user_agent LIKE '%spider%'
	 OR user_agent LIKE '%archiver%')
;

-- 2. 마스터 데이터를 사용해 제외
WITH 
mst_bot_user_agent AS (
			  SELECT '%bot%' 		AS rule
	UNION ALL SELECT '%crawler%'    AS rule
	UNION ALL SELECT '%spider%'     AS rule
	UNION ALL SELECT '%archiver%'   AS rule
)
,filtered_action_log AS (
	SELECT l.stamp,
		l.session,
		l.action,
		l.products,
		l.url,
		l.ip,
		l.user_agent
	FROM action_log_with_noise l
	WHERE -- useragent의 규칙에 해당하지 않는 로그만 남기기
		NOT EXISTS (SELECT *
					 FROM mst_bot_user_agent m
					 WHERE l.user_agent LIKE m.rule)
)
SELECT *
FROM filtered_action_log
;

-- 3. 크롤러 감시하기
-- 크롤러가 새로 발생하는지 확인 (크롤러를 제외한 로그에서 접근이 많은 user agent를 주기적으로 확인)
WITH 
mst_bot_user_agent AS (
			  SELECT '%bot%' 		AS rule
	UNION ALL SELECT '%crawler%'    AS rule
	UNION ALL SELECT '%spider%'     AS rule
	UNION ALL SELECT '%archiver%'   AS rule
)
,filtered_action_log AS (
	SELECT l.stamp,
		l.session,
		l.action,
		l.products,
		l.url,
		l.ip,
		l.user_agent
	FROM action_log_with_noise l
	WHERE -- useragent의 규칙에 해당하지 않는 로그만 남기기
		NOT EXISTS (SELECT *
					 FROM mst_bot_user_agent m
					 WHERE l.user_agent LIKE m.rule)
)
SELECT user_agent,
	COUNT(*) AS count,
	100.0 
	* SUM(COUNT(*)) OVER(ORDER BY COUNT(*) DESC
							  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	/ SUM(COUNT(*)) OVER()
	AS cumulative_ratio
FROM filtered_action_log
GROUP BY user_agent
ORDER BY count DESC
;