--DML: modify languge
---insert, delet, update
/* *********************************************************************
INSERT 문 - 행 추가
구문
 - 한행추가 :
   - INSERT INTO 테이블명 (컬럼 [, 컬럼]) VALUES (값 [, 값[])
   - 모든 컬럼에 값을 넣을 경우 컬럼 지정구문은 '생략 할 수 있다'.

 - 조회결과를 INSERT 하기 (subquery 이용)
   - INSERT INTO 테이블명 (컬럼 [, 컬럼])  SELECT 구문         <- select에서 조회한 값을 다 넣어줌
	- INSERT할 컬럼과 조회한(subquery) 컬럼의 개수와 타입이 맞아야 한다.  <- 순서도 맞아야함
	- 모든 컬럼에 다 넣을 경우 컬럼 설정은 생략할 수 있다.
	
************************************************************************ */
-- 모든 컬럼에 값 넣기
insert into dept (dept_id, dept_name, loc) values(500,'기획부','서울');    -- 괄호안은 생략가능 (단, 모들 컬럼 값들을 다 넣을 경우에만)
insert into dept values(501,'구매부','인천');      -- 괄호 생략

-- 일부 컬럼에만 값 넣기
insert into dept (dept_id, dept_name) values(502,'자재부');     -- error 발생. 문법적으로는 맞지만, loc 컬럼 속성이 NOT NULL이기 때문에 오류남


select * from dept order by dept_id desc;
desc dept;    -- table 정보 알려줌


-- 테이블 생성  ----------------------------------------------------------------------------------------------------------------
create table emp_copy(
    emp_id number(6),
    emp_name varchar2(20),
    salary number(7,2)
);

select * from emp_copy;

insert into emp_copy (emp_id, emp_name, salary)
select emp_id, emp_name, salary
from emp
where job_id = 'FA_ACCOUNT';

select * from emp_copy;

--모든 컬럼에 다 넣을 경우 컬럼 지정 구문() 은 생략 가능
insert into emp_copy
select emp_id, emp_name, salary
from emp
where dept_id = 50;

select * from emp_copy;

insert into emp_copy (emp_id, emp_name)
select emp_id, emp_name --,salary 제외됨     -> salary 부분은 NULL값으로 들어감
from emp
where dept_id = 30;

select * from emp_copy;




/*======================================================================================================*/
--TODO: 부서별 직원의 급여에 대한 통계 테이블 생성. 
--      조회결과를 insert. 집계: 합계, 평균, 최대, 최소, 분산, 표준편차
create table salary_stat(
    dept_id number(6),
    salary_sum number(15,2),
    salary_avg number(10, 2),
    salary_max number(7,2),
    salary_min number(7,2),
    salary_var number(20,2),
    salary_stddev number(7,2)
);


insert into salary_stat
select dept_id, sum(salary), avg(salary), max(salary), min(salary), VARIANCE(salary), STDDEV(salary)
from emp
group by dept_id
order by dept_id;

select * from salary_stat;

delete from salary_stat;    -- 테이블 전체 값 삭제

select * from salary_stat;

/* *********************************************************************
UPDATE : 테이블의 컬럼의 값을 '수정'

UPDATE 테이블명                  -- 테이블은 하나만 지정 가능
SET    변경할 '컬럼' = 변경할 값  [, 변경할 컬럼 = 변경할 값]
[WHERE 제약조건]   <- 변경할 '행'에대한 제약조건  (행 제약조건 생략하면, 해당 컬럼의 모든 값이 변경됨!!!)

-- update는 join자체가 없어서, 서브쿼리 사용해야함

 - UPDATE: 변경할 '테이블' 지정
 - SET: 변경할 '컬럼'과 값을 지정
 - WHERE: 변경할 '행'을 선택. 
************************************************************************ */
update emp
set salary = 5000
where emp_id = 200;   -- emp_id가 200인 행만 변경


select * from emp;

rollback;     -- 마지막 commit 이후 변경한 내용을 처름 상태로 돌린다.   -- 변경작업 잘못했을경우, 실행하기 전 상태로 되돌려줌 (like control + z)
commit;      -- 지금가지 한 작업을 DB에 적용한다.(중간 저장 느낌)


/*==================================================================================================================*/
-- 직원 ID가 200인 직원의 급여를 5000으로 변경
update emp
set salary = 5000
where emp_id = 200;

select * from emp where emp_id =200;

-- 직원 ID가 200인 직원의 급여를 10% 인상한 값으로 변경.
update emp
set salary = salary*1.1
where emp_id = 200;

select * from emp where emp_id =200;

-- 부서 ID가 100인 직원의 커미션 비율을 0.2로 salary는 3000을 더한 값으로 변경.
update emp
set comm_pct = 0.2
        ,salary = salary + 3000
        ,mgr_id = 100
where dept_id = 100;

select * from emp where dept_id =100;

-- 부서 ID가 100인 직원의 커미션 비율을 null로 변경
update emp
set comm_pct = null
where dept_id = 100;

select * from emp where dept_id =100;

-- TODO: 부서 ID가 100인 직원들의 급여를 100% 인상
update emp
set salary = salary*2
where dept_id = 100;

select * from emp where dept_id =100;

-- TODO: IT 부서의 직원들의 급여를 3배 인상
update emp
set salary = salary*3
where dept_id in (select dept_id from dept where dept_name = 'IT');

-- TODO: EMP2 테이블의 모든 데이터를 MGR_ID는 NULL로 HIRE_DATE 는 현재일시로 COMM_PCT는 0.5로 수정.
update emp
set mgr_id = null
    ,hire_date = sysdate
    ,comm_pct = 0.5;

/* *********************************************************************
DELETE : 테이블의 '행'을 삭제       -- 컬럼을 넣지 않음!! 컬럼 넣으면 error!
구문 
 - DELETE FROM '테이블명' [WHERE 제약조건]  -- 특정 행 지정 안하면, 테이블 전체 data 삭제.
   - WHERE: 삭제할 행을 선택
************************************************************************ */
delete from emp;
select * from emp;

rollback;   -- 마지막 commit 전까지 rollback

delete from emp
where dept_id = 100;

select * from emp where dept_id = 100; 

-- 자식테이블에서 참조하는 행은 삭제할 수 없다.  (무결성 제약조건 위배됨)
-- 참조하는 자식테이블의 행을 삭제하거나 참조 컬럼의 값을 NULL로 바꾼뒤 삭제한다.    (참조하는 얘들을 모두 없애야함..)

delete from dept
where dept_id = 10;

select * from dept where dept_id = 10;

/*===================================================================================================================*/
-- TODO: 부서 ID가 없는 직원들을 삭제
delete from emp
where dept_id is null;


-- TODO: 담당 업무(emp.job_id)가 'SA_MAN'이고 급여(emp.salary) 가 12000 미만인 직원들을 삭제.
delete from emp
where job_id = 'SA_MAN'
and salary < 12000;

-- TODO: comm_pct 가 null이고 job_id 가 IT_PROG인 직원들을 삭제
rollback;

delete from emp
where job_id = 'IT_PROG'
and comm_pct is null;


-- 전체 데이터를 삭제
delete from emp_copy;    => rollback 가능
truncate table emmp_copt;  => rollback 불가능!!!!  한번 삭제하면 되돌릴 수 없음...

