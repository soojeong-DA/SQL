/*SELECT - Advanced =========*/

/* Type of Triangle */
SELECT CASE
        WHEN (A+B)>C AND A=B AND B=C THEN 'Equilateral'
        WHEN (A+B)>C AND (A=B OR B=C OR A=C) THEN 'Isosceles'  -- 괄호 안의 조건이 하나라도 만족하면
        WHEN (A+B)>C THEN 'Scalene'
        ELSE 'Not A Triangle' END
FROM Triangles;

/* */



