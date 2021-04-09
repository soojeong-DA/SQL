/* 새로운 지표 정의
- 단순하게 숫자로 비교하면 숫치가 큰 데이터만 주목하게 되지만, 
'개인별' or '비율' 등의 지표를 사용하면 **다양한 관점**에서 데이터를 바라볼 수 있음 
- ex. 페이지뷰 / 방문자수 = '사용자 한 명이 페이지를 몇번이나 방문했는 가?' */

/* 1. 문자열 연결 */
-- CONCAT 함수 or ||
SELECT user_id,
	CONCAT(pref_name, ' ', city_name) AS pref_city1, -- 주소 연결
	pref_name||' '||city_name AS pref_city2
FROM mst_user_location;

/* 2. 여러 개의 값 비교 */
SELECT * FROM quarterly_sales;

-- 분기별 매출 증감 판정(q1, q2)
SELECT year,
	-- Q1, Q2의 매출 변화 평가
	CASE 
		WHEN q1 < q2 THEN '+'
		WHEN q1 = q2 THEN ' '
	ELSE '-' END AS judge_q1_q2,
	-- 매출액 차이 계산
	q2 - q1 AS diff_q2_q1,
	-- 매출 변화를 1,0,-1로 표현 	
	SIGN(q2 - q1) AS sign_q2_q1
FROM quarterly_sales
ORDER BY year;

-- 연간 최대/최소 분기 매출 찾기
-- greatest/least 함수 사용 (한 컬컴 안에서 비교는 MAX/MIN. but, 이 경우는 여러개 컬럼 값들을 비교하는 경우니까!)
SELECT year,
	greatest(q1,q2,q3,q4) AS greatest_sales,
	least(q1,q2,q3,q4) AS least_sales
FROM quarterly_sales
ORDER BY year;

-- 연간 평균 4분기 매출 계산
SELECT year,
		(COALESCE(q1,0) + COALESCE(q2,0) + COALESCE(q3,0) + COALESCE(q4,0)) 
		/ (SIGN(COALESCE(q1,0)) + SIGN(COALESCE(q2,0)) + SIGN(COALESCE(q3,0)) + SIGN(COALESCE(q4,0)))
		AS average
FROM quarterly_sales
ORDER BY year;

/* 3. 2개의 값 비율 계산 */
SELECT * FROM advertising_stats;

-- CTR
SELECT dt,
		ad_id,
		-- 정수 자료형 나누면, 정수 형태 출력됨 -> 자료형 변경한뒤 나눠줘야함
		CAST(clicks AS float) / impressions AS CTR, -- float이 double precision보다 속도가 더 빠름
		-- 실수를 상수 앞에 두고 계산하면, 암묵적으로 자료형 변환이 일어남
		100.0 * clicks / impressions AS CTR_AS_PERCENT
FROM advertising_stats
WHERE dt = '2017-04-01';

-- 0으로 나누는 것을 피해 CTR 계산
-- -- 1. CASE식
SELECT dt,
		ad_id,
		CASE 
			WHEN impressions != 0 THEN CAST(clicks AS float) / impressions
			ELSE NULL 
		END AS CTR,
		CASE 
			WHEN impressions != 0 THEN 100.0 * clicks / impressions 
			ELSE NULL 
		END AS CTR_AS_PERCENT
FROM advertising_stats;

-- -- 2. NULL 전파 이용 - NULLIF
SELECT dt,
		ad_id,
		CAST(clicks AS float) / NULLIF(impressions, 0) AS CTR, -- impressions가 0이면 NULL 반환
		100.0 * clicks / NULLIF(impressions, 0) AS CTR_AS_PERCENT
FROM advertising_stats;

/* 4. 두 값의 거리 계산 */
-- 절댓값, 제곱 평균 제곱근(RMS) 계산 <- 1차원
SELECT abs(x1 - x2) AS abs,
	sqrt(power(x1-x2,2)) AS rms
FROM location_1d;

