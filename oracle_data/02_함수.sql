 /***********************
 단일행 함수: 각 행별로 처리하는 함수
    - select 절, where 절에서 사용.
    - 집계하는 애들빼고, 다 단일행 함수다.
 다중행 함수: 전달된 컬럼의 값들을 묶어서 한번에 처리  - 결과 1개
            집계 함수(평균, 합계, 최대/최소값, 분산, 표준편차), 그룹 함수.
    - select 절, having 절에서 사용. (where절에는 사용 못함 -> sub query(서브쿼리)이용해야 쓸 수 있음)
    ex) sum()
**************************/

/* *************************************
함수 - '문자열'관련 함수
 UPPER()/ LOWER() : 대문자/소문자 로 변환
 INITCAP(): 단어 첫글자만 대문자 나머진 소문자로 변환
 LENGTH() : 글자수 조회
 LPAD(값, 크기, 채울값) : "값"을 지정한 "크기"의 고정길이 문자열로 만들고 모자라는 것은 왼쪽부터 "채울값"으로 채운다.
 RPAD(값, 크기, 채울값) : "값"을 지정한 "크기"의 고정길이 문자열로 만들고 모자라는 것은 오른쪽부터 "채울값"으로 채운다.
 SUBSTR(값, 시작index, 글자수) - "값"에서 "시작index"번째 글자부터 지정한 "글자수" 만큼의 문자열을 추출. 글자수 생략시 끝까지. 
 REPLACE(값, 찾을문자열, 변경할문자열) - "값"에서 "찾을문자열"을 "변경할문자열"로 바꾼다.
 LTRIM(값): 왼공백 제거
 RTRIM(값): 오른공백 제거
 TRIM(값): 양쪽 공백 제거
 ************************************* */
-- 연습
select upper('abc'),lower('ABC'),initcap('abc def') from dual;
select length('가나다라') from dual;  --글자수

select lpad('test', 10, '-') from dual;  -- 4글자를 고정길이 10글자로 만들어라, 나머지는 '-'로 채울것. 
select rpad('test', 10, '-') from dual;  -- 4글자를 고정길이 10글자로 만들어라, 나머지는 '-'로 채울것.
-- lpad/rpad: 채울글자 생략하면, 공백으로 채워줌

-- sub가 들어가면, 주어진 문자에서 일부만 뽑아내겠다. 라는 뜻
select substr('123456789',2,5) from dual;       -- 2번째 부터 5개 뽑아라(- 5번째 X)
-- 2: 두번째 글자(index는 1부터 시작), 5: 5글자.(글자수)

select replace('abc-def-hij', '-', '**') from dual;   -- '-'를 '**'으로 바꿔라.
select trim('       a          ') "A" from dual;   -- 양쪽 공백제거
select ltrim('       a          ') "A" from dual;   -- 왼쪽 공백제거
select rtrim('       a          ') "A" from dual;   -- 오른쪽 공백제거

-- 함수안에서 함수를 호출하는 경우  ->  안쪽 함수를 처리한 결과를 바깥쪽 함수에 전달.
select length(trim('     abc     ')) from dual;   -- 공백을 제거한, 글자수 세기


-- 함수 적용한거 별칭 가능  <- 함수를 where조건문 뿐만아니라, select의 불러오는 값 자체로 불러올 수 있음.
select emp_name "이름"
        ,length(emp_name) "글자수"
from emp
where length(emp_name) >= 7;

select lpad('$'||salary, 6, '-') "급여"   -- 자리수 맞추기. 고정길이 6자리(제일 긴 길이임)
from emp;


--EMP 테이블에서 직원의 이름(emp_name)을 모두 대문자, 소문자, 첫글자 대문자, 이름 글자수를 조회
select upper(emp_name) "대문자 이름"
        ,lower(emp_name) "소문자 이름"
        ,initcap(emp_name) "첫글자 대문자"
        ,length(emp_name)  "글자수"
from emp;

-- TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 급여(salary), 부서(dept_name)를 조회. 단 직원이름(emp_name)은 모두 대문자, 부서(dept_name)는 모두 소문자로 출력.
-- UPPER/LOWER
select emp_id
        ,upper(emp_name)
        ,salary
        ,lower(dept_name)
from emp;


--(아래 2개는 비교값의 대소문자를 확실히 모르는 가정)
--TODO: EMP 테이블에서 직원의 이름(emp_name)이 PETER인 직원의 모든 정보를 조회하시오.
select *
from emp
where upper(emp_name) = 'PETER';


