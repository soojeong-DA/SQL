/* 18. 이상값 검출하기 
- 웹사이트의 접근 로그를 기반으로 노이즈 등의 이상값을 검출해서 데이터 클렌징 하기 */

/* 18-1. 데이터 분산 계산 =================================================================================
- 분산에서 많이 벗어난 값 찾기  
--> 특정 세션의 페이지 조회 수가 극단적으로 많다면, 크롤러일 가능성 높음
--> 반대로 특정 세션의 접근이 적다면 존재하지 않는 URL에 잘못 접근했을 가능성이 있음 ===============================*/

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

