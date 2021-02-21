/* **************************************************************************
다중행 함수, 그룹함수
집계(Aggregation) 함수와 GROUP BY, HAVING
************************************************************************** */

/* ************************************************************
집계함수, 그룹함수, 다중행 함수     => select/having절 사용가능 (but, where절에서는 사용 못함)
- 인수(argument)는 컬럼.
  - sum(): 전체합계
  - avg(): 평균
  - min(): 최소값
  - max(): 최대값
  - stddev(): 표준편차
  - variance(): 분산
  - count(): 개수
        - 인수: 
            - 컬럼명: null을 제외한 개수   : count(column_name)
            -  *: 총 행수(null을 포함)    : count(*)

- count(*) 를 제외하고 "모든 집계함수는 null은 빼고 계산한다."
- sum, avg, stddev, variance: "number 타입에만" 사용가능.
- min, max, count :  "모든 타입"에 다 사용가능.
************************************************************* */

-- EMP 테이블에서 급여(salary)의 총합계, 평균, 최소값, 최대값, 표준편차, 분산, 총직원수를 조회 
select sum(salary) "총합계"
        ,round(avg(salary),2) "평균"
        ,min(salary) "최소값"
        ,max(salary) "최대값"
        ,ceil(stddev(salary)) "표준편차"
        ,trunc(variance(salary),2) "분산"
        ,count(*) "총개수"
from emp;

select count(comm_pct)
        ,count(*)
from emp;

-- null값은 포함 안되지만, 0은 포함됨.
select avg(comm_pct)   -- 35개의 평균
from emp;

select avg(nvl(comm_pct,0))  --전체 평균
from emp;


-- EMP 테이블에서 가장 최근 입사일(hire_date)과 가장 오래된 입사일을 조회
select max(hire_date) "최근 입사일"
        ,min(hire_date) "가장 오래된 입사일"
from emp;

select max(emp_name), min(emp_name) from emp;  -- 문자열 min/max  (특수문자 < 숫자 < 대문자 < 소문자)

-- EMP 테이블의 부서(dept_name) 의 개수를 조회
select count(dept_name) from emp;  --null값 제외하고 count


-- emp 테이블에서 job 종류의 개수 조회
select count(distinct(job)) from emp;

-- emp 테이블에서 부서(dept_name) 종류의 개수 조회
select count(distinct(dept_name)) from emp;   -- 종류 list에 나온 null값 종류 제외됨.  11개

select count(distinct(nvl(dept_name,'미배치'))) from emp; -- 12개

--TODO:  커미션 비율(comm_pct)이 있는 직원의 수를 조회
select count(comm_pct) from emp;

--TODO: 커미션 비율(comm_pct)이 없는 직원의 수를 조회
select count(*) - count(comm_pct) from emp;

/*select count(nvl(emp_pct,1))
from emp
where comm_pct is null;*/

--TODO: 가장 큰 커미션비율(comm_pct)과 과 가장 적은 커미션비율을 조회
select max(comm_pct)
        ,min(comm_pct)
from emp;


--TODO:  커미션 비율(comm_pct)의 평균을 조회. 
--소수점 이하 2자리까지 출력
select round(avg(comm_pct),2)     -- comm_pct가 있는 직원들의 평균.(35명의 평균)
from emp;

/*전체 직원의 평균(107명)
select round(avg(nvl(comm_pct,0)),2) from emp;*/

--TODO: 직원 이름(emp_name) 중 사전식으로 정렬할때 가장 나중에 위치할 이름을 조회.
select max(emp_name) from emp;


--TODO: 급여(salary)에서 최고 급여액과 최저 급여액의 차액을 출력
select max(salary) - min(salary) from emp;


--TODO: 가장 긴 이름(emp_name)이 몇글자 인지 조회.
select max(length(emp_name)) from emp;



--TODO: EMP 테이블의 부서(dept_name)가 몇종류가 있는지 조회. 
-- 고유값들의 개수
select count(distinct(dept_name)) from emp;
select count(distinct(nvl(dept_name,'a'))) from emp;



