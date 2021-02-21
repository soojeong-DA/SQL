
/* ***********************************************************************************
DDL (Data Definition Language)  -  데이터베이스에서 사용되는 객체(테이블, 사용자, 시퀀스)를 관리하는 언어
creat(생성) - drop(삭제) - alter(수정)

테이블 생성
- 구문
create table 테이블 이름(
  컬럼 설정      --  컬럼이름, 데이터타입, [default 값, 제약조건] 설정 가능
)

- 데이터 타입
    - 문자열: char/nchar - 고정길이, varchar2/nvarchar2/clob - 가변길이
    - 숫자: number, number(전체자릿수, 소수부자릿수)
    - 날짜: date, timestamp
    - 파일: blob  - 파일경로

제약조건
- primary key(PK) - 기본키. 형식별 컬럼.
- 'unique' key(UK) - 중복값을 못가지는 컬럼. null은 가질 수 있다.
- not null (NN) - null을 못가지는 컬럼
- check key (CK) - 컬럼에 넣을 값의 조건을 직접 지정.
- foreign key (FK) - 참조 컬럼. 부모테이블의 primary key만 값으로 가지는 컬럼. => 부모테이블 참조(조인)할 때 사용.


제약조건 설정 
- 컬럼 레벨 설정
    - 컬럼 설정에 같이 설정
- 테이블 레벨 설정
    - 컬럼 설정뒤에 따로 설정

- 기본 문법 : 'constraint' 제약조건이름 제약조건타입
- 테이블 제약 조건 조회
    - USER_CONSTRAINTS 딕셔너리 뷰에서 조회
    
테이블 삭제
- 구분
DROP TABLE 테이블이름 [CASCADE CONSTRAINTS]
*********************************************************************************** */
select * from user_constraints;  -- 여태 실행한 제약조건들 모아둔 테이블 조회
--drop table dept cascade constraints;  -- 참조관계까지 지워줘서, 테이블 싹 삭제 가능

---************************************************************************************
-- 테이블 생성
create table parent_tb(
    no   number constraint pk_parent_tb primary key,    -- 제약조건 이름설정: constraint 테이블이름+어떤제약조건인지    --이름설정 생략가능
    name nvarchar2(50) not null, --NN: 컬럼레벨 설정.
    birthday date default sysdate, -- default 값 => 기본값. nullable 컬럼.
    email  varchar2(100) constraint uk_parent_tb_email unique,  -- unique에 key 붙이면안됨
    gender char(1) not null constraint ck_parent_tb_gender check(gender in ('M','F'))  -- check(컬럼이 가질 수 있는 값 제한/설정)
);

select * from user_constraints where table_name = 'PARENT_TB';  -- 여기서 테이블명 조회할 땐 반드시 대문자 사용
insert into parent_tb values(1, '홍길동','1990-10-20','a@a.com', 'M');
insert into parent_tb values(1, '홍길동','1990-10-20','a@a.com', 'A'); --'A' : check 조건 위배됨
insert into parent_tb values(2, '홍길동','1990-10-20','a@a.com', 'M'); -- email: unique(UK) 조건 위배
insert into parent_tb values(3, '홍길동','1990-10-20',null, 'M'); 
insert into parent_tb values(2, '홍길동', null, null, 'M'); 
insert into parent_tb (no, name, gender) values(5, '이순신','M');  --어떤 컬럼에 해당하는 값인지 알려줘야함

select * from parent_tb;

-- 테이블 레벨 제약조건 설정.
-- 한줄에 constraint까지  다 안쓰고, 나중에 설정하는 ver.
drop table parent_tb cascade constraint;    --  모든 참조관계 끊으면서, 데이터 모두 삭제
create table child_tb(
    no        number, --PK
    jumin_num char(14), --UK
    age       number not null, --CK(10~90)
    p_no      number, -- FK(parent_tb) 
    constraint pk_child_tb primary key(no),
    constraint uk_child_tb_jumin_num unique(jumin_num),
    constraint ck_child_tb_age check(age between 10 and 90),
    --constraint fk_child_tb_parent_tb foreign key(p_no) references parent_tb(no)   -- no컬럼 생략가능.
    -- 부모테이블에서 참조하는 행이 삭제되면, 자식의 행도 같이 삭제 하겠다.  --이거 설정하면, 부모 테이블에서 no지울때, 자식 테이블의 p_no먼저 지워주고, no지워줌 자동으로
    --constraint fk_child_tb_parent_tb foreign key(p_no) references parent_tb on delete cascade,   
    -- 부모테이블에서 참조하는 행이 삭제되면, p_no(참조 컬럼)의 값을 null로 update
    constraint fk_child_tb_parent_tb foreign key(p_no) references parent_tb on delete set null
);

