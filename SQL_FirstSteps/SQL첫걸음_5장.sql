SET SQL_SAFE_UPDATES = 0;   # safe모드 해제
/*집계함수
- 집합으로부터 '하나의 값(행)'을 반환함
- COUNT, SUM, AVG, MIN, MAX */

# COUNT: 행 개수 구하기
# (*): null값 포함해서 행 개수 구함.
select * from sample51;
select count(*) from sample51;   
select count(*) from sample51 where name = 'A';

# null 제외한 집계 <- 원래 집계 함수는 null값 제외하고 처리함
select count(no), count(name) from sample51;    # name에만 null 값 있어서, no: 5, name: 4 반환됨

# DISTINCT: 중복 제거    
select name from sample51; # name열에서 'A' 2개
select distinct(name) from sample51;   # 중복된 값 제거된 결과 반환
select distinct name from sample51;    # 괄호에 안넣어도 됨.

select count(distinct name) from sample51;   # COUNT + DISTINCT: 중복제거, NULL 제거

# SUM: 합계
SELECT SUM(quantity) FROM sample51;

# AVG: 평균
SELECT AVG(quantity), SUM(quantity)/COUNT(quantity) FROM sample51;

# AVG에서 CASE문으로 NULL값을 0으로 변환한 뒤, 계산
SELECT AVG(CASE WHEN quantity IS NULL THEN 0 ELSE quantity END) AS "avg_null_0" FROM sample51;

# MIN/MAX : 숫자형, 문자형, 날짜시간형 타입 모두 가능
SELECT MIN(quantity), MAX(quantity), MIN(name), MAX(name) FROM sample51;

/*그룹화
- GROUP BY에서 지정한 열 이외의 열은 집계함수를 사용하지 않을 채 SELECT구에 지정할 수 없다!*/
# GROUP BY
select name from sample51 group by name;    # 중복제거한 것과 같은 결과 나옴 <= 하나의 그룹으로 묶이니까!
select no, quantity from sample51 group by no, quantity;

# 집계함수와 함께 사용해야 의미가 더해짐.
SELECT name, count(name), sum(quantity) FROM sample51 GROUP BY name;
SELECT min(no), name, sum(quantity) from sample51 group by name;

# HAVING: 집계한 결과의/집계함수를 사용한 조건 지정
SELECT name, count(name) FROM sample51 GROUP BY name;
select name, count(name) from sample51 group by name HAVING count(name) = 1;  # 집계함수를 사용할 경우 WHERE절이 아닌, HAVING절에 조건 지정!

# ORDER BY로 그룹화한 결과 정렬
SELECT name, count(name), sum(quantity) FROM sample51 GROUP BY name ORDER BY sum(quantity) desc;


/*서브쿼리*/
# 스칼라 서브쿼리: 단일 값 반환
# WHERE절 스칼라 서브쿼리 활용
select * from sample54;
select * from sample54 where a = (select min(a) from sample54);   # 원 예제는 delete지만, mysql에서는 실행 불가

# SELECT절 스칼라 서브쿼리 활용
select 
	(select count(*) from sample51) as sq1,
    (select count(*) from sample54) as sq2;   # 메인쿼리 from 절 생략됨(MySQL만 가능). Oracle은 from dual 사용해야함.

# UPDATE SET 구에서 스칼라 서브쿼리 활용
UPDATE sample54 SET a = (SELECT MAX(a) FROM sample54);   # 실행안됨. 실제로 잘 쓰이지 않음

# FROM절 서브쿼리 활용
select * from (select * from sample54) sq;
select * from (select * from sample54) as sq;   # Oracle에서는 from절에 as 사용하면 error남
# FROM절 중첩 서브쿼리 사용
SELECT * FROM (SELECT * FROM ( SELECT * FROM sample54) sq1) sq2;   # 3단계 구조

# oracle에서 limit구의 대체 명령 - 서브쿼리 활용해 행 개수 제한
select * from(
	select * from sample54 order by desc
    ) sq
where rownum <= 2;


# INSERT문 서브쿼리 활용
# VALUES구의 일부로 사용 -  서브쿼리의 결과값을 삽입
INSERT INTO sample541 VALUES(
	(select count(*) from sample51),
    (select count(*) from sample54)
);
select * from sample541;

# INSERT SELECT: VALUES구 대신 SELECT 사용
INSERT INTO sample541 SELECT 1,2;  # 1,2값 그냥 삽입됨
select * from sample541;
# 열 구성이 똑같은 테이블 사이에, 행 복사도 가능
select * from sample542;
select * from sample543;
INSERT INTO sample542 SELECT * FROM sample543;

/*상관 서브쿼리*/
SELECT * FROM sample551;
select * from sample552;
# EXISTS 술어 사용
# sample552에 no열의 값과 같은 행이 있으면 '있음'으로 update
update sample551 set a = '있음' where exists (select no2 from sample552 where no2= no);
select * from sample551;

# NOT EXISTS
# 없으면 '없음'으로 update
update sample551 set a = '없음' where not exists (select no2 from sample552 where no2= no);
select * from sample551;

# 테이블명 붙이기: 어느 테이블의 열인지 열명 앞에 테이블명을 붙여야함
UPDATE sample551 SET a = '있음' where
	EXISTS (SELECT * FROM sample552 where sample552.no2 = sample551.no);
select * from sample551;

# IN
select * from sample551 where no IN (3,5);
select * from sample551 where no IN (select no2 from sample552);

# NOT IN
select * from sample551 where no NOT IN (3,5);