/* *****************************************************
group by 절
- 특정 컬럼(들)의 값별로(그룹별로) 나눠 집계할 때 나누는 기준컬럼을 지정하는 구문.  -- null 그룹도 계산됨.
	- 예) 업무별 급여평균. 부서-업무별 급여 합계. 성별 나이평균
- 구문: group by 컬럼명 [, 컬럼명]
	- 컬럼: 분류형(범주형, 명목형) - 부서별 급여 평균, 성별 급여 합계
	- select의 where 절 다음에!! 기술한다.
	- select 절에는 group by 에서 선언한 컬럼들만 집계함수와 같이! 올 수 있다
*******************************************************/
-- 부서별(그룹별) salary 합
select dept_name
       ,sum(salary)
from emp
group by dept_name;

select job, sum(salary)
from emp
group by job;

-- 순서
select dept_name
        ,job
        ,sum(salary)
from emp
where to_char(hire_date,'yyyy') >= '2005'
group by dept_name, job
order by dept_name;

/*==========================================================================*/
-- 업무(job)별 급여의 총합계, 평균, 최소값, 최대값, 표준편차, 분산, 직원수를 조회
select job
        ,sum(salary)
        ,round(avg(salary),2) "평균"
        ,min(salary)
        ,max(salary)
        ,round(stddev(salary),2) "표준편차"
        ,round(variance(salary),2) "분산"
        ,count(*)
from emp
group by job;

-- 입사연도 별 직원들의 급여 평균.
select to_char(hire_date,'yyyy')
        ,round(avg(salary),2)
from emp
group by to_char(hire_date,'yyyy')
order by 1;


-- 부서명(dept_name) 이 'Sales'이거나 'Purchasing' 인 직원들의 업무별 (job) 직원수를 조회
select dept_name
        ,job
        ,count(*)
from emp
where dept_name in ('Sales','Purchasing')
group by dept_name, job    -- dept_name: 대분류, job: 소분류 개념.
order by dept_name;


-- 부서(dept_name), 업무(job) 별 최대값, 평균급여(salary)를 조회.
select dept_name
        ,job
        ,max(salary)
        ,round(avg(salary))
from emp
group by dept_name, job
order by dept_name;


-- 급여(salary) 범위별 직원수를 출력. 급여 범위는 10000 미만,  10000이상 두 범주.   -- case 조건문 활용해서 범주 생성.
select case when salary < 10000 then '$10000미만'
            else '$10000이상' end
            ,count(*) "직원수"
from emp
group by case when salary < 10000 then '$10000미만'
              else '$10000이상' end;
/*group by case when salary < 10000 then '$10000미만'
              else '$10000이상' end, dept_name;*/ --뒤에 추가 가능. 그냥 조건문이라 생각하지 말고, 컬럼하나 지정했다 생각   



--TODO: 부서별(dept_name) 직원수를 조회
select dept_name
        ,count(*)
from emp
group by dept_name;


--TODO: 업무별(job) 직원수를 조회. 직원수가 많은 것부터 정렬.
select job
        ,count(*)
from emp
group by job
order by 2 desc;


--TODO: 부서명(dept_name), 업무(job)별 직원수, 최고급여(salary)를 조회. 부서이름으로 오름차순 정렬.
select dept_name
        ,job
        ,count(*)
        ,max(salary)
from emp
group by dept_name, job
order by dept_name;


--TODO: EMP 테이블에서 입사연도별(hire_date) 총 급여(salary)의 합계을 조회. 
--(급여 합계는 자리구분자 , 를 넣으시오. ex: 2,000,000)
select sum(salary) from emp;
select to_char(hire_date,'yyyy')
        ,to_char(sum(salary),'fm$9,999,999')
from emp
group by to_char(hire_date,'yyyy');


--TODO: 업무(job)와 입사년도(hire_date)별 평균 급여(salary)을 조회
select job
        ,to_char(hire_date,'yyyy')
        ,round(avg(salary),2)
from emp
group by job, to_char(hire_date,'yyyy');


--TODO: 부서별(dept_name) 직원수 조회하는데 부서명(dept_name)이 null인 것은 제외하고 조회.
select dept_name
        ,count(*)
from emp
where dept_name is not null  -- where: 집계하고싶은 행들을 걸러내는 용도로 사용.
/*and dept_name in ('IT', 'Sales','Marketing')
and salary < 10000*/
group by dept_name;


