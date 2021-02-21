SELECT * FROM Address;

-- GROUP BY
SELECT sex, COUNT(*)   -- null 포함
FROM address
GROUP BY sex;

SELECT sex, COUNT(phone_nbr)  -- phone_nbr 컬럼에 있는 null값 제외되서 개수 달라짐!
FROM address
GROUP BY sex;

SELECT address, COUNT(*)
FROM ADDRESS
GROUP BY address;

SELECT COUNT(*)
FROM ADDRESS
GROUP BY ();    -- GROUP BY 키 지정 안하면 '전체'에 대해 함수가 적용됨   (이런 구문은 사용 잘 안됨. 아예 구를 생략해버림)

SELECT COUNT(*)
FROM ADDRESS;   -- 아예 GROUP BY 생략해서 함수 적용 (일반적인 방법)

-- HAVING: '결과 집합'에 대해 또 조건을 걸어 선택하는 기능!
SELECT address, COUNT(*)
FROM address
GROUP BY address
HAVING COUNT(*) = 1;   -- 결과가 한명뿐인 주소 필드만

-- ORDER BY
SELECT name, phone_nbr, address, sex, age
FROM address
ORDER BY  age DESC;

-- view: SELECT 구문을 저장하지만, 내부에 데이터를 보유하지는 않음! (TABLE과 다름)
-- CRE