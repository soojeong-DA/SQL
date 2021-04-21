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

/* 15-3. 성과로 이어지는 페이지 파악 ===============================================================*/

-- 1. 경로별 방문 횟수, 성과수, CVR 집계  (완료 화면에 도달하는 것을 성과(conversion)로 정의)
-- 1-1. conversion page에 도달할 때까지의 접근 로그에 flag 추가 (complete 이후 접근 페이지, complete 미포함 세션은 0으로)
WITH
activity_log_with_conversion_flag AS (
	SELECT session,
		stamp,
		path,
		-- 성과를 발생시키는 conversion page의 이전 접근에 플래그 추가
		SIGN(SUM(CASE WHEN path = '/complete' THEN 1 ELSE 0 END) OVER(PARTITION BY session ORDER BY stamp DESC
																	 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
		AS has_conversion
	FROM activity_log
)
SELECT *
FROM activity_log_with_conversion_flag
ORDER BY session, stamp
;

-- 1-2. 경로별 방문 횟수, 구성 수, CVR 집계
WITH
activity_log_with_conversion_flag AS (
	SELECT session,
		stamp,
		path,
		-- 성과를 발생시키는 conversion page의 이전 접근에 플래그 추가
		SIGN(SUM(CASE WHEN path = '/complete' THEN 1 ELSE 0 END) OVER(PARTITION BY session ORDER BY stamp DESC
																	 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
		AS has_conversion
	FROM activity_log
)
SELECT path,
	-- 방문 횟수
	COUNT(DISTINCT session) AS sessions,
	-- 성과 수
	SUM(has_conversion) AS conversions,
	-- CVR = 성과 수 / 방문 횟수
	1.0 * SUM(has_conversion) / COUNT(DISTINCT session) AS cvr
FROM activity_log_with_conversion_flag
GROUP BY path
ORDER BY cvr DESC
;

/* 15-4. 페이지 가치 산출 =====================================================================
- 이전에 구한 방법에서 추가로 '금액'이라는 개념을 사용해 성과를 고려하는 '페이지 가치' 지표 추출 */

-- 1. 페이지 가치 산출 (5가지 가치 할당 방법 모두 사용)
---------------------------------------------------------------------------
-- 성과 수치를 1,000으로 계산하여, 5가지 가치 할당법을 이용해 각각 계산해보자
-- 입력, 확인, 완료 페이지는 신청(성과)할 때 무조건 거치는 페이지 -> 집계 대상에서 제외 
---------------------------------------------------------------------------

-- 1-1. 페이지 가치 할당 계산 (5가지)
WITH
activity_log_with_conversion_flag AS (
	SELECT session,
		stamp,
		path,
		-- 성과를 발생시키는 conversion page의 이전 접근에 플래그 추가
		SIGN(SUM(CASE WHEN path = '/complete' THEN 1 ELSE 0 END) OVER(PARTITION BY session ORDER BY stamp DESC
																	 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
		AS has_conversion
	FROM activity_log
),
activity_log_with_conversion_assign AS (
	SELECT session,
		stamp,
		path,
		-- 성과에 이르기까지의 접근 로그를 오름차순으로 정렬해 순번 부여
		ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp ASC) AS asc_order,
		-- 성과에 이르기까지의 접근 수 세기 (성과 있는 flag=1 것만 사용할 예정이라 그냥 counting하면 됨)
		COUNT(*) OVER(PARTITION BY session) AS page_count,
		-- 1. 성과에 이르기까지의 접근 로그에 '균등'한 가치 부여
		1000.0 / COUNT(*) OVER(PARTITION BY session) AS fair_assign,
		-- 2. 성과에 이르기까지의 접근 로그의 '첫 페이지'에 가치 부여
		CASE WHEN ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp ASC) = 1 THEN 1000.0 ELSE 0.0 END
		AS first_assign,
		-- 3. 성과에 이르기까지의 접근 로그의 '마지막 페이지'에 가치 부여
		CASE WHEN ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp DESC) = 1 THEN 1000.0 ELSE 0.0 END
		AS last_assign,
		-- 4. 성과에 이르기까지의 접근 로그의 '성과 지점에서 가까운 페이지에' 높은 가치 부여
		1000.0 
		* ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp ASC)
			-- 순번 합계로 나누기(N * (N+1) / 2)  -> 성과(complete)로 갈수록 합계가 점점 커짐
		/ ( COUNT(*) OVER(PARTITION BY session) 
		   * COUNT(*) OVER(PARTITION BY session) + 1 
		   / 2 )
		AS decrease_assign,
		-- 5. 성과에 이르기까지의 접근 로그의 '성과 지점에서 먼 페이지에' 높은 가치 부여
		1000.0 
		* ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp DESC)
			-- 순번 합계로 나누기(N * (N+1) / 2)  -> 성과(complete)로 갈수록 합계가 점점 커짐
		/ ( COUNT(*) OVER(PARTITION BY session) 
		   * COUNT(*) OVER(PARTITION BY session) + 1 
		   / 2 )
		AS increase_assign
	FROM activity_log_with_conversion_flag
	WHERE 
		-- conversion으로 이어지는 session log만 추출
		has_conversion = 1
		-- 입력, 확인, 완료 페이지 제외
		AND path NOT IN ('/input', '/confirm', '/complete')
)
SELECT *
FROM activity_log_with_conversion_assign
ORDER BY session, asc_order
;
	
-- 1-2. 경로(path)별 페이지 가치 합계 집계
WITH
activity_log_with_conversion_flag AS (
	SELECT session,
		stamp,
		path,
		-- 성과를 발생시키는 conversion page의 이전 접근에 플래그 추가
		SIGN(SUM(CASE WHEN path = '/complete' THEN 1 ELSE 0 END) OVER(PARTITION BY session ORDER BY stamp DESC
																	 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
		AS has_conversion
	FROM activity_log
),
activity_log_with_conversion_assign AS (
	SELECT session,
		stamp,
		path,
		-- 성과에 이르기까지의 접근 로그를 오름차순으로 정렬해 순번 부여
		ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp ASC) AS asc_order,
		-- 성과에 이르기까지의 접근 수 세기 (성과 있는 flag=1 것만 사용할 예정이라 그냥 counting하면 됨)
		COUNT(*) OVER(PARTITION BY session) AS page_count,
		-- 1. 성과에 이르기까지의 접근 로그에 '균등'한 가치 부여
		1000.0 / COUNT(*) OVER(PARTITION BY session) AS fair_assign,
		-- 2. 성과에 이르기까지의 접근 로그의 '첫 페이지'에 가치 부여
		CASE WHEN ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp ASC) = 1 THEN 1000.0 ELSE 0.0 END
		AS first_assign,
		-- 3. 성과에 이르기까지의 접근 로그의 '마지막 페이지'에 가치 부여
		CASE WHEN ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp DESC) = 1 THEN 1000.0 ELSE 0.0 END
		AS last_assign,
		-- 4. 성과에 이르기까지의 접근 로그의 '성과 지점에서 가까운 페이지에' 높은 가치 부여
		1000.0 
		* ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp ASC)
			-- 순번 합계로 나누기(N * (N+1) / 2)  -> 성과(complete)로 갈수록 합계가 점점 커짐
		/ ( COUNT(*) OVER(PARTITION BY session) 
		   * COUNT(*) OVER(PARTITION BY session) + 1 
		   / 2 )
		AS decrease_assign,
		-- 5. 성과에 이르기까지의 접근 로그의 '성과 지점에서 먼 페이지에' 높은 가치 부여
		1000.0 
		* ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp DESC)
			-- 순번 합계로 나누기(N * (N+1) / 2)  -> 성과(complete)로 갈수록 합계가 점점 커짐
		/ ( COUNT(*) OVER(PARTITION BY session) 
		   * COUNT(*) OVER(PARTITION BY session) + 1 
		   / 2 )
		AS increase_assign
	FROM activity_log_with_conversion_flag
	WHERE 
		-- conversion으로 이어지는 session log만 추출
		has_conversion = 1
		-- 입력, 확인, 완료 페이지 제외
		AND path NOT IN ('/input', '/confirm', '/complete')
),
page_total_values AS (
	-- 페이지 가치 합계 계산
	SELECT path,
		SUM(fair_assign) AS sum_fair,
		SUM(first_assign) AS sum_first,
		SUM(last_assign) AS sum_last,
		SUM(decrease_assign) AS sum_dec,
		SUM(increase_assign) AS sum_inc
	FROM activity_log_with_conversion_assign
	GROUP BY path
)
SELECT *
FROM page_total_values
;