insert into child_tb values(100, '801010-1010101', 20, 1);

delete from parent_tb where no = 1;    -- 원래 on delete 설정 안하면, 참조하고있기때문에 안지워짐. but, on delete 설정 했기때문에, 참조하고 있더라도 지워짐

select * from parent_tb;


-- 모든 참조관계 끊으면서, 데이터 모두 삭제
select * from user_constraints where table_name = 'CHILD_TB';   -- 삭제전 조회
drop table parent_tb cascade constraint;   -- 보통 테이블 만드는 문 시작 전에 넣어줌.




/* ************************************************************************************
ALTER : 테이블 수정

컬럼 관련 수정

- 컬럼 추가
  ALTER TABLE 테이블이름 ADD (추가할 컬럼설정 [, 추가할 컬럼설정])
  - 하나의 컬럼만 추가할 경우 ( ) 는 생략가능

- 컬럼 수정
  ALTER TABLE 테이블이름 MODIFY (수정할컬럼명  변경설정 [, 수정할컬럼명  변경설정])
	- 하나의 컬럼만 수정할 경우 ( )는 생략 가능
	- 숫자/문자열 컬럼은 크기를 늘릴 수 있다.
		- 크기를 줄일 수 있는 경우 : 열에 값이 없거나 모든 값이 줄이려는 크기보다 작은 경우
	- 데이터가 모두 NULL이면 데이터타입을 변경할 수 있다. (단 CHAR<->VARCHAR2 는 가능.)

- 컬럼 삭제	
  ALTER TABLE 테이블이름 DROP COLUMN 컬럼이름 [CASCADE CONSTRAINTS]
    - CASCADE CONSTRAINTS : 삭제하는 컬럼이 Primary Key인 경우 그 컬럼을 참조하는 다른 테이블의 Foreign key 설정을 모두 삭제한다.
	- 한번에 하나의 컬럼만 삭제 가능.
	
  ALTER TABLE 테이블이름 SET UNUSED (컬럼명 [, ..])
  ALTER TABLE 테이블이름 DROP UNUSED COLUMNS
	- SET UNUSED 설정시 컬럼을 바로 삭제하지 않고 삭제 표시를 한다. 
	- 설정된 컬럼은 사용할 수 없으나 실제 디스크에는 저장되 있다. 그래서 속도가 빠르다.
	- DROP UNUSED COLUMNS 로 SET UNUSED된 컬럼을 디스크에서 삭제한다. 

- 컬럼 이름 바꾸기
  ALTER TABLE 테이블이름 RENAME COLUMN 원래이름 TO 바꿀이름;

**************************************************************************************  
제약 조건 관련 수정
-제약조건 추가
  ALTER TABLE 테이블명 ADD CONSTRAINT 제약조건 설정

- 제약조건 삭제
  ALTER TABLE 테이블명 DROP CONSTRAINT 제약조건이름
  PRIMARY KEY 제거: ALTER TABLE 테이블명 DROP PRIMARY KEY [CASCADE]
	- CASECADE : 제거하는 Primary Key를 Foreign key 가진 다른 테이블의 Foreign key 설정을 모두 삭제한다.

- NOT NULL <-> NULL 변환은 컬럼 수정을 통해 한다.
   - ALTER TABLE 테이블명 MODIFY (컬럼명 NOT NULL),  - ALTER TABLE 테이블명 MODIFY (컬럼명 NULL)  
************************************************************************************ */
/*
- 기존 테이블을 복사해서 테이블 생성.
- 컬럼, 데이터 복사 가능. 제약조건은 not null을 제외한 제약조건은 복사되지 않는다.
create table 테이블 이름
as
select 문
*/

create table cust
as
select * from customers;

select * from cust;
select * from user_constraints 
where table_name = 'CUST';

--
create table ord
as
select * from orders
where 1 != 1;  -- 무조건 False인 조건이라, 형식은 가져오지만, data는 아무것도 가져오지 않음

select * from ord;

--PK 제약조건 추가: add constraint
alter table cust add constraint pk_cust primary key(cust_id);
alter table ord add constraint fk_ord_cust foreign key(cust_id) references cust;


-- 컬럼 변경
- 추가: add      
alter table cust add(age number(2) default 0);  -- age컬럼 추가, 기본값: 0
alter table cust add(age number(2) not null);  --(기존에 데이터가 있는 컬럼에 not null을 추가하려면, 반드시 기본값 설정해야함. 설정안하면 null 값들어가는데 not null이라 null 못넘;)
select * from cust;
-수정: modify
desc cust;
alter table cust modify (cust_name nvarchar2(200));
alter table cust modify (address varchar2(10));   -- error: '일부 값이 너무 커서 열 길이를 줄일 수 없음'  -> 주소길이가 10넘는게 있어서, 10으로 못줄임
alter table cust modify (cust_name null
                            ,address null
                            ,postal_code null);

