-- # 코드값을 레이블로 변경하기: CASE문 이용 (특정 조건 기반으로 값을 결정할 때)########
select * from mst_users;
SELECT
	user_id
	, CASE
		WHEN register_device = 1 THEN '데스크톱'
		WHEN register_device = 2 THEN '스마트폰'
		WHEN register_device = 3 THEN '애플리케이션'
		-- 디폴트 값을 지정할 경우 ELSE 구문을 사용
		-- ELSE ''
	END AS device_name
FROM mst_users;
select * from mst_users;

-- # 로그 데이터의 url에서 요소 추출########################
select * from access_log;

-- 레퍼러(referrer)로 어떤 웹 페이지를 거쳐 넘어왔는지 판별
-- 페이지 단위로 집계하면 밀도가 너무 작아 복잡해짐 -> 호스트 단위로 집계하는 것이 일반적
SELECT 
	stamp
	-- referrer의 호스트 이름 부분 추출
	-- substring 함수와 정규 표현식 사용
	, substring(referrer from 'https?://([^/]*)') AS referrer_host
FROM access_log;

-- URL 경로와 GET 매개변수에 있는 특정 키 값 추출 (path, key/id)
SELECT
	stamp
	, url
	,substring(url from '//[^/]+([^?#]+)') AS path
	,substring(url from 'id=([^&]*)') AS id
FROM access_log;

-- URL 경로를 슬래시로 분할해서 계층을 추출
SELECT
	stamp
	, url
	, split_part(substring(url from '//[^/]+([^?#]+)'),'/',2) AS path1
	, split_part(substring(url from '//[^/]+([^?#]+)'),'/',3) AS path2
FROM access_log;

-- # 날짜와 타임스탬스 다루기########################
-- 현재 날짜와 타임스탬프 추출
SELECT 
	CURRENT_DATE AS date
	,CURRENT_TIMESTAMP AS stamp1  -- 타임존이 적용된 타임스탬프
	,LOCALTIMESTAMP AS stamp2  -- 타임존 적용 안하는 타임스탬프
;

-- 문자열 값에서 날짜/시각 데이터 추출
-- 1. CAST 함수 사용 (가장 범용적)
SELECT
	CAST('2016-01-30' AS date) AS dt
	,CAST('2016-01-30 12:00:00' AS timestamp) AS stamp
;
-- 2. type value 사용 (단, value는 상수이므로 컬럼 이름으로 지정 불가)
SELECT
	date '2016-01-30' AS dt
	,timestamp '2016-01-30 12:00:00' AS stamp
;
-- 3. value::type 사용
SELECT
	'2016-01-30'::date AS dt
	,'2016-01-30 12:00:00'::timestamp AS stamp
;

-- 타임스탬프 자료형의 데이터에서 년, 월, 일, 시간 등을 추출: EXTRACT 함수 사용
SELECT
	stamp
	, EXTRACT(YEAR FROM stamp) AS year
	, EXTRACT(MONTH FROM stamp) AS month
	, EXTRACT(DAY FROM stamp) AS day
	, EXTRACT(HOUR FROM stamp) AS hour
	, EXTRACT(MINUTE FROM stamp) AS minute
	, EXTRACT(SECOND FROM stamp) AS second
FROM (SELECT CAST('2016-01-30 12:56:01' AS timestamp) AS stamp) AS t
;

-- 타임스탬프 문자열에서 년, 월, 일, 시간 등 추출: substring 함수 사용
SELECT
	stamp
	, substring(stamp, 1,4) AS year
	, substring(stamp, 6,2) AS month
	, substring(stamp, 1,7) AS year_month   -- 연,월 같이 추출
	, substring(stamp, 9,2) AS day
	, substring(stamp, 12,2) AS hour
	, substring(stamp, 15,2) AS minute
	, substring(stamp, 18,2) AS second
FROM (SELECT CAST('2016-01-30 12:56:01' AS text) AS stamp) AS t;   -- 문자열::text (string X)
-- 타임스탬프 문자열에서 년, 월, 일, 시간 등 추출: substr 함수 사용
SELECT
	stamp
	, substr(stamp, 1,4) AS year
	, substr(stamp, 6,2) AS month
	, substr(stamp, 1,7) AS year_month   -- 연,월 같이 추출
	, substr(stamp, 9,2) AS day
	, substr(stamp, 12,2) AS hour
	, substr(stamp, 15,2) AS minute
	, substr(stamp, 18,2) AS second
FROM (SELECT CAST('2016-01-30 12:56:01' AS text) AS stamp) AS t;   -- 문자열::text (string X)

-- # 결측치 값을 디폴트 값으로 대치 #############
select * from purchase_log_with_coupon;
-- COALESCE로 NULL 처리
SELECT
	purchase_id
	, amount
	,coupon
	, amount - coupon AS discount_amount1
	, amount - COALESCE(coupon, 0) AS discount_amount2
FROM purchase_log_with_coupon;