--TODO: EMP 테이블에서 업무(job)가 'Sh_Clerk' 인 직원의의  ID(emp_id), 이름(emp_name), 업무(job), 급여(salary)를 조회
select emp_id
        ,emp_name
        ,job
        ,salary
from emp
where initcap(job) = 'Sh_Clerk';


--TODO: 직원 이름(emp_name) 의 자릿수를 15자리로 맞추고 글자수가 모자랄 경우 공백을 앞에 붙여 조회. 끝이 맞도록 조회
select lpad(emp_name, 15) 
from emp;

    
--TODO: EMP 테이블에서 모든 직원의 이름(emp_name)과 급여(salary)를 조회.
--(단, "급여(salary)" 열을 길이가 7인 문자열로 만들고, 길이가 7이 안될 경우 왼쪽부터 빈 칸을 '_'로 채우시오. EX) ______5000) -LPAD() 이용
select emp_name
        ,lpad(salary, 7, '_')
from emp;


-- TODO: EMP 테이블에서 이름(emp_name)이 10글자 이상인 직원들의 이름(emp_name)과 이름의 글자수 조회
select emp_name "이름"
        ,length(emp_name) "글자수"
from emp
where length(emp_name) >= 10;


-- 공백 없애고 글자수 세기
select emp_name, length(replace(emp_name, ' ', ''))
from emp
where length(replace(emp_name, ' ', '')) >= 10;


/* *************************************
함수 - 숫자관련 함수
 round(값, 자릿수) : 자릿수 이하에서 반올림 (양수 - 실수부, 음수 - 정수부)
 trunc(값, 자릿수) : 자릿수 이하에서 절삭(양수 - 실수부, 음수 - 정수부)
 - 무조건 정수로 올림/내림
     - ceil(값) : 올림
     - floor(값) : 내림 
 mod(나뉘는수, 나누는수) : 나눗셈의 나머지 연산
 
************************************* */
-- ceil/floor(): 결과가 정수로 나온다.
select ceil(50.123) "올림"  -- 반올림 X 무조건 올림!!
        ,floor(50.567) "내림"
from dual;

-- 반올림 (소수점 자릿수 지정 가능)
select round(50.12)
        ,round(50.79)
        ,round(50.123456, 2)   -- 소수점 2자리 이하인 3번째에서 반올림함
        ,round(50.123456, 5)
        ,round(567.123456, -1)  -- -1: 정수 일의자리에서 반올림
from dual;

-- 내림 (소수점 자릿수 지정 가능)
select trunc(50.12)
        ,trunc(50.79)
        ,trunc(50.123456, 2)   
        ,trunc(50.123456, 5)
        ,trunc(567.123456, -1) 
from dual;

select mod(10,3) from dual;   -- 나눈 나머지 값

select comm_pct
        ,round(comm_pct,1) 
from emp;


/*=====================================================================================*/

--TODO: EMP 테이블에서 각 직원에 대해 직원ID(emp_id), 이름(emp_name), 급여(salary) 그리고 15% 인상된 급여(salary)를 조회하는 질의를 작성하시오.
--(단, 15% 인상된 급여는 올림해서 정수로 표시하고, 별칭을 "SAL_RAISE"로 지정.)
select emp_id
        ,emp_name
        ,ceil(salary*1.15) "SAL_RAISE"
from emp;


--TODO: 위의 SQL문에서 인상 급여(sal_raise)와 급여(salary) 간의 차액을 추가로 조회 (직원ID(emp_id), 이름(emp_name), 15% 인상급여, 인상된 급여와 기존 급여(salary)와 차액)
select emp_id
        ,emp_name
        ,ceil(salary*1.15) "SAL_RAISE"
        ,ceil(salary*1.15) - salary "차액"    -- 실제로 table에 있는 컬럼/값으로 계산해야함. 조회값(SAL_RAISE)은 실제 table에 있는 값이 아니므로 계산 불가.
from emp;


-- TODO: EMP 테이블에서 '커미션이 있는' 직원들의 직원_ID(emp_id), 이름(emp_name), 커미션비율(comm_pct), 커미션비율(comm_pct)을 8% 인상한 결과를 조회.
--(단 커미션을 8% 인상한 결과는 소숫점 이하 2자리에서 반올림하고 별칭은 comm_raise로 지정)
select emp_id
        ,emp_name
        ,comm_pct
        ,round(comm_pct*1.08, 2) "comm_raise"
