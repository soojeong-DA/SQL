/* 17. 오픈 데이터를 활용해 서비스와 결합해보기 
- 외부 데이터 읽어 들이는 방법, 데이터 가공하는 방법을 알아보자! */

/* 17-1. IP주소를 기반으로 국가와 지역 보완 
'https://dev.maxmind.com/geoip/geoip2/geolite2/'에서 오픈 데이터 다운 (라이센스 필요) =======================================*/

-- 1. GeoLite2의 CSV 데이터 로드
-- 1-1. table 생성 (데이터 넣을 뼈대 생성)
DROP TABLE IF EXISTS mst_city_ip;
CREATE TABLE mst_city_ip(
	network 						inet PRIMARY KEY,
	geoname_id 						integer,
	registered_country_geoname_id 	integer,
	represented_country_geoname_id 	integer,
	is_anonymous_proxy 				boolean,
	is_satellite_provider 			boolean,
	postal_code 					varchar(255),
	latitude 						numeric,
	longitude 						numeric,
	accuracy_radius 				integer
);

DROP TABLE IF EXISTS mst_locations;
CREATE TABLE mst_locations(
	geoname_id 						integer PRIMARY KEY,
	locale_code						varchar(255),
	continent_code					varchar(10),
	continent_name					varchar(255),
	country_iso_code				varchar(10),
	country_name					varchar(255),
	subdivision_1_iso_code			varchar(10),
	subdivision_1_name				varchar(255),
	subdivision_2_iso_code			varchar(10),
	subdivision_2_name				varchar(255),
	city_name						varchar(255),
	metro_code						integer,
	time_zone						varchar(255),
	is_in_european_union			boolean
);

-- 1-2. SQL Shell(psql)에서 \copy 사용
-- \copy [스키마.테이블명] from [파일 경로] delimiter [구분자]

-- \COPY mst_city_ip FROM 'path(절대경로)\GeoLite2-City-Blocks-IPv4.csv' DELIMITER ',' CSV HEADER;
-- \COPY mst_locations FROM 'path(절대경로)\GeoLite2-City-Locations-en.csv' DELIMITER ',' CSV HEADER;  -- ''\encoding UTF8'로 인코딩 필요

-- -- 확인해보기
SELECT * FROM mst_city_ip;
SELECT COUNT(*) FROM mst_city_ip;

SELECT * FROM mst_locations;
SELECT COUNT(*) FROM mst_locations;

-- 2. 액션 로그의 ip 주소로 국가와 지역 정보 추출
SELECT a.ip,
	l.continent_name,
	l.country_name,
	l.city_name,
	l.time_zone
FROM action_log_with_ip a LEFT JOIN mst_city_ip i ON a.ip::inet << i.network
					LEFT JOIN mst_locations l ON i.geoname_id = l.geoname_id
;

/* 17-2. 주말과 공휴일 판정 ========================================================================= */

-- 주말, 공휴일 판정
SELECT a.action,
	a.stamp,
	c.dow,
	c.holiday_name,
	EXTRACT(DOW FROM a.stamp::date) IN (0,6) -- 토, 일요일 판정
	OR c.holiday_name IS NOT NULL -- 공휴일 판정
	AS is_day_off
FROM access_log a INNER JOIN mst_calender c 
					ON CAST(substring(a.stamp, 1, 4) AS int) = c.year
					AND CAST(substring(a.stamp, 6, 2) AS int) = c.month
					AND CAST(substring(a.stamp, 9, 2) AS int) = c.day
;	



