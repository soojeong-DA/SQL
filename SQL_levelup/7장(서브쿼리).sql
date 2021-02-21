-- 서브쿼리가 유용한 경우와 유용하지 않은 경우가 있음
-- 서브쿼리에 접근할 때 마다 구문실행, 데이터 i/o 비용(메모리), 최적화 불가 문제가 있음
-- "해당 내용이 정말 서브쿼리를 사용하지 않으면 구현할 수 없는 것인지"를 항상 생각해야함!!!

-- ex.1 유용하지 않은 경우 (고객별 가장 오래된 구입 이력 찾기 - 최소 순번(seq))
-- 서브쿼리 ver. - table 접근/스캔 2회 발생
SELECT R1.cust_id, R1.seq, R1.price
FROM Receipts R1
		INNER JOIN 
			(SELECT cust_id, MIN(seq) AS min_seq
			FROM Receipts
			GROUP BY cust_id) R2
		ON R1.cust_id = R2.cust_id
		AND R1.seq = R2.min_seq; 
		
-- 상관 서브쿼리 ver. - table 접근/스캔 2회 발생
SELECT cust_id, seq, price
FROM Receipts R1
WHERE seq = (SELECT MIN(seq)
			FROM Receipts R2
			WHERE R1.cust_id = R2.cust_id);

-- 윈도우 함수 이용 ver. - table 접근 1회로 줄어듬(정렬 발생하지만, 다른 쿼리에 min있어서 그게 그거이니 상관 놉)
SELECT cust_id, seq, price
FROM (SELECT cust_id, seq, price, ROW_NUMBER() OVER(PARTITION BY cust_id
												   ORDER BY seq) AS row_seq
	 FROM Receipts) WORK
WHERE row_seq = 1;  -- WHERE WORK.row_seq = 1;  WORK. 생략 가능!

SELECT cust_id, seq, price
FROM (SELECT cust_id, 
	  			seq, 
	  			price,
	 			RANK() OVER(PARTITION BY cust_id
								 ORDER BY seq) AS row_seq
	 FROM Receipts) WORK
WHERE row_seq = 1;

-- EX.2 cust_id별 순번diff(최댓값-최솟값) 구하기
SELECT cust_id,
		SUM(CASE WHEN min_seq = 1 THEN price ELSE 0 END)
		- SUM(CASE WHEN max_seq = 1 THEN price ELSE 0 END) AS diff
FROM (SELECT cust_id, 
	  		price,
	 		ROW_NUMBER() OVER(PARTITION BY cust_id
							 ORDER BY seq) AS min_seq,
	 		ROW_NUMBER() OVER(PARTITION BY cust_id
							 ORDER BY seq DESC) AS max_seq
	 FROM Receipts) WORK
WHERE min_seq = 1   -- 불필요한 RECODE(행) 제거
OR max_seq = 1
GROUP BY cust_id; -- MIN/MAX에 해당하는 price가 각각 다른 행에 있어서, 집약 필요!!
							 
-- 서브쿼리가 더 나은 경우: 결합(JOIN) 상황
-- "JOIN 전에 결합 레코드 대상 수를 압축/줄인다" (집약 후 JOIN 수행)
-- EX. 회사별 주요 사업소의 직원 수 합
-- -- 1. 결합 -> 집약
SELECT C.co_cd, 
		C.district,
		SUM(S.emp_nbr) AS sum_emp
FROM Companies C
		INNER JOIN
			Shops2 S
		ON C.co_cd = S.co_cd
WHERE main_flg = 'Y'
GROUP BY C.co_cd;

-- -- 2. 집약 -> 결합
SELECT C.co_cd,
		C.district,
		CSUM.sum_emp
FROM Companies C
		INNER JOIN
			(SELECT co_cd, SUM(emp_nbr) AS sum_emp
			FROM Shops2
			 WHERE main_flg = 'Y'
			GROUP BY co_cd) CSUM 
		ON C.co_cd = CSUM.co_cd;
				