from emp
where comm_pct is not null;



/* *************************************
함수 - 날짜관련 계산 및 함수
Date +- 정수 : 날짜 계산.
months_between(d1, d2) -경과한 개월수(d1이 최근, d2가 과거)
add_months(d1, 정수) - 정수개월 지난 날짜. 마지막 날짜의 1개월 후는 달의 마지막 날이 된다. 
next_day(d1, '요일') - d1에서 첫번째 지정한 요일의 날짜. 요일은 한글(locale)로 지정한다.
last_day(d) - d 달의 마지막날.
extract(year|month|day from date) - date에서 year/month/day만 추출
************************************* */
-- day
select sysdate + 10 "10일 후"
        ,sysdate - 10 "10일 전"
from dual;

--month
select add_months(sysdate, 10)
        ,add_months(sysdate, -10)
        ,add_months(sysdate, 12)
from dual;

-- 경과 개월수(최신, 과거)
select months_between(sysdate, '2019-05-26')
from dual;

-- sysdate(현재)에서 첫번째로 오는 '입력 요일'의 날짜
select next_day(sysdate, '목요일') from dual;

-- 해달 월의 마지막날 날짜 
select last_day('2020-02-03') from dual;

-- - date에서 year/month/day만 추출
select extract(year from sysdate) "년도"
        ,extract(month from sysdate) "월"
        ,extract(day from sysdate) "일"
from dual;

select hire_date
        ,hire_date + 3
        ,add_months(hire_date, 3)
from emp
where extract(year from hire_date) = 2004; 


/*=======================================================*/
--TODO: EMP 테이블에서 부서이름(dept_name)이 'IT'인 직원들의 '입사일(hire_date)로 부터 10일전', 입사일과 '입사일로 부터 10일후',  의 날짜를 조회. 
select dept_name
        ,hire_date - 10 "10일 전"
        ,hire_date + 10 "10일 후"
from emp
where dept_name = 'IT';

--TODO: 부서가 'Purchasing' 인 직원의 이름(emp_name), 입사 6개월전과 입사일(hire_date), 6개월후 날짜를 조회.
select emp_name
        ,add_months(hire_date, -6)
        ,add_months(hire_date, 6)
from emp
where dept_name = 'Purchasing';

--TODO: EMP 테이블에서 입사일과 입사일 2달 후, 입사일 2달 전 날짜를 조회.
select hire_date
        ,add_months(hire_date, 2)
        ,add_months(hire_date, -2)
from emp;


-- TODO: 각 직원의 이름(emp_name), 근무 개월수 (입사일에서 현재까지의 달 수)를 계산하여 조회.
--(단 근무 개월수가 실수 일 경우 정수로 반올림. '근무개월수 내림차순으로 정렬'.)
select emp_name
        ,round(months_between(sysdate,hire_date),0)||'개월' as "근무 개월수"
        ,round(sysdate - hire_date)||'일' as "근무 일수"
from emp
order by "근무 개월수" desc;
/*order by 2 desc*/

--TODO: 직원 ID(emp_id)가 100 인 직원의 입사일 이후 첫번째 금요일의 날짜를 구하시오.
select next_day(hire_date, '금요일')
from emp
where emp_id = 100;



/* *************************************
> 데이터 타입 review
숫자: number
문자: char, varchar
날짜: date
- 숫자 -> <- '문자' -> <- 날짜     =>  '숫자 -> <- 날짜'는 불가능

> 함수 - (데이터 타입)변환 함수
to_char() : 숫자형, 날짜형을  -> 문자형으로 변환   ex) 특정 형식 문자열로 변환:  '20,000,000', '2020/03/24', '2020년03월24일'
to_number() : 문자형을 -> 숫자형으로 변환         ex) 함수, 연산을 위해: '2000'+5000 = (x)  -> 2000 + 5000
to_date() : 문자형을 -> 날짜형으로 변환           ex) 날짜 계산을 위해: add_months(...)

- 호출 구문
    - 함수(변환값, 형식)
    - 형식: 변환할 값이 어떤 형식으로 되어 있는지를 지정

형식문자 
숫자 : 0, 9, - 자릿수 지정.
        . , ',', 'L', '$'
일시 : yyyy, mm, dd, hh24, mi, ss, day(요일), am 또는 pm )
************************************* */
select to_char(20000000, '99,999,999') from dual;     -- 9: 자릿수 표현,  ','형식문자
select to_char(20000000, '00,000,000') from dual;     -- 0: 자릿수 표현,  ','형식문자

