/* **************************************************************************
서브쿼리(Sub Query)
- 쿼리안에서 select 쿼리를 사용하는 것.
- 메인 쿼리 - 서브쿼리
- 반드시 괄호로( ) 묶어줘야함!

서브쿼리가 사용되는 구
 - select절, from절, where절, having절
 
서브쿼리의 종류
- 어느 구절에 사용되었는지에 따른 구분
    - 스칼라 서브쿼리 - select 절에 사용. 반드시 서브쿼리 결과가 1행 1열(값 하나-스칼라) 0행이 조회되면 null을 반환 -- '컬럼 역할'
    - 인라인 뷰 - from 절에 사용되어 '테이블의 역할'을 한다.
서브쿼리 조회결과 행수에 따른 구분    (단일/다중에따라 코드가 좀 다름)
    - 단일행 서브쿼리 - 서브쿼리의 조회'결과 행이 ~한행~'인 것. 
    - 다중행 서브쿼리 - 서브쿼리의 조회'결과 행이 ~여러행~'인 것.
동작 방식에 따른 구분  (서브쿼리 단독으로 실행 되느냐  - 비상관   / 아니면, 서브쿼리 바깥족 값을 받아야? 실행되느냐)   => 비상관 쿼리가 대부분, 상관 쿼리는 거의 없음
    - 비상관(비연관) 서브쿼리 - 서브쿼리에 '메인쿼리의 컬럼'이 사용되지 않는다. 메인쿼리에 사용할 값을 서브쿼리가 제공하는 역할을 한다.
    - 상관(연관) 서브쿼리 - 서브쿼리에서 '메인쿼리의 컬럼'을 사용한다. 
                            메인쿼리가 먼저 수행되어 읽혀진 데이터를 서브쿼리에서 조건이 맞는지 확인하고자 할때 주로 사용한다.
************************************************************************** */
--단일행 서브쿼리  ==========================================================================================================================

-- 직원_ID(emp.emp_id)가 120번인 직원과 같은 업무(emp.job_id)가진    <- 서브쿼리 활용믄 대상
-- 직원의 id(emp_id),이름(emp.emp_name), 업무(emp.job_id), 급여(emp.salary) 조회
--- 서브쿼리 활용 X ver.
select job_id from emp where emp_id = 120;
select emp_id
        ,emp_name
        ,job_id
        ,salary
from emp
where job_id = 'ST_MAN';

--- 서브쿼리 활용 ver.   반드시 (괄호)로 묶어줘야함!
-- 서브쿼리를 먼저 실행하고, 그 조회결과를 가지고 메인쿼리 실행.
select emp_id
        ,emp_name
        ,job_id
        ,salary
from emp
where job_id = (select job_id from emp where emp_id = 120);


-- 직원_id(emp.emp_id)가 115번인 직원과 같은 업무(emp.job_id)를 하고 같은 부서(emp.dept_id)에 속한 직원들을 조회하시오.
--- 서브쿼리 활용 X ver.
select job_id, dept_id from emp where emp_id = 115;  -- PU_MAN, 30
select *
from emp
where job_id = 'PU_MAN'
and dept_id = 30;

--- 서브쿼리 활용 ver.
select *
from emp
where (job_id, dept_id) = (select job_id, dept_id from emp where emp_id = 115);    -- 서브쿼리일때만 가능!! 튜블 묶듯이, 서브쿼리 결과값 대입됨. (순서 조심, 2개이상도 가능)  
/*이거는 안됨!! 서브쿼리일때만 가능한거임.     where (job_id, dept_id) = 'PU_MAN', 30*/

-- 직원들 중 급여(emp.salary)가 전체 직원의 평균 급여보다 적은 
-- 직원들의 id(emp.emp_id), 이름(emp.emp_name), 급여(emp.salary)를 조회. 급여(emp.salary) 내림차순 정렬.
select emp_id
        ,emp_name
        ,salary
from emp
where salary < (select avg(salary) from emp)
order by 3 desc;



-- 전체 직원의 평균 급여(emp.salary) 이상을 받는 부서의  이름(dept.dept_name), 소속직원들의 평균 급여(emp.salary) 출력. 
-- 평균급여는 소숫점 2자리까지 나오고 통화표시($)와 단위 구분자 출력
select dept_name
        ,to_char(avg(salary), '$999,999.99')
from dept d left join emp e on d.dept_id = e.dept_id
group by dept_name
having avg(salary) >= (select avg(salary) from emp)    -- 전체평균 구하는 서브쿼리
order by 2;  


