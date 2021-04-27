/* 16. 입력 양식 최적화 
- 엔트리폼(Entry Form): 자료 청구 양식, 구매 양식 등
- 입력 양식 최적화: 해당 과정 중 사용자의 이탈을 막고, 성과를 높이고자 입력 양식을 최적화하는 것 */

/* 16-1. 오류율 집계 ================================================================*/

-- 확인 화면에서의 오류율을 집계
SELECT COUNT(*) AS confirm_count,
	SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) AS error_count,
	AVG(CASE WHEN status = 'error' THEN 1.0 ELSE 0.0 END) AS error_rate,
	SUM(CASE WHEN status = 'error' THEN 1.0 ELSE 0.0 END) / COUNT(DISTINCT session)
	AS error_per_user
FROM form_log
WHERE path = '/regist/confirm' -- 확인 화면 페이지만
;

/* 16-2. '입력~확인~완료'까지의 이동률 집계 ============================================================*/

-- 입력 양식의 폴아웃 리포트
WITH mst_fallout_step AS (
	-- /regist 입력 양식의 폴아웃 단계와 경로 master
			SELECT 1 AS step, '/regist/input' AS path
	UNION ALL SELECT 2 AS step, 'regist/confirm' AS path
	UNION ALL SELECT 3 AS step, 'regist/complete' AS path
),
form_log_with_fallout_step AS (
	SELECT l.session,
		m.step,
		m.path,
		-- 특정 단계 경로의 처음/마지막 접근 시간 구하기
		MAX(l.stamp) AS max_stamp,
		MIN(l.stamp) AS min_stamp
	FROM mst_fallout_step m JOIN form_log l ON m.path = l.path
	WHERE status = '' 
	GROUP BY l.session, m.step, m.path
),
form_log_with_mod_fallout_step AS (
	SELECT session,
		step,
		path,
		max_stamp,
		-- 직전 단계 경로의 첫 접근 시간
		LAG(min_stamp) OVER(PARTITION BY session ORDER BY step) AS lag_min_stamp,
		-- 세션 내부에서 단계 순서 최솟값
		MIN(step) OVER(PARTITION BY session) AS min_step,
		-- 해당 단계에 도달할 때까지의 누계 단계 수 
		COUNT(*) OVER(PARTITION BY session ORDER BY step
					 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS cum_count
	FROM form_log_with_fallout_step
),
fallout_log AS (
	-- 폴아웃 리포트에 필요한 정보 추출
	SELECT session,
		step,
		path
	FROM form_log_with_mod_fallout_step
	WHERE min_step = 1 -- 세션 내부에서 단계 순서=1인 URL에 접근하는 경우
	AND step = cum_count -- 현재 단계 순서 =  해당 단계에 도착할 때까지의 누계 단계 수와 같은 경우
	AND (lag_min_stamp IS NULL OR max_stamp >= lag_min_stamp)  -- 직전 단계의 첫 접근 시간이 null or 현재 단계의 최종 접근 시간보다 앞인 경우
)
SELECT step,
	path,
	COUNT(*) AS count,
	-- 단계 순서 = 1인 url로부터의 이동률
	100.0 * COUNT(*) / FIRST_VALUE(COUNT(*)) OVER(ORDER BY step ASC
												 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS first_trans_rate,
	-- 직전 단계로부터의 이동률
	100.0 * COUNT(*) / LAG(COUNT(*)) OVER(ORDER BY step ASC)
	AS step_trans_rate
FROM fallout_log
GROUP BY step, path
ORDER BY step
;

/* 16-3. 입력 양식 직귀율 집계 ==============================================================================
- 입력 양식 직귀율: 입력 화면으로 이동한 후 입력 시작, 확인 확면, 오류 화면으로 이동한 로그가 없는 상태의 레코드 수의 비율 
- 직귀율이 높다면 아래의 이유가 있을 수 있음
-->사용자가 입력을 중간에 포기할 만큼 입력 항목이 많음
--> 레이아웃이 난잡함 등 ====================================================================================- */

-- 입력 양식 직귀율을 집계
WITH form_with_progress_flag AS (
	SELECT substring(stamp, 1, 10) AS dt,
		session,
		-- 입력 화면으로의 방문 flag 계산
		SIGN(SUM(CASE WHEN path IN ('/regist/input') THEN 1 ELSE 0 END)) AS has_input,
		-- 입력 확인 화면 or 완료 화면으로의 방문 flag 계산
		SIGN(SUM(CASE WHEN path IN ('/regist/confirm', '/regist/complete') THEN 1 ELSE 0 END)) AS has_progress
	FROM form_log
	GROUP BY dt, session
)
SELECT dt,
	COUNT(*) AS input_count,
	SUM(CASE WHEN has_progress = 0 THEN 1 ELSE 0 END) AS bounce_count,
	100.0 * AVG(CASE WHEN has_progress = 0 THEN 1 ELSE 0 END) AS bounce_rate
FROM form_with_progress_flag
WHERE has_input = 1 -- 입력 화면에 방문했던 session만 추출
GROUP BY dt
;

/* 16-4. 오류가 발생하는 항목과 내용 집계 =======================================================================*/

-- 각 입력 양식의 오류 발생 장소와 원인을 집계
SELECT form,
	field,
	error_type,
	COUNT(*) AS count,
	100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY form) AS share
FROM form_error_log
GROUP BY form, field, error_type
ORDER BY form, count DESC
;

