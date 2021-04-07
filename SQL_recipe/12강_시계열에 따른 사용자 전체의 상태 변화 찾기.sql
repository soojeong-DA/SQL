/* 시계열에 따른 사용자 전체의 상태 변화 찾기 
- 사용자의 서비스 사용을 시계열로 수치화하고, 변화를 시각화 해보자! */

-- 사용자 마스터 TABLE
SELECT * FROM mst_users;
-- 액션 로그 TABLE
SELECT * FROM action_log;

/* 12-1. 등록 수의 추이와 경향 살펴보기 =============================================*/
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

/* 12-2. 지속률과 정착률 산출하기 ======================================================================
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


/* 12-3. 지속과 정착에 영향을 주는 액션 집계(액션 여부) ==================================================
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

-- 1-2. 사용자의 액션 로그를 0,1 플래그로 표현
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
),
register_action_flag AS (
	SELECT DISTINCT m.user_id,
		m.register_date,
		m.action,
		-- 등록일에 해당 액션을 사용함 1, 사용안함 0
		CASE
			WHEN a.action IS NOT NULL THEN 1 ELSE 0
		END AS do_action,
		index_name,
		index_date_action
	FROM mst_user_actions m LEFT JOIN action_log a ON m.user_id = a.user_id AND m.action = a.action
							LEFT JOIN user_action_flag f ON m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
)
SELECT *
FROM register_action_flag
ORDER BY user_id, index_name, action
;

-- 1-3. 액션에 따른 지속률 집계
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
),
register_action_flag AS (
	SELECT DISTINCT m.user_id,
		m.register_date,
		m.action,
		-- 등록일에 해당 액션을 사용함 1, 사용안함 0
		CASE
			WHEN a.action IS NOT NULL THEN 1 ELSE 0
		END AS do_action,
		index_name,
		index_date_action
	FROM mst_user_actions m LEFT JOIN action_log a ON m.user_id = a.user_id AND m.action = a.action
							LEFT JOIN user_action_flag f ON m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
)
SELECT action,
	COUNT(1) users,
	AVG(100.0 * do_action) AS usage_rate,
	index_name,
	AVG(CASE do_action WHEN 1 THEN 100.0 * index_date_action END) AS do_action_idx_rate,
	AVG(CASE do_action WHEN 0 THEN 100.0 * index_date_action END) AS no_action_idx_rate
FROM register_action_flag
GROUP BY action, index_name
ORDER BY 1,2
;

/* 12-4. 액션 수에 따른 정착률 집계 ============================================================*/
-- 1. 등록일과 이후 7일동안(7일 정착률 기간) 실행한 '액션 수'에 따라, 14일 정착률이 어떻게 변화하는지 알아보자!
-- 1-1. 액션 단계(계급) 마스터 일시 테이블 정의, 사용자 액션 플래그 모든 조합 산출(CROSS JOIN)
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
	VALUES('14 day retention', 8, 14)
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
mst_action_bucket(action, min_count, max_count) AS (
	-- 액션 단계 마스터
	VALUES
	('comment', 0, 0),
	('comment', 1, 5),
	('comment', 6, 10),
	('comment', 11, 9999), -- 최댓값 임시적으로 간단하게 9999지정
	('follow', 0, 0),
	('follow', 1, 5),
	('follow', 6, 10),
	('follow', 11, 9999)
),
mst_user_action_bucket AS (
	-- 사용자 마스터와 액션 단계 마스터 조합하기
	SELECT u.user_id,
		u.register_date,
		a.action,
		a.min_count,
		a.max_count
	FROM mst_users u CROSS JOIN mst_action_bucket a
)
SELECT *
FROM mst_user_action_bucket
ORDER BY user_id, action, min_count
;

-- 1-2. 등록 후 7일 동안의 액션 수 집계 및 JOIN(BETWEEN)
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
	VALUES('14 day retention', 8, 14)
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
mst_action_bucket(action, min_count, max_count) AS (
	-- 액션 단계 마스터
	VALUES
	('comment', 0, 0),
	('comment', 1, 5),
	('comment', 6, 10),
	('comment', 11, 9999), -- 최댓값 임시적으로 간단하게 9999지정
	('follow', 0, 0),
	('follow', 1, 5),
	('follow', 6, 10),
	('follow', 11, 9999)
),
mst_user_action_bucket AS (
	-- 사용자 마스터와 액션 단계 마스터 조합하기
	SELECT u.user_id,
		u.register_date,
		a.action,
		a.min_count,
		a.max_count
	FROM mst_users u CROSS JOIN mst_action_bucket a
),
register_action_flag AS (
	SELECT m.user_id,
		m.action,
		m.min_count,
		m.max_count,
		-- 등록일 ~ 7일후 까지의 액션 수 집계
		COUNT(a.action) AS action_count,
		-- 액션 단계별 14일 정착 달성 flag
		CASE 
			WHEN COUNT(a.action) BETWEEN m.min_count AND m.max_count THEN 1 ELSE 0
		END AS achieve,
		index_name,
		index_date_action
	FROM mst_user_action_bucket m 
			LEFT JOIN action_log a ON m.user_id = a.user_id
									AND CAST(a.stamp AS date) 
										BETWEEN CAST(m.register_date AS date) 
										AND CAST(m.register_date AS date) + interval '7 days'
									AND m.action = a.action
			LEFT JOIN user_action_flag f ON m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
	GROUP BY m.user_id, m.action, m.min_count, m.max_count, f.index_name, f.index_date_action
)
SELECT *
FROM register_action_flag
ORDER BY user_id, action, min_count
;

