# 테이블 실행(조회)
SELECT * FROM sample21;
SELECT * 
FROM sample21;

# 테이블 구조 참조(조회)
DESC sample21;

# 열 지정
SELECT no, name FROM sample21;
## 중복가능
SELECT no, no, name FROM sample21;

# 행 조건: WHERE
select * from sample21 where no != 2;
select * from sample21 where name = '박준용';

# NULL 조회/조건 => 무조건 is null or is not null
select * from sample21 where birthday is null;
select * from sample21 where birthday is not null;

# AND, OR
select * from sample24 where a<>0 and b<>0;
select * from sample24 where a<>0 or b<>0;
select * from sample24 where a=1 or a=2 and b=1 or b=2;  # 연산자 우선순위 때문에, 이렇게하면 원하는 결과 안나옴 -> 밑에처럼 작성해야함
select * from sample24 where (a=1 or a=2) and (b=1 or b=2);

# NOT - 오른쪽 조건식에 포함되지 않는 나머지값 반환
select * from sample24 where not(a<>0 or b<>0);   # a가0이 아니거나, b가 0이아닌 집합 외의 값들

# 패턴 매칭 검색 = LIKE 문자열의 일부분을 비교   :  %, _ 사용가능
# 특정 문자나 문자열이 포함되어 있는지 검색하고 싶을 때
# 열명 LIKE '패턴'
select * from sample25;
select * from sample25 where text like 'SQL%';    # 전방일치(~으로 시작하는 : 앞에 문자 있으면 안됨) # 'SQL'을 포함하는 행
select * from sample25 where text like '%sql%';   # 중간일치  # %: 빈문자열과도 매치함 -> 'SQL은 ~'처럼 앞의 문자가 없는 경우도 포함됨!!
select * from sample25 where text like '%SQL';    # 후방일치(뒤에 아무것도 없어야함)
## 이스케이프(\): 매타문자(%, _) 포함하는 문자열 검색하고 싶을 때 활용
select * from sample25 where text like '%\%%';    # \%
select * from sample25 where text like '%\_%';    # \_
## ' (문자열 상수)의 이스케이프 처리: '' 2개 연속 기술    ex. It's -> 'It''s',  ' -> ''''

