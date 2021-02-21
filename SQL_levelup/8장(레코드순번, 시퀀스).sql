-- 1. 기본 키가 한 개의 필드일 경우(student_id)
-- -- ex.1 윈도우 함수 사용: ROW_NUMBER
SELECT student_id,
		ROW_NUMBER() OVER(ORDER BY weight) AS seq
FROM Weights;

-- -- ex.2 상관 서브쿼리: 재귀 집합의 요소 한 개씩 증가하는 트릭(MySQL에서는 ROW_NUMBER 지원안됨)
SELECT student_id,
		(SELECT COUNT(*)
		FROM Weights W2
		WHERE W2.student_id <= W1.student_id) AS seq
FROM Weights W1
ORDER BY 2;

-- 2. 기본 키가 여러 개의 필드로 구성되는 경우(class, student_id)
-- -- ex.1 윈도우 함수 사용: ROW_NUMBER
SELECT class,
		student_id,
		ROW_NUMBER() OVER(ORDER BY class, weight) AS seq
FROM Weights2;

-- -- ex.2 상관 서브쿼리: 재귀 집합의 요소 한 개씩 증가하는 트릭(MySQL에서는 ROW_NUMBER 지원안됨)
SELECT class,
		student_id,
		(SELECT COUNT(*)
		FROM Weights2 W2
		WHERE (W2.class, W2.student_id) <= (W1.class, W1.student_id)
		) AS seq
FROM Weights2 W1;

-- 3. 그룹마다(그룹 내부의 레코드에) 순번을 붙이는 경우
-- -- ex.1 윈도우 함수 사용: ROW_NUMBER
SELECT class,
		student_id,
		ROW_NUMBER() OVER(PARTITION BY class
						 ORDER BY weight) AS seq
FROM Weights2;

-- -- ex.2 상관 서브쿼리: 재귀 집합의 요소 한 개씩 증가하는 트릭(MySQL에서는 ROW_NUMBER 지원안됨)
SELECT class,
		student_id,
		(SELECT COUNT(*)
		FROM Weights2 W2
		WHERE W2.class = W1.class
		AND W2.student_id <= W1.student_id) AS seq
FROM Weights2 W1;

-- 4. 검색이 아닌, 갱신(UPDATE)으로 순번 매기는 방법 (순번 필드 채우기/UPDATE)
-- EX.1 윈도우 함수 사용 -> 서브쿼리를 함께 사용해서 넣어줘야함(매칭용인듯?)
UPDATE Weights3
SET seq = (SELECT seq
		  FROM (SELECT class,
			   			student_id,
			   			ROW_NUMBER() OVER(PARTITION BY class ORDER BY weight) AS seq
			   FROM Weights3) SeqTbl
		   WHERE Weights3.class = SeqTbl.class
		  AND Weights3.student_id = SeqTbl.student_id);
-- ex.2 서브 쿼리 사용 -> 그냥 넣어주면됨(이미 매칭 양식? 쓰니까 그냥 넣으면 되는 듯)
UPDATE Weights3
SET seq = (SELECT COUNT(*)
		  FROM Weights3 W2
		  WHERE W2.class = Weights3.class
		  AND W2.student_id <= Weights3.student_id);


-- 레코드 순번 붙이기 활용
-- 1. 중앙값 구하기
-- -- ex. 양쪽 끝에서 레코드 하나씩 세어 중간 찾기
SELECT ROUND(AVG(weight),2) AS median   -- 짝수일 때 평균내야함
FROM (SELECT weight, 
	 		ROW_NUMBER() OVER(ORDER BY weight ASC, student_id ASC) AS hi,
	 		ROW_NUMBER() OVER(ORDER BY weight DESC, student_id DESC) AS lo
	 FROM Weights) TMP
WHERE hi IN(lo, lo+1, lo-1);  -- lo: 홀수인 경우, lo+1, lo-1: 짝수인 경우

-- -- ex. 반환점 활용하기
SELECT ROUND(AVG(weight),2)
FROM (SELECT weight,
	 			2*ROW_NUMBER() OVER(ORDER BY weight) - COUNT(*) OVER() AS diff
	 FROM Weights) TMP
WHERE diff BETWEEN 0 AND 2;

-- 2. 순번 단절 구간 찾기
SELECT num+1 AS gap_start,
		'~',
		(num+diff-1) AS gap_end
FROM (SELECT num,
	 		MAX(num) OVER(ORDER BY num
						 ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING) - num AS diff   -- (다음 num - 현재 num) AS diff
	 FROM Numbers) TMP
WHERE diff != 1;  -- 단절되지 않은 정상 구간은 제외하고 출력


-- 3. 테이블에 존재하는 시퀀스 구하기
-- -- 존재하는 수열을 그룹화
-- -- ex. 인원수에 맞게 자리 예약 (예약 번호 그룹 / 단절 구간 제외한 나머지 끊어서 구한다 생각)
SELECT * 
FROM Numbers;

SELECT MIN(num) AS low,
		'~',
		MAX(num) AS high
FROM(SELECT N1.num,
		COUNT(N2.num) - N1.num AS gp
	FROM Numbers N1 INNER JOIN Numbers N2
	ON N2.num <= N1.num
	GROUP BY N1.num) N
GROUP BY gp;