# ORDER BY 정렬
select * from sample31;
select * from sample31 order by age;   # ASC
select * from sample31 order by age desc;   # DESC
select * from sample31 order by address;   # ASC

# 문자형, 숫자형 정렬 다름
# a열: 문자형, b: 숫자형
select * from sample311;
desc sample311;
## 둘이 정렬 결과 다름: 문자형 - 1 < 10 < 2, 숫자형 - 1 < 2 < 10
select * from sample311 order by a;
select * from sample311 order by b;

# 복수열 정렬
select * from sample32;  # 두 열 모두 integer형
select * from sample32 order by a, b;
select * from sample32 order by b,a;
select * from sample32 order by a, b desc;   # 아래 코드와 같은 결과
select * from sample32 order by a asc, b desc;

# LIMIT: 결과 행수 제한 (표준 SQL 아님. mysql, postgresql에서만 사용가능) !
## 가장 마지막에 옴. LIMIT 행수 [OFFSET 시작행]
## 행수 = 최대행수 => 3으로 지정해도, 데이터 전체 1건이면 1건만 반환
select * from sample33;
select * from sample33 limit 3;
## 정렬한 후 행수 제한하기 -> 가장 마지막으로 실행되기 때문에 가능한 것!
select * from sample33 order by no desc limit 3;
## LIMIT 행수 OFFSET 시작행 => (시작할 행 - 1)로 이해해야함
SELECT * FROM sample33 LIMIT 3 OFFSET 0;    # 1번째 행부터 = 1 - 1 = 0
SELECT * FROM sample33 LIMIT 3 OFFSET 3;    # 4번재 행부터


# 연산자 - 연산
## SELECT절 연산
SELECT * FROM sample34;
SELECT *, price*quantity FROM sample34;  # 모든 열, 계산된 열
select *, price*quantity as amount from sample34;    # AS: 별명 지정. 생략가능

## WHERE절 연산  -> 연산된 결과로 행 제한   # 별명 사용 불가 (select절보다 먼저 실행되기때문)
SELECT *, price*quantity amount FROM sample34
WHERE price*quantity >= 2000;

## ORDER BY절 연산 -> 연산된 순서로 정렬  # 별명 사용 가능 (가장 마지막에 실행되기때문)
select *, price*quantity amount from sample34 order by price*quantity desc;
select *, price*quantity amount from sample34 order by amount desc;

# 함수 - 연산
select 10 % 3 from dual;
select mod(10,3) from dual;

## ROUND(열, 반올림할 자릿수 = defalt 0)  반올림
SELECT * FROM sample341;
select amount, round(amount) from sample341;   # 자릿수 생략하면, 기본값 0 -> 정수됨
select amount, round(amount, 1) from sample341;
select amount, round(amount, -2) from sample341;  # 음수: 정수부 반올림  # -2: 10의 자리에서 반올림

## truncate: 버림
select amount, truncate(amount, 0) from sample341;  # 버림해줌

/*문자열 연산*/
# 문자열 결험: CONCAT, ||, +   => MySQL은 CONCAT만 가능
select * from sample35;
select no, price, concat(quantity, unit) cnt from sample35;

# SUBSTRING 문자열 추출
select substring('20200912',1,4) from dual;  # 년
select substring('20200912',5,2) from dual;  # 월

# TRIM 앞뒤 공백 제거, 인수 지정시 해당 문자 제거 가능
select trim('  abc  ') from dual;

# CHARACTER_LENGTH = CHAR_LENGTH 문자열 길이
SELECT char_length('가나아라아') from dual;   # 5

# OCTET_LENGTH 문자열 바이트 단위
SELECT octet_length('가나아라아');  # 15 - 1단어 3바이트(UTF-8)

/*날짜 연산*/
# CURRENT_TIMESTAMP: 현재 시스템 날짜/시간 조회. 인수 필요 없음
select current_timestamp();

# 날짜 +,- 연산
select current_date() + 1 day;	# 20200913
select current_date() + interval 1 day;  # 2020-09-13
select current_date() - 3 day; # 20200909

# DATEFIFF 날짜간의 차이(뺄쎔)
SELECT datediff('2020-09-12','2020-04-28');  # 137일

/*CASE문 - select, order by, where 등 모든 구에 사용 가능*/
# CASE WHER 조건식1 THEN 반환값 ... [ELSE 반환값] END
# ELSE 생략하면, 해당부분은 NULL 반환

# NULL값을 0으로 변환하는 CASE식
select a from sample37;
select a, case when a is null then 0 else a end "a(null=0)" from sample37;

# COALESCE로 NULL값 간단 변환 (표준 SQL임. VAL과 같은 역할)
SELECT a, coalesce(a,0) FROM sample37;

# 디코드: 숫자를 문자화하는 것. ex. 1 -> 남자, 2 -> 여자
## 검색 CASE문
SELECT a AS "코드",
CASE
	WHEN a=1 THEN '남자'
    WHEN a=2 THEN '여자'
	ELSE '미지정'
END AS "성별" FROM sample37;

## 단순 CASE문
SELECT a AS "코드",
CASE a                     # a 지정 후, 조건식 진행 => a=1 -> 1만 기술해도됨
	WHEN 1 THEN '남자'
    WHEN 2 THEN '여자'
    ELSE '미지정'
END AS "성별" FROM sample37;












