/* **********************************************************************************************
집합 연산자 (결합 쿼리)
- 둘 이상의 select 결과를 가지고 하는 연산.
- 구문
 select문  집합연산자 select문 [집합연산자 select문 ...] [order by 정렬컬럼 정렬방식]

-연산자  (union all만 중복허용, 나머지는 중복 제거)
  - UNION: 두 select 결과를 하나로 결합한다. 단 중복되는 행은 제거한다. (합집합)  -  중복 검사로 performance가 낮아짐
  - UNION ALL : 두 select 결과를 하나로 결합한다. 중복되는 행을 포함한다. (합집합) - 중복 검사 안해도 되니까 performnace 좋음
  - INTERSECT: 두 select 결과의 동일한 결과행만 결합한다. (교집합)   - 값이 여러개라도, 중복 값 제거하고 나옴
  - MINUS: 왼쪽 조회결과에서 오른쪽 조회결과에 없는 행만 결합한다. (차집합)  - 값이 여러개라도, 중복 값 제거하고 나옴
   
 - 규칙
  - 연산대상 select 문의 컬럼 수가 같아야 한다. 
  - 연산대상 select 문의 컬럼의 타입이 같아야 한다.
  - 연산 결과의 컬럼이름은 첫번째 왼쪽 select문의 것을 따른다.
  - order by 절은 구문의 마지막에 넣을 수 있다.
  - UNION ALL을 제외한 나머지 연산은 중복되는 행은 제거한다.
*************************************************************************************************/

-- emp 테이블의 salary 최대값와 salary 최소값, salary 평균값 조회    (원래 하던 방법처럼하면, 한행씩 해당 값이 나오는 것이 아니라, 열 3개로 나옴 )
-- 연산 결과의 컬럼이름은 첫번째 왼쪽 select문의 것을 따른다.  
-- '행이름'은 컬럼 앞에 붙이고 '쉼표'를 붙인다.  '최대급여' as "label",...
select '최대급여' as "label", max(salary) as "집계" from emp   
union all
select '최소급여', min(salary) from emp
union all
select '평균급여', round(avg(salary),2) from emp;


-- emp 테이블에서 업무별(emp.job_id) 급여 합계와 전체 직원의 급여합계를 조회.
select job_id
        ,sum(salary) as "급여합계"
from emp
group by job_id
union all
select '총급여합계', sum(salary)
from emp;

----------------------------------------------------------------------------
-- 합집합 - 중복 포함
select * from emp where dept_id in (10,20)
union all
select * from emp where dept_id in (20,30)
order by 8;

-- 합집합 - 중복 제거
select * from emp where dept_id in (10,20)
union
select * from emp where dept_id in (20,30)
order by 8;

-- 교집합: 두 조회 결과에서 공통으로 있는 것만나옴. - 중복 제거
select * from emp where dept_id in (10,20)
intersect
select * from emp where dept_id in (20,30)
order by 8;

-- 차집합: 첫번째 조회 결과에서 두번째 조회 결과에 없는 것만 나옴.  - 중복 제거
select * from emp where dept_id in (10,20)
minus
select * from emp where dept_id in (20,30)
order by 8;


select * from emp where dept_id in (10,20)
union
select * from emp where dept_id in (20,30)
union
select * from emp where dept_id in (40,50)
order by 8;



/*======================================================================================================*/
--한국 연도별 수출 품목 랭킹
drop table export_rank;
create table export_rank(
    year char(4) not null,
    ranking number(2) not null,
    item varchar2(60) not null
);
insert into export_rank values(1990, 1, '의류');
insert into export_rank values(1990, 2, '반도체');
insert into export_rank values(1990, 3, '가구');
insert into export_rank values(1990, 4, '영상기기');
insert into export_rank values(1990, 5, '선박해양구조물및부품');
insert into export_rank values(1990, 6, '컴퓨터');
insert into export_rank values(1990, 7, '음향기기');
insert into export_rank values(1990, 8, '철강판');
insert into export_rank values(1990, 9, '인조장섬유직물');
insert into export_rank values(1990, 10, '자동차');

insert into export_rank values(2000, 1, '반도체');
insert into export_rank values(2000, 2, '컴퓨터');
insert into export_rank values(2000, 3, '자동차');
insert into export_rank values(2000, 4, '석유제품');
insert into export_rank values(2000, 5, '선박해양구조물및부품');
insert into export_rank values(2000, 6, '무선통신기기');
insert into export_rank values(2000, 7, '합성수지');
insert into export_rank values(2000, 8, '철강판');
insert into export_rank values(2000, 9, '의류');
insert into export_rank values(2000, 10, '영상기기');

