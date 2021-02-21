/* **************************************************************************
������ �Լ�, �׷��Լ�
����(Aggregation) �Լ��� GROUP BY, HAVING
************************************************************************** */

/* ************************************************************
�����Լ�, �׷��Լ�, ������ �Լ�     => select/having�� ��밡�� (but, where�������� ��� ����)
- �μ�(argument)�� �÷�.
  - sum(): ��ü�հ�
  - avg(): ���
  - min(): �ּҰ�
  - max(): �ִ밪
  - stddev(): ǥ������
  - variance(): �л�
  - count(): ����
        - �μ�: 
            - �÷���: null�� ������ ����   : count(column_name)
            -  *: �� ���(null�� ����)    : count(*)

- count(*) �� �����ϰ� "��� �����Լ��� null�� ���� ����Ѵ�."
- sum, avg, stddev, variance: "number Ÿ�Կ���" ��밡��.
- min, max, count :  "��� Ÿ��"�� �� ��밡��.
************************************************************* */

-- EMP ���̺��� �޿�(salary)�� ���հ�, ���, �ּҰ�, �ִ밪, ǥ������, �л�, ���������� ��ȸ 
select sum(salary) "���հ�"
        ,round(avg(salary),2) "���"
        ,min(salary) "�ּҰ�"
        ,max(salary) "�ִ밪"
        ,ceil(stddev(salary)) "ǥ������"
        ,trunc(variance(salary),2) "�л�"
        ,count(*) "�Ѱ���"
from emp;

select count(comm_pct)
        ,count(*)
from emp;

-- null���� ���� �ȵ�����, 0�� ���Ե�.
select avg(comm_pct)   -- 35���� ���
from emp;

select avg(nvl(comm_pct,0))  --��ü ���
from emp;


-- EMP ���̺��� ���� �ֱ� �Ի���(hire_date)�� ���� ������ �Ի����� ��ȸ
select max(hire_date) "�ֱ� �Ի���"
        ,min(hire_date) "���� ������ �Ի���"
from emp;

select max(emp_name), min(emp_name) from emp;  -- ���ڿ� min/max  (Ư������ < ���� < �빮�� < �ҹ���)

-- EMP ���̺��� �μ�(dept_name) �� ������ ��ȸ
select count(dept_name) from emp;  --null�� �����ϰ� count


-- emp ���̺��� job ������ ���� ��ȸ
select count(distinct(job)) from emp;

-- emp ���̺��� �μ�(dept_name) ������ ���� ��ȸ
select count(distinct(dept_name)) from emp;   -- ���� list�� ���� null�� ���� ���ܵ�.  11��

select count(distinct(nvl(dept_name,'�̹�ġ'))) from emp; -- 12��

--TODO:  Ŀ�̼� ����(comm_pct)�� �ִ� ������ ���� ��ȸ
select count(comm_pct) from emp;

--TODO: Ŀ�̼� ����(comm_pct)�� ���� ������ ���� ��ȸ
select count(*) - count(comm_pct) from emp;

/*select count(nvl(emp_pct,1))
from emp
where comm_pct is null;*/

--TODO: ���� ū Ŀ�̼Ǻ���(comm_pct)�� �� ���� ���� Ŀ�̼Ǻ����� ��ȸ
select max(comm_pct)
        ,min(comm_pct)
from emp;


--TODO:  Ŀ�̼� ����(comm_pct)�� ����� ��ȸ. 
--�Ҽ��� ���� 2�ڸ����� ���
select round(avg(comm_pct),2)     -- comm_pct�� �ִ� �������� ���.(35���� ���)
from emp;

/*��ü ������ ���(107��)
select round(avg(nvl(comm_pct,0)),2) from emp;*/

--TODO: ���� �̸�(emp_name) �� ���������� �����Ҷ� ���� ���߿� ��ġ�� �̸��� ��ȸ.
select max(emp_name) from emp;


--TODO: �޿�(salary)���� �ְ� �޿��װ� ���� �޿����� ������ ���
select max(salary) - min(salary) from emp;


--TODO: ���� �� �̸�(emp_name)�� ����� ���� ��ȸ.
select max(length(emp_name)) from emp;



--TODO: EMP ���̺��� �μ�(dept_name)�� �������� �ִ��� ��ȸ. 
-- ���������� ����
select count(distinct(dept_name)) from emp;
select count(distinct(nvl(dept_name,'a'))) from emp;



