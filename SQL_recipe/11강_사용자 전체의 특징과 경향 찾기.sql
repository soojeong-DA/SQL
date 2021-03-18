/* [참고] 데이터 설명 및 파악
- 사용자 속성, 사용자 행동(액션로그) 2개의 테이블 */
SELECT *
FROM mst_users;

SELECT *
FROM action_log;

/* 사용자 액션 수 집계 */
-- 액션 수와 비율 계산 (사용률, 1명 당 액션수)
WITH stats AS (
	-- 로그 전체의 유니크 사용자 수 구하기 (session unique 값으로 구함!)
	SELECT COUNT(DISTINCT session) AS total_uu
	FROM action_log
)
SELECT l.action,
	-- 액션 UU
	COUNT(DISTINCT l.session) AS action_uu,
	-- 액션 수
	COUNT(1) AS action_count,
	-- 전체 UU
	s.total_uu,
	-- 사용률: 액션 UU / 전체 UU
	100.0 * COUNT(DISTINCT l.session) / s.total_uu AS usage_rate,
	-- 1인당 액션 수: 액션 수 / 액션 UU
	1.0 * COUNT(1) / COUNT(DISTINCT l.session) AS count_per_user
FROM action_log l
	-- 로그 전체의 유니크 사용자 수를 모든 레코드에 결합하기
	CROSS JOIN
	stats s
GROUP BY l.action, s.total_uu
;