-- oracle ver.
select dept_name
        ,to_char(avg(salary), '$999,999.99')
from dept d, emp e
where d.dept_id = e.dept_id(+)
group by dept_name
having avg(salary) >= (select avg(salary) from emp)  
order by 2; 


-- TODO: 직원의 ID(emp.emp_id)가 145인 직원보다 많은 연봉을 받는 직원들의 이름(emp.emp_name)과 급여(emp.salary) 조회.
-- 급여가 큰 순서대로 조회
select emp_name
        ,salary
from emp
where salary > (select salary from emp where emp_id = 145)
order by 2 desc;


-- TODO: 직원의 ID(emp.emp_id)가 150인 직원과 같은 업무(emp.job_id)를 하고 같은 상사(emp.mgr_id)를 가진 직원들의 
-- id(emp.emp_id), 이름(emp.emp_name), 업무(emp.job_id), 상사(emp.mgr_id) 를 조회
select emp_id
        ,emp_name
        ,job_id
        ,mgr_id
from emp
where (job_id, mgr_id) = (select job_id, mgr_id from emp where emp_id =150);  --SQ_REP, 145



-- TODO : EMP 테이블에서 직원 이름이(emp.emp_name)이  'John'인 직원들 중에서 급여(emp.salary)가 가장 높은 직원의 salary(emp.salary)보다 많이 받는 
-- 직원들의 id(emp.emp_id), 이름(emp.emp_name), 급여(emp.salary)를 직원 ID(emp.emp_id) 오름차순으로 조회.
select emp_id
        ,emp_name
        ,salary
        ,emp_id
from emp
where salary > (select max(salary) 
                from emp 
                where emp_name = 'John');  -- 14000


-- TODO: 급여(emp.salary)가 가장 높은 직원이 속한 부서의 이름(dept.dept_name), 위치(dept.loc)를 조회.
select d.dept_name
        ,d.loc
from emp e join dept d on e.dept_id = d.dept_id
where emp_id = (select emp_id from emp where salary = (select max(salary) from emp));



-- TODO: 급여(emp.salary)를 제일 많이 받는 직원들의 이름(emp.emp_name), 부서명(dept.dept_name), 급여(emp.salary) 조회. 
--       급여는 앞에 $를 붙이고 단위구분자 , 를 출력
select e.emp_name
        ,d.dept_name
        ,to_char(e.salary, '$999,999')
from emp e left join dept d on e.dept_id = d.dept_id   -- 부서_id 
없는 사람이 급여를 가장받는 사람일 수도 있으니까. 근데 여기서는 null 없어서 상관없음
where e.salary = (select max(salary) from emp);


-- TODO: 담당 업무ID(emp.job_id) 가 'ST_CLERK'인 직원들의 평균 급여보다 적은 급여를 받는 직원들의 모든 정보를 조회. 단 업무 ID가 'ST_CLERK'이 아닌 직원들만 조회. 
select *
from emp
where salary < (select avg(salary) from emp where job_id = 'ST_CLERK')
and (job_id != 'ST_CLERK'
or job_id is null);        --이렇게 is null 조건 안붙이면, 기본적으로 null값은 안나옴(값이 있냐 없냐를 판단하는 것이기때문에).   => null값도 포함되게 하려고 추가함.
/*and nvl(job_id,' ') != 'ST_CLERK'*/   -- null값이 공백값이되어(값이 있게됨), 결과 나옴   

-- TODO: 30번 부서(emp.dept_id) 의 평균 급여(emp.salary)보다 급여가 많은 직원들의 모든 정보를 조회.
select *
from emp
where salary > (select avg(salary) from emp where dept_id = 30) --5150
order by salary;


-- TODO: EMP 테이블에서 업무(emp.job_id)가 'IT_PROG' 인 직원들의 평균 급여 이상을 받는 
-- 직원들의 id(emp.emp_id), 이름(emp.emp_name), 급여(emp.salary)를 급여 내림차순으로 조회.
select emp_id
        ,emp_name
        ,salary
from emp
where salary >= (select avg(salary) from emp where job_id = 'IT_PROG')
order by 3 desc;


