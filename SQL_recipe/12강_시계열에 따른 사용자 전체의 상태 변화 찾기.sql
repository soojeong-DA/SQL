/* 시계열에 따른 사용자 전체의 상태 변화 찾기 
- 사용자의 서비스 사용을 시계열로 수치화하고, 변화를 시각화 해보자! */

-- 사용자 마스터 TABLE
SELECT * FROM mst_users;
-- 액션 로그 TABLE
SELECT * FROM action_log;

/* 등록 수의 추이와 경향 살펴보기 =============================================*/
-- 1. 날짜별 등록 수 추이
SELECT register_date,
	COUNT(DISTINCT user_id) AS register_count
FROM mst_users
GROUP BY 1
ORDER BY 1;

-- 2. 월별 등록 수 추이와 전월비 집계
WITH mst_user_with_year_month AS (
SELECT substring(register_date, 1,7) AS year_month,
	COUNT(DISTINCT user_id) AS register_count
FROM mst_users
GROUP BY 1
)
SELECT year_month,
	register_count,
	1.0 * register_count / LAG(register_count) OVER(ORDER BY year_month) AS month_over_month_ratio
FROM mst_user_with_year_month
ORDER BY 1;

-- 3. 등록 디바이스별 추이
WITH mst_user_with_year_month AS (
SELECT *,
	substring(register_date, 1,7) AS year_month
FROM mst_users
)
SELECT year_month,
	COUNT(DISTINCT user_id) AS register_count,
	COUNT(DISTINCT CASE WHEN register_device = 'pc' THEN user_id END) AS register_pc,
	COUNT(DISTINCT CASE WHEN register_device = 'sp' THEN user_id END) AS register_sp,
	COUNT(DISTINCT CASE WHEN register_device = 'app' THEN user_id END) AS register_app
FROM mst_user_with_year_month
GROUP BY 1
ORDER BY 1;

/* 지속률과 정착률 산출하기 ======================================================================
- 지속률: 등록일 기준으로 '이후 지정일(판정날짜, day) 동안' 사용자가 서비스를 얼마나 이용했는지 나타내는 지표
- 정착률: 등록일 기준으로 '이후 지정한 7일 동안' 사용자가 서비스를 사용했는지 나타내는 지표
- 두 지표 모두 '사용자 수 / 등록 수'로 계산하지만, 집계 기간이 다름 */

-- 1. 지속률 ======================================
-- 1-1. '로그 최근 일자'와 '사용자별 등록일'의 다음날 계산 
WITH
action_log_with_mst_users AS (
	SELECT u.user_id,
		u.register_date,
		-- 액션 날짜, 로그 전체의 최신 날짜를 날짜 자료형으로 변환
		CAST(a.stamp AS date) AS action_date,
		MAX(CAST(a.stamp AS date)) OVER() AS latest_date,  -- 로그 전체의 최신 날짜
		-- 등록일 다음날의 날짜 계산
		CAST(u.register_date::date + '1day'::interval AS date) AS next_day_1
	FROM mst_users u LEFT OUTER JOIN action_log a ON u.user_id = a.user_id
)
SELECT *
FROM action_log_with_mst_users
ORDER BY register_date;

-- 1-2. 사용자의 액션 플래그 계산 (지정한 날의 다음날 액션을 했는지 안했는지)
WITH
action_log_with_mst_users AS (
	SELECT u.user_id,
		u.register_date,
		-- 액션 날짜, 로그 전체의 최신 날짜를 날짜 자료형으로 변환
		CAST(a.stamp AS date) AS action_date,
		MAX(CAST(a.stamp AS date)) OVER() AS latest_date,  -- 로그 전체의 최신 날짜
		-- 등록일 다음날의 날짜 계산
		CAST(u.register_date::date + '1day'::interval AS date) AS next_day_1
	FROM mst_users u LEFT OUTER JOIN action_log a ON u.user_id = a.user_id
),
user_action_flag AS (
	SELECT user_id,
		register_date,
		-- 4) 등록일 다음날에 액션을 했는지 안했는지 flag
		SIGN(
			-- 3) 사용자별 등록일 다음날에 한 액션의 합계
			SUM(
				-- 1) 등록일 다음날이 로그의 최신 날짜 이전인지 확인
				CASE WHEN next_day_1 <= latest_date THEN
					-- 2) 등록일 다음날의 날짜에 액션을 했다면 1, 안했다면 0
					CASE WHEN next_day_1 = action_date THEN 1 ELSE 0 END
				END
			)
		) AS next_1_day_action
	FROM action_log_with_mst_users
	GROUP BY user_id, register_date
)
SELECT * 
FROM user_action_flag
ORDER BY register_date, user_id;