-- 1-3. 경로들의 평균 페이지 가치 계산 
-- (페이지 뷰가 적으면서, 높은 페이지 가치를 가진 page 찾기 -> 단순히 페이지 가치를 방문 횟수 or 페이지 뷰로 나누면 됨)
WITH
activity_log_with_conversion_flag AS (
	SELECT session,
		stamp,
		path,
		-- 성과를 발생시키는 conversion page의 이전 접근에 플래그 추가
		SIGN(SUM(CASE WHEN path = '/complete' THEN 1 ELSE 0 END) OVER(PARTITION BY session ORDER BY stamp DESC
																	 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
		AS has_conversion
	FROM activity_log
),
activity_log_with_conversion_assign AS (
	SELECT session,
		stamp,
		path,
		-- 성과에 이르기까지의 접근 로그를 오름차순으로 정렬해 순번 부여
		ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp ASC) AS asc_order,
		-- 성과에 이르기까지의 접근 수 세기 (성과 있는 flag=1 것만 사용할 예정이라 그냥 counting하면 됨)
		COUNT(*) OVER(PARTITION BY session) AS page_count,
		-- 1. 성과에 이르기까지의 접근 로그에 '균등'한 가치 부여
		1000.0 / COUNT(*) OVER(PARTITION BY session) AS fair_assign,
		-- 2. 성과에 이르기까지의 접근 로그의 '첫 페이지'에 가치 부여
		CASE WHEN ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp ASC) = 1 THEN 1000.0 ELSE 0.0 END
		AS first_assign,
		-- 3. 성과에 이르기까지의 접근 로그의 '마지막 페이지'에 가치 부여
		CASE WHEN ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp DESC) = 1 THEN 1000.0 ELSE 0.0 END
		AS last_assign,
		-- 4. 성과에 이르기까지의 접근 로그의 '성과 지점에서 가까운 페이지에' 높은 가치 부여
		1000.0 
		* ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp ASC)
			-- 순번 합계로 나누기(N * (N+1) / 2)  -> 성과(complete)로 갈수록 합계가 점점 커짐
		/ ( COUNT(*) OVER(PARTITION BY session) 
		   * COUNT(*) OVER(PARTITION BY session) + 1 
		   / 2 )
		AS decrease_assign,
		-- 5. 성과에 이르기까지의 접근 로그의 '성과 지점에서 먼 페이지에' 높은 가치 부여
		1000.0 
		* ROW_NUMBER() OVER(PARTITION BY session ORDER BY stamp DESC)
			-- 순번 합계로 나누기(N * (N+1) / 2)  -> 성과(complete)로 갈수록 합계가 점점 커짐
		/ ( COUNT(*) OVER(PARTITION BY session) 
		   * COUNT(*) OVER(PARTITION BY session) + 1 
		   / 2 )
		AS increase_assign
	FROM activity_log_with_conversion_flag
	WHERE 
		-- conversion으로 이어지는 session log만 추출
		has_conversion = 1
		-- 입력, 확인, 완료 페이지 제외
		AND path NOT IN ('/input', '/confirm', '/complete')
),
page_total_values AS (
	-- 페이지 가치 합계 계산
	SELECT path,
		SUM(fair_assign) AS sum_fair,
		SUM(first_assign) AS sum_first,
		SUM(last_assign) AS sum_last,
		SUM(decrease_assign) AS sum_dec,
		SUM(increase_assign) AS sum_inc
	FROM activity_log_with_conversion_assign
	GROUP BY path
),
page_total_cnt AS (
	SELECT path,
		-- 페이지 뷰 계산
		COUNT(*) AS access_cnt
		-- 방문 횟수 계산
		-- COUNT(DISTINCT session) AS access_cnt
	FROM activity_log
	GROUP BY path
)
SELECT c.path,
	c.access_cnt,
	-- 5가지 방법별 평균 페이지 가치 산출
	v.sum_fair / c.access_cnt AS avg_fair,
	v.sum_first / c.access_cnt AS avg_first,
	v.sum_last / c.access_cnt AS avg_last,
	v.sum_dec / c.access_cnt AS avg_dec,
	v.sum_inc / c.access_cnt AS avg_inc
