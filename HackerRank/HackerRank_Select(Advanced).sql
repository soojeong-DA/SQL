/*SELECT - Advanced =========*/

/* Type of Triangle */
SELECT CASE
        WHEN (A+B)>C AND A=B AND B=C THEN 'Equilateral'
        WHEN (A+B)>C AND (A=B OR B=C OR A=C) THEN 'Isosceles'  -- 괄호 안의 조건이 하나라도 만족하면
        WHEN (A+B)>C THEN 'Scalene'
        ELSE 'Not A Triangle' END
FROM Triangles;

/* The PADS */
-- Query 1
SELECT CONCAT(name,'(', SUBSTR(occupation,1,1), ')') 
FROM OCCUPATIONS
ORDER BY 1;

-- Query 2
SELECT CONCAT("There are a total of ", COUNT(*)," ", LOWER(occupation),"s.")
FROM OCCUPATIONS
GROUP BY occupation
ORDER BY COUNT(*), occupation;

/* Occupations */
-- occupation별 ROWNUM(행번호)를 생성해서, 나중에 GROUP BY해주면, 행별 X occupation별로 나오게 할 수 있음!!
SET @r1=0, @r2=0, @r3=0, @r4=0; -- 초기화

SELECT MAX(Doctor), MAX(Professor), MAX(Singer), MAX(Actor)  -- MIN/MAX 둘중 아무거나 해도됨
FROM (SELECT 
		-- rownum
        CASE 
            WHEN occupation = 'Doctor' THEN (@r1:=@r1+1)
            WHEN occupation = 'Professor' THEN (@r2:=@r2+1)
            WHEN occupation = 'Singer' THEN (@r3:=@r3+1)
            WHEN occupation = 'Actor' THEN (@r4:=@r4+1) 
        END AS rownum,
        -- 각 occupation에 해당하는 name 출력
        CASE WHEN occupation = 'Doctor' THEN name END AS Doctor,
        CASE WHEN occupation = 'Professor' THEN name END AS Professor,
        CASE WHEN occupation = 'Singer' THEN name END AS Singer,
        CASE WHEN occupation = 'Actor' THEN name END AS Actor
    FROM OCCUPATIONS
    ORDER BY name) TEMP   -- name 순으로 행번호 붙게하기 위함
GROUP BY rownum;  -- 행별로 집계