-- 1-3. 다음날 지속률 계산
WITH
action_log_with_mst_users AS (
	SELECT u.user_id,
		u.register_date,
		-- 액션 날짜, 로그 전체의 최신 날짜를 날짜 자료형으로 변환
		CAST(a.stamp AS date) AS action_date,
		MAX(CAST(a.stamp AS date)) OVER() AS latest_date,  -- 로그 전체의 최신 날짜
		-- 등록일 다음날의 날짜 계산
		CAST(u.register_date::date + '1day'::interval AS date) AS next_day_1
	FROM mst_users u LEFT OUTER JOIN action_log a ON u.user_id = a.user_id
),
user_action_flag AS (
	SELECT user_id,
		register_date,
		-- 4) 등록일 다음날에 액션을 했는지 안했는지 flag
		SIGN(
			-- 3) 사용자별 등록일 다음날에 한 액션의 합계
			SUM(
				-- 1) 등록일 다음날이 로그의 최신 날짜 이전인지 확인
				CASE WHEN next_day_1 <= latest_date THEN
					-- 2) 등록일 다음날의 날짜에 액션을 했다면 1, 안했다면 0
					CASE WHEN next_day_1 = action_date THEN 1 ELSE 0 END
				END
			)
		) AS next_1_day_action
	FROM action_log_with_mst_users
	GROUP BY user_id, register_date
)
SELECT register_date,
	AVG(100.0 * next_1_day_action) AS repeat_rate_1_day
FROM user_action_flag
GROUP BY register_date
ORDER BY register_date;

-- 1-4. 지속률 지표를 관리하는 마스터 테이블 작성(각각의 지표를 세로 기반으로 표현하기 위해)
-- day별 지속률을 컬럼 단위로 표현하면 복잡한 쿼리가되어, 관리가 힘들어짐
WITH
repeat_interval(index_name, interval_date) AS (
	-- VALUES 구문으로 일시 테이블 생성
	VALUES
	('01 day repeat', 1),
	('02 day repeat', 2),
	('03 day repeat', 3),
	('04 day repeat', 4),
	('05 day repeat', 5),
	('06 day repeat', 6),
	('07 day repeat', 7)
)
SELECT *
FROM repeat_interval
ORDER BY index_name
;

-- 1-5. 지속률을 세로 기반으로 집계
WITH
repeat_interval(index_name, interval_date) AS (
	-- VALUES 구문으로 일시 테이블 생성
	VALUES
	('01 day repeat', 1),
	('02 day repeat', 2),
	('03 day repeat', 3),
	('04 day repeat', 4),
	('05 day repeat', 5),
	('06 day repeat', 6),
	('07 day repeat', 7)
),
action_log_with_index_date AS (
	SELECT u.user_id,
		u.register_date,
		-- 액션 날짜와 로그 전체의 최신 날짜를 날짜 형식으로 변환
		CAST(a.stamp AS date) AS action_date,
		MAX(CAST(a.stamp AS date)) OVER() AS latest_date,
		-- 등록일로부터 n일 후의 날짜 계산 (1 * interval_date => + 1,2,3,....day)	
		r.index_name,	
		CAST(CAST(u.register_date AS date) + interval '1 day' * r.interval_date AS date) AS index_date	
	FROM mst_users u 
					LEFT OUTER JOIN action_log a ON u.user_id = a.user_id
					CROSS JOIN repeat_interval r
),
user_action_flag AS (
	SELECT user_id,
		register_date,
		index_name,
		-- 4) 등록일로부터 n일 후에 액션을 했는지 flag로 나타내기
		SIGN(
			-- 3) 사용자별로 등록일로부터 n일 후에 한 액션의 합계
			SUM(
				-- 1) 등록일로부터 n일 후가, 로그인의 최신 날짜 이전인지 확인!
				CASE WHEN index_date <= latest_date THEN
					-- 2) 등록일로부터 n일 후의 날짜에 액션을 했다면 1, 아니면 0
					CASE WHEN index_date = action_date THEN 1 ELSE 0 END
				END
			)
		) AS index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_date
)
SELECT register_date,
	index_name,
	AVG(100.0 * index_date_action) AS repeat_rate
FROM user_action_flag
GROUP BY 1,2
ORDER BY 1,2
;