/*형식문자가 범위를 초과했을 때(남는 자리가 있을때):
- 9: 정수부의 남는 자리를 공백으로 채운다.
- 0: 정수부의 남는 자리를 0으로 채운다.
- 둘다 실수부의 남는 자리를 0으로 채운다.*/
select to_char(20000000, '999,999,999') from dual;     
select to_char(20000000, '000,000,000') from dual; 

select to_char(20000000, 'fm999999,999,999') from dual;     -- fm을 붙이면 공백 안들어옴.  (fm 항상 맨앞에 붙임)
select to_char(20000000, '0000000,000,000') from dual;     -- fm을 붙이면 공백 안들어옴.


-- 형식문자 범위가 범위보다 모자를때:   ###으로 표현됨.  => 최대길이 값에 맞춰야, 모자르는 것보다 초과되는게 나음.
select to_char(20000000, '00,000') from dual; 


select to_char(1234.567, '0,000.000') from dual;
select to_char(1234.567, '000,000.00000') from dual;
select to_char(1234.567, '999,999.99999') from dual;
-- 실수부에서 자릿수가 모자랄 경우 반올림 처리. (정수부가 모자랄 경우 #으로 표시)
select to_char(1234.567, '0,000.0') from dual;

select to_char(3000, 'fm$9,999') from dual;
-- L: local 통화 표시
select to_char(3000, 'fmL9,999') from dual;   -- 한국이니까 원표시

-- 문자열 -> number
select to_number('2,000,000','9,999,999') + 100000 from dual;  -- '9,999,999': 지금 문자열이 어떤 형식인지 알려줘야 number로 변환할 수 있음.
-- '10' 문자열인데도 불구하고 계산됨.  => '10'dmf 10(숫자)로 변환 후 계산  => 자동 형변환.
select '10' + 20 from dual;    -- 표시형식? 같은거 없으면 자동 형변환.

-- 날짜/시간
select sysdate
    ,to_char(sysdate, 'yyyy-mm-dd hh:mi:ss am') "12시간제"   -- mm: 05, m: 5, hh: 오전이든 오후든 구분이 안됨,am/pm: 둘중하나 쓰면, 오전인지 오후인지 알려달라
    ,to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss day') "24시간제"   -- hh24: 오전/오후 구분됨 24시간제니까.  --day: 요일 반환
    ,to_char(sysdate, 'yyyy"년도" mm"월" dd"일"') "년월일"   -- 형식문자 안에 글자 넣을경우 "" 쌍따옴표로 감싸야.
from dual;

-- '2020-10' 경우 날짜형식('yyyy-mm-dd')에 맞지 않아 오류남 => 날짜 형식으로 변환 후, add_months 계산해야함.
select add_months(to_date('2020-10', 'yyyy-mm'), 2) from dual;

select add_months('2020-10-20', 3) from dual;   -- 아까 문자 => 숫자로 자동 형변환처럼. 문자 => 날짜로 자동 형변환됨.


/*==========================================================================================*/
-- EMP 테이블에서 업무(job)에 "CLERK"가 들어가는 직원들의 ID(emp_id), 이름(name), 업무(job), 급여(salary)를 조회
--(급여는 단위 구분자 , 를 사용하고 앞에 $를 붙여서 출력.)
select emp_id
        ,emp_name
        ,job
        ,salary
        ,to_char(salary, '$99,999.99') salary2    -- 사전 data정보 보면 (7,2) 총 7자리 중, 소수자리 2,=> 정수자리 5
        ,to_char(salary, 'fm$99,999.99') salary3
        ,to_char(salary, '$00,000.00') salary4
from emp
where job like '%CLERK%';


-- 문자열 '20030503' 를 2003년 05월 03일 로 출력.
-- 문자열 -> date -> 문자열
select to_char(to_date('20030503', 'yyyymmdd'), 'yyyy"년" mm"월" dd"일"') from dual;

/* 날짜를 문자열로 저장할때, 일반적인 패턴
'yyyymmdd' -> char(8)
'yyyymmddhh24miss' -> char(15)
*/


-- TODO: 부서명(dept_name)이 'Finance'인 직원들의 ID(emp_id), 이름(emp_name)과 입사년도(hire_date) 4자리만 출력하시오. (ex: 2004);
--to_char()
select emp_id
        ,emp_name
        ,to_char(hire_date, 'yyyy')   -- 방법1
        ,extract(year from hire_date)  -- 방법2
from emp
where dept_name = 'Finance'
order by hire_date;


--TODO: 직원들중 11월에 입사한 직원들의 직원ID(emp_id), 이름(emp_name), 입사일(hire_date)을 조회
--to_char()
select emp_id
        ,emp_name
        ,hire_date
from emp
where to_char(hire_date,'mm') = '11';


--TODO: 2006년에 입사한 모든 직원의 이름(emp_name)과 입사일(yyyy-mm-dd 형식)을 입사일(hire_date)의 오름차순으로 조회
--to_char()
select emp_name
        ,to_char(hire_date,'yyyy-mm-dd') hire_date    -- 별칭에 ""안붙여도 되지만,  소/대문자 그대로, 공백 포함 등 할때는 감싸주기 
from emp
where to_char(hire_date,'yyyy') = '2006'
order by hire_date;


--TODO: 2004년 01월 이후 입사한 직원 조회의 이름(emp_name)과 입사일(hire_date) 조회
select emp_name
        ,hire_date
from emp
where to_char(hire_date,'yyyymm') > '200401';    -- 'yyy-mm' or 'yyyymm' or ... 가능


--TODO: 문자열 '20100107232215' 를 2010년 01월 07일 23시 22분 15초 로 출력. (dual 테입블 사용)
select to_char(to_date('20100107232215','yyyy-mm-dd-hh24-mi-ss'),    -- 'yyyymmddhh24miss' 가능
                                                            'yyyy"년" mm"월" dd"일" hh24"시" mi"분" ss"초"') 
from dual;  


/* *************************************
함수 - null 관련 함수 
    - null: 값이 없다. 모르는 값.
NVL(expr, 기본값)  - expr이 null이면 지정한 기본값을 반환****
NVL2(expr, nn, null) - expr이 null이 아니면 nn, 널이면 세번째
nullif(ex1, ex2) 둘이 같으면 null, 다르면 ex1

************************************* */
select comm_pct from emp;
-- NVL: 기본값으로 comm_pct type의 값만 지정한다.(결과 값 type이 같아야함!)
select nvl(comm_pct, 0) from emp;   -- null이면 0 반환.
select nvl(comm_pct, '없음') from emp;   --(X) null이면 '없음' 반환  but, comm_pct =  number type, '없음' = string type  => 같은 열 내에서는 type이 같아야함.

select * from emp
where nvl(comm_pct, 0) != 0;
/*where comm_pct is not null;*/

--NVL2: comm_pct type이 아닌, 결과 값 type이 같아야함!  => 결과값 '있음' or '없음' 둘중 하나  => 같은 type
select nvl2(comm_pct,'있음','없음')
from emp;

--  -1: 자동 형변환 일어나서, 문자열 '-1'로 반환됨 
    -- (앞의 값인 '있음' 문자열 기준으로 type 맞춤)  => (1,'없음')이면 '없음'문자열음 number type으로 바꿀 수 없기 때문에 error남.  
-- 모든 type을 문자열로 바꿀 수 있기 때문에, 둘 type이 달라도, 하나가(첫번째값이) 문자열이면 만능.
select nvl2(comm_pct,'있음',-1)   
from emp;

-- nullif
select nullif(10,10) from dual;  -- 둘이 같으니까 null 반환
select nullif(10,5) from dual;   -- 둘이 다르니까 첫번째 값 반환
-- 일반적 예시: select nullif(2010년판매개수컬럼, 2011년판매개수컬럼) from 판매테이블;


/*===========================================================*/
-- EMP 테이블에서 직원 ID(emp_id), 이름(emp_name), 급여(salary), 커미션비율(comm_pct)을 조회. 단 커미션비율이 NULL인 직원은 0이 출력되도록 한다..
select emp_id
        ,emp_name
        ,salary
        ,nvl(comm_pct, 0)
from emp;


--TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 업무(job), 부서(dept_name)을 조회. 부서가 없는 경우 '부서미배치'를 출력.
select emp_id
        ,emp_name
        ,job
        ,nvl(dept_name,'부서미배치')
from emp;


--TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 급여(salary), 커미션 (salary * comm_pct)을 조회. 커미션이 없는 직원은 0이 조회되록 한다.
select emp_id
        ,emp_name
        ,salary
        ,nvl(salary*comm_pct,0)
        ,to_char(nvl(salary*comm_pct,0),'L99,999')
from emp;


/* *************************************
DECODE(오라클에만 있는 함수)함수와 CASE 문
    -- CASE문을 이용해서 조건문을 만든다. (like python if/else)
decode(컬럼, [비교값, 출력값,비교값, 출력값, ...] , else출력) 
        == decode(컬럼, 비교값, 출력값,비교값, 출력값, ... , else출력) : 대괄호 없어도 됨.

case문 동등비교 (같은 컬럼 내)
case 컬럼 when 비교값 then 출력값
              [when 비교값 then 출력값]
              [else 출력값]
              end
              
case문 조건문 (컬럼 여러가지일 때)
case when 조건 then 출력값
       [when 조건 then 출력값]
       [else 출력값]
       end

************************************* */
--nvl() -> decode()
select decode(dept_name, null, '부서없음'        -- decode에서 null은 정상적으로 처리됨.
                        ,'IT','전산실'
                        ,'Finance','회계부'
                        ,dept_name) dept_name2
        ,dept_name
from emp;

select case dept_name /*when null then '부서없음'   -> 이렇게하면 null값 못잡음 */   -- case문에서는 null 정상적 처리 x
                      when 'IT' then '전산실'
                      when 'Finance' then '회계부'
                      else nvl(dept_name, '부서없음') end as "DEPT_NAME2"
            ,dept_name
from emp;

select case when dept_name is null then '부서없음'    -- is null
            else dept_name  end
from emp
order by 1 desc;


/*==================================================================================*/
--EMP테이블에서 급여와 급여의 등급을 조회하는데 급여 등급은 10000이상이면 '1등급', 10000미만이면 '2등급' 으로 나오도록 조회
select salary
        ,case when salary >= 10000 then '1등급'
            else '2등급' end "SALARY_GRADE"
from emp;


--decode()/case 를 이용한 정렬  (잘 안쓰임)
-- 직원들의 모든 정보를 조회한다. 단 정렬은 업무(job)가 'ST_CLERK', 'IT_PROG', 'PU_CLERK', 'SA_MAN' 순서대로 먼저나오도록 한다. (나머지 JOB은 상관없음)
-- decode를 order by에 넣으면 됨.
select * from emp
order by decode(job, 'ST_CLERK', 1
                    ,'IT_PROG', 2
                    ,'PU_CLERK', 3
                    ,'SA_MAN',4
                    ,5) asc;

select * from emp
order by case job when 'ST_CLERK' then 1
                  when 'IT_PROG' then 2
                  when 'PU_CLERK' then 3
                  when 'SA_MAN' then 4
                  else 5 end;


select * from emp
order by case job when 'ST_CLERK' then 1
                  when 'IT_PROG' then 2
                  when 'PU_CLERK' then 3
                  when 'SA_MAN' then 4
                  else 5 end, salary desc;    -- salary로 2차 정렬.


--TODO: EMP 테이블에서 업무(job)이 'AD_PRES'거나 'FI_ACCOUNT'거나 'PU_CLERK'인 직원들의 ID(emp_id), 이름(emp_name), 업무(job)을 조회. 
-- 업무(job)가 'AD_PRES'는 '대표', 'FI_ACCOUNT'는 '회계', 'PU_CLERK'의 경우 '구매'가 출력되도록 조회
select emp_id
        ,emp_name
        ,job
        ,case job when 'AD_PRES' then '대표'
                  when 'FI_ACCOUNT' then '회계'
                  when 'PU_CLERK' then '구매' end
from emp
where job in ('AD_PRES', 'FI_ACCOUNT', 'PU_CLERK');



--TODO: EMP 테이블에서 부서이름(dept_name)과 급여 인상분을 조회. 
--급여 인상분은 부서이름이 'IT' 이면 급여(salary)에 10%를 'Shipping' 이면 급여(salary)의 20%를 'Finance'이면 30%를 나머지는 0을 출력
-- decode 와 case문을 이용해 조회
select dept_name
        ,case dept_name when 'IT' then salary*0.1
                        when 'Shipping' then salary*0.2
                        when 'Finance' then salary*0.3
                        else 0 end
from emp;
                        


--TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 급여(salary), 인상된 급여를 조회한다. 
--단 급여 인상율은 급여가 5000 미만은 30%, 5000이상 10000 미만는 20% 10000 이상은 10% 로 한다.
select emp_id
        ,emp_name
        ,salary
        ,case when salary < 5000 then salary*1.3
              when salary between 5000 and 10000 then salary*1.2
              else salary*1.1 end
from emp;
