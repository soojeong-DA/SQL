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

/* 18-3. 데이터 타당성 확인 =============================================================================== */

-- 1. 로그 데이터의 액션별 필수 컬럼 존재 여부에 따른 판정
SELECT action,
	-- session은 NULL이 아니여야 함
	AVG(CASE WHEN session IS NOT NULL THEN 1.0 ELSE 0.0 END) AS session,
	-- user_id는 NULL이 아니여야 함
	AVG(CASE WHEN user_id IS NOT NULL THEN 1.0 ELSE 0.0 END) AS user_id,
	-- category는 action=view일 경우 NULL, 이외의 경우 NOT NULL
	AVG(
		CASE action 
			WHEN 'view' THEN 
				CASE WHEN category IS NULL THEN 1.0 ELSE 0.0 END
			ELSE
				CASE WHEN category IS NOT NULL THEN 1.0 ELSE 0.0 END
		END
	) AS category,
	-- products는 action=view일 경우 NULL, 이외의 경우 NOT NULL
	AVG(
		CASE action 
			WHEN 'view' THEN 
				CASE WHEN products IS NULL THEN 1.0 ELSE 0.0 END
			ELSE
				CASE WHEN products IS NOT NULL THEN 1.0 ELSE 0.0 END
		END
	) AS products,
	-- amount는 action='purchase'의 경우 NOT NULL, 이외의 경우는 NULL
	AVG(
		CASE action 
			WHEN 'purchase' THEN 
				CASE WHEN amount IS NOT NULL THEN 1.0 ELSE 0.0 END
			ELSE
				CASE WHEN amount IS NULL THEN 1.0 ELSE 0.0 END
		END
	) AS amount,
	-- stamp는 NOT NULL
	AVG(CASE WHEN stamp IS NOT NULL THEN 1.0 ELSE 0.0 END) AS stamp
FROM invalid_action_log
GROUP BY action
;

/* 18-4. 특정 IP 주소에서의 접근 제외 
- IP주소를 기반으로 정규 서비스 사용자 이외의 테스트 사용자, 사내 접근 등을 판별해보자 =========================================*/

-- 1. 특정 IP 주소 제외
-- 1-1. 제외 대상 IP 주소를 정의한 master table
WITH
mst_reserved_ip AS (
			  SELECT '127.0.0.0/8' AS network,	'localhost' AS description
	UNION ALL SELECT '10.0.0.0/8' AS network,	'Private network' AS description
	UNION ALL SELECT '172.16.0.0/12' AS network, 'Private network' AS description
	UNION ALL SELECT '192.0.0.0/24' AS network,	'Private network' AS description
	UNION ALL SELECT '192.168.0.0/16' AS network, 'Private network' AS description
)
SELECT *
FROM mst_reserved_ip
;

-- 1-2. inet 자료형을 사용해 IP 주소 판정
WITH
mst_reserved_ip AS (
			  SELECT '127.0.0.0/8' AS network,	'localhost' AS description
	UNION ALL SELECT '10.0.0.0/8' AS network,	'Private network' AS description
	UNION ALL SELECT '172.16.0.0/12' AS network, 'Private network' AS description
	UNION ALL SELECT '192.0.0.0/24' AS network,	'Private network' AS description
	UNION ALL SELECT '192.168.0.0/16' AS network, 'Private network' AS description
)
, action_log_with_reserved_ip AS (
	SELECT a.user_id,
		a.ip,
		a.stamp,
		m.network,
		m.description
	FROM action_log_with_ip a LEFT JOIN mst_reserved_ip m ON a.ip::inet << m.network::inet
)
SELECT *
FROM action_log_with_reserved_ip
;

-- 1-3. 제외 대상 IP 주소의 로그를 제외
WITH
mst_reserved_ip AS (
			  SELECT '127.0.0.0/8' AS network,	'localhost' AS description
	UNION ALL SELECT '10.0.0.0/8' AS network,	'Private network' AS description
	UNION ALL SELECT '172.16.0.0/12' AS network, 'Private network' AS description
	UNION ALL SELECT '192.0.0.0/24' AS network,	'Private network' AS description
	UNION ALL SELECT '192.168.0.0/16' AS network, 'Private network' AS description
)
, action_log_with_reserved_ip AS (
	SELECT a.user_id,
		a.ip,
		a.stamp,
		m.network,
		m.description
	FROM action_log_with_ip a LEFT JOIN mst_reserved_ip m ON a.ip::inet << m.network::inet
)
SELECT *
FROM action_log_with_reserved_ip
WHERE network IS NULL
;
