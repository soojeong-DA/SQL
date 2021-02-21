-- 집약
-- 집약 함수(표준SQL에서는 5개): COUNT, SUM, AVG, MAX, MIN
-- -- ex1. 여러개의 레코드를 한 개의 레코드로 집약 (한 사람의 정보가 모두 같은 한 레코드에 들어있게)
select * 
from nonaggtbl; -- data type 3가지에 따라 한 사람의 정보가 흩어져 있음 => 한사람 정보 조회할 때마다 3개 쿼리 필요 (비효율적)

SELECT id,
	MAX(CASE WHEN data_type ='A' THEN data_1 ELSE NULL END) AS data_1,
	MAX(CASE WHEN data_type ='A' THEN data_2 ELSE NULL END) AS data_2,
	MAX(CASE WHEN data_type ='B' THEN data_3 ELSE NULL END) AS data_3,
	MAX(CASE WHEN data_type ='B' THEN data_4 ELSE NULL END) AS data_4,
	MAX(CASE WHEN data_type ='B' THEN data_5 ELSE NULL END) AS data_5,
	MAX(CASE WHEN data_type ='C' THEN data_6 ELSE NULL END) AS data_6
FROM nonaggtbl
GROUP BY id;

-- -- ex2. 여러개의 레코드를 한 개의 레코드로 집약 (한 제품의 정보를 모아서 계산)
-- -- 연령 범위가 0 ~100을 아우르는 => hig age - low age +1 =101
SELECT product_id
FROM pricebyage
GROUP BY product_id
HAVING SUM(high_age - low_age + 1) = 101;

-- -- ex3. 여러개의 레코드를 한 개의 레코드로 집약 (숙박한 날이 10일 이상인 방을 선택)
SELECT room_nbr,
	SUM(end_date - start_date) AS working_days
FROM hotelrooms
GROUP BY room_nbr
HAVING SUM(end_date -  start_date) >= 10;


-- 자르기
-- 테이블을 작은 부분 집합들로 분리
-- -- ex. 특정 알파벳으로 시작하는 이름별로 그룹, 각 그룹 사람이 몇 명인지
SELECT SUBSTRING(name,1,1) AS label,
		COUNT(*)
FROM persons
GROUP BY SUBSTRING(name, 1, 1);

-- -- ex. 나이 기준으로 3가지 그룹으로 나누기 (자르기 기준이 되는 키를 GROUP BY, SELECT구 모두에 입력하는 것이 point!)
SELECT CASE WHEN age < 20 THEN '어린이'
			WHEN age BETWEEN 20 AND 69 THEN '성인'
			WHEN age >= 70 THEN '노인'
			ELSE NULL END AS age_class,
		COUNT(*)
FROM persons
GROUP BY CASE WHEN age < 20 THEN '어린이'
			WHEN age BETWEEN 20 AND 69 THEN '성인'
			WHEN age >= 70 THEN '노인'
			ELSE NULL END;
-- -- PostgreSQL, MySQL에서는 별칭(AS)를 GROUP BY에 사용 가능  (표준은 아님)
SELECT CASE WHEN age < 20 THEN '어린이'
			WHEN age BETWEEN 20 AND 69 THEN '성인'
			WHEN age >= 70 THEN '노인'
			ELSE NULL END AS age_class,
		COUNT(*)
FROM persons
GROUP BY age_class;

-- -- ex. 연산을 통해 구한 BMI로 3그룹으로 나누기 (자르기 기준이 되는 키를 GROUP BY, SELECT구 모두에 입력)
-- -- 이렇게 복잡한 수직을 기준으로도 자를 수 있다!!
SELECT CASE WHEN weight / POWER(height/100, 2) < 18.5 THEN '저체중'
			WHEN weight / POWER(height/100, 2) BETWEEN 18.5 AND 24 THEN '정상'
			WHEN weight / POWER(height/100, 2) >= 25 THEN '과체중'
		ELSE NULL END AS bmi,
		COUNT(*)
FROM persons
GROUP BY CASE WHEN weight / POWER(height/100, 2) < 18.5 THEN '저체중'
			WHEN weight / POWER(height/100, 2) BETWEEN 18.5 AND 24 THEN '정상'
			WHEN weight / POWER(height/100, 2) >= 25 THEN '과체중'
		ELSE NULL END;
-- -- PostgreSQL, MySQL에서는 별칭(AS)를 GROUP BY에 사용 가능  (표준은 아님)
SELECT CASE WHEN weight / POWER(height/100, 2) < 18.5 THEN '저체중'
			WHEN weight / POWER(height/100, 2) BETWEEN 18.5 AND 24 THEN '정상'
			WHEN weight / POWER(height/100, 2) >= 25 THEN '과체중'
		ELSE NULL END AS bmi,
		COUNT(*)
FROM persons
GROUP BY bmi;

-- PARTITION BY를 이용해 같은 연령 등급(어린이, 성인, 노인)에 어린 순서로 순위 매기는 코드
SELECT name,
		age,
	CASE WHEN age < 20 THEN '어린이'
		WHEN age BETWEEN 20 AND 69 THEN '성인'
		WHEN age > 70 THEN '노인'
	ELSE NULL END AS age_class,
	RANK() OVER(PARTITION BY CASE WHEN age < 20 THEN '어린이'
			   					WHEN age BETWEEN 20 AND 69 THEN '성인'
			   					WHEN age > 70 THEN '노인'
			   				ELSE NULL END
			   ORDER BY age) AS age_rank_in_class
FROM persons
ORDER BY age_class, age_rank_in_class;