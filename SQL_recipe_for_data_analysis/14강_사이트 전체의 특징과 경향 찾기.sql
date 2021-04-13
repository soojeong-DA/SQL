/* 사이드 전체의 특징/경향 찾기 */
SELECT * FROM access_log;
SELECT * FROM purchase_log;

/* 14-1. 날짜별 방문자 수, 방문 횟수, 페이지 뷰 집계 
- 방문자 수: 브라우저를 꺼도 사라지지 않는 쿠키의 유니크 수 (long_session)
- 방문 횟수: 브라우저를 껐을 때 사라지는 쿠키의 유니크 수 (short_session)
- 페이지 뷰: 페이지를 출력한 로그의 줄 수      ============================================================ */

-- 날짜별 접근 데이터, 1인당 페이지 뷰 수 집계
SELECT substring(stamp, 1, 10) AS dt,
		-- 방문자 수
		COUNT(DISTINCT long_session) AS access_users,
		-- 방문 횟수
		COUNT(DISTINCT short_session) AS access_count,
		-- 페이지 뷰
		COUNT(*) AS page_view,
		-- 1인당 페이지 뷰 수
		1.0 * COUNT(*) / NULLIF(COUNT(DISTINCT long_session), 0) AS pv_per_user
FROM access_log
GROUP BY dt
ORDER BY dt
;

/* 14-2. 페이지별 쿠기, 방문 횟수, 페이지 뷰 집계 
- 로그 데이터의 URL에는 요청 매개변수가 포함되어 있는 경우가 많음 => 이를 제거하고 집계해야 ====================================== */

-- 1. 단순 URL별 집계 (요청 매개변수 제거 X)
SELECT url,
	COUNT(DISTINCT long_session) AS access_users,
	COUNT(DISTINCT short_session) AS access_count,
	COUNT(*) AS page_view
FROM access_log
GROUP BY url
;

-- 2. 경로별 집계 (요청 매개변수를 생략하고, 경로만으로 집계)
WITH
access_log_with_path AS (
	SELECT *,
		-- URL에서 경로 추출(정규 표현식)
		substring(url from '//[^/]+([^?#]+)') AS url_path
	FROM access_log
)
SELECT url_path,
	COUNT(DISTINCT long_session) AS access_users,
	COUNT(DISTINCT short_session) AS access_count,
	COUNT(*) AS page_view
FROM access_log_with_path
GROUP BY 1
;

-- 3. 카테고리별로 나눠져 있는 list page를 묶어서 집계 (URL에 의미를 부여해서 집계)
-- ex. '/list/cd', '/list/dvd', .. => category_list
WITH
access_log_with_path AS (
	SELECT *,
		-- URL에서 경로 추출(정규 표현식)
		substring(url from '//[^/]+([^?#]+)') AS url_path
	FROM access_log
),
access_log_with_split_path AS (
	-- 경로의 첫 번째 요소, 두 번째 요소 추출
	SELECT *,
		split_part(url_path, '/', 2) AS path1,
		split_part(url_path, '/', 3) AS path2
	FROM access_log_with_path
),
access_log_with_page_name AS (
	-- 경로를 슬래시로 분할하고, 조건에 따라 페이지에 이름 붙이기
	SELECT *,
		CASE 
			WHEN path1 = 'list' THEN 
				CASE 
					WHEN path2 = 'newly' THEN 'newly_list' ELSE 'category_list'
				END
			-- 이외의 경우는 경로 그대로 사용
			ELSE url_path
		END AS page_name
	FROM access_log_with_split_path
)
SELECT page_name,
	COUNT(DISTINCT long_session) AS access_users,
	COUNT(DISTINCT short_session) AS access_count,
	COUNT(*) AS page_view
FROM access_log_with_page_name
GROUP BY page_name
ORDER BY 1
;
