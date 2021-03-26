/* 시계열에 따른 사용자 전체의 상태 변화 찾기 
- 사용자의 서비스 사용을 시계열로 수치화하고, 변화를 시각화 해보자! */

-- 사용자 마스터 TABLE
SELECT * FROM mst_users;
-- 액션 로그 TABLE
SELECT * FROM action_log;

/* 등록 수의 추이와 경향 살펴보기 */
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