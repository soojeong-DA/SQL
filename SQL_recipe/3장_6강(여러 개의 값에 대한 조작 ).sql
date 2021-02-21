select * from mst_user_location;
-- # 문자열 연결하기  ###############################
-- # 문자 결합: CONCAT, ||
SELECT
	user_id
	, CONCAT(pref_name, ' ', city_name) AS pref_city1   -- 띄어쓰기(' ') 빼도 됨
	, pref_name||' '||city_name AS pref_city2
FROM mst_user_location;

-- # 여러 개의 값 비교하기 ###############################
-- 분기별 매출 증감 판정: CASE문, SIGN 함수
select * from quarterly_sales;
SELECT
	year
	,q1
	,q2
	-- q1,q2의 매출 증감 판단(+, , -)
	, CASE
		WHEN q1 < q2 THEN '+'
		WHEN q1 = q2 THEN ' '
		ELSE '-'
	  END AS judge_q1_q2
	-- q1,q2의 매출액 차이 계산
	,q2 - q1 AS diff_q2_q1
	-- q1,q2의 매출 증감 판단(1,0,-1)
	,SIGN(q2-q1) AS sign_q2_q1
FROM quarterly_sales
ORDER BY year;

-- 연간 최대/최소 분기 매출 찾기: 행별 "여러개의 컬럼" 중 최대/최솟값 찾기: greatest, least 함수
select
	year
	, greatest(q1,q2,q3,q4) as greatest_sales
	, least(q1,q2,q3,q4) as least_sales
from quarterly_sales
order by year;

-- 연간 평균 매출 계산: 행별 여러개 컬럼의 평균값 계산
-- 1. 단순 계산  -> null 있는 컬럼 값 => null 반환
select
	year
	, (q1+q2+q3+q4) / 4 as average
from quarterly_sales
order by year;
-- 2. COALESCE로 NULL 처리 후, 평균 계산 -> null값 존재로 q1,q2밖에 없는 경우, 4로 나누면 값이 너무 작아짐
select
	year
	, (coalesce(q1,0)+coalesce(q2,0)+coalesce(q3,0)+coalesce(q4,0))/4 as average
from quarterly_sales
order by year;
-- 3. SIGN 함수로 양의 값(1) 컬럼의 수를 세서 나누기
select
	year
	, (coalesce(q1,0)+coalesce(q2,0)+coalesce(q3,0)+coalesce(q4,0))
	/ (sign(coalesce(q1,0))+sign(coalesce(q2,0))+sign(coalesce(q3,0))+sign(coalesce(q4,0)))
	as average
from quarterly_sales
order by year;

-- # 2개의 값 비율 계산하기 ###################
select * from advertising_stats;
-- 정수 자료형의 데이터 나누기
-- CTR: 클릭/노출수
SELECT
	dt
	, ad_id
	-- postgresql은 정수를 나누면 정수로 나옴 -> 자료형 변환 필요
	, CAST(clicks as double precision) / impressions as ctr  -- 비중
	-- 실수(100.0)를 상수로 앞에 두고 계산하면, 암묵적으로 자료형 변환이 일어남
	, 100.0 * clicks / impressions as ctr_as_percent    -- 퍼센트
from advertising_stats
where dt = '2017-04-01'
order by dt, ad_id;

-- 0으로 나누는 것 피하기
-- 1. CASE 식 이용
SELECT
	dt
	, ad_id
	, case
		when impressions > 0 then 100.0 * clicks/impressions
	  end as ctr_as_percent_by_case
from advertising_stats
order by dt, ad_id;

-- 2. NULLIF 이용
SELECT
	dt
	, ad_id
	-- 분모(impressions)가 0이라면, null을 반환하여, 결과를 null로 만드는 방법
	, 100.0 * clicks / nullif(impressions,0) as ctr_as_percent_by_null
from advertising_stats
order by dt, ad_id;

-- # 두 값의 거리 계산 ###############################
-- (일차원)두 값 간의 거리: 절댓값, 제곱 평균 제곱근(RMS) 계산: ABS, POWER,SQRT
select * from location_1d;
select
	abs(x1-x2) as abs
	, sqrt(power(x1 - x2, 2)) as rms
from location_1d;

-- (이차원) xy평면위 두 점의 유클리드 거리 계산: 제곱 평균 제곱근(RMS) = POINT 자료형 변화 & 거리 연산자 <->
select * from location_2d;
select
	sqrt(power(x1-x2,2) + power(y1-y2,2)) as dist_rms
	-- PostgreSQL의 POINT 자료형(좌표를 다루는 자료 구조)으로 변환 후, 거리연산자 <-> 사용 => 유클리드 거리와 동일
	, point(x1,y1) <-> point(x2,y2) as dist_point
from location_2d;

