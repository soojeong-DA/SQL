-- view: SELECT 구문을 저장하지만, 내부에 데이터를 보유하지는 않음! (TABLE과 다름)
-- CREATE VIEW [뷰이름] ([필드 이름1],[필드 이름2],..) AS ~~select 구문~~

-- -- ex. 주소별 사람수를 구하는 select 구문 view 생성
CREATE VIEW CountAddress (v_address, cnt)
AS
	SELECT address, COUNT(*)
	FROM Address
	GROUP BY address;

-- -- view 사용
SELECT v_address, cnt
FROM CountAddress;

-- 서브쿼리(subquery): FROM, where, 등의 구에 직접 SELECT 구문을 지정. (괄호) 사용
-- -- ex. 서브쿼리를 사용한 조건 지정 (where 구)
SELECT name
FROM address
WHERE name IN (SELECT name FROM address2);  -- IN은 서브쿼리를 매개변수로 받을 수 있음


-- 조건 분기: CASE 식 
-- 처음에 있는 WHEN 구의 평가식부터 평가됨
-- 식을 적을 수 있는 곳이라면 어디든지 적을 수 있음 ex. SELECT, WHERE, GROUP BY, HAVING, ORDER BY
/*
CASE WHEN [평가식(조건식)] THEN [식]
	WHEN [평가식(조건식)] THEN [식]
	WHEN [평가식(조건식)] THEN [식]
	...
	ELSE [식]
END
*/
-- -- ex. 시도의 이름은 큰 지역으로 구분하는 CASE 식 (교환식)
SELECT name, address,
	CASE WHEN address = '서울시' THEN '경기'
		WHEN address = '인천시' THEN '경기'
		WHEN address = '부산시' THEN '영남'
		WHEN address = '속초시' THEN '관동'
		WHEN address = '서귀포시' THEN '호남'
		ELSE NULL END AS distict
FROM address;

-- UNION 테이블간 합집합 (중복제거 기본)  -> 중복 제외하고 싶지 않으면, ALL 옵션 추가 (UNION ALL)
SELECT *
FROM address
UNION
SELECT *
FROM address2;

select count(*)
from (SELECT *
	FROM address
	UNION
	SELECT *
	FROM address2) as tmp;  -- from 절에 서브쿼리 사용시 아얄라스(AS, 별명) 반듯이 서술해야함
	
-- INTERSECT 교집합 (중복제거 기본)
SELECT * 
FROM ADDRESS
INTERSECT
SELECT *
FROM ADDRESS2;

-- EXCEPT 차집합 (중복제거 기본) <- 어떤 테이블이 먼저 오느냐에 따라 결과가 달라지니 주의!! (교환 법칙이 뺄셈엔 적용되지 않음)
SELECT * 
FROM ADDRESS
EXCEPT
SELECT *
FROM ADDRESS2;

-- 윈도우 함수: GROUP BY 에서 '자르기 기능'만 있고, 집약 기능은 없는 것
-- 집약 함수 뒤에 OVER구 작성, 내부에 '자를 키를 지정하는 PARTITION BY' 또는 ORDER BY를 입력
-- -- PARTITION BY구와 ORDER BY구는 둘중 하나만 입력해도 되고, 둘 다 입력해도됨!
-- -- COUNT, SUM 등의 일반함수 외에 RANK, ROW_NUMBER 등의 순서함수에도 사용가능

-- -- ex. 주소별 사람수를 계산
SELECT address,
		COUNT(*) OVER(PARTITION BY address)    -- 집약되지 않아 테이블의 레코드 수와 같은 9개 레코드 출력됨
FROM address;

-- -- ex. 나이가 많은 순서로 순위 구하기(RANK - 건너뛰기 있음)
SELECT name,
		age,
		RANK() OVER(ORDER BY age DESC) AS rnk
FROM address;
-- -- ex. 나이가 많은 순서로 순위 구하기(DENSE_RANK - 건너뛰기 없음)
SELECT name,
		age,
		DENSE_RANK() OVER(ORDER BY age DESC) AS dense_rnk
FROM address;
-- -- ex. PARTITION BY, ORDER BY 둘다 사용하기
SELECT name,
	sex,
	age,
	RANK() OVER(PARTITION BY sex ORDER BY age DESC) rnk_desc
FROM address;