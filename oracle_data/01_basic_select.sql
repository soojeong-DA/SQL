/* *************************************
-- 주석 적용/풀기 단축키: control + /
Select 기본 구문 - 연산자, 컬럼 별칭

select 컬럼명1, 컬럼명2, 컬럼명3, ... => 조회할 컬럼명
from   테이블명                     => 조회할 테이블명

테이블에 있는 모든 컬럼을 조회 => *     (컬럼명 안넣어도 조회가능)

*************************************** */
--EMP 테이블의 모든 컬럼의 모든 항목을 조회.
select * from emp;

--EMP 테이블의 직원 ID(emp_id), 직원 이름(emp_name), 업무(job) 컬럼의 값을 조회.
/* select emp_id, emp_name, job 
from emp;
*/
-- 아래처럼하면 지우기 편함
select emp_id
        ,emp_name
        ,job 
from emp;

--EMP 테이블의 업무(job) 어떤 값들로 구성되었는지 조회. - 동일한 값은 하나씩만 조회되도록 처리.
select distinct job
from emp;

--EMP 테이블의 부서명(dept_name)이 어떤 값들로 구성되었는지 조회 - 동일한 값은 하나씩만 조회되도록 처리.
select distinct dept_name
from emp;

--별칭
--EMP 테이블에서 emp_id는 직원ID, emp_name은 직원이름, hire_date는 입사일, salary는 급여, dept_name은 소속부서 '별칭'으로 조회한다.
--select 조회할 컬럼명 as 별칭(alias)
--별칭(alias) : 조회결과의 컬럼명.
select emp_id as 직원ID
        ,emp_name as 직원이름
        ,hire_date as 입사일
        ,salary as 급여
        ,dept_name as 소속부서
from emp;


-- as는 생략가능
select emp_id 직원ID
        ,emp_name 직원이름
        ,hire_date 입사일
        ,salary 급여
        ,dept_name 소속부서
from emp;

--별칭에 컬럼명으로 사용하지 못하는 문자(공백,..)를 쓸 경우 " "로 감싼다.
select emp_id as "직원 ID"
        ,emp_name as "직원 이름"
        ,hire_date as 입사일
        ,salary as 급여
        ,dept_name as "소속 부서"
from emp;

select salary*20 "20개월치 급여"
from emp;

-- sum(salary) : 모든 salary 더한 값 나옴
select sum(salary) "총급여"
from emp;

/* 
연산자 

산술연산자: +,-,*,/
문자열 합치기: ||
- '문자열A'||'문자열B' =>  '문자열A문자열B'

 연산은 그 컬럼의 모든 값들에 일률적으로 적용된다.
 같은 컬럼을 여러번 조회할 수 있다.

- 컬럼 + 값 : 컬럼의 모든값에 더한다.(곱한다,뺀다,나눈다)
- 컬럼 * 컬럼 : 같은 행의 값끼리 곱한다.(더한다,뺀다,나눈다)
*/
select 20, 20+10, 20-10, 20*5, 20/3, round(20/3,2)  --소수점 2자리까지 나오게 반올림.
from dual;  --dual(더미테이블): select의 from절을 만들기 위해 사용되는 가짜/가상의 테이블명. (oracle에서 select&from은 필수라서)

--sysdate: sql구문 실행 시점의 일시 => type: date   ex) 20/05/25
select sysdate
from dual;

--date는  +,-만 가능.
-- date + 정수: 정수 일(day) 후 날짜.
-- date - 정수: 정수 일(day) 전 날짜.
select sysdate +3, sysdate -3, sysdate +10, sysdate
from dual;

-- date - date: 며칠 차이
select sysdate - sysdate
from dual;

--number값/date값과 null을 계산하면 결과는 null(모르는 값, 값이 없다)
select 10+null, sysdate-null
from dual;

-- ||: 문자열 합치기(보통 피연산자 2개중 하나 or 2개가 column인 경우 다수)
select 3000||'원', '홍길동'||'허허허'
from dual;
-- 값||null => null은 무시
--'A'
select 'A'||null
from dual;

--EMP 테이블에서 직원의 이름(emp_name), 급여(salary) 그리고  급여 + 1000 한 값을 조회.
select emp_name
        ,salary
        ,salary + 1000
