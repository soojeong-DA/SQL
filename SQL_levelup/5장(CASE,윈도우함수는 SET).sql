-- SQL에서 반복 표현: "CASE식과 윈도우 함수" (둘이 SET라고 생각!!)
-- ex1. 윈도우 함수를 사용해 직전 년도와의 판매 변화 var에 나타내기
INSERT INTO Sales2
SELECT company,
		year,
		sale,
		-- SIGN 함수! (음수면 -1, 양수면 1, 0은 0을 리턴하는 함수)
		-- 현재 sale - 직전 sale 1개 (1개로 집계해야해서 집계함수 써야하는 듯함)
		CASE SIGN(sale - MAX(sale) OVER (PARTITION BY company
										 ORDER BY year
										 ROWS BETWEEN 1 PRECEDING
								 		 		AND 1 PRECEDING)) -- 대상 범위 레코드를 직전의 1개로 제한 (현재 레코드에서 1개 이전 ~ 1개 이전까지)
		WHEN 0 THEN '='
		WHEN 1 THEN '+'
		WHEN -1 THEN '-'
		ELSE NULL END AS var
FROM Sales;

SELECT * FROM Sales2;  -- 결과 확인

-- ex2. 윈도우 함수로 직전회사명, 직전 매상 검색
SELECT company,
		year,
		sale,
		-- MAX는 단순 집계함수용으로 쓰였을 뿐임
		MAX(company) OVER (PARTITION BY company 
						   ORDER BY year
						  ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS pre_company,
		MAX(sale) OVER (PARTITION BY company
					   ORDER BY year
					   ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS pre_sale
FROM Sales;

-- ex3. 가장 가까운 우편번호 찾기 (결국 순위 매기기 문제) - 최종 순위가 가장 높은(min) 값들 반환
SELECT pcode,
		district_name
FROM PostalCode
WHERE CASE WHEN pcode = '4130033' THEN 0
			WHEN pcode LIKE '413003%' THEN 1
			WHEN pcode LIKE '41300%' THEN 2
			WHEN pcode LIKE '4130%' THEN 3
			WHEN pcode LIKE '413%' THEN 4
			WHEN pcode LIKE '41%' THEN 5
			WHEN pcode LIKE '4%' THEN 6
			ELSE NULL END = 
				(SELECT MIN(CASE WHEN pcode = '4130033' THEN 0
								WHEN pcode LIKE '413003%' THEN 1
								WHEN pcode LIKE '41300%' THEN 2
								WHEN pcode LIKE '4130%' THEN 3
								WHEN pcode LIKE '413%' THEN 4
								WHEN pcode LIKE '41%' THEN 5
								WHEN pcode LIKE '4%' THEN 6
						   		ELSE NULL END)
				FROM PostalCode);

-- 반복 개수가 정해지지 않았을 때
-- 계층구조: 재귀 연산 (Recusive Explosion)
-- ex.1 가장 오래된 주소 검색
WITH RECURSIVE Explosion (name, pcode, new_pcode, depth)
AS
(SELECT name, pcode, new_pcode, 1
FROM PostalHistory
WHERE name = 'A'
AND new_pcode IS NULL -- 검색 시작
UNION
SELECT Child.name, Child.pcode, Child.new_pcode, depth + 1
 FROM Explosion AS Parent, PostalHistory AS Child
 WHERE Parent.pcode = Child.new_pcode
 AND Parent.name = Child.name)
-- main select 구문
SELECT name, pcode, new_pcode
FROM Explosion
WHERE depth = (SELECT MAX(depth)
			  FROM Explosion);

-- 중첩 집합 모델: 각 레코드의 데이터를 집합(원)으로 보고, 계층 구조를 집합의 중첩 관계로 나타내는 것
-- 새로운 우편 번호가 이전의 우편번호 안에 포함되는 형태
-- lft, rgt: 원의 왼쪽 끝과 오른쪽 끝에 위치하는 좌표
-- ex.1 가장 외부에 있는 원 찾기(가장 오래된 우편번호 찾기)
SELECT name, pcode
FROM PostalHistory2 PH1
WHERE name = 'A'
AND NOT EXISTS  -- 가장 바깥쪽에 있는 원은 다른 어떠한 원에도 포함되지 않는 원
	(SELECT *
	FROM PostalHistory2 PH2
	WHERE PH2.name = 'A'
	AND PH1.lft > PH2.lft);
