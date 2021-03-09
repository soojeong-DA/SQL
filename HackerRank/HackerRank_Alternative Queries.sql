/* Alternative Queries ============*/

/* Draw The Triangle 1 */
-- '*' 20개 -> 1개까지 출력
SET @n=21;
SELECT REPEAT('* ', @n:=@n-1) 
FROM information_schema.tables;

/* Draw The Triangle 2 */
-- '*'1개 -> 20개까지 출력
SET @n=0;
SELECT REPEAT('* ', @n:=@n+1) 
FROM information_schema.tables
WHERE @n < 20;  -- 종료 조건