from emp;


--EMP 테이블에서 입사일(hire_date)과 입사일에 10일을 더한 날짜를 조회.
select hire_date "입사일"
        ,hire_date + 10 "입사 10일후"
from emp;

/*TODO*/
--TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 급여(salary), 커미션_PCT(comm_pct), 급여에 커미션_PCT를 곱한 값을 조회.
select emp_ID "직원의 ID"
        ,emp_name "이름"
        ,salary "급여"
        ,comm_pct "커미션"
        ,salary*comm_pct "급여*커미션"
from emp;

--TODO:  EMP 테이블에서 급여(salary)을 연봉으로 조회. (곱하기 12)
select salary*12 "연봉"
from emp;

--TODO: EMP 테이블에서 직원이름(emp_name)과 급여(salary)을 조회. 급여 앞에 $를 붙여 조회.
select emp_name "직원이름"
        ,'$'||salary "급여"
from emp;

--TODO: EMP 테이블에서 입사일(hire_date) 30일전, 입사일, 입사일 30일 후를 조회
select hire_date - 30 "입사일 30일전"
        ,hire_date +30 "입사일 30일후"
from emp;




/* *************************************
Where 절을 이용한 행 행 제한
************************************* */
--EMP 테이블에서 직원_ID(emp_id)가 110인 직원의 이름(emp_name)과 부서명(dept_name)을 조회
--emp_id: primary key : 조회 => 하나만 조회하겠다는 뜻 (primary key는 only one)
select emp_name
        ,dept_name
from emp
where emp_id = 110;


--EMP 테이블에서 'Sales' 부서에 속하지 않은 직원들의 ID(emp_id), 이름(emp_name), 부서명(dept_name)을 조회.
select emp_id
        ,emp_name
        ,dept_name
from emp
where dept_name != 'Sales';   --값('Sales')은 반드시 대소문자 맞춰야!   / where dept_name <> 'Sales'; 도 가능


--EMP 테이블에서 급여(salary)가 $10,000를 초과인 직원의 ID(emp_id), 이름(emp_name)과 급여(salary)를 조회
select emp_id
        ,emp_name
        ,salary
from emp
where salary > 10000;
 
 
--EMP 테이블에서 커미션비율(comm_pct)이 0.2~0.3 사이인 직원의 ID(emp_id), 이름(emp_name), 커미션비율(comm_pct)을 조회.
select emp_id
        ,emp_name
        ,comm_pct
from emp
where comm_pct between 0.2 and 0.3;



--EMP 테이블에서 커미션을 받는 직원들 중 커미션비율(comm_pct)이 0.2~0.3 사이가 아닌 직원의 ID(emp_id), 이름(emp_name), 커미션비율(comm_pct)을 조회.
select emp_id
        ,emp_name
        ,comm_pct
from emp
where comm_pct not between 0.2 and 0.3;
--comm_pct < 0.2 or comm_pct >0.3;

select distinct job from emp;
--EMP 테이블에서 업무(job)가 'IT_PROG' 거나 'ST_MAN' 인 직원의  ID(emp_id), 이름(emp_name), 업무(job)을 조회.
select emp_id
        ,emp_name
        ,job
from emp
where job in ('IT_PROG', 'ST_MAN');
/*where job = 'IT_PROG'
or    job = 'ST_MAN';*/


--EMP 테이블에서 업무(job)가 'IT_PROG' 나 'ST_MAN' 가 아닌 직원의  ID(emp_id), 이름(emp_name), 업무(job)을 조회.
select emp_id
        ,emp_name
        ,job
from emp
where job not in ('IT_PROG','SM_MAN');
/*where job <> 'IT_PROG'
and    job <> 'ST_MAN';*/


--EMP 테이블에서 직원 이름(emp_name)이 S로 시작하는 직원의  ID(emp_id), 이름(emp_name)
select emp_id
        ,emp_name
from emp
where emp_name like 'S%';


--EMP 테이블에서 직원 이름(emp_name)이 S로 시작하지 않는 직원의  ID(emp_id), 이름(emp_name)
select emp_id
        ,emp_name
from emp
where emp_name not like 'S%';


