/* 1. 코드 값을 레이블로 변경하기 */
SELECT * FROM mst_users;
-- 특정 조건을 기반으로 값을 결정/변환할 때 CASE식 사용
SELECT user_id,
		CASE
			WHEN register_device = 1 THEN '데스크톱'
			WHEN register_device = 2 THEN '스마트폰'
			WHEN register_device = 3 THEN '애플리케이션'
		-- ELSE
		END AS device_name
FROM mst_users;

/* 2. URL에서 요소 추출하기 */
SELECT * FROM access_log;
-- 1. 레퍼러로 어떤 웹 페이지를 거쳐 넘어왔는지 판별하기 - 호스트 단위로 집계
SELECT stamp,
	-- referrer의 호스트 이름 부분 추출 (정규 표현식 사용)
	-- s? : s가 0 or 1번, [^/]: /가 없는, *: 0개 이상
	substring(referrer from 'https?://([^/]*)') AS referrer_host
FROM access_log;

-- 2. URL에서 path와 get매개변수의 id 추출
SELECT stamp,
		url,
		substring(url from '//[^/]+([^?#]+)') AS path,
		substring(url from 'id=([^&]*)') AS id
FROM access_log;

/* 3. 문자열을 배열로 분해하기 */
-- URL PATH를 '/'로 분할해서 계층 추출
-- split_part()로 n번째 요소 추출
SELECT stamp,
		url,
		split_part(substring(url from '//[^/]+([^?#]+)'), '/', 2) AS path1,
		split_part(substring(url from '//[^/]+([^?#]+)'), '/', 3) AS path2
FROM access_log;

/* 4. 날짜와 타임스탬프 다루기 */
-- 현재 날짜와 타임스탬프 추출
SELECT CURRENT_DATE AS dt,
		CURRENT_TIMESTAMP AS stamp1, 
		LOCALTIMESTAMP AS stamp2;  -- 타임존 적용 x
		
-- 지정한 값의 날짜/시각 데이터 추출
-- -- 1. CAST(value AS type)
SELECT CAST('2016-01-30' AS date) AS dt,
		CAST('2016-01-30 12:00:00' AS timestamp) AS stamp
;
-- -- 2. 'type value'
SELECT date '2016-01-30' AS dt,
		timestamp '2016-01-30 12:00:00' AS stamp
;
-- -- 3. 'value::type'
SELECT '2016-01-30'::date AS dt,
		'2016-01-30 12:00:00'::timestamp AS stamp
;

-- 날짜/시각에서 특정 필드(년,월,일,시간 등) 추출
-- EXTRACT 함수 사용
SELECT stamp,
	EXTRACT(YEAR FROM stamp) AS year,
	EXTRACT(MONTH FROM stamp) AS MONTH,
	EXTRACT(DAY FROM stamp) AS DAY,
	EXTRACT(HOUR FROM stamp) AS HOUR,
	EXTRACT(MINUTE FROM stamp) AS MINUTE,
	EXTRACT(SECOND FROM stamp) AS SECOND
FROM (SELECT CAST('2016-01-30 12:00:00' AS timestamp) AS stamp ) AS T ;

-- timestamp를 나타내는 문자열에서 연, 월, 일 등 추출
-- SUBSTRING / SUBSTR 함수 사용
SELECT stamp,
	SUBSTRING(stamp, 1,4) AS year,  -- SUBSTR함수로 대체 가능
	SUBSTRING(stamp, 6,2) AS month,
	SUBSTRING(stamp, 9,2) AS day,
	SUBSTRING(stamp, 12,2) AS hour,
	-- 년, 월 함께 추출
	SUBSTRING(stamp, 1,7) AS year_month

FROM (SELECT CAST('2016-01-30 12:00:00' AS text) AS stamp) AS t;  -- text(문자열) 자료형으로 변환

/* 5. 결손 값을 default 값으로 대치 */
-- 쿠폰으로 할인했을 때 매출 금액 (쿠폰 없으면 null로 저장되어있음)
SELECT * FROM purchase_log_with_coupon;
SELECT *,
		amount - COALESCE(coupon,0) AS discount_amount -- null과 연산하면 결과 null이됨 => 0으로 대치해야함
FROM purchase_log_with_coupon;