-- 컬럼 명 변경: rename column
alter table cust rename column cust_name to name; -- cust_name을 name으로 변경
select * from cust;

-- 컬럼 삭제: drop column
alter table cust drop column age;

-- 제약조건 삭제
alter table ord drop constraint fk_ord_cust; -- 제약조건 이름
alter table cust drop primary key; -- 그냥 제약조건 명으로도 삭제 가능 --alter table cust drop consstraint pk_cust;


--TODO: emp 테이블을 카피해서 emp2를 생성(틀만 카피)
create table emp2
as
select * from emp
where 1 != 1;

desc emp2;
select * from emp2;

--TODO: gender 컬럼을 추가: type char(1)
alter table emp2 add(gender char(1));
desc emp2;

--TODO: email 컬럼 추가. type: varchar2(100),  not null  컬럼
--TODO: jumin_num(주민번호) 컬럼을 추가. type: char(14), null 허용. 유일한 값을 가지는 컬럼.
alter table emp2 add(email varchar2(100) not null,
                    jumin_num char(14) constraint ck_emp2_jumin unique);
                    
desc emp2;
select * from user_constraints
where table_name = 'EMP2';


--TODO: emp_id 를 primary key 로 변경
alter table emp2 add primary key(emp_id);
/*alter table emp2 add constraint pk_emp_id primary key(emp_id);*/

  
--TODO: gender 컬럼의 M, F 저장하도록  제약조건 추가
alter table emp2 add constraint ck_emp_gender check(gender in ('M','F'));

 
--TODO: salary 컬럼에 0이상의 값들만 들어가도록 제약조건 추가
alter table emp2 add constraint ck_emp_salary check(salary >= 0);


--TODO: email 컬럼을 null을 가질 수 있되 다른 행과 같은 값을 가지지 못하도록 제약 조건 변경
alter table emp2 add constraint uk_emp_email unique(email);


--TODO: emp_name 의 데이터 타입을 varchar2(100) 으로 변환
alter table emp2 modify(emp_name varchar2(100));
desc emp2;


--TODO: job_id를 not null 컬럼으로 변경
alter table emp2 modify(job_id not null);

desc emp2;
--TODO: dept_id를 not null 컬럼으로 변경
alter table emp2 modify(dept_id not null);


--TODO: job_id  를 null 허용 컬럼으로 변경
--TODO: dept_id  를 null 허용 컬럼으로 변경
alter table emp2 modify(job_id null,
                        dept_id null);

--TODO: 위에서 지정한 emp2_email_uk 제약 조건을 제거
alter table emp2 drop constraint uk_emp_email;


--TODO: 위에서 지정한 emp2_salary_ck 제약 조건을 제거
alter table emp2 drop constraint ck_emp_salary;


--TODO: primary key 제약조건 제거
alter table emp2 drop primary key;


--TODO: gender 컬럼제거
alter table emp2 drop column gender;


--TODO: email 컬럼 제거
alter table emp2 drop column email;


