/*Basic JOIN - medium*/

-- The Report
SELECT CASE
            WHEN grade < 8 THEN NULL ELSE name 
        END AS name, 
        grade, 
        marks
FROM Students A LEFT JOIN Grades B 
                ON A.marks BETWEEN B.Min_Mark AND B.Max_Mark
ORDER BY grade DESC, name, marks;


-- TOP Competitors
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