/* 1. 우유와 요거트가 담긴 장바구니 */
SELECT DISTINCT(A.cart_id)
FROM CART_PRODUCTS A JOIN CART_PRODUCTS B ON A.cart_id = B.cart_id
WHERE A.name = 'Milk'
AND B.name = 'Yogurt'
ORDER BY 1
;

/* 2. 보호소에서 중성화한 동물 */
SELECT i.animal_id,
    i.animal_type,
    i.name
FROM ANIMAL_INS i INNER JOIN ANIMAL_OUTS o ON i.animal_id = o.animal_id
WHERE i.sex_upon_intake LIKE '%Intact%'
AND o.sex_upon_outcome REGEXP ('Spayed|Neutered')
ORDER BY 1
;

/* 3. 입양 시각 구하기(2) */
-- recursive 재귀 쿼리 활용!!
WITH recursive hour_list AS (
    SELECT 0 AS hour
    UNION ALL
    SELECT hour + 1
    FROM hour_list
    WHERE hour < 23  -- 22 + 1 = 23
)
SELECT hour,
    COUNT(animal_id) AS count
FROM hour_list LEFT JOIN animal_outs ON hour = date_format(datetime, '%H')
GROUP BY hour
ORDER BY hour
;