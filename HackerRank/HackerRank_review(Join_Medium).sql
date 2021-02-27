/*Basic JOIN - mediu ====*/

/* The Report */
SELECT CASE
            WHEN grade < 8 THEN NULL ELSE name 
        END AS name, 
        grade, 
        marks
FROM Students A LEFT JOIN Grades B 
                ON A.marks BETWEEN B.Min_Mark AND B.Max_Mark
ORDER BY grade DESC, name, marks;


/* TOP Competitors */
SELECT H.hacker_id,
        H.name
FROM Submissions S 
        INNER JOIN Hackers H ON S.hacker_id = H.hacker_id
        INNER JOIN Challenges C ON S.challenge_id = C.challenge_id
        INNER JOIN Difficulty D ON C.difficulty_level = D.difficulty_level
WHERE S.score = D.score
GROUP BY 1,2
HAVING COUNT(H.hacker_id) > 1 -- more than one => 1 포함 x
ORDER BY COUNT(H.hacker_id) DESC, H.hacker_id;

/* Ollivander's Inventory */
SELECT
    T.id,
    T.age,
    T.coins_needed,
    T.power
FROM (
        SELECT
            RANK() OVER(PARTITION BY B.age, A.power order by A.coins_needed) RNK,  -- 동일 순위 고려
            A.id,
            B.age,
            A.coins_needed,
            A.power
        FROM Wands A INNER JOIN Wands_Property B ON A.code = B.code
        WHERE B.is_evil = 0
     ) T
WHERE T.RNK = 1
ORDER BY power DESC, age DESC;

/* Challenges -> Oracle 사용 */
-- with절
WITH Base
AS
(
SELECT A.hacker_id as id, A.name as name, COUNT(B.hacker_id) as cnt
FROM Hackers A INNER JOIN Challenges B on A.hacker_id = B.hacker_id
GROUP BY A.hacker_id, A.name
)
-- 결과 쿼리
SELECT id, name, cnt
FROM Base
WHERE
    -- max 값일 때
    cnt = (SELECT MAX(cnt) 
           FROM Base) 
OR
    -- cnt 수가 중복된 값이 없을 때
    cnt in (SELECT cnt 
            FROM Base
            GROUP BY cnt
            HAVING count(*) = 1 )
ORDER BY cnt DESC, id;


/* Contest Leaderboard */
SELECT T.hacker_id,
        T.name,
        SUM(T.m_score) AS total_score
	-- MAX SOCRE 찾기
FROM (SELECT A.hacker_id,
        B.challenge_id,
        A.name,
        MAX(B.score) AS m_score
    FROM Hackers A INNER JOIN Submissions B ON A.hacker_id = B.hacker_id
    GROUP BY 1,2,3) T
GROUP BY 1,2
HAVING total_score != 0 -- 총합이 0인 것 제외
ORDER BY 3 DESC, 1;

