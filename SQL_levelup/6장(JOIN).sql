-- JOIN 종류
-- CROSS JOIN, INNER JOIN, OUTER JOIN
-- SELF JOIN, 등가(=)/비등가(= 이외 부등호) 결합, NETURAL JOIN(inner + 등가 join <- 이거 쓸바엔 inner join에 조건명시 형태로 씀)

-- 1. CROSS JOIN
-- 실무에서 사용 거의 안함. 가능한 모든 조합으로 결합(M*N개의 레코드수가 만들어짐, 데카르트 곱)
-- EX. 사원과 소속 부서를 관리하는 TABLE JOIN
SELECT * 
FROM Employees2
		CROSS JOIN
	Departments;

-- 2. INNER JOIN
-- 가장 많이 사용되는 JOIN. 결합 KEY 지정
-- EX. 사원과 소속 부서를 관리하는 TABLE JOIN
SELECT E.emp_id, E.emp_name, E.dept_id, D.dept_name
FROM Employees2 E INNER JOIN Departments D
					ON E.dept_id = D.dept_id;

-- 상관 서브쿼리로 구현 가능 (but, 비용이 높아, 결합 알고리즘 inner join 사용하는 게 좋음)
SELECT E.emp_id, 
		E.emp_name, 
		E.dept_id,
		(SELECT D.dept_name
		FROM Departments D
		WHERE E.dept_id = D.dept_id) AS dept_name
FROM Employees2 E;

-- 3. OUTER JOIN
-- LEFT/RIGHT/(FULL) OUTER JOIN 3가지 종류가 있음. 
-- -- MASTER TABLE을 어디에 적느냐에 따라 LEFT/RIGHT 자유롭게 사용 가능
-- MASTER TABLE에만 존재한ㄴ 키가 있을 때, 결과에서 제거하지 않고 보존함 (키를 모두 가진 레이아웃의 리포트를 만들 때 자주 사용)
-- -- MASTER TABLE의 정보를 모두 보존하고자 NULL을 생성함 (but, CROSS, INNER JOIN은 NULL을 생성하지 않음)
-- EX. 왼쪽 외부 결합(왼쪽이 마스터 테이블)
SELECT E.emp_id, E.emp_name, E.dept_id, D.dept_name
FROM Departments D LEFT OUTER JOIN Employees2 E
					ON D.dept_id = E.dept_id;

-- EX. 오른쪽 외부 결합(오른쪽이 마스터 테이블)
SELECT E.emp_id, E.emp_name, E.dept_id, D.dept_name
FROM Employees2 E RIGHT OUTER JOIN Departments D
					ON D.dept_id = E.dept_id;


-- [참고] SELF JOIN
-- 자기 자신과 결합하는 것으로, 같은 테이블(or view)에 별칭을 붙여 마치 다른 테이블인 것 처럼 다룸
-- 물리적으로는 같은 테이블과 결합하는 것이지만, 논리적으로는 서로 다른 두 개의 테이블을 결합하는 것과 같음
-- CROSS/INNER/OUTER JOIN 모두 사용 가능
-- ex. 숫자 테이블 self join
SELECT D1.digit + (D2.digit*10) AS seq
FROM Digits D1 CROSS JOIN Digits D2
ORDER BY 1;  -- 0~99까지 10*10=100개의 레코드 생성됨

