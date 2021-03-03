/* 코드 값을 레이블로 변경하기 */
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

/* URL에서 요소 추출하기 */
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

/* 문자열을 배열로 분해하기 */
-- URL PATH를 '/'로 분할해서 계층 추출
-- split_part()로 n번째 요소 추출
SELECT stamp,
		url,
		split_part(substring(url from '//[^/]+([^?#]+)'), '/', 2) AS path1,
		split_part(substring(url from '//[^/]+([^?#]+)'), '/', 3) AS path2
FROM access_log;

/* 날짜와 타임스탬프 다루기 */
-- 현재 날짜와 타임스탬프 추출
SELECT CURRENT_DATE AS dt,
		CURRENT_TIMESTAMP AS stamp1, 
		LOCALTIMESTAMP AS stamp2;  -- 타임존 적용 x
		
-- 지정한 값의 날짜/시각 데이터 추출


