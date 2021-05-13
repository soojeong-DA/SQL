/* 1. 없어진 기록 찾기 */
SELECT animal_id,
    name
FROM ANIMAL_OUTS 
WHERE animal_id NOT IN (SELECT animal_id FROM ANIMAL_INS)
ORDER BY animal_id
;

/* 2. 있었는데요 없었습니다 */
SELECT i.animal_id,
    i.name
FROM ANIMAL_INS i INNER JOIN ANIMAL_OUTS o ON i.animal_id = o.animal_id
WHERE i.datetime > o.datetime
ORDER BY i.datetime ASC
;

/* 3. 오랜 기간 보호한 동물(1) */
SELECT name,
    datetime
FROM ANIMAL_INS
WHERE animal_id NOT IN (SELECT animal_id FROM ANIMAL_OUTS)
ORDER BY datetime ASC
LIMIT 3
;

/* 4. 오랜 기간 보호한 동물(2) */
SELECT i.animal_id,
    i.name
FROM ANIMAL_INS i INNER JOIN ANIMAL_OUTS o ON i.animal_id = o.animal_id
ORDER BY DATEDIFF(o.datetime, i.datetime) DESC   -- (o.datetime - i.datetime) DESC
LIMIT 2
;

/* 5. 해비 유저가 소유한 장소 */
SELECT *
FROM PLACES
WHERE host_id IN (SELECT host_id
                 FROM PLACES
                 GROUP BY host_id
                 HAVING COUNT(id) >= 2)
ORDER BY id
;