-- TODO: 'IT' 부서(dept.dept_name)의 최대 급여보다 많이 받는 직원의 ID(emp.emp_id), 이름(emp.emp_name), 입사일(emp.hire_date), 부서 ID(emp.dept_id), 급여(emp.salary) 조회
-- 입사일은 "yyyy년 mm월 dd일" 형식으로 출력
-- 급여는 앞에 $를 붙이고 단위구분자 , 를 출력
select e.emp_id
        ,e.emp_name
        ,to_char(e.hire_date, 'yyyy"년" mm"월" dd"일"')
        ,e.dept_id
        ,to_char(e.salary, '$999,999')
from emp e join dept d on e.dept_id = d.dept_id
where e.salary > (select max(e.salary) from emp e join dept d on e.dept_id = d.dept_id where d.dept_name = 'IT') -- 9000
order by 5;


/* ----------------------------------------------
 다중행 서브쿼리      =====================================================================================================================
 - 서브쿼리의 조회 결과가 '여러행'인 경우
 - where절 에서의 연산자
	- in       (조회결과 값들 중에 하나)
	- 비교연산자 any : 조회된 값들 중 하나만 참이면 참 (where 컬럼 > any(서브쿼리) )
	- 비교연산자 all : 조회된 값들 모두와 참이면 참 (where 컬럼 > all(서브쿼리) )
------------------------------------------------*/
select * from emp
where emp_id in (145,146,147,148);

select * from emp
where emp_id < any(145,146,147,148);   -- 괄호안의 값들중에 하나라도 만족하면   --but, min 값으로 대체되는 경우도 있음.  

select * from emp
where emp_id > all(145,146,147,148);   -- 괄호안의 값들 전부 True일때, 조회   --but, 'max 값보다 큰' 조건으로 대체되는 경우도 있음. 활용성 적음


--'Alexander' 란 이름(emp.emp_name)을 가진 관리자(emp.mgr_id)의 
-- 부하 직원들의 ID(emp_id), 이름(emp_name), 업무(job_id), 입사년도(hire_date-년도만출력), 급여(salary)를 조회
-- 급여는 앞에 $를 붙이고 단위구분자 , 를 출력
select emp_id
        ,emp_name
        ,to_char(hire_date,'yyyy')
        ,to_char(salary, '$999,999')
        ,mgr_id
from emp
where mgr_id in (select emp_id from emp where emp_name = 'Alexander');   -- 'Alexander' 2명(103,115)


-- 직원 ID(emp.emp_id)가 101, 102, 103 인 직원들 보다 '급여(emp.salary)를 많이 받는' 직원의 모든 정보를 조회.
select *
from emp
where salary > all(select salary 
                    from emp 
                    where emp_id in (101, 102, 103));   --max로 대체가능


-- 직원 ID(emp.emp_id)가 101, 102, 103 인 직원들 중 급여가 '가장 적은 직원보다 급여를 많이 받는' 직원의 모든 정보를 조회.
select *
from emp
where salary > any(select salary 
                    from emp 
                    where emp_id in (101, 102, 103));


-- TODO : 부서 위치(dept.loc) 가 'New York'인 부서에 소속된 직원의 ID(emp.emp_id), 이름(emp.emp_name), 부서_id(emp.dept_id) 를 sub query를 이용해 조회.
select emp_id
        ,emp_name
        ,dept_id
from emp
where dept_id in (select dept_id from dept where loc = 'New York');


-- TODO : 최대 급여(job.max_salary)가 6000이하인 업무를 담당하는 직원(emp)의 모든 정보를 sub query를 이용해 조회.
select *
from emp
where job_id in (select job_id from job where max_salary <= 6000);


-- TODO: 부서_ID(emp.dept_id)가 20인 부서의 직원들 보다 급여(emp.salary)를 많이 받는 직원들의 정보를  sub query를 이용해 조회.
select *
from emp
where salary > all(select salary from emp where dept_id = 20)  --13000, 6000    <= max로 대체가능. 
order by salary;


-- TODO: 부서별 급여의 평균중 가장 적은 부서의 평균 급여보다 보다 많이 받는 직원들이 이름, 급여, 업무를 sub query를 이용해 조회
--min
select emp_name
        ,salary
        ,job_id
from emp
where salary > (select min(avg(salary)) from emp group by dept_id)   --3459
order by 2;

--any
select emp_name
        ,salary
        ,job_id
from emp
where salary > any(select avg(salary) from emp group by dept_id)   --3459
order by 2;


