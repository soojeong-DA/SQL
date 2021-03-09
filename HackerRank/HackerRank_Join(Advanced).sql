/* Advanced Join =============*/

/* SQL Project Planning */
SELECT start_date, MIN(end_date)
FROM -- CROSS JOIN
    (SELECT start_date 
      FROM Projects 
      WHERE start_date NOT IN (SELECT end_date FROM Projects)) A,
      (SELECT end_date 
      FROM Projects 
      WHERE end_date NOT IN (SELECT start_date FROM Projects)) B
WHERE start_date < end_date -- CROSS JOIN 특성상, 이 조건이 있어야 옳바른 MIN(end date) 추출 가능
GROUP BY start_date
ORDER BY DATEDIFF(MIN(end_date), start_date), start_date;

/* Placements */
SELECT name
FROM Students A INNER JOIN Friends B ON A.id = B.id
                INNER JOIN Packages C ON A.id = C.id
                INNER JOIN Packages D ON B.friend_id = D.id
WHERE C.salary < D.salary  -- 본인, 친구 각각의 salary
ORDER BY D.salary;

/* Symmetric Pairs */
-- 주의: 현재의 x값이 다음의 y값에 있는 것을 확인하는 문제가 아니라, y값들중에 있기만 하면 되는 문제
SELECT A.x, A.y
FROM Functions A INNER JOIN Functions B ON A.x = B.y AND A.y = B.x   -- inner join을 통해 null(x or y값이 y or x 열에 없는 것) 제외
GROUP BY A.x, A.y
HAVING COUNT(*) >= 2 OR A.x < A.y  -- 2개 이상, x가 y보다 작아야함
ORDER BY A.x;

