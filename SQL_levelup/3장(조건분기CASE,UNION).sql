-- 조건분기 CASE vs UNION
-- UNION은 성능, 코드 적으로 낭비가 심함. CASE식으로 조건분기하는 게 훨씬 좋음!
-- CASE식: "조건분기를 WHERE구로 하는 사람들은 초보자다. 잘하는 사람은 *SELECT 구*만으로 조건분기를 한다"

-- -- UNION 조건분기: 코드가 길어지고, 테이블 2번 조회해야해서 성능도 비효율적임
SELECT item_name, year, price_tax_ex AS price
FROM items
WHERE year <= 2001
UNION ALL
SELECT item_name, year, price_tax_in AS price
FROM items
WHERE year >=2002;

-- -- CASE 조건분기
SELECT item_name, year,
	CASE WHEN year <=2001 THEN price_tax_ex
		WHEN year >=2002 THEN price_tax_in
	END AS price
FROM items;

-- -- 집약에 조건분기 적용 - "HAVING구에서 조건분기를 하는 사람은 초보자!"
-- -- ex. 표측/표두 레이아웃 이동 문제 (CASE식을 '집약함수 내부'에 포함시켜서 필터를 만드는 것)
SELECT prefecture,
	SUM(CASE WHEN sex='1' THEN pop ELSE 0  END) AS pop_men,
	SUM(CASE WHEN sex='2' THEN pop ELSE 0 END) AS pop_wom
FROM population
GROUP BY prefecture;
-- -- ex. '집약 결과'에 조건 분기 (조건 분기가 레코드값이 아닌, 집합의 '레코드 수'에 적용)
-- -- COUNT, SUM 등의 집약 함수 결과에 CASE식 적용 가능 (CASE식의 매개변수에 집약함수 넣을 수 있음)
SELECT emp_name,
	CASE WHEN COUNT(*)=1 THEN MAX(team)  -- 그냥 team 출력시 오류남. 아무거로 집약해서 출력해야함
		WHEN COUNT(*)=2 THEN '2개를 겸무'
		WHEN COUNT(*)>=3 THEN '3개 이상을 겸무'
	END AS team
FROM employees
GROUP BY emp_name;

-- 예외 상황
-- UNION을 사용할 수 밖에 없는 경우: '다른 테이블의 결과를 merge'하는 경우
SELECT col_1
FROM Table_A
UNION ALL
SELECT col_3
FROM Table_B
WHERE col_4='B';

-- UNION을 사용하는 것이 성능적으로 더 좋은 경우
-- -- UNION
SELECT key, name,
	date_1, flg_1,
	date_2, flg_2,
	date_3, flg_3
FROM ThreeElements
WHERE date_1='2013-11-01'
AND flg_1 ='T'
UNION
SELECT key, name,
	date_1, flg_1,
	date_2, flg_2,
	date_3, flg_3
FROM ThreeElements
WHERE date_2='2013-11-01'
AND flg_2 ='T'
UNION
SELECT key, name,
	date_1, flg_1,
	date_2, flg_2,
	date_3, flg_3
FROM ThreeElements
WHERE date_3='2013-11-01'
AND flg_3 ='T';
-- -- OR 사용
SELECT key, name,
	date_1, flg_1,
	date_2, flg_2,
	date_3, flg_3
FROM ThreeElements
WHERE (date_1='2013-11-01' AND flg_1='T')
OR (date_2='2013-11-01' AND flg_2='T')
OR (date_3='2013-11-01' AND flg_3='T');
-- -- IN 사용
SELECT key, name,
	date_1, flg_1,
	date_2, flg_2,
	date_3, flg_3
FROM ThreeElements
WHERE ('2013-11-01', 'T')
		IN ((date_1, flg_1),
		   (date_2, flg_2),
		   (date_3, flg_3));
-- -- CASE 식 사용
SELECT key, name,
	date_1, flg_1,
	date_2, flg_2,
	date_3, flg_3
FROM ThreeElements
WHERE CASE WHEN date_1 = '2013-11-01' THEN flg_1
			WHEN date_2 = '2013-11-01' THEN flg_2
			WHEN date_3 = '2013-11-01' THEN flg_3
	ELSE NULL END = 'T';
