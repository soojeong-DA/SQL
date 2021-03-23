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

-- 로그인/비로그인 사용자 구분해서 집계
-- -- 이를 통해 서비스에 대한 충성도가 높은/낮은 사용자가 어떤 경향을 보이는 지 파악하는 데 도움이 될 수 있음
WITH action_log_with_status AS (
	SELECT session,
		user_id,
		action,
		-- user_id가 NULL or ''(빈문자)가 아닐 경우, login이라고 판정해 구별
		CASE WHEN COALESCE(user_id,'') != '' THEN 'login' ELSE 'guest' END 
		AS login_status
	FROM action_log
)
SELECT
	-- login_status를 기반으로 action수와 UU를 집계
	COALESCE(action, 'all') AS action,
	COALESCE(login_status, 'all') AS login_status,
	COUNT(DISTINCT session) AS action_uu,
	COUNT(1) AS action_count
FROM action_log_with_status
GROUP BY ROLLUP(action, login_status) -- rollup구문 사용해 집계
; -- > 여기서 all은 session 기반으로 집계함 => guest + login != all

-- 회원/비회원 구분해서 집계
-- -- 로그인하지 않은 상태라도, 이전에 한 번이라도 로그인 했다면 회원으로 계산
SELECT session,
	user_id,
	action,
	-- log를 timestamp 순으로 정렬 후, 이전에 한번이라도 로그인한(max(uesr_id)) 사용자일 경우,
	-- 이후의 모든 로그 상태를 member로 설정
	CASE
		WHEN COALESCE(MAX(user_id) OVER(PARTITION BY session ORDER BY stamp
										ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
					  , '') != ''
		THEN 'member' 
		ELSE 'none' 
	END AS member_status,
	stamp
FROM action_log;

/* 연령별 구분 집계 */
-- 나이 계산 및 연령별 구분
WITH 
mst_user_with_int_birth_date AS (
	SELECT *,
		-- 특정 날짜(2021년 3월 19일)의 정수 표현(기준 시점)
		20210319 AS int_specific_date,
		-- 문자열로 구성된 생년월일 -> 정수 표현으로 변환
		CAST(replace(substring(birth_date, 1, 10), '-', '') AS integer) AS int_birth_date
	FROM mst_users
),
mst_user_with_age AS (
	SELECT *,
		-- 특정 날짜(2021년 3월 19일) 시점의 나이 계산
		FLOOR((int_specific_date - int_birth_date) / 10000) AS age
	FROM mst_user_with_int_birth_date
)
SELECT user_id,
	sex,
	birth_date,
	age,
	-- 시청률 분석에 많이 사용되는 성별/연령별 구분 기준 사용
	CONCAT(
		CASE
			WHEN age >= 20 THEN sex ELSE ''
		END,
		CASE
			WHEN age BETWEEN 4 AND 12 THEN 'C'
			WHEN age BETWEEN 13 AND 19 THEN 'T'
			WHEN age BETWEEN 20 AND 34 THEN '1'
			WHEN age BETWEEN 35 AND 49 THEN '2'
			WHEN age >= 50 THEN '3'
		END
	) AS age_category
FROM mst_user_with_age;


-- 연령별 구분에 따른 사람 수 계산
WITH 
mst_user_with_int_birth_date AS (
	SELECT *,
		-- 특정 날짜(2021년 3월 19일)의 정수 표현(기준 시점)
		20210319 AS int_specific_date,
		-- 문자열로 구성된 생년월일 -> 정수 표현으로 변환
		CAST(replace(substring(birth_date, 1, 10), '-', '') AS integer) AS int_birth_date
	FROM mst_users
),
mst_user_with_age AS (
	SELECT *,
		-- 특정 날짜(2021년 3월 19일) 시점의 나이 계산
		FLOOR((int_specific_date - int_birth_date) / 10000) AS age
	FROM mst_user_with_int_birth_date
),
mst_user_with_age_category AS (
	SELECT user_id,
		sex,
		birth_date,
		age,
		-- 시청률 분석에 많이 사용되는 성별/연령별 구분 기준 사용
		CONCAT(
			CASE
				WHEN age >= 20 THEN sex ELSE ''
			END,
			CASE
				WHEN age BETWEEN 4 AND 12 THEN 'C'
				WHEN age BETWEEN 13 AND 19 THEN 'T'
				WHEN age BETWEEN 20 AND 34 THEN '1'
				WHEN age BETWEEN 35 AND 49 THEN '2'
				WHEN age >= 50 THEN '3'
			END
		) AS age_category
	FROM mst_user_with_age
)
SELECT age_category,
	COUNT(*) AS user_count -- COUNT(1)과 동일
FROM mst_user_with_age_category
GROUP BY 1
ORDER BY 1
;

/* 연령별 구분에 따른 특징 추출 */
-- 연령별 구매 카테고리 집계
WITH 
mst_user_with_int_birth_date AS (
	SELECT *,
		-- 특정 날짜(2021년 3월 19일)의 정수 표현(기준 시점)
		20210319 AS int_specific_date,
		-- 문자열로 구성된 생년월일 -> 정수 표현으로 변환
		CAST(replace(substring(birth_date, 1, 10), '-', '') AS integer) AS int_birth_date
	FROM mst_users
),
mst_user_with_age AS (
	SELECT *,
		-- 특정 날짜(2021년 3월 19일) 시점의 나이 계산
		FLOOR((int_specific_date - int_birth_date) / 10000) AS age
	FROM mst_user_with_int_birth_date
),
mst_user_with_age_category AS (
	SELECT user_id,
		sex,
		birth_date,
		age,
		-- 시청률 분석에 많이 사용되는 성별/연령별 구분 기준 사용
		CONCAT(
			CASE
				WHEN age >= 20 THEN sex ELSE ''
			END,
			CASE
				WHEN age BETWEEN 4 AND 12 THEN 'C'
				WHEN age BETWEEN 13 AND 19 THEN 'T'
				WHEN age BETWEEN 20 AND 34 THEN '1'
				WHEN age BETWEEN 35 AND 49 THEN '2'
				WHEN age >= 50 THEN '3'
			END
		) AS age_category
	FROM mst_user_with_age
)
SELECT A.category AS product_category,
	B.age_category AS user_category,
	COUNT(*) AS purchase_count
FROM action_log A
	INNER JOIN mst_user_with_age_category B ON A.user_id = B.user_id
WHERE action = 'purchase'  -- 구매 로그만 선택!
GROUP BY 1,2
ORDER BY 1,2
; --> 카테고리 내부의 연령 분포 + 연령 내부의 카테고리 분포 두가지 그래프 모두 확인!


/* 사용자의 방문 빈도 집계 */
-- 일주일 동안의 사용자 사용 일수와 구성비
WITH 
action_log_with_dt AS (
	SELECT *,
		-- 날짜 추출
		substring(stamp,1, 10) AS dt
	FROM action_log
),
action_day_count_per_user AS (
	SELECT user_id,
		COUNT(DISTINCT dt) AS action_day_count
	FROM action_log_with_dt
	WHERE dt BETWEEN '2016-11-01' AND '2016-11-07'  -- 일주일 동안
	GROUP BY user_id
)
SELECT action_day_count,
	-- 사용 일수별 사용자 COUNT
	COUNT(DISTINCT user_id) AS user_count,
	-- 구성비
	100.0 * COUNT(DISTINCT user_id) / SUM(COUNT(DISTINCT user_id)) OVER()  -- OVER(): 전체 범위 
	AS composition_ratio,
	-- 구성비누계
	100.0
	* SUM(COUNT(DISTINCT user_id)) OVER(ORDER BY action_day_count
									   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	/ SUM(COUNT(DISTINCT user_id)) OVER()
	AS cumulative_ratio
FROM action_day_count_per_user
GROUP BY action_day_count
ORDER BY action_day_count
;

/* 벤 다이어그램으로 사용자 액션 집계 
- 여러 기능의 사용자 사용 상황을 조사할 때 쓰임 */

-- 사용자들의 액션 플래그 집계 (3개 액션 purchase, review, favorite에 대해)
SELECT user_id,
	SIGN(SUM(CASE WHEN action='purchase' THEN 1 ELSE 0 END)) AS has_purchase,
	SIGN(SUM(CASE WHEN action='review' THEN 1 ELSE 0 END)) AS has_review,
	SIGN(SUM(CASE WHEN action='favorite' THEN 1 ELSE 0 END)) AS has_favorite
FROM action_log
GROUP BY user_id
ORDER BY user_id;

-- '모든 액션 조합'에 대한 사용자 수 집계 (CUBE 구문)
WITH user_action_flag AS (
	SELECT user_id,
	SIGN(SUM(CASE WHEN action='purchase' THEN 1 ELSE 0 END)) AS has_purchase,
	SIGN(SUM(CASE WHEN action='review' THEN 1 ELSE 0 END)) AS has_review,
	SIGN(SUM(CASE WHEN action='favorite' THEN 1 ELSE 0 END)) AS has_favorite
	FROM action_log
	GROUP BY user_id
)
SELECT has_purchase, 
	has_review, 
	has_favorite,
	COUNT(*) AS users
FROM user_action_flag
GROUP BY CUBE(has_purchase, has_review, has_favorite)
ORDER BY 1,2,3
;