--TODO 급여 범위별 직원수를 출력. 급여 범위는 5000 미만, 5000이상 10000 미만, 10000이상 20000미만, 20000이상. 
select case when salary < 5000 then '5000미만'
            when salary < 10000 then '5000이상 10000미만'
            when salary < 20000 then '10000이상 20000미만'
            else '20000이상' end "등급" 
        ,count(*)
from emp
group by case when salary < 5000 then '5000미만'
            when salary < 10000 then '5000이상 10000미만'
            when salary < 20000 then '10000이상 20000미만'
            else '20000이상' end;


/* **************************************************************
having 절
- '집계결과'에 대한 행 제약 조건!!
- group by 다음 order by 전에 온다.
- 구문
    having 제약조건  --연산자는 where절의 연산자를 사용한다. 피연산자는 집계함수(의 결과)
************************************************************** */

-- 직원수가 10 이상인 부서의 부서명(dept_name)과 직원수를 조회
select dept_name
        ,count(*)
from emp
group by dept_name
having count(*) >= 10;    -- 그룹 연산 결과(집계한 결과)에 대해 제약 조건을 거는 것.



--TODO: 15명 이상이 입사한 년도와 (그 해에) 입사한 직원수를 조회.
select to_char(hire_date, 'yyyy') "입사년도"
        ,count(*) "직원수"
from emp
group by to_char(hire_date, 'yyyy')
having count(*) >= 15;



--TODO: 그 업무(job)을 담당하는 직원의 수가 10명 이상인 업무(job)명과 담당 직원수를 조회
select job
        ,count(*)
from emp
group by job
having count(*) >= 10;


--TODO: 평균 급여가(salary) $5000이상인 부서의 이름(dept_name)과 평균 급여(salary), 직원수를 조회
select dept_name
        ,round(avg(salary),2)
        ,count(*)
from emp
group by dept_name
having avg(salary) > 5000
order by 2;


--TODO: 평균급여가 $5,000 이상이고 총급여가 $50,000 이상인 부서의 부서명(dept_name), 평균급여와 총급여를 조회
select dept_name
        ,round(avg(salary),2)
        ,sum(salary)
from emp
group by dept_name
having avg(salary) >= 5000
and sum(salary) >= 50000;


-- TODO 직원이 2명 이상인 부서들의 이름과 급여의 표준편차를 조회
select dept_name
        ,round(stddev(salary),2) "표준편차"
        ,count(*) "직원수"
from emp
group by dept_name
having count(*) >= 2;


/* **************************************************************
- rollup : group by의 확장.
  - 두개 이상의 컬럼을 group by로 묶은 경우 '누적집계(중간집계나 총집계)'를 부분 집계에 추가해서 조회한다.
  - 구문 : group by rollup(컬럼명 [,컬럼명,..])



- grouping(), grouping_id()
  - rollup 이용한 집계시 컬럼이 각 행의 집계에 참여했는지 여부를 반환하는 함수.
  - case/decode를 이용해 레이블을 붙여 가독성을 높일 수 있다.
  - 반환값
	- 0 : 참여한 경우
	- 1 : 참여 안한 경우.
 

- grouping() 함수 
 - 구문: grouping(groupby컬럼)
 - select 절에 사용되며 rollup이나 cube와 함께 사용해야 한다.
 - group by의 컬럼이 집계함수의 집계에 참여했는지 여부를 반환
	- 반환값 0 : 참여함(부분집계함수 결과), 반환값 1: 참여 안함(누적집계의 결과)
 - 누적 집계인지 부분집계의 결과인지를 알려주는 알 수 있다. 



- grouping_id() 함수
  - 구문: grouping_id(groupby 컬럼, ..)
  - 전달한 컬럼이 집계에 사용되었는지 여부 2진수(0: 참여 안함, 1: 참여함)로 반환 한뒤 10진수로 변환해서 반환한다.
 
************************************************************** */

-- EMP 테이블에서 업무(job) 별 급여(salary)의 평균과 평균의 총계도 같이나오도록 조회.
select job
        ,round(avg(salary),2) "평균급여"
