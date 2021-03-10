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

/* Interviews */
SELECT A.contest_id, 
    A.hacker_id, 
    A.name, 
    SUM(E.total_submissions), 
    SUM(E.total_accepted_submissions), 
    SUM(D.total_views), 
    SUM(D.total_unique_views)
FROM Contests A INNER JOIN Colleges B ON A.contest_id = B.contest_id
                 INNER JOIN Challenges C ON B.college_id = C.college_id
                 -- View_Stats, Submission_Stats Table을 그대로 join하면, college의 challenge가 2번이상 개최된 경우, 중복값이 무더기로 생기는 문제 발생함
                 -- 따라서 group by를 통해 수치들을 먼저 집약한 다음 join 해줘야함
                 LEFT JOIN (SELECT challenge_id,
                                SUM(total_views) AS total_views,
                                SUM(total_unique_views) AS total_unique_views
                            FROM View_Stats
                           GROUP BY 1) D 
                 ON C.challenge_id = D.challenge_id
                 LEFT JOIN (SELECT challenge_id,
                                SUM(total_submissions) AS total_submissions,
                                SUM(total_accepted_submissions) AS total_accepted_submissions
                            FROM Submission_Stats
                           GROUP BY 1) E 
                 ON C.challenge_id = E.challenge_id
GROUP BY 1,2,3
HAVING SUM(E.total_submissions) + SUM(E.total_accepted_submissions) + 
    SUM(D.total_views) + SUM(D.total_unique_views) != 0
ORDER BY 1;