-- # 날짜/시간 계산 ########################
--  timestamp, date로 미래/과거의 날짜/시간 계산
-- PostgreSQL은 interval 자료형의 데이터에 사칙연산 적용하면 됨
select * from mst_users_with_dates;
select
	user_id
	-- timestamp
	, register_stamp::timestamp as register_stamp
	, register_stamp::timestamp + '1 hour'::interval as after_1_hour
	, register_stamp::timestamp - '30 minutes'::interval as befroe_30_minutes
	-- date
	, register_stamp::date as register_date
	, (register_stamp::date + '1 day'::interval)::date as after_1_day
	, (register_stamp::date - '1 month'::interval)::date as before_1_month
from mst_users_with_dates;

-- 날짜간 차이 계산: PostgreSQL은 날짜 자료형끼리 뺄 수 있음
select
	user_id
	, current_date as today
	, register_stamp::date as register_date
	, current_date - register_stamp::date as diff_days  -- 날짜 자료형(date)으로 변환해줘야 계산 가능
from mst_users_with_dates;

-- 나이 계산(현재날짜, 사용자 생년월일)
-- 1. PostgreSQL의 날짜 자료형에 사용하는 age 함수 사용 (윤년 등도 고려)
select
	user_id
	, current_date as today
	, register_stamp::date as register_date
	, birth_date::date as birth_date
	-- 현재 날짜 기준 나이 (age함수의 기본값)
	, EXTRACT(YEAR from age(birth_date::date)) as current_age
	, EXTRACT(YEAR from age(register_stamp::date, birth_date::date)) as register_age
	-- 한국 나이: 연도만 추출하고 현재 연도에서 빼고, 1 더하면됨
	, EXTRACT(YEAR from current_date) - EXTRACT(YEAR from birth_date::date) as korea_age
from mst_users_with_dates;

-- 2. 함수 사용 안하고 날짜를 정수로 표현해, 나이 계산: 날짜 뺀 후, 10000으로 나누면 됨
select floor((20160228-20000229)/10000) as age;   

-- 3. 문자열로 계산
select
	user_id
	, substring(register_stamp,1,10) as register_date
	, birth_date
	-- 등록 시점의 나이 계산
	, floor(
		(CAST(replace(substring(register_stamp, 1, 10), '-', '') as integer)
		- CAST(replace(birth_date, '-','')as integer)
		) / 10000
	) as register_age
	-- 현재 시점의 나이 계산
	, floor(
		(CAST(replace(CAST(current_date AS text), '-', '') as integer)
		- CAST(replace(birth_date, '-', '') as integer)
		) / 10000
	) as current_age
from mst_users_with_dates;

-- # IP 주소 다루기 ###################################
-- PostgreSQL에는 IP 주소를 쉽게 다루기 위한, inet 자료형 존재  (대소 비교시 < or > 사용)
select
	CAST('127.0.0.1' as inet) < CAST('127.0.0.2' as inet) as lt
	,CAST('127.0.0.1' as inet) > CAST('192.168.0.1' as inet) as gt
;

-- address/y 형식의 네트워크 범위에 "특정 IP 주소가 포함되는지 판정": << or >> 연산자 사용
select CAST('127.0.0.1' AS inet) << CAST('127.0.0.0/8' AS inet) AS is_contained; -- 이게 << 여기에 들어있나

-- IP 주소에 있는 4개의 10진수 부분(점으로 구분된 각각의 값)을 정수 자료형으로 추출/분해
select
	ip
	, CAST(split_part(ip, '.', 1)AS integer) AS ip_part_1
	, CAST(split_part(ip, '.', 2)AS integer) AS ip_part_2
	, CAST(split_part(ip, '.', 3)AS integer) AS ip_part_3
	, CAST(split_part(ip, '.', 4)AS integer) AS ip_part_4 
from
	(select CAST('192.168.0.1' AS text)AS ip) AS t
;
-- 분해 추출한 각각의 IP 주소에 "* 2^00" 해준 후, 대소 비교 or 범위 판정 가능
select
	ip
	, CAST(split_part(ip, '.', 1)AS integer) * 2^24
	+ CAST(split_part(ip, '.', 2)AS integer) * 2^16
	+ CAST(split_part(ip, '.', 3)AS integer) * 2^8
	+ CAST(split_part(ip, '.', 4)AS integer) * 2^0
	AS ip_integer
from
	(select CAST('192.168.0.1' AS text)AS ip) AS t
;

-- IP 주소를 0으로 메워서 각 10진수 부분을 3자리의 '고정길이 문자열'로 만들기 -> 만든 후, 문자열 합치기 => 대소 비교 가능해짐
-- lpad 함수: 고정길이 문자열 -> 지정한 문자 수가 되게 문자열의 왼쪽을 메우는 함수
SELECT
	ip
	, lpad(split_part(ip,'.',1), 3, '0')   -- 3자리가 되게 0으로 메워라
	|| lpad(split_part(ip,'.',2), 3, '0')
	|| lpad(split_part(ip,'.',3), 3, '0')
	|| lpad(split_part(ip,'.',4), 3, '0')
	AS ip_padding
FROM
	(SELECT CAST('192.168.0.1' AS text) AS ip) AS t
;