from emp
group by rollup(job);  -- null행 이름으로 전체 직원의 총 평균을 구해줌


select dept_name
        ,job
        ,sum(salary) "급여 합계"
from emp
group by rollup(dept_name, job);  -- group by에 넣었던걸, rollup으로 감싼다고 생각 -- 부서별 각 합계가 중간중간 나옴 + 총합도 나옴.


-- EMP 테이블에서 업무(JOB) 별 급여(salary)의 평균과 평균의 총계도 같이나오도록 조회.  (위에하고 똑같지만, 총계( 1- 참여안함)에 null대신 '총평균'이름 붙이기)
-- 업무 컬럼에  소계나 총계이면 '총평균'을  일반 집계이면 업무(job)을 출력
select job
        ,grouping_id(job)      -- 집계하는데 참여: 0, 참여x: 1  <- 총계/소계
        ,decode(grouping_id(job),0,job,1,'총평균')    --decode문 이용해서  0일때 job반환, 1일때 '총평균'반환
        ,round(avg(salary),2) "평균 급여"
from emp
group by rollup(job);


-- EMP 테이블에서 부서(dept_name), 업무(job) 별 salary의 합계와 직원수를 소계와 총계가 나오도록 조회
select dept_name
        ,job
        ,grouping_id(dept_name,job) 
        ,sum(salary) "급여합계"
        ,count(*) "직원수"
from emp
group by rollup(dept_name,job);


select dept_name
        ,job
        ,decode(grouping_id(dept_name,job),0,dept_name||job,
                                           1,'소계',
                                            '총집계') as label    -- 3: 총집계  <- 2**0 + 2**1 = 3
        ,sum(salary) "급여합계"
        ,count(*) "직원수"
from emp
group by rollup(dept_name,job);

/*    -- cube: 할수 있는 모든 group 조합에 대한 결과 내줌.
group by dept_name, job
group by dept_name
group by job
group by x (그룹 아무것도 안한거.)*/
select dept_name
        ,job
        ,sum(salary) "급여합계"
from emp
group by cube(dept_name, job);


--# 총계/소계 행의 경우 :  총계는 '총계', 중간집계는 '계' 로 출력
--TODO: 부서별(dept_name) 별 최대 salary와 최소 salary를 조회
select decode(grouping_id(dept_name),0,dept_name,1,'총계')
        ,max(salary)
        ,min(salary)
from emp
group by rollup(dept_name);



--TODO: 상사_id(mgr_id) 별 직원의 수와 총계를 조회하시오.
-- 반환하는 값의 타입이 다를 경우, 뒤의 것을 앞의 타입으로 변환한다.
-- 앞에 있는 type을 따름.  => 앞이 문자열이면 만사ok. : (숫자 -> 문자열 <- 날짜) type 변환 가능하기 때문.
/*select decode(grouping_id(mgr_id),0,mgr_id,'총계')*/    -- mgr_id type: number, '총계' -> number type변환 불가함. => error
select decode(grouping_id(mgr_id),1,'총계',mgr_id)   -- '총계': string, 'mgr_id' -> string type변환 rksmd
        ,count(*)
from emp
group by rollup(mgr_id);

       

--TODO: 입사연도(hire_date의 year)별 직원들의 수와 연봉 합계 그리고 총계가 같이 출력되도록 조회.
select decode(grouping_id(to_char(hire_date,'yyyy')),0,to_char(hire_date,'yyyy'),1,'총계')
        ,count(*)
        ,sum(salary)
from emp
group by rollup(to_char(hire_date,'yyyy'));




--TODO: 부서별(dept_name), 입사년도별 평균 급여(salary) 조회. 부서별 집계와 총집계가 같이 나오도록 조회
select dept_name
        ,to_char(hire_date,'yyyy')
        ,decode(grouping_id(dept_name,to_char(hire_date,'yyyy')),0,dept_name||'-'||to_char(hire_date,'yyyy')
                                                                ,1,dept_name||'소계'
                                                                ,'총집계') label   -- 3
        ,round(avg(salary),2)
from emp
group by rollup(dept_name,to_char(hire_date,'yyyy'));


/* 구문 실행 순서
5. selct
1. from
2. where
3. group by
4. having
6. order by 
*/