-- 1-3. 등록 후 7일동안의 액션 횟수별 '14일 정착률' 집계
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
	VALUES('14 day retention', 8, 14)
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
mst_action_bucket(action, min_count, max_count) AS (
	-- 액션 단계 마스터
	VALUES
	('comment', 0, 0),
	('comment', 1, 5),
	('comment', 6, 10),
	('comment', 11, 9999), -- 최댓값 임시적으로 간단하게 9999지정
	('follow', 0, 0),
	('follow', 1, 5),
	('follow', 6, 10),
	('follow', 11, 9999)
),
mst_user_action_bucket AS (
	-- 사용자 마스터와 액션 단계 마스터 조합하기
	SELECT u.user_id,
		u.register_date,
		a.action,
		a.min_count,
		a.max_count
	FROM mst_users u CROSS JOIN mst_action_bucket a
),
register_action_flag AS (
	SELECT m.user_id,
		m.action,
		m.min_count,
		m.max_count,
		-- 등록일 ~ 7일후 까지의 액션 수 집계
		COUNT(a.action) AS action_count,
		-- 액션 단계별 14일 정착 달성 flag
		CASE 
			WHEN COUNT(a.action) BETWEEN m.min_count AND m.max_count THEN 1 ELSE 0
		END AS achieve,
		index_name,
		index_date_action
	FROM mst_user_action_bucket m 
			LEFT JOIN action_log a ON m.user_id = a.user_id
									AND CAST(a.stamp AS date) 
										BETWEEN CAST(m.register_date AS date) 
										AND CAST(m.register_date AS date) + interval '7 days'
									AND m.action = a.action
			LEFT JOIN user_action_flag f ON m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
	GROUP BY m.user_id, m.action, m.min_count, m.max_count, f.index_name, f.index_date_action
)
SELECT action,
	min_count || ' ~ ' || max_count AS count_range,
	SUM(CASE achieve WHEN 1 THEN 1 ELSE 0 END) AS achieve,
	index_name,
	AVG(CASE WHEN achieve = 1 THEN 100.0 * index_date_action END) AS achieve_index_rate
FROM register_action_flag
GROUP BY index_name, action, min_count, max_count
ORDER BY index_name, action, min_count
;

/* 12-5. 사용 일수에 따른 정착률 집계 ===========================================================*/
-- 1. 7일 정착 기간 동안 사용자가 며칠 사용했는지가 '이후 정착률(28일 정착률)'에 어떠한 영향을 주는지 확인해보자
-- 1-1. 등록일 다음날 ~ 7일 동안의 사용 일수 계산, 28일 정착 flag 생성
WITH
repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
	VALUES ('28 day retention', 22, 28)
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
register_action_flag AS (
	SELECT m.user_id,
		-- 사용일수
		COUNT(DISTINCT CAST(a.stamp AS date)) AS dt_count,
		f.index_name,
		f.index_date_action
	FROM mst_users m 
				LEFT JOIN action_log a ON m.user_id = a.user_id
										-- 등록일 다음날 ~ 7일 이내의 액션 로그 결합
										AND CAST(a.stamp AS date)
											BETWEEN CAST(m.register_date AS date) + interval '1 day' 
											AND CAST(m.register_date AS date) + interval '8 days'
				LEFT JOIN user_action_flag f ON m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
	GROUP BY m.user_id, f.index_name, f.index_date_action
)
SELECT *
FROM register_action_flag
;

-- 1-2. 사용 일수(dates)에 따른 정착율 집계
WITH
repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
	VALUES ('28 day retention', 22, 28)
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
register_action_flag AS (
	SELECT m.user_id,
		-- 사용일수
		COUNT(DISTINCT CAST(a.stamp AS date)) AS dt_count,
		index_name,
		index_date_action
	FROM mst_users m 
				LEFT JOIN action_log a ON m.user_id = a.user_id
										-- 등록일 다음날 ~ 7일 이내의 액션 로그 결합
										AND CAST(a.stamp AS date)
											BETWEEN CAST(m.register_date AS date) + interval '1 day' 
											AND CAST(m.register_date AS date) + interval '8 days'
				LEFT JOIN user_action_flag f ON m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
	GROUP BY m.user_id, f.index_name, f.index_date_action
)
SELECT dt_count AS dates,
	COUNT(user_id) AS users,
	100.0 * COUNT(user_id) / SUM(COUNT(user_id)) OVER() AS user_ratio,
	100.0 
	* SUM(COUNT(user_id)) OVER(ORDER BY index_name, dt_count
									ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	/ SUM(COUNT(user_id)) OVER()
	AS cum_ratio,
	SUM(index_date_action) AS achieve_users,
	AVG(100.0 * index_date_action) AS achieve_ratio
FROM register_action_flag
GROUP BY index_name, dt_count
ORDER BY index_name, dt_count
; -- 사용일수 기준으로 진행했지만, 서비스에 따라 게시글 개수, 게임 레벨 등으로 대상 적절히 변경해서 사용!