-- TODO: 업무 id(job_id)가 'SA_REP' 인 직원들중 가장 많은 급여를 받는 직원보다 많은 급여를 받는 직원들의 이름(emp_name), 급여(salary), 업무(job_id) 를 sub query를 이용해 조회.
select emp_name
        ,salary
        ,job_id
from emp
where salary > (select max(salary) from emp where job_id = 'SA_REP');  --11500  --9명

select emp_name
        ,salary
        ,job_id
from emp
where salary > all(select salary from emp where job_id = 'SA_REP');  --11500  --9명
-- max: all, min: any 쓴다고 생각하면됨.

select emp_name
        ,salary
        ,job_id
from emp
where emp_id in (select emp_id from emp where salary > (select max(salary) from emp where job_id = 'SA_REP'));  --11500  --9명


/* ****************************************************************
상관(연관) 쿼리   ==================================================================================================================
메인쿼리문의 조회값을 서브쿼리의 조건에서 사용하는 쿼리.
메인쿼리를 실행하고 그 결과를 바탕으로 서브쿼리의 조건절을 비교한다.
* ****************************************************************/
-- 부서별(DEPT) 급여(emp.salary)를 가장 많이 받는 직원들의 id(emp.emp_id), 이름(emp.emp_name), 연봉(emp.salary), 소속부서ID(dept.dept_id) 조회
select *
from emp e
where salary = (select max(salary)
                from emp
                where dept_id = e.dept_id); -- 바깥쪽 쿼리 실행시키면서, 한행씩 가져옴. -- e.dept_id(현재 바깥쪽에서 조회하고있는 dept_id)에서 max(salary 값)
-- 지금 조회하고 있는 90번 부서(e.dept_id => dept_id)의 최대 값(max (salary))이랑 현재 행 값(salary)이랑 같냐 비교
-- 한행씩 다 비교하기 때문에 전체행(107번) 실행됨. 하나식 비교해서, 결과 값에 넣을지 말지 결정. 

/* ******************************************************************************************************************
EXISTS, NOT EXISTS 연산자 (상관(연관)쿼리와 같이 사용된다)  '값이 있냐 없냐'
-- 서브쿼리의 결과를 만족하는 '값이 존재하는지 여부'를 확인하는 조건. 조건을 만족하는 행이 여러개라도 '한행만 있으면 더이상 검색하지 않는다'.

-- where exists(서브(상관)쿼리)
**********************************************************************************************************************/

-- 직원이 한명이상 있는 부서의 부서ID(dept.dept_id)와 이름(dept.dept_name), 위치(dept.loc)를 조회
select d.dept_id
        ,d.dept_name
        ,d.loc
from dept d
where exists(select emp_name from emp where dept_id = d.dept_id);  -- 직원이 있으면 나오고, 없으면 안나올테니.  emp_name은 구색 맞추려고 그냥 넣은것(아무값이나 넣어도됨. 1 넣어도됨


-- 직원이 한명도 없는 부서의 부서ID(dept.dept_id)와 이름(dept.dept_name), 위치(dept.loc)를 조회
select d.dept_id
        ,d.dept_name
        ,d.loc
from dept d
where not exists(select emp_name from emp e where e.dept_id = d.dept_id);


-- 부서(dept)에서 연봉(emp.salary)이 13000이상인 한명이라도 있는 부서의 부서ID(dept.dept_id)와 이름(dept.dept_name), 위치(dept.loc)를 조회
select d.dept_id
        ,d.dept_name
        ,d.loc
from dept d
where exists(select emp_id 
            from emp e 
            where e.dept_id = d.dept_id 
            and e.salary >= 13000);



/* ******************************
주문 관련 테이블들 이용.
******************************* */

--TODO: 고객(customers) 중 주문(orders)을 한번 이상 한 고객들을 조회.
select c.cust_id
        ,c.cust_name
from customers c
where exists(select order_id from orders o where o.cust_id = c.cust_id);


--TODO: 고객(customers) 중 주문(orders)을 한번도 하지 않은 고객들을 조회.
select c.cust_id
        ,c.cust_name
from customers c
where not exists(select order_id from orders o where o.cust_id = c.cust_id);


--TODO: 제품(products) 중 한번이상 주문된 제품 정보 조회
select p.product_id
        ,p.product_name
from products p
where exists(select order_id from order_items oi where oi.product_id = p.product_id);

--TODO: 제품(products)중 주문이 한번도 안된 제품 정보 조회
select p.product_id
        ,p.product_name
from products p
where not exists(select order_id from order_items oi where oi.product_id = p.product_id);