--EMP 테이블에서 직원 이름(emp_name)이 en으로 끝나는 직원의  ID(emp_id), 이름(emp_name)을 조회
select emp_id
        ,emp_name
from emp
where emp_name like '%en';

--EMP 테이블에서 직원 이름(emp_name)의 세 번째 문자가 “e”인 모든 사원의 이름을 조회
select emp_name
from emp
where emp_name like '__e%';   -- '_'가 한글자
-- xx로 시작하는: 'xx%'
-- xx로 끝나는 : '%xx'
-- xx가 들어간 : '%xx%'
-- 글자수: _


-- EMP 테이블에서 직원의 이름에 '%' 가 들어가는 직원의 ID(emp_id), 직원이름(emp_name) 조회
select emp_id
        ,emp_name
from emp
where emp_name like '%#%%' escape '#';    -- escape ' ' 아무거나 내맘대로 지정 가능
--like 연산시. %나 _앞에 escape에서 지정한 문자(#)을 붙이면 리터럴임을 가리킨다.
-- ' #%  #_ ' => %, _ 자체

--EMP 테이블에서 부서명(dept_name)이 null인 직원의 ID(emp_id), 이름(emp_name), 부서명(dept_name)을 조회.
select emp_id
        ,emp_name
from emp
where dept_name is null;    -- ' = null'로 조회하면 안나옴. 꼭 is null 사용해야함.


--부서명(dept_name) 이 NULL이 아닌 직원의 ID(emp_id), 이름(emp_name), 부서명(dept_name) 조회
select emp_id
        ,emp_name
from emp
where dept_name is not null; 


--TODO: EMP 테이블에서 업무(job)가 'IT_PROG'인 직원들의 모든 컬럼의 데이터를 조회. 
select *
from emp
where job = 'IT_PROG';


--TODO: EMP 테이블에서 업무(job)가 'IT_PROG'가 아닌 직원들의 모든 컬럼의 데이터를 조회. 
select *
from emp
where job != 'IT_PROG';


--TODO: EMP 테이블에서 이름(emp_name)이 'Peter'인 직원들의 모든 컬럼의 데이터를 조회
select *
from emp
where emp_name = 'Peter';

--TODO: EMP 테이블에서 급여(salary)가 $10,000 이상인 직원의 ID(emp_id), 이름(emp_name)과 급여(salary)를 조회
select emp_id
        ,emp_name
        , salary
from emp
where salary >= 10000;


--TODO: EMP 테이블에서 급여(salary)가 $3,000 미만인 직원의 ID(emp_id), 이름(emp_name)과 급여(salary)를 조회
select emp_id
        ,emp_name
        , salary
from emp
where salary < 3000;


--TODO: EMP 테이블에서 급여(salary)가 $3,000 이하인 직원의 ID(emp_id), 이름(emp_name)과 급여(salary)를 조회
select emp_id
        ,emp_name
        , salary
from emp
where salary <= 3000;


--TODO: 급여(salary)가 $4,000에서 $8,000 사이에 포함된 직원들의 ID(emp_id), 이름(emp_name)과 급여(salary)를 조회
select emp_id
        ,emp_name
        , salary
from emp
where salary between 4000 and 8000;


--TODO: 급여(salary)가 $4,000에서 $8,000 사이에 포함되지 않는 모든 직원들의  ID(emp_id), 이름(emp_name), 급여(salary)를 표시
select emp_id
        ,emp_name
        , salary
from emp
where salary not between 4000 and 8000;


-- 보기에는 '07/02/21'형식으로 보이지만, 실제 data 상에서는 'yyyy-mm-dd'형식으로 되어있음.
--TODO: EMP 테이블에서 2007년 이후 입사한 직원들의  ID(emp_id), 이름(emp_name), 입사일(hire_date)을 조회.
select distinct hire_date from emp;
select emp_id
        ,emp_name
        ,hire_date
from emp
where hire_date >= '2007-01-01';
/*where to_char(hire_date,'yyyy')  > 2007;         -- hire_date에서 년도만 빼서 문자열로 변환*/
/*where hire_date >= to_date('20070101','yyyymmdd');*/
/*where hire_date >= to_date('2007','yyyy');*/     -- to_date() 활용(but, 실행 시점 월로 설정 ex)2007-05-26) => 위의 방식으로 해야함.
/*where hire_date like '07%'
or hire_date like '08%';*/