/* *****************************************************
group by ��
- Ư�� �÷�(��)�� ������(�׷캰��) ���� ������ �� ������ �����÷��� �����ϴ� ����.  -- null �׷쵵 ����.
	- ��) ������ �޿����. �μ�-������ �޿� �հ�. ���� �������
- ����: group by �÷��� [, �÷���]
	- �÷�: �з���(������, �����) - �μ��� �޿� ���, ���� �޿� �հ�
	- select�� where �� ������!! ����Ѵ�.
	- select ������ group by ���� ������ �÷��鸸 �����Լ��� ����! �� �� �ִ�
*******************************************************/
-- �μ���(�׷캰) salary ��
select dept_name
       ,sum(salary)
from emp
group by dept_name;

select job, sum(salary)
from emp
group by job;

-- ����
select dept_name
        ,job
        ,sum(salary)
from emp
where to_char(hire_date,'yyyy') >= '2005'
group by dept_name, job
order by dept_name;

/*==========================================================================*/
-- ����(job)�� �޿��� ���հ�, ���, �ּҰ�, �ִ밪, ǥ������, �л�, �������� ��ȸ
select job
        ,sum(salary)
        ,round(avg(salary),2) "���"
        ,min(salary)
        ,max(salary)
        ,round(stddev(salary),2) "ǥ������"
        ,round(variance(salary),2) "�л�"
        ,count(*)
from emp
group by job;

-- �Ի翬�� �� �������� �޿� ���.
select to_char(hire_date,'yyyy')
        ,round(avg(salary),2)
from emp
group by to_char(hire_date,'yyyy')
order by 1;


-- �μ���(dept_name) �� 'Sales'�̰ų� 'Purchasing' �� �������� ������ (job) �������� ��ȸ
select dept_name
        ,job
        ,count(*)
from emp
where dept_name in ('Sales','Purchasing')
group by dept_name, job    -- dept_name: ��з�, job: �Һз� ����.
order by dept_name;


-- �μ�(dept_name), ����(job) �� �ִ밪, ��ձ޿�(salary)�� ��ȸ.
select dept_name
        ,job
        ,max(salary)
        ,round(avg(salary))
from emp
group by dept_name, job
order by dept_name;


-- �޿�(salary) ������ �������� ���. �޿� ������ 10000 �̸�,  10000�̻� �� ����.   -- case ���ǹ� Ȱ���ؼ� ���� ����.
select case when salary < 10000 then '$10000�̸�'
            else '$10000�̻�' end
            ,count(*) "������"
from emp
group by case when salary < 10000 then '$10000�̸�'
              else '$10000�̻�' end;
/*group by case when salary < 10000 then '$10000�̸�'
              else '$10000�̻�' end, dept_name;*/ --�ڿ� �߰� ����. �׳� ���ǹ��̶� �������� ����, �÷��ϳ� �����ߴ� ����   



--TODO: �μ���(dept_name) �������� ��ȸ
select dept_name
        ,count(*)
from emp
group by dept_name;


--TODO: ������(job) �������� ��ȸ. �������� ���� �ͺ��� ����.
select job
        ,count(*)
from emp
group by job
order by 2 desc;


--TODO: �μ���(dept_name), ����(job)�� ������, �ְ�޿�(salary)�� ��ȸ. �μ��̸����� �������� ����.
select dept_name
        ,job
        ,count(*)
        ,max(salary)
from emp
group by dept_name, job
order by dept_name;


--TODO: EMP ���̺��� �Ի翬����(hire_date) �� �޿�(salary)�� �հ��� ��ȸ. 
--(�޿� �հ�� �ڸ������� , �� �����ÿ�. ex: 2,000,000)
select sum(salary) from emp;
select to_char(hire_date,'yyyy')
        ,to_char(sum(salary),'fm$9,999,999')
from emp
group by to_char(hire_date,'yyyy');


--TODO: ����(job)�� �Ի�⵵(hire_date)�� ��� �޿�(salary)�� ��ȸ
select job
        ,to_char(hire_date,'yyyy')
        ,round(avg(salary),2)
from emp
group by job, to_char(hire_date,'yyyy');


--TODO: �μ���(dept_name) ������ ��ȸ�ϴµ� �μ���(dept_name)�� null�� ���� �����ϰ� ��ȸ.
select dept_name
        ,count(*)
from emp
where dept_name is not null  -- where: �����ϰ���� ����� �ɷ����� �뵵�� ���.
/*and dept_name in ('IT', 'Sales','Marketing')
and salary < 10000*/
group by dept_name;