FROM page_total_cnt c INNER JOIN page_total_values v ON c.path = v.path
ORDER BY c.access_cnt
;

/* 검색 조건들의 사용자 행동 가시화 
- 검색 조건을 더 자세하게 지정해서 사용하는 user는 동기가 명확하다는 의미 -> 성과로 이어지는 비율이 높음 
- 하지만, 조건을 상세하게 지정하더라도 검색 결과 항목이 적거나 없으면 user가 이탈할 확률이 높아짐
-> 검색 조건과 히트되는 항목 수의 '균형'을 고려해서 카테고리 검토/개선 해야함!! =============================================*/

-- 1. 검색 타입별 CTR, CVT, 방문 횟수 집계
-- -- (정의 - click: 상세 페이지 이동, conversion: 제출 완료)
-- 1-1. 클릭 플래그와 컨버전 플래그 계산
WITH
activity_log_with_session_click_conversion_flag  AS (
	SELECT session,
		stamp,
		path,
		search_type,
		-- 상세 페이지 ~ 이전 접근에 플래그 추가
		SIGN(SUM(CASE WHEN path='/detail' THEN 1 ELSE 0 END) OVER(PARTITION BY session ORDER BY stamp DESC
																 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
		AS has_session_click,
		-- 성과 발생 페이지 ~ 이전 접근에 플래그 추가
		SIGN(SUM(CASE WHEN path='/complete' THEN 1 ELSE 0 END) OVER(PARTITION BY session ORDER BY stamp DESC
																   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
		AS has_session_conversion
	FROM activity_log
)
SELECT session,
	stamp,
	path,
	search_type,
	has_session_click AS click,
	has_session_conversion AS cnv
FROM activity_log_with_session_click_conversion_flag
ORDER BY session, stamp
;

-- 1-2. 검색 타입별 CTR, CVR 집계
WITH
activity_log_with_session_click_conversion_flag AS (
	SELECT session,
		stamp,
		path,
		search_type,
		-- 상세 페이지 ~ 이전 접근에 플래그 추가
		SIGN(SUM(CASE WHEN path='/detail' THEN 1 ELSE 0 END) OVER(PARTITION BY session ORDER BY stamp DESC
																 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
		AS has_session_click,
		-- 성과 발생 페이지 ~ 이전 접근에 플래그 추가
		SIGN(SUM(CASE WHEN path='/complete' THEN 1 ELSE 0 END) OVER(PARTITION BY session ORDER BY stamp DESC
																   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
		AS has_session_conversion
	FROM activity_log
)
SELECT search_type,
	COUNT(*) AS count,
	-- Click
	SUM(has_session_click) AS detail,
	AVG(has_session_click) AS ctr,
	-- Conversion
	SUM(CASE WHEN has_session_click = 1 THEN has_session_conversion END) AS conversion,
	AVG(CASE WHEN has_session_click = 1 THEN has_session_conversion END) AS cvr
FROM activity_log_with_session_click_conversion_flag
WHERE path = '/search_list'  -- 검색 조건으로 집약하니, 검색 로그만 추출
GROUP BY search_type
ORDER BY count DESC
;

-- 1-3. [번외] click flag를 성과 직전의 검색 결과로 한정해 다시 집계
WITH
activity_log_with_session_click_conversion_flag  AS (
	SELECT session,
		stamp,
		path,
		search_type,
		-- 상세 페이지 '직전 접근'에 플래그 추가
		CASE WHEN LAG(path) OVER(PARTITION BY session ORDER BY stamp DESC) = '/detail' THEN 1 ELSE 0 END 
		AS has_session_click,
		-- 성과 발생 페이지 ~ 이전 접근에 플래그 추가
		SIGN(SUM(CASE WHEN path='/complete' THEN 1 ELSE 0 END) OVER(PARTITION BY session ORDER BY stamp DESC
																   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
		AS has_session_conversion
	FROM activity_log
)
SELECT session,
	stamp,
	path,
	search_type,
	has_session_click AS click,
	has_session_conversion AS cnv
FROM activity_log_with_session_click_conversion_flag
ORDER BY session, stamp
;

/* 15-6. 폴아웃 리포트를 사용해 사용자 회유 가시화 ================================================================*/

-- 1. 폴아웃 리포트
-- 1-1. 폴아웃 단계 순서를 접근 로그와 결합
WITH
mst_fallout_step AS (
	-- 폴아웃 단계와 경로의 마스터 테이블
			  SELECT 1 AS step, '/' AS path
	UNION ALL SELECT 2 AS step, '/search_list' AS path
	UNION ALL SELECT 3 AS step, '/detail' AS path
	UNION ALL SELECT 4 AS step, '/input' AS path
	UNION ALL SELECT 5 AS step, '/complete' AS path
),
activity_log_with_fallout_step AS (
	SELECT a.session,
		m.step,
		m.path,
		-- 첫 접근과 마지막 접근 시간 구하기
		MAX(a.stamp) AS max_stamp,
		MIN(a.stamp) AS min_stamp
	FROM mst_fallout_step m INNER JOIN activity_log a ON m.path = a.path
	GROUP BY a.session, m.step, m.path
),
activity_log_with_mod_fallout_step AS (
	SELECT session,
		step,
		path,
		max_stamp,
		-- 직전 단계에서의 첫 접근 시간 구하기
		LAG(min_stamp) OVER(PARTITION BY session ORDER BY step) AS lag_min_stamp,
		-- 세션에서의 단계 순서 최소값 구하기
		MIN(step) OVER(PARTITION BY session) AS min_step,
		-- 해당 단계에 도달할 때까지 걸린 단계 수 누계
		COUNT(*) OVER(PARTITION BY session ORDER BY step ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS cum_count
	FROM activity_log_with_fallout_step
)
SELECT *
FROM activity_log_with_mod_fallout_step
ORDER BY session, step
;

-- 1-2. 폴아웃 리포트에 필요한 로그를 압축
WITH
mst_fallout_step AS (
	-- 폴아웃 단계와 경로의 마스터 테이블
			  SELECT 1 AS step, '/' AS path
	UNION ALL SELECT 2 AS step, '/search_list' AS path
	UNION ALL SELECT 3 AS step, '/detail' AS path
	UNION ALL SELECT 4 AS step, '/input' AS path
	UNION ALL SELECT 5 AS step, '/complete' AS path
),
activity_log_with_fallout_step AS (
	SELECT a.session,
		m.step,
		m.path,
		-- 첫 접근과 마지막 접근 시간 구하기
		MAX(a.stamp) AS max_stamp,
		MIN(a.stamp) AS min_stamp
	FROM mst_fallout_step m INNER JOIN activity_log a ON m.path = a.path
	GROUP BY a.session, m.step, m.path
),
activity_log_with_mod_fallout_step AS (
	SELECT session,
		step,
		path,
		max_stamp,
		-- 직전 단계에서의 첫 접근 시간 구하기
		LAG(min_stamp) OVER(PARTITION BY session ORDER BY step) AS lag_min_stamp,
		-- 세션에서의 단계 순서 최소값 구하기
		MIN(step) OVER(PARTITION BY session) AS min_step,
		-- 해당 단계에 도달할 때까지 걸린 단계 수 누계
		COUNT(*) OVER(PARTITION BY session ORDER BY step ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS cum_count
	FROM activity_log_with_fallout_step
),
fallout_log AS (
	-- 폴아웃 리포트에 사용할 로그만 추출
	SELECT session,
		step,
		path
	FROM activity_log_with_mod_fallout_step
	WHERE
	-- 세션에서 단계 순서가 1인지 확인
	min_step = 1
	-- 현재 단계 순서가 해당 단계에 도달할 때까지의 누계 단계 수와 같은지 확인
	AND step = cum_count
	-- 직전 단계의 첫 접근 시간이, NULL or 현재 시간의 최종 접근 시간보다 이전인지 확인
	AND (lag_min_stamp IS NULL OR max_stamp >= lag_min_stamp)
)
SELECT *
FROM fallout_log
ORDER BY session, step
;

-- 1-3. 폴아웃 리포트 출력 (step 순서와 url로 집약하고, 접근수와 페이지 이동률 집계)
WITH
mst_fallout_step AS (
	-- 폴아웃 단계와 경로의 마스터 테이블
			  SELECT 1 AS step, '/' AS path
	UNION ALL SELECT 2 AS step, '/search_list' AS path
	UNION ALL SELECT 3 AS step, '/detail' AS path
	UNION ALL SELECT 4 AS step, '/input' AS path
	UNION ALL SELECT 5 AS step, '/complete' AS path
),
activity_log_with_fallout_step AS (
	SELECT a.session,
		m.step,
		m.path,
		-- 첫 접근과 마지막 접근 시간 구하기
		MAX(a.stamp) AS max_stamp,
		MIN(a.stamp) AS min_stamp
	FROM mst_fallout_step m INNER JOIN activity_log a ON m.path = a.path
	GROUP BY a.session, m.step, m.path
),
activity_log_with_mod_fallout_step AS (
	SELECT session,
		step,
		path,
		max_stamp,
		-- 직전 단계에서의 첫 접근 시간 구하기
		LAG(min_stamp) OVER(PARTITION BY session ORDER BY step) AS lag_min_stamp,
		-- 세션에서의 단계 순서 최소값 구하기
		MIN(step) OVER(PARTITION BY session) AS min_step,
		-- 해당 단계에 도달할 때까지 걸린 단계 수 누계
		COUNT(*) OVER(PARTITION BY session ORDER BY step ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS cum_count
	FROM activity_log_with_fallout_step
),
fallout_log AS (
	-- 폴아웃 리포트에 사용할 로그만 추출
	SELECT session,
		step,
		path
	FROM activity_log_with_mod_fallout_step
	WHERE
	-- 세션에서 단계 순서가 1인지 확인
	min_step = 1
	-- 현재 단계 순서가 해당 단계에 도달할 때까지의 누계 단계 수와 같은지 확인
	AND step = cum_count
	-- 직전 단계의 첫 접근 시간이, NULL or 현재 시간의 최종 접근 시간보다 이전인지 확인
	AND (lag_min_stamp IS NULL OR max_stamp >= lag_min_stamp)
)
SELECT step,
	path,
	COUNT(*) AS count,
	-- 단계 순서 = 1 인 url부터의 이동률
	100.0 * COUNT(*) / FIRST_VALUE(COUNT(*)) OVER(ORDER BY step ASC 
												 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS first_trans_rate,
	-- 직전 단계까지의 이동률
	100.0 * COUNT(*) / LAG(COUNT(*)) OVER(ORDER BY step ASC) AS step_trans_rate
FROM fallout_log
GROUP BY step, path
ORDER BY step
;

/* 15-7. 사이트 내부에서 사용자 흐름 파악 ===================================================================*/

-- 1. 사용자 흐름 집계 (시작 지점 이후에 어떤 페이지로 가는지 정리. 시작 페이지 = /detail)
-- 1-1. /detail 페이지 이후의 사용자 흐름을 집계
WITH
activity_log_with_lead_path AS (
	SELECT session,
		stamp,
		path AS path0,
		-- 다음 경로(페이지)1 추출
		LEAD(path, 1) OVER(PARTITION BY session ORDER BY stamp ASC) AS path1,
		-- 다음 경로2 추출
		LEAD(path, 2) OVER(PARTITION BY session ORDER BY stamp ASC) AS path2
	FROM activity_log
),
raw_user_flow AS (
	SELECT path0,
		-- 시작 지점 경로의 접근 수
		SUM(COUNT(*)) OVER() AS count0,
		-- 다음 경로1 (존재하지 않는 경우 문자열 NULL)
		COALESCE(path1, 'NULL') AS path1,
		-- 다음 경로1의 접근 수
		SUM(COUNT(*)) OVER(PARTITION BY path0, path1) AS count1,
		-- 다음 경로2 (존재하지 않는 경우 문자열 NULL)
		COALESCE(path2, 'NULL') AS path2,
		-- 다음 경로2의 접근 수
		COUNT(*) AS count2
	FROM activity_log_with_lead_path
	WHERE path0 = '/detail'  -- 상세 페이지가 시작점인 것만
	GROUP BY path0, path1, path2
)
SELECT path0,
	count0,
	path1,
	count1,
	100.0 * count1 / count0 AS rate1,
	path2,
	count2,
	100.0 * count2 / count1 AS rate2
FROM raw_user_flow
ORDER BY count1 DESC, count2 DESC
;

-- 1-2. /detail 페이지 이후의 사용자 흐름을 집계 (바로 전의 레코드와 같은 값을 가졌을 때(중복 값) 출력하지 않게 가공)
WITH
activity_log_with_lead_path AS (
	SELECT session,
		stamp,
		path AS path0,
		-- 다음 경로(페이지)1 추출
		LEAD(path, 1) OVER(PARTITION BY session ORDER BY stamp ASC) AS path1,
		-- 다음 경로2 추출
		LEAD(path, 2) OVER(PARTITION BY session ORDER BY stamp ASC) AS path2
	FROM activity_log
),
raw_user_flow AS (
	SELECT path0,
		-- 시작 지점 경로의 접근 수
		SUM(COUNT(*)) OVER() AS count0,
		-- 다음 경로1 (존재하지 않는 경우 문자열 NULL)
		COALESCE(path1, 'NULL') AS path1,
		-- 다음 경로1의 접근 수
		SUM(COUNT(*)) OVER(PARTITION BY path0, path1) AS count1,
		-- 다음 경로2 (존재하지 않는 경우 문자열 NULL)
		COALESCE(path2, 'NULL') AS path2,
		-- 다음 경로2의 접근 수
		COUNT(*) AS count2
	FROM activity_log_with_lead_path
	WHERE path0 = '/detail'  -- 상세 페이지가 시작점인 것만
	GROUP BY path0, path1, path2
)