--TODO: EMP 테이블에서 2004년에 입사한 직원들의 ID(emp_id), 이름(emp_name), 입사일(hire_date)을 조회.
select emp_id
        ,emp_name
        ,hire_date
from emp
where hire_date between '2004-01-01' and '2004-12-31';
/*where hire_date like '04%';*/


--TODO: EMP 테이블에서 2005년 ~ 2007년 사이에 입사(hire_date)한 직원들의 ID(emp_id), 이름(emp_name), 업무(job), 입사일(hire_date)을 조회.
select emp_id
        ,emp_name
        ,job
        ,hire_date
from emp
where hire_date between '2005-01-01' and '2007-12-31';
/*where hire_date like '05%'
or hire_date like '06%'
or hire_date like '07%';*/


--TODO: EMP 테이블에서 직원의 ID(emp_id)가 110, 120, 130 인 직원의  ID(emp_id), 이름(emp_name), 업무(job)을 조회
select emp_id
        ,emp_name
        ,job
from emp
where emp_id in (110, 120, 130);


--TODO: EMP 테이블에서 부서(dept_name)가 'IT', 'Finance', 'Marketing' 인 직원들의 ID(emp_id), 이름(emp_name), 부서명(dept_name)을 조회.
select emp_id
        ,emp_name
        ,dept_name
from emp
where dept_name in ('IT','Finance','Marketing');


--TODO: EMP 테이블에서 'Sales' 와 'IT', 'Shipping' 부서(dept_name)가 아닌 직원들의 ID(emp_id), 이름(emp_name), 부서명(dept_name)을 조회.
select emp_id
        ,emp_name
        ,dept_name
from emp
where dept_name not in ('IT','Sales','Shipping');


--TODO: EMP 테이블에서 급여(salary)가 17,000, 9,000,  3,100 인 직원의 ID(emp_id), 이름(emp_name), 업무(job), 급여(salary)를 조회.
select emp_id
        ,emp_name
        ,job
        ,salary
from emp
where salary in (17000, 9000, 3100);


--TODO EMP 테이블에서 업무(job)에 'SA'가 들어간 직원의 ID(emp_id), 이름(emp_name), 업무(job)를 조회
select distinct job from emp;
select emp_id
        ,emp_name
        ,job
from emp
where job like 'SA%';


--TODO: EMP 테이블에서 업무(job)가 'MAN'로 끝나는 직원의 ID(emp_id), 이름(emp_name), 업무(job)를 조회
select emp_id
        ,emp_name
        ,job
from emp
where job like '%MAN';



--TODO. EMP 테이블에서 커미션이 없는(comm_pct가 null인) 모든 직원의 ID(emp_id), 이름(emp_name), 급여(salary) 및 커미션비율(comm_pct)을 조회
select emp_id
        ,emp_name
        ,salary
        ,comm_pct
from emp
where comm_pct is null;
    

--TODO: EMP 테이블에서 커미션을 받는 모든 직원의 ID(emp_id), 이름(emp_name), 급여(salary) 및 커미션비율(comm_pct)을 조회
select emp_id
        ,emp_name
        ,salary
        ,comm_pct
from emp
where comm_pct is not null;


--TODO: EMP 테이블에서 관리자 ID(mgr_id) 없는 직원의 ID(emp_id), 이름(emp_name), 업무(job), 소속부서(dept_name)를 조회
select distinct mgr_id from emp;
select emp_id
        ,emp_name
        ,job
        ,dept_name
from emp
where mgr_id is null;

-- 일반연산자: select, where 절에서 사용가능 (column)
--TODO : EMP 테이블에서 연봉(salary * 12) 이 200,000 이상인 직원들의 모든 정보를 조회.
select *
from emp
where salary*12 >= 200000;


