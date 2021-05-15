/* 177. Nth Highest Salary */
SELECT DISTINCT salary
FROM (SELECT salary,
			DENSE_RANK() OVER(ORDER BY salary DESC) AS rnk
		FROM Employee) A
WHERE rnk = N
;

/* 178. Rank Sores */
SELECT score,
    DENSE_RANK() OVER(ORDER BY score DESC) AS "Rank"
FROM Scores
ORDER BY 2
;

/* 180. Consecutive Numbers */
-- 연속해서 3번 나타난 숫자!
SELECT DISTINCT l1.Num AS ConsecutiveNums
FROM Logs l1, Logs l2, logs l3 
WHERE l1.id = l2.id - 1 
AND l2.id = l3.id - 1 
AND l1.Num = l2.Num
AND l2.Num = l3.Num
;

/* 184. Department Highest Salary */
SELECT Department,
    Employee,
    Salary
FROM (SELECT d.name AS Department,
        e.name AS Employee,
        e.salary AS Salary,
        DENSE_RANK() OVER(PARTITION BY d.id ORDER BY e.salary DESC) AS rnk
    FROM Employee e INNER JOIN Department d ON e.departmentid = d.id
    ) A 
WHERE rnk = 1
;