/* **************************************************************************************************************
시퀀스 : SEQUENCE
- '자동증가하는 숫자'를 제공하는 오라클 객체
- 테이블 컬럼이 자동증가하는 고유번호를 가질때 사용한다.
	- 하나의 시퀀스를 여러 테이블이 공유하면 중간이 빈 값들이 들어갈 수 있다.

생성 구문
CREATE SEQUENCE sequence이름
	[INCREMENT BY n]	
	[START WITH n]                		  
	[MAXVALUE n | NOMAXVALUE]   
	[MINVALUE n | NOMINVALUE]	
	[CYCLE | NOCYCLE(기본)]		
	[CACHE n | NOCACHE]		  

- INCREMENT BY n: 증가치 설정. 생략시 1
- START WITH n: 시작 값 설정. 생략시 0
	- 시작값 설정시
	 - 증가: MINVALUE 보다 크커나 같은 값이어야 한다.
	 - 감소: MAXVALUE 보다 작거나 같은 값이어야 한다.
- MAXVALUE n: 시퀀스가 생성할 수 있는 최대값을 지정
- NOMAXVALUE : 시퀀스가 생성할 수 있는 최대값을 오름차순의 경우 10^27 의 값. 내림차순의 경우 -1을 자동으로 설정. 
- MINVALUE n :최소 시퀀스 값을 지정
- NOMINVALUE :시퀀스가 생성하는 최소값을 오름차순의 경우 1, 내림차순의 경우 -(10^26)으로 설정
- CYCLE 또는 NOCYCLE : 최대/최소값까지 갔을때 순환할 지 여부. NOCYCLE이 기본값(순환반복하지 않는다.)
- CACHE|NOCACHE : 캐쉬 사용여부 지정.(오라클 서버가 시퀀스가 제공할 값을 미리 조회해 메모리에 저장) NOCACHE가 기본값(CACHE를 사용하지 않는다. )


시퀀스 자동증가값 조회
 - sequence이름.nextval  : 다음 증감치 조회
 - sequence이름.currval  : 현재 시퀀스값 조회


시퀀스 수정
ALTER SEQUENCE 수정할 시퀀스이름
	[INCREMENT BY n]	               		  
	[MAXVALUE n | NOMAXVALUE]   
	[MINVALUE n | NOMINVALUE]	
	[CYCLE | NOCYCLE(기본)]		
	[CACHE n | NOCACHE]	

수정후 생성되는 값들이 영향을 받는다. (그래서 start with 절은 수정대상이 아니다.)	  


시퀀스 제거
DROP SEQUENCE sequence이름
	
************************************************************************************************************** */
---시퀀스는 table과는 다른 객체임
-- 1부터 1씩 '자동증가'하는 시퀀스
create sequence dept_id_seq;  --dept_id: 이 시퀀스를 사용할 컬럼 이름.  보통 끝에 _seq를 붙임

select dept_id_seq.nextval from dual;   --실행할 때마다 1씩 증가

insert into dept values (dept_id_seq.nextval, '연구소', '부산');

select * from dept;

-- 1부터 50까지 10씩 자동증가 하는 시퀀스
create sequence ex1_seq 
increment by 10 
maxvalue 50;

select ex1_seq.nextval from dual;


-- 100 부터 150까지 10씩 자동증가하는 시퀀스
create sequence ex2_seq
increment by 10
start with 100
maxvalue 150;

select ex2_seq.nextval from dual;
-- 100 부터 150까지 2씩 자동증가하되 최대값에 다다르면 순환하는 시퀀스
-- 순환하게 되면 증가 일 경우에는 minvalue부터 시작. minvalue 설정 안하면 기본값: 1
--             감소 일 경우에는 maxvalue부터 시작. maxvalue 설정 안하면 기본값: -1
create sequence ex3_seq
increment by 2
start with 100
maxvalue 150
cycle;

select ex3_seq.nextval from dual;


-- -1부터 자동 감소하는 시퀀스
create sequence ex4_seq
increment by -1;

select ex4_seq.nextval from dual;


-- -1부터 -50까지 -10씩 자동 감소하는 시퀀스
create sequence ex5_seq
increment by -10
minvalue -50;

select ex5_seq.nextval from dual;


-- 100 부터 -100까지 -100씩 자동 감소하는 시퀀스
-- 감소 : maxvalue 기본값: -1. start with가 maxvalue보다 크면 안된다.
-- 증가 : start with가 minvalue보다 작으면 안된다.
create sequence ex6_seq
increment by -100
start with 100
minvalue -100
maxvalue 100;

select ex6_seq.nextval from dual;


-- 15에서 -15까지 1씩 감소하는 시퀀스 작성
create sequence ex7_seq
increment by -2
start with 15
minvalue -15
maxvalue 30
cycle;

select ex7_seq.nextval from dual;

-- -10 부터 1씩 증가하는 시퀀스 작성
create sequence ex8_seq
increment by 1
start with -10
minvalue -10;

--순환하는 시퀀스의 경우 제공하는 값의 개수가 cache 개수보다 많아야 한다.
--cache의 기본값 6

create sequence ex9_seq
increment by 10
maxvalue 50
cycle
cache 3;


-- Sequence를 이용한 값 insert



-- TODO: 부서ID(dept.dept_id)의 값을 자동증가 시키는 sequence를 생성. 10 부터 10씩 증가하는 sequence
-- 위에서 생성한 sequence를 사용해서  dept_copy에 5개의 행을 insert.
create table dept_copy
as 
select * from dept
where 1 = 0;

create sequence dept_id_seq2
increment by 10
start with 10;

insert into dept_copy values (dept_id_seq2.nextval, 
                                '새부서'||ex9_seq.nextval,
                                '서울');

select * from dept_copy;


-- TODO: 직원ID(emp.emp_id)의 값을 자동증가 시키는 sequence를 생성. 10 부터 1씩 증가하는 sequence
-- 위에서 생성한 sequence를 사용해 emp_copy에 값을 5행 insert