--TODO �޿� ������ �������� ���. �޿� ������ 5000 �̸�, 5000�̻� 10000 �̸�, 10000�̻� 20000�̸�, 20000�̻�. 
select case when salary < 5000 then '5000�̸�'
            when salary < 10000 then '5000�̻� 10000�̸�'
            when salary < 20000 then '10000�̻� 20000�̸�'
            else '20000�̻�' end "���" 
        ,count(*)
from emp
group by case when salary < 5000 then '5000�̸�'
            when salary < 10000 then '5000�̻� 10000�̸�'
            when salary < 20000 then '10000�̻� 20000�̸�'
            else '20000�̻�' end;


/* **************************************************************
having ��
- '������'�� ���� �� ���� ����!!
- group by ���� order by ���� �´�.
- ����
    having ��������  --�����ڴ� where���� �����ڸ� ����Ѵ�. �ǿ����ڴ� �����Լ�(�� ���)
************************************************************** */

-- �������� 10 �̻��� �μ��� �μ���(dept_name)�� �������� ��ȸ
select dept_name
        ,count(*)
from emp
group by dept_name
having count(*) >= 10;    -- �׷� ���� ���(������ ���)�� ���� ���� ������ �Ŵ� ��.



--TODO: 15�� �̻��� �Ի��� �⵵�� (�� �ؿ�) �Ի��� �������� ��ȸ.
select to_char(hire_date, 'yyyy') "�Ի�⵵"
        ,count(*) "������"
from emp
group by to_char(hire_date, 'yyyy')
having count(*) >= 15;



--TODO: �� ����(job)�� ����ϴ� ������ ���� 10�� �̻��� ����(job)��� ��� �������� ��ȸ
select job
        ,count(*)
from emp
group by job
having count(*) >= 10;


--TODO: ��� �޿���(salary) $5000�̻��� �μ��� �̸�(dept_name)�� ��� �޿�(salary), �������� ��ȸ
select dept_name
        ,round(avg(salary),2)
        ,count(*)
from emp
group by dept_name
having avg(salary) > 5000
order by 2;


--TODO: ��ձ޿��� $5,000 �̻��̰� �ѱ޿��� $50,000 �̻��� �μ��� �μ���(dept_name), ��ձ޿��� �ѱ޿��� ��ȸ
select dept_name
        ,round(avg(salary),2)
        ,sum(salary)
from emp
group by dept_name
having avg(salary) >= 5000
and sum(salary) >= 50000;


-- TODO ������ 2�� �̻��� �μ����� �̸��� �޿��� ǥ�������� ��ȸ
select dept_name
        ,round(stddev(salary),2) "ǥ������"
        ,count(*) "������"
from emp
group by dept_name
having count(*) >= 2;


/* **************************************************************
- rollup : group by�� Ȯ��.
  - �ΰ� �̻��� �÷��� group by�� ���� ��� '��������(�߰����質 ������)'�� �κ� ���迡 �߰��ؼ� ��ȸ�Ѵ�.
  - ���� : group by rollup(�÷��� [,�÷���,..])



- grouping(), grouping_id()
  - rollup �̿��� ����� �÷��� �� ���� ���迡 �����ߴ��� ���θ� ��ȯ�ϴ� �Լ�.
  - case/decode�� �̿��� ���̺��� �ٿ� �������� ���� �� �ִ�.
  - ��ȯ��
	- 0 : ������ ���
	- 1 : ���� ���� ���.
 

- grouping() �Լ� 
 - ����: grouping(groupby�÷�)
 - select ���� ���Ǹ� rollup�̳� cube�� �Բ� ����ؾ� �Ѵ�.
 - group by�� �÷��� �����Լ��� ���迡 �����ߴ��� ���θ� ��ȯ
	- ��ȯ�� 0 : ������(�κ������Լ� ���), ��ȯ�� 1: ���� ����(���������� ���)
 - ���� �������� �κ������� ��������� �˷��ִ� �� �� �ִ�. 



- grouping_id() �Լ�
  - ����: grouping_id(groupby �÷�, ..)
  - ������ �÷��� ���迡 ���Ǿ����� ���� 2����(0: ���� ����, 1: ������)�� ��ȯ �ѵ� 10������ ��ȯ�ؼ� ��ȯ�Ѵ�.
 
************************************************************** */

-- EMP ���̺��� ����(job) �� �޿�(salary)�� ��հ� ����� �Ѱ赵 ���̳������� ��ȸ.
select job
        ,round(avg(salary),2) "��ձ޿�"
from emp
group by rollup(job);  -- null�� �̸����� ��ü ������ �� ����� ������


select dept_name
        ,job
        ,sum(salary) "�޿� �հ�"