-- xy 평면 위에 있는 두 점의 유클리드 거리 계산 <- 2차원
SELECT sqrt(power(x1 - x2,2) + power(y1 - y2,2)) AS dist,
	-- point 자료형과 거리 연상자(<->) 사용
	point(x1, y1) <-> point(x2,y2) AS dist
FROM location_2d;

/* 5. 날짜/시간 계산 */
-- 미래/과거 날짜/시간 계산
SELECT user_id,
		register_stamp::timestamp AS register_stamp,
	-- interval 자료형 활용
	register_stamp::timestamp + '1 hour'::interval AS after_1_hour,
	register_stamp::timestamp - '30 minutes'::interval AS before_30_minutes,
	-- interval 자료형 활용해서 계산 후, date 자료형으로 재변환
	(register_stamp::date + '1 day'::interval)::date AS after_1_day,
	(register_stamp::date + '1 month'::interval)::date AS before_1_month
FROM mst_users_with_dates;

-- 날짜간 차이 계산
SELECT user_id,
	CURRENT_DATE AS today,
	register_stamp::date AS register_date,
	CURRENT_DATE - register_stamp::date AS diff_days
FROM mst_users_with_dates;

-- 사용자 생년월일로 등록시점의 나이 계산(한국나이)
SELECT EXTRACT(YEAR from register_stamp::date) - EXTRACT(YEAR from birth_date::date) + 1
FROM mst_users_with_dates;

-- 사용자 생년월일로 나이 계산(만나이) - age 함수 이용
SELECT
	-- 현재 기준 나이
	EXTRACT(YEAR from age(birth_date::date)) AS current_age,
	-- 등록시점의 나이
	EXTRACT(YEAR from age(register_stamp::date, birth_date::date)) AS current_age
FROM mst_users_with_dates;

-- 날짜를 정수로 표현해서 나이 계산(날짜를 빼고 10000으로 나누면 계산됨)
-- -- 미들웨어마다 날짜/시간 데이터 계산 표현에 차이가 커서 실수 많음
-- -- 따라서, 수치/문자열 등으로 변환해서 다루는 것이 편함
SELECT user_id,
		substring(register_stamp,1,10) AS register_stamp,
		birth_date,
		-- 등록 시점의 나이
		floor(
			(CAST(replace(substring(register_stamp,1,10),'-','') AS integer)
			- CAST(replace(birth_date,'-','') AS integer)
			) / 10000 
		) AS register_age,
		-- 현재 시점의 나이
		floor(
			(CAST(replace(CURRENT_DATE::text,'-','') AS integer)
			- CAST(replace(birth_date,'-','') AS integer)
			) / 10000
		) AS current_age
FROM mst_users_with_dates;

/* 6. IP 주소 다루기 */
-- ip주소 다루기 위한 inet 자료형 활용
-- IP 주소 비교(bool)
SELECT CAST('127.0.0.1' AS inet) < CAST('127.0.0.2' AS inet) AS lt,
	CAST('127.0.0.1' AS inet) > CAST('192.168.0.1' AS inet) AS gt
;

-- address/y 형식의 '네트워크 범위'에 해당 IP 주소가 포함되는지 판정 가능! (<< or >> 연산자 사용)
SELECT CAST('127.0.0.1' AS inet) << CAST('127.0.0.0/8' AS inet) AS is_contained;

-- IP 주소를 0으로 메우기(고정 길이 문자열)  <- inet 자료형 처럼 ip 주소 전용 자료형이 제공되지 않는 경우
-- -- lpad함수로 문자열 왼쪽을 0으로 매워, 모든 10진수가 3자리 수가 되게하기
SELECT ip,
	lpad(split_part(ip, '.', 1), 3, '0') ||
	lpad(split_part(ip, '.', 2), 3, '0') ||
	lpad(split_part(ip, '.', 3), 3, '0') ||
	lpad(split_part(ip, '.', 4), 3, '0') AS ip_padding
FROM (SELECT CAST('192.168.0.1' AS text) AS ip) AS t;
-- > 이렇게 맞춰 준 후, 대소 비교 등 가능!


