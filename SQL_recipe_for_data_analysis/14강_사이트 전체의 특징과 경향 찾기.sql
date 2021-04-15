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

/* 14-3. 유입 경로별 방문 횟수, CVR 집계 
- 유입원 판정 방법: URL 매개변수 기반 판정, 레퍼러 도메인과 랜딩 페이지를 사용한 판정 ==================================== */

-- 1. 유입원별 방문 횟수 집계
WITH
access_log_with_parse_info AS (
	SELECT *,
		-- 유입원 정보 추출 (정규 표현식 이용)
		-- *: 해당 패턴이 0개 이상 일치, [^]: ~아닌
		substring(url from 'https?://([^/]*)') AS url_domain,  -- 우리 사이트 도메인 -> 나중에 제외
		substring(url from 'utm_source=([^&]*)') AS url_utm_source,
		substring(url from 'utm_medium=([^&]*)') AS url_utm_medium,
		substring(referrer from 'https?://([^/]*)') AS referrer_domain
	FROM access_log
),
access_log_with_via_info AS (
	SELECT *,
		ROW_NUMBER() OVER(ORDER BY stamp) AS log_id,
		CASE
			WHEN url_utm_source != '' AND url_utm_medium != ''
				THEN CONCAT(url_utm_source, '-', url_utm_medium)
			WHEN referrer_domain IN ('search.yahoo.co.jp', 'www.google.co.jp') THEN 'search'
			WHEN referrer_domain IN ('twitter.com', 'www.facebook.com') THEN 'social'
			ELSE 'other'
		END AS via
	FROM access_log_with_parse_info
	-- referrer가 없는 경우(''), 우리 사이트 도메인(url_domain)인 경우 제외
	WHERE COALESCE(referrer_domain, '') NOT IN ('', url_domain)
)
SELECT via,
	COUNT(*) AS access_count
FROM access_log_with_via_info
GROUP BY via
ORDER BY access_count DESC
;

-- 2. 유입원별 CVR(각 방문에서 구매한 비율) 집계
WITH
access_log_with_parse_info AS (
	SELECT *,
		-- 유입원 정보 추출 (정규 표현식 이용)
		-- *: 해당 패턴이 0개 이상 일치, [^]: ~아닌
		substring(url from 'https?://([^/]*)') AS url_domain,  -- 우리 사이트 도메인 -> 나중에 제외
		substring(url from 'utm_source=([^&]*)') AS url_utm_source,
		substring(url from 'utm_medium=([^&]*)') AS url_utm_medium,
		substring(referrer from 'https?://([^/]*)') AS referrer_domain
	FROM access_log
),
access_log_with_via_info AS (
	SELECT *,
		ROW_NUMBER() OVER(ORDER BY stamp) AS log_id,
		CASE
			WHEN url_utm_source != '' AND url_utm_medium != ''
				THEN CONCAT(url_utm_source, '-', url_utm_medium)
			WHEN referrer_domain IN ('search.yahoo.co.jp', 'www.google.co.jp') THEN 'search'
			WHEN referrer_domain IN ('twitter.com', 'www.facebook.com') THEN 'social'
			ELSE 'other'
		END AS via
	FROM access_log_with_parse_info
	-- referrer가 없는 경우(''), 우리 사이트 도메인(url_domain)인 경우 제외
	WHERE COALESCE(referrer_domain, '') NOT IN ('', url_domain)
),
access_log_with_purchase_amount AS (
	SELECT a.log_id,
		a.via,
		SUM(
			CASE 
				WHEN p.stamp::date BETWEEN a.stamp::date AND a.stamp::date + '1 day'::interval THEN amount
			END
		) AS amount
	FROM access_log_with_via_info a LEFT OUTER JOIN purchase_log p ON a.long_session = p.long_session
	GROUP BY a.log_id, a.via
)
SELECT via,
	COUNT(*) AS via_count,
	COUNT(amount) AS conversions,
	AVG(100.0 * SIGN(COALESCE(amount, 0))) AS CVR,  -- 1: 구매함, 0: 안함
	SUM(COALESCE(amount, 0)) AS amount,
	AVG(1.0 * COALESCE(amount, 0)) AS avg_amount
FROM access_log_with_purchase_amount
GROUP BY via
ORDER BY cvr DESC
;

/* 14-4. 접근 요일, 시간대 파악 
- postgresql의 요일 번호: 일요일(0) ~ 토요일(6) =============================================================*/

-- 요일/시간대별 방문자 수 집계
WITH
access_log_with_dow AS  (
	SELECT stamp,
		-- 요일 번호 추출
		date_part('dow', stamp::timestamp) AS dow,
		-- 00:00:00부터의 경과 시간 계산 (초 단위)
		CAST(substring(stamp, 12, 2) AS int) * 60 * 60
		+ CAST(substring(stamp, 15, 2) AS int) * 60
		+ CAST(substring(stamp, 18, 2) AS int) 
		AS whole_seconds,
		-- 집계 시간 간격 정하기 (30분 단위 = 1800초)
		30 * 60 AS interval_seconds
	FROM access_log
),
access_log_with_floor_seconds AS (
	SELECT stamp,
		dow,
		-- 00:00:00부터의 경과 시간을 interval_seconds로 나누기!
		CAST((floor(whole_seconds / interval_seconds) * interval_seconds) AS int) AS floor_seconds
	FROM access_log_with_dow
),
access_log_with_index AS (
	SELECT stamp,
		dow,
		-- seconds를 다시 timestamp '형식'으로 변환 (문자열 합치기)
		lpad(floor(floor_seconds / (60 * 60))::text, 2, '0') || ':'
			|| lpad(floor(floor_seconds % (60 * 60) / 60)::text, 2, '0') || ':'
			|| lpad(floor(floor_seconds % 60)::text, 2, '0')
		AS index_time
	FROM access_log_with_floor_seconds
)
SELECT index_time,
	COUNT(CASE WHEN dow = 0 THEN 1 END) AS sun,
	COUNT(CASE WHEN dow = 1 THEN 1 END) AS mon,
	COUNT(CASE WHEN dow = 2 THEN 1 END) AS tue,
	COUNT(CASE WHEN dow = 3 THEN 1 END) AS wed,
	COUNT(CASE WHEN dow = 4 THEN 1 END) AS thu,
	COUNT(CASE WHEN dow = 5 THEN 1 END) AS fri,
	COUNT(CASE WHEN dow = 6 THEN 1 END) AS sat
FROM access_log_with_index
GROUP BY index_time
ORDER BY index_time
;