-- 2. 정착률 =====================================
-- 2-1. 정착률 지표룰 관리할 마스터 테이블 작성
WITH
repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
	-- 지속률과는 달리 begin/end date로 확장
	VALUES
	('07 day retention', 1, 7),
	('14 day retention', 8, 14),
	('21 day retention', 15, 21),
	('28 day retention', 22, 28)
)
SELECT *
FROM repeat_interval;

-- 2-2. 정착률 계산
WITH
repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
	-- 지속률과는 달리 begin/end date로 확장
	VALUES
	('07 day retention', 1, 7),
	('14 day retention', 8, 14),
	('21 day retention', 15, 21),
	('28 day retention', 22, 28)
),
action_log_with_index_date AS (
	SELECT u.user_id,
		u.register_date,
		-- 액션 날짜와 로그 전체의 최신 날짜를 날짜 자료형으로 변환
		CAST(a.stamp AS date) AS action_date,
		MAX(CAST(a.stamp AS date)) OVER() AS latest_date,
		r.index_name,
		-- 지표의 대상 기간 시작일/종료일 계산
		CAST(u.register_date::date + '1 day'::interval * r.interval_begin_date AS date) AS index_begin_date,
		CAST(u.register_date::date + '1 day'::interval * r.interval_end_date AS date) AS index_end_date
	FROM mst_users u 
					LEFT OUTER JOIN action_log a ON u.user_id = a.user_id
					CROSS JOIN repeat_interval r
),
user_action_flag AS (
	SELECT user_id,
		register_date,
		index_name,
		-- 4) 지표 대상 기간에 액션 했는지 flag로 나타내기
		SIGN(
			-- 3) 사용자별 대상 기간에 한 액션의 합계
			SUM(
				-- 1) 대상 기간의 종료일이 로그 최신 날짜 이전인지 확인
				CASE WHEN index_end_date <= latest_date THEN
					-- 2) 지표 대상 기간에 액션 했다면 1, 안했다면 0
					CASE WHEN action_date BETWEEN index_begin_date AND index_end_date THEN 1 ELSE 0 END
				END
			)
		) AS index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
)
SELECT register_date,
	index_name,
	AVG(100.0 * index_date_action) AS index_rate
FROM user_action_flag
GROUP BY 1,2
ORDER BY 1,2
;


/* 지속과 정착에 영향을 주는 액션 집계 ==================================================
- 해당 n일/기간 동안 사용자들이 무엇을 했는지 액션을 조사하면 알 수 있음 */

-- 1. '등록일 액션 사용 여부'에 따라 '1일 지속률'에 어떤 차이가 있는지 알아보자!
-- -- (여부에 따른 차이가 클 수록 지속률에 더 영향을 주는 액션임)

-- 1-1. 모든 사용자와 액션의 조합을 도출 (CROSS JOIN 이용)
WITH 
repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
	VALUES ('01 day repeat', 1, 1)
),
action_log_with_index_date AS (
	SELECT u.user_id,
		u.register_date,
		-- 액션 날짜와 로그 전체의 최신 날짜를 날짜 자료형으로 변환
		CAST(a.stamp AS date) AS action_date,
		MAX(CAST(a.stamp AS date)) OVER() AS latest_date,
		r.index_name,
		-- 지표의 대상 기간 시작일/종료일 계산
		CAST(u.register_date::date + '1 day'::interval * r.interval_begin_date AS date) AS index_begin_date,
		CAST(u.register_date::date + '1 day'::interval * r.interval_end_date AS date) AS index_end_date
	FROM mst_users u 
					LEFT OUTER JOIN action_log a ON u.user_id = a.user_id
					CROSS JOIN repeat_interval r
),
user_action_flag AS (
	SELECT user_id,
		register_date,
		index_name,
		-- 4) 지표 대상 기간에 액션 했는지 flag로 나타내기
		SIGN(
			-- 3) 사용자별 대상 기간에 한 액션의 합계
			SUM(
				-- 1) 대상 기간의 종료일이 로그 최신 날짜 이전인지 확인
				CASE WHEN index_end_date <= latest_date THEN
					-- 2) 지표 대상 기간에 액션 했다면 1, 안했다면 0
					CASE WHEN action_date BETWEEN index_begin_date AND index_end_date THEN 1 ELSE 0 END
				END
			)
		) AS index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
),
mst_actions AS (
			SELECT 'view' AS action
	UNION ALL SELECT 'comment' AS action
	UNION ALL SELECT 'follow' AS action
),
mst_user_actions AS (
	SELECT u.user_id,
		u.register_date,
		a.action
	FROM mst_users u CROSS JOIN mst_actions a
)
SELECT *
FROM mst_user_actions
ORDER BY user_id, action
;