from emp
group by rollup(dept_name, job);  -- group by�� �־�����, rollup���� ���Ѵٰ� ���� -- �μ��� �� �հ谡 �߰��߰� ���� + ���յ� ����.


-- EMP ���̺��� ����(JOB) �� �޿�(salary)�� ��հ� ����� �Ѱ赵 ���̳������� ��ȸ.  (�����ϰ� �Ȱ�����, �Ѱ�( 1- ��������)�� null��� '�����'�̸� ���̱�)
-- ���� �÷���  �Ұ質 �Ѱ��̸� '�����'��  �Ϲ� �����̸� ����(job)�� ���
select job
        ,grouping_id(job)      -- �����ϴµ� ����: 0, ����x: 1  <- �Ѱ�/�Ұ�
        ,decode(grouping_id(job),0,job,1,'�����')    --decode�� �̿��ؼ�  0�϶� job��ȯ, 1�϶� '�����'��ȯ
        ,round(avg(salary),2) "��� �޿�"
from emp
group by rollup(job);


-- EMP ���̺��� �μ�(dept_name), ����(job) �� salary�� �հ�� �������� �Ұ�� �Ѱ谡 �������� ��ȸ
select dept_name
        ,job
        ,grouping_id(dept_name,job) 
        ,sum(salary) "�޿��հ�"
        ,count(*) "������"
from emp
group by rollup(dept_name,job);


select dept_name
        ,job
        ,decode(grouping_id(dept_name,job),0,dept_name||job,
                                           1,'�Ұ�',
                                            '������') as label    -- 3: ������  <- 2**0 + 2**1 = 3
        ,sum(salary) "�޿��հ�"
        ,count(*) "������"
from emp
group by rollup(dept_name,job);

/*    -- cube: �Ҽ� �ִ� ��� group ���տ� ���� ��� ����.
group by dept_name, job
group by dept_name
group by job
group by x (�׷� �ƹ��͵� ���Ѱ�.)*/
select dept_name
        ,job
        ,sum(salary) "�޿��հ�"
from emp
group by cube(dept_name, job);


--# �Ѱ�/�Ұ� ���� ��� :  �Ѱ�� '�Ѱ�', �߰������ '��' �� ���
--TODO: �μ���(dept_name) �� �ִ� salary�� �ּ� salary�� ��ȸ
select decode(grouping_id(dept_name),0,dept_name,1,'�Ѱ�')
        ,max(salary)
        ,min(salary)
from emp
group by rollup(dept_name);



--TODO: ���_id(mgr_id) �� ������ ���� �Ѱ踦 ��ȸ�Ͻÿ�.
-- ��ȯ�ϴ� ���� Ÿ���� �ٸ� ���, ���� ���� ���� Ÿ������ ��ȯ�Ѵ�.
-- �տ� �ִ� type�� ����.  => ���� ���ڿ��̸� ����ok. : (���� -> ���ڿ� <- ��¥) type ��ȯ �����ϱ� ����.
/*select decode(grouping_id(mgr_id),0,mgr_id,'�Ѱ�')*/    -- mgr_id type: number, '�Ѱ�' -> number type��ȯ �Ұ���. => error
select decode(grouping_id(mgr_id),1,'�Ѱ�',mgr_id)   -- '�Ѱ�': string, 'mgr_id' -> string type��ȯ rksmd
        ,count(*)
from emp
group by rollup(mgr_id);

       

--TODO: �Ի翬��(hire_date�� year)�� �������� ���� ���� �հ� �׸��� �Ѱ谡 ���� ��µǵ��� ��ȸ.
select decode(grouping_id(to_char(hire_date,'yyyy')),0,to_char(hire_date,'yyyy'),1,'�Ѱ�')
        ,count(*)
        ,sum(salary)
from emp
group by rollup(to_char(hire_date,'yyyy'));




--TODO: �μ���(dept_name), �Ի�⵵�� ��� �޿�(salary) ��ȸ. �μ��� ����� �����谡 ���� �������� ��ȸ
select dept_name
        ,to_char(hire_date,'yyyy')
        ,decode(grouping_id(dept_name,to_char(hire_date,'yyyy')),0,dept_name||'-'||to_char(hire_date,'yyyy')
                                                                ,1,dept_name||'�Ұ�'
                                                                ,'������') label   -- 3
        ,round(avg(salary),2)
from emp
group by rollup(dept_name,to_char(hire_date,'yyyy'));


/* ���� ���� ����
5. selct
1. from
2. where
3. group by
4. having
6. order by 
*/