/* *************************************
 WHERE 조건이 여러개인 경우
 AND OR
 
 참 and 참 -> 참: 조회 결과 행
 거짓 or 거짓 -> 거짓: 조회 결과 행이 아님.
 
 **연산 우선순위 : and > or
 
 --where 절은 쉼표를 쓰는게 아님, and나 or로 묶어주는 것!!
 where 조건1 and 조건2 or 조건3
 1. 조건 1 and 조건2
 2. 1결과 or 조건3
 ***or를 먼저 하려면 where 조건1 and (조건2 or 조건3)
 
***************************************/
-- EMP 테이블에서 업무(job)가 'SA_REP' 이고 급여(salary)가 $9,000 인 직원의 직원의 ID(emp_id), 이름(emp_name), 업무(job), 급여(salary)를 조회.
select emp_id
        ,job
        ,salary
from emp
where job = 'SA_REP'
and   salary = 9000;


-- EMP 테이블에서 업무(job)가 'FI_ACCOUNT' 거나 급여(salary)가 $8,000 이상인인 직원의 ID(emp_id), 이름(emp_name), 업무(job), 급여(salary)를 조회.
select emp_id
        ,job
        ,salary
from emp
where job = 'FT_ACCOUNT'
or   salary >= 8000;


--TODO: EMP 테이블에서 부서(dept_name)가 'Sales이'고 업무(job)가 'SA_MAN' 이고 급여가 $13,000 이하인 
--      직원의 ID(emp_id), 이름(emp_name), 업무(job), 급여(salary), 부서(dept_name)를 조회
select emp_id
        ,emp_name
        ,job
        ,salary
        ,dept_name
from emp
where dept_name = 'Sales'
and   job = 'SA_MAN'
and   salary <= 13000;


--TODO: EMP 테이블에서 업무(job)에 'MAN'이 들어가는 직원들 중에서 부서(dept_name)가 'Shipping' 이고 2005년이후 입사한 
--      직원들의  ID(emp_id), 이름(emp_name), 업무(job), 입사일(hire_date), 부서(dept_name)를 조회
select distinct job from emp;
select emp_id
        ,emp_name
        ,job
        ,hire_date
        ,dept_name
from emp
where job like '%MAN'
and   dept_name = 'Shipping'
and   hire_date >= '2005-01-01';



--TODO: EMP 테이블에서 입사년도가 2004년인 직원들과 급여가 $20,000 이상인 
--      직원들의 ID(emp_id), 이름(emp_name), 입사일(hire_date), 급여(salary)를 조회.
select emp_id
        ,emp_name
        ,hire_date
        ,salary
from emp
where hire_date between '2004-01-01' and '2004-12-31'
or    salary >= 20000;


--TODO : EMP 테이블에서, 부서이름(dept_name)이  'Executive'나 'Shipping' 이면서 급여(salary)가 6000 이상인 사원의 모든 정보 조회. 
select *
from emp
where salary >= 6000
and dept_name in('Executive','Shipping');
/*where salary >= 6000
and   (dept_name = 'Executive'
or   dept_name = 'Shipping');*/


--TODO: EMP 테이블에서 업무(job)에 'MAN'이 들어가는 직원들 중에서 부서이름(dept_name)이 'Marketing' 이거나 'Sales'인 
--      직원의 ID(emp_id), 이름(emp_name), 업무(job), 부서(dept_name)를 조회
select emp_id
        ,emp_name
        ,job
        ,dept_name
from emp
where job like '%MAN'
and   dept_name in ('Marketing', 'Sales');
/*where job like '%MAN'
and   (dept_name = 'Marketing'  
or  dept_name = 'Sales');*/


--TODO: EMP 테이블에서 업무(job)에 'MAN'이 들어가는 직원들 중 급여(salary)가 $10,000 이하이 거나 2008년 이후 입사한 
--      직원의 ID(emp_id), 이름(emp_name), 업무(job), 입사일(hire_date), 급여(salary)를 조회
select emp_id
        ,emp_name
        ,job
        ,hire_date
        ,salary
from emp
where job like '%MAN'
and   (salary <= 10000
or     hire_date >= '2008-01-01');


