-- dash2개: 한줄 주석
-- select * from tabs;
/* 주석시작
block 주석.
주석 끝*/
-- 실행: control + enter  (한줄씩, 블럭 합쳐서.. 등 실행가능)
-- F5: 파일안에 있는 모든코드 실행해줌


/*
테이블: 회원 (member)
속성
id: varchar2(10) primary key   -- not null + uniqe
password: varchar2(10) not null (필수입력, 값이 null일 수 없음)
name: nvarchar2(30)  not null (varchar도 가능하지만, 한글도 편하게 입력하려면, varchar2)    
point: number(6,2) nullable (null을 허용 = not null이 아니면, nullable)  <- 최대 포인트(6) = 10**6 : -9999.99~9999.99 범위 지정  ex) $달러,키 등 / 무한이면 그냥 number
join_date: date not null   (type: date)    -- 보통 char(고정길이)로 만듬 000-00-00
*/

--format
--컬럼명 데이터차입 제약조건
--쉼표 주의!
create table member(
 id         varchar2(10)  primary key,
 password   varchar2(10)  not null,
 name       nvarchar2(30) not null,
 point      number(6),
 join_date  date          not null
);

--테이블 잘 만들어졌나 확인 -- 테이블에 대한 상세 사항(속성) 보여줌  (다 대문자로 나옴, but 상관없음)
desc member;

--테이블 삭제  & 다시 생성
drop table member;
create table member(
 id         varchar2(10)  primary key,
 password   varchar2(10)  not null,
 name       nvarchar2(30) not null,
 point      number(6),
 join_date  date          not null
);



-- 한행 insert(데이터를 삽입)  -- 컬럼 순서는 상관 없으나, 컬럼-값 대칭? 순서는 맞춰줘야함   -- 한번 더 실행하면 error남 because id(primery) 값 중복되서.
insert into member(id, password, name, point, join_date) values('id-1','11111','박수정',1000,'2020-05-20');

-- 모든 column에 값을 넣을경우, column 지정 생략가능!   (이때는 컬럼 순서 지켜줘야함.)
insert into member values('id-2','2252','박성현',3000,'2018-11-11');

-- point 빼고 넣을때(컬럼중 하나라도 생략되면), 일부 column 에만 값 넣을경우 컬럼 지정해야
insert into member (id, password, name, join_date) values('id-3','3333','김팽수','2019-03-24');

-- join_date는 not null이므로 반드시 값을 넣어야한다.
insert into member (id, password, name) values('id-4','433','김팽수얌');

-- null: null값 표현식.
insert into member values('id-5','2939','아아아',null,'2019-05-28');



--------------파일에 있는 코드 다 실행
@C:\Users\Playdata\oracle_data\emp_table.sql;