insert into export_rank values(2018, 1, '반도체');
insert into export_rank values(2018, 2, '석유제품');
insert into export_rank values(2018, 3, '자동차');
insert into export_rank values(2018, 4, '평판디스플레이및센서');
insert into export_rank values(2018, 5, '합성수지');
insert into export_rank values(2018, 6, '자동차부품');
insert into export_rank values(2018, 7, '철강판');
insert into export_rank values(2018, 8, '선박해양구조물및부품');
insert into export_rank values(2018, 9, '무선통신기기');
insert into export_rank values(2018, 10, '컴퓨터');

--년도별 수입 품목 랭킹
drop table import_rank;
create table import_rank(
    year char(4) not null,
    ranking number(2) not null,
    item varchar2(60) not null
);
insert into import_rank values(1990, 1, '원유');
insert into import_rank values(1990, 2, '반도체');
insert into import_rank values(1990, 3, '석유제품');
insert into import_rank values(1990, 4, '섬유및화학기계');
insert into import_rank values(1990, 5, '가죽');
insert into import_rank values(1990, 6, '컴퓨터');
insert into import_rank values(1990, 7, '철강판');
insert into import_rank values(1990, 8, '항공기및부품');
insert into import_rank values(1990, 9, '목재류');
insert into import_rank values(1990, 10, '계측제어분석기');

insert into import_rank values(2000, 1, '원유');
insert into import_rank values(2000, 2, '반도체');
insert into import_rank values(2000, 3, '컴퓨터');
insert into import_rank values(2000, 4, '석유제품');
insert into import_rank values(2000, 5, '천연가스');
insert into import_rank values(2000, 6, '반도체제조용장비');
insert into import_rank values(2000, 7, '금은및백금');
insert into import_rank values(2000, 8, '유선통신기기');
insert into import_rank values(2000, 9, '철강판');
insert into import_rank values(2000, 10, '정밀화학원료');

insert into import_rank values(2018, 1, '원유');
insert into import_rank values(2018, 2, '반도체');
insert into import_rank values(2018, 3, '천연가스');
insert into import_rank values(2018, 4, '석유제품');
insert into import_rank values(2018, 5, '반도체제조용장비');
insert into import_rank values(2018, 6, '석탄');
insert into import_rank values(2018, 7, '컴퓨터');
insert into import_rank values(2018, 8, '정밀화학원료');
insert into import_rank values(2018, 9, '자동차');
insert into import_rank values(2018, 10, '무선통신기기');

commit;

select * from import_rank;
select * from export_rank;


--TODO:  2018년(year) 수출(export_rank)과 수입(import_rank)을 동시에 많이한 품목(item)을 조회
-- 양쪽에 있는 것. intersect
select item from export_rank where year = 2018
intersect
select item from import_rank where year = 2018;


--TODO:  2018년(export_rank.year) 주요 수출 품목(export_rank.item)중 2000년에는 없는 품목 조회
-- 2018-2000
select item from export_rank where year = 2018
minus
select item from export_rank where year = 2000;


--TODO: 1990 수출(export_rank)과 수입(import_rank) 랭킹에 포함된  품목(item)들을 합쳐서 조회. 중복된 품목도 나오도록 조회
--union all
select '수출' as "label", item from export_rank where year = 1990
union all
select '수입', item from import_rank where year = 1990;


--TODO: 1990 수출(export_rank)과 수입(import_rank) 랭킹에 포함된  품목(item)들을 합쳐서 조회. 중복된 품목은 안나오도록 조회
--union
select item from export_rank where year = 1990
union
select item from import_rank where year = 1990;



--TODO: 1990년과 2018년의 공통 주요 수출 품목(export_rank.item) 조회
-- intersect
select item from export_rank where year = 1990
intersect
select item from export_rank where year = 2018;


--TODO: 1990년 주요 수출 품목(export_rank.item)중 2018년과 2000년에는 없는 품목 조회
--1990 - 2018 - 2000
select item from export_rank where year = 1990
minus
select item from export_rank where year = 2018
minus
select item from export_rank where year = 2000;


--TODO: 2000년 수입품목중(import_rank.item) 2018년에는 없는 품목을 조회.
-- 2000 - 2018
select item from import_rank where year = 2000
minus
select item from import_rank where year = 2018;