/* *************************************
order by를 이용한 정렬
- select문에 가장 마지막에 오는 구절.(select -> from  -> where -> 'oreder by')
- order by 정렬기준컬럼 정렬방식 [, 정렬기준컬럼 정렬방식,...]
- 정렬기준컬럼
	- 컬럼이름.            -----   order by salary, emp_name, job    : salary로 정렬하고, salary가 같은 애들은 emp_name으로 정렬, emp_name이 같으면, job기준으로 정렬.
	- select절에 선언된 순서.  -----   order by 6    :  6번째 열인 salary 기준으로 정렬해라.
	- 별칭이 있을 경우 별칭.   -----   order by 급여    : salary 별칭인 '급여' 기준으로 정렬해라.

- 정렬방식
	- asc : 오름차순 (기본-생략가능)
	- desc : 내림차순
        - 문자열: 특수문자 < 숫자 < 대문자 < 소문자 < 한글
        - date : 과거 < 미래	

NULL 값
ASC : 마지막.  order by 컬럼명 asc nulls first   -- asc 정렬하면 null이 맨 뒤에 나옴 -> nulls first -> null이 맨 처음에 나옴
DESC : 처음.   order by 컬럼명 desc nulls last  -- dasc 정렬하면 null이 맨 처음에 나옴 -> nulls last -> null이 맨 뒤에 나옴
-- nulls first, nulls last ==> 오라클 문법.

************************************* */

-- 직원들의 전체 정보를 직원 ID(emp_id)가 큰 순서대로 정렬해 조회
select * from emp 
order by emp_id desc;  
-- 기본값: 오름차순(asc)
-- 큰 순서대로(내림차순 = desc)


-- 직원들의 id(emp_id), 이름(emp_name), 업무(job), 급여(salary)를 
-- 업무(job) 순서대로 (A -> Z) 조회하고 업무(job)가 같은 직원들은  급여(salary)가 높은 순서대로 2차 정렬해서 조회.
select emp_id
        ,emp_name
        ,job
        ,salary
from emp
order by job, salary desc;    - job이 같은 애들끼리 정렬, job이 같은 것들은 내림차순 정렬
/*order by 3,4 desc;       컬럼 순서로 지정할 경우는 select 절에 선언한 컬럼 순서 기준!!!*/

--부서명을 부서명(dept_name)의 오름차순으로 정렬해 조회하시오.
select dept_name as "부서명"
from emp
order by dept_name;
/*order by 1;*/
/*order by "부서명";*/


--TODO: 급여(salary)가 $5,000을 넘는 직원의 ID(emp_id), 이름(emp_name), 급여(salary)를 급여가 높은 순서부터 조회
select emp_id
        ,emp_name
        , salary
from emp
where salary >= 5000
order by salary desc;
/*order by 3 desc;*/


--TODO: 급여(salary)가 $5,000에서 $10,000 사이에 포함되지 않는 모든 직원의  ID(emp_id), 이름(emp_name), 급여(salary)를 이름(emp_name)의 오름차순으로 정렬
select emp_id
        ,emp_name
        ,salary
from emp
where salary not between 5000 and 10000
order by emp_name;


--TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 업무(job), 입사일(hire_date)을 입사일(hire_date) 순(오름차순)으로 조회.
select emp_id
        ,emp_name
        ,job
        ,hire_date
from emp
order by hire_date;


--TODO: EMP 테이블에서 ID(emp_id), 이름(emp_name), 급여(salary), 입사일(hire_date)을 급여(salary) 오름차순으로 정렬하고 급여(salary)가 같은 경우는 입사일(hire_date)가 오래된 순서로 정렬.
select emp_id
        ,emp_name
        ,salary
        ,hire_date
from emp
order by salary, hire_date;


--- 추가 문제: asc/desc일때 null값 맨 앞에 나오게 하기.
select emp_name
        ,dept_name
from emp
order by dept_name nulls first;
/*orede by dept_name*/

--- 추가 문제: asc/desc일때 null값 맨 뒤에 나오게 하기.
select emp_name
        ,dept_name
from emp
order by dept_name nulls last;
/*order by dept_name;*/

--*************************************************************************
-- # 치환변수(실행할 때마다, 사용자로부터 input값을 받아서 실행)
--input값 숫자
select * from emp
where emp_id =&id;     --id번호 입력받기:  =&아무이름

--input값 문자
select * from emp
where emp_name ='&name'; 
/*where emp_name =&name;  이렇게 해서 입력할때 값에 ''붙이기*/


--input값 여러개: and로 묶어줌
select * from emp
where emp_name ='&name'
and emp_id =&id; 

-- # 치환변수를 사용하지 않겠다(off), 사용하겠다(on)
set define off;
set define on;