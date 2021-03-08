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



