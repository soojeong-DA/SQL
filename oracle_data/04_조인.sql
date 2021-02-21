-- ����� ���� ����
/*create user c##scott_join identified by tiger;
grant all privileges to c##scott_join;*/

-- ���̺�/������ ����
@"C:\Users\Playdata\oracle_data\hr_join_table.sql"
select * from emp;
select * from dept;
select * from job;
select * from salary_grade;

select * from emp
where emp_id = 110;

select * from dept
where dept_id = 100;

/* ****************************************
����(JOIN) �̶�
- 2�� �̻��� ���̺� �ִ� �÷����� '���ļ� ������ ���̺��� ����� ��ȸ'�ϴ� ����� ���Ѵ�.
 	- �ҽ����̺� : ���� ���� �о�� �Ѵٰ� �����ϴ� ���̺�(main info)  ex) emp table�� ��������(emp_id)
	- Ÿ�����̺� : �ҽ��� ���� �� �ҽ��� ������ ����� �Ǵ� ���̺�  ex) �� ������ �μ�����, �������...

- �ܷ�Ű (foregin key)
    - �ܷ�Ű �÷��� �̿��� join 
    - �ٸ� table���� ���輺�� ��Ÿ������.

- �� ���̺��� ��� ��ĥ���� ǥ���ϴ� ���� ���� �����̶�� �Ѵ�.
    - ���� ���꿡 ���� ��������
        - Equi join , non-equi join
- ������ ����
    - Inner Join (�󰪾���, �� ��Ī�Ǵ�)
        - ���� ���̺��� ���� ������ �����ϴ� ��鸸 ��ģ��. 
    - Outer Join(��ĥ ����� ��� null ���̶� ������ �ϴ°�  ex. emp �μ� ��ȣ ����. �μ� table�� ��ĥ�� ���ܵǴ°� �ƴ϶�, null ǥ�� )
        - ���� ���̺��� ����� ��� ����ϰ� �ٸ� �� ���̺��� ���� ������ �����ϴ� �ุ ��ģ��. ���������� �����ϴ� ���� ���� ��� NULL�� ��ģ��.
        - ���� : Left Outer Join,  Right Outer Join, Full Outer Join
    - Cross Join
        - �� ���̺��� �������� ��ȯ�Ѵ�. 
- ���� ����
    - ANSI ���� ����
        - ǥ�� SQL ����
        - ����Ŭ�� 9i ���� ����.
    - ����Ŭ ���� ����
        - ����Ŭ ���� �����̸� �ٸ� DBMS�� �������� �ʴ´�.
**************************************** */        
        -- ���̺��� ��� �׳� ���缭 ��ġ���

/* ****************************************
-- inner join : ANSI ���� ����
FROM  ���̺�a INNER JOIN ���̺�b ON �������� 

- inner�� ���� �� �� �ִ�.
**************************************** */
-- ������ ID(emp.emp_id), �̸�(emp.emp_name), �Ի�⵵(emp.hire_date), �ҼӺμ��̸�(dept.dept_name)�� ��ȸ
-- ����: (�θ���)foreign key�� (�ڽ���)primary key ���δٰ� ����!
-- emp e: emp ���̺� ��Ī e ����, dept d: dept ���̺� ��Ī d  (���� �ձ��� ���� ����)
-- select ���� e. or d. ���� �����ϳ�, �򰥸��ϱ� �׳� ���̴� �� ����
select e.emp_id
        ,e.emp_name
        ,e.hire_date
        ,d.dept_name
from emp e inner join dept d on e.dept_id = d.dept_id;   -- emp.dept_id = dept.dept_id   


-- ������ ID(emp.emp_id)�� 100�� ������ ����_ID(emp.emp_id), �̸�(emp.emp_name), �Ի�⵵(emp.hire_date), �ҼӺμ��̸�(dept.dept_name)�� ��ȸ.
select e.emp_id
        ,e.emp_name
        ,e.hire_date
        ,d.dept_name
from emp e join dept d on e.dept_id = d.dept_id   -- inner ��������! join���ᵵ inner�� �ν�!
where e.emp_id = 100;


-- ����_ID(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), ��������(job.job_title), �ҼӺμ��̸�(dept.dept_name)�� ��ȸ
-- ���̺� 3�� join  -> �ϳ���(1:1��) join�ϴ� ����
select e.emp_name
        ,e.salary
        ,j.job_title
        ,d.dept_name
from emp e join job j on e.job_id = j.job_id
            join dept d on e.dept_id = d.dept_id;


-- �μ�_ID(dept.dept_id)�� 30�� �μ��� �̸�(dept.dept_name), ��ġ(dept.loc), �� �μ��� �Ҽӵ� ������ �̸�(emp.emp_name)�� ��ȸ.
select d.dept_id
        ,d.dept_name
        ,d.loc
        ,e.emp_name
from dept d join emp e on d.dept_id = e.dept_id
where d.dept_id = 30;


-- ������ ID(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), '�޿����(salary_grade.grade)' �� ��ȸ. �޿� ��� ������������ ����
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,s.grade||'���'
from emp e join salary_grade s on e.salary between s.low_sal and s.high_sal    -- ����: salary ��� 00(low_sal)~00(high_sal) ����(between)�ϱ�! ����
order by 4;


--TODO 200����(200 ~ 299) ���� ID(emp.emp_id)�� ���� �������� ����_ID(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), 
--     �ҼӺμ��̸�(dept.dept_name), �μ���ġ(dept.loc)�� ��ȸ. ����_ID�� ������������ ����.
select emp_id from emp;
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,d.dept_name
        ,d.loc
from emp e join dept d on e.dept_id = d.dept_id
where e.emp_id between 200 and 299
order by 1;

--TODO ����(emp.job_id)�� 'FI_ACCOUNT'�� ������ ID(emp.emp_id), �̸�(emp.emp_name), ����(emp.job_id), 
--     �ҼӺμ��̸�(dept.dept_name), �μ���ġ(dept.loc)�� ��ȸ.  ����_ID�� ������������ ����.
select e.emp_id
        ,e.emp_name
        ,e.job_id
        ,d.dept_name
        ,d.loc
from emp e join dept d on d.dept_id = e.dept_id
where e.job_id = 'FI_ACCOUNT';


--TODO Ŀ�̼Ǻ���(emp.comm_pct)�� �ִ� �������� ����_ID(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), Ŀ�̼Ǻ���(emp.comm_pct), 
--     �ҼӺμ��̸�(dept.dept_name), �μ���ġ(dept.loc)�� ��ȸ. ����_ID�� ������������ ����.
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,e.comm_pct
        ,d.dept_name
        ,d.loc
from emp e join dept d on d.dept_id = e.dept_id
where e.comm_pct is not null;



--TODO 'New York'�� ��ġ��(dept.loc) �μ��� �μ�_ID(dept.dept_id), �μ��̸�(dept.dept_name), ��ġ(dept.loc), 
--     �� �μ��� �Ҽӵ� ����_ID(emp.emp_id), ���� �̸�(emp.emp_name), ����(emp.job_id)�� ��ȸ. �μ�_ID �� ������������ ����.
select d.dept_id
        ,d.dept_name
        ,d.loc
        ,e.emp_id
        ,e.emp_name
        ,e.job_id
from emp e join dept d on d.dept_id = e.dept_id
where d.loc = 'New York'
order by 1;

--TODO ����_ID(emp.emp_id), �̸�(emp.emp_name), ����_ID(emp.job_id), ������(job.job_title) �� ��ȸ.
select e.emp_id
        ,e.emp_name
        ,e.job_id
        ,j.job_title
from emp e join job j on e.job_id = j.job_id;

              
-- TODO: ���� ID �� 200 �� ������ ����_ID(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), 
--       ��������(job.job_title), �ҼӺμ��̸�(dept.dept_name)�� ��ȸ              
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,j.job_title
        ,d.dept_name
from emp e join job j on e.job_id = j.job_id
            join dept d on e.dept_id = d.dept_id
where e.emp_id = 200;


-- TODO: 'Shipping' �μ��� �μ���(dept.dept_name), ��ġ(dept.loc), �Ҽ� ������ �̸�(emp.emp_name), ������(job.job_title)�� ��ȸ. 
--       �����̸� ������������ ����
select d.dept_name
        ,d.loc
        ,e.emp_name
        ,j.job_title
from emp e join job j on e.job_id = j.job_id
            join dept d on e.dept_id = d.dept_id
where d.dept_name = 'Shipping'
order by e.emp_name desc;


-- TODO:  'San Francisco' �� �ٹ�(dept.loc)�ϴ� ������ id(emp.emp_id), �̸�(emp.emp_name), �Ի���(emp.hire_date)�� ��ȸ
--         �Ի����� 'yyyy-mm-dd' �������� ���
select e.emp_id
        ,e.emp_name
        ,to_char(e.hire_date,'yyyy-mm-dd')
        ,d.loc
from emp e join dept d on e.dept_id = d.dept_id
where d.loc = 'San Francisco';


-- TODO �μ��� �޿�(salary)�� ����� ��ȸ. �μ��̸�(dept.dept_name)�� �޿������ ���. �޿� ����� ���� ������ ����.
-- �޿��� , ���������ڿ� $ �� �ٿ� ���.
select d.dept_name
        ,to_char(round(avg(e.salary),2),'fm$9,999,999.99')    # ���������� ������, round ���� ����
from emp e join dept d on e.dept_id  = d.dept_id
group by d.dept_name
order by 2 desc;
        

--TODO ������ ID(emp.emp_id), �̸�(emp.emp_name), ������(job.job_title), �޿�(emp.salary), 
--     �޿����(salary_grade.grade), �ҼӺμ���(dept.dept_name)�� ��ȸ. ��� ������������ ����
select e.emp_id
        ,e.emp_name
        ,j.job_title
        ,e.salary
        ,s.grade
        ,d.dept_name
from emp e join job j on e.job_id = j.job_id
            join dept d on e.dept_id = d.dept_id
            join salary_grade s on e.salary between s.low_sal and s.high_sal
order by s.grade desc;


--TODO �μ��� �޿������(salary_grade.grade) 1�� �����ִ� �μ��̸�(dept.dept_name)�� 1����� ������ ��ȸ. �������� ���� �μ� ������� ����.
select d.dept_name
        ,count(*)
from dept d join emp e on d.dept_id = e.dept_id
            join salary_grade s on e.salary between s.low_sal and s.high_sal
where  s.grade = 1
group by d.dept_name
order by 2 desc;


/* ###################################################################################### 
����Ŭ ���� - ������ ǥ��sql�� ������, ������ �ٸ�
- Join�� ���̺���� from���� �����Ѵ�.
- Join ������ where���� ����Ѵ�. 

###################################################################################### */
-- ������ ID(emp.emp_id), �̸�(emp.emp_name), �Ի�⵵(emp.hire_date), �ҼӺμ��̸�(dept.dept_name)�� ��ȸ
-- �Ի�⵵�� �⵵�� ���
select e. emp_id
        ,e.emp_name
        ,to_char(e.hire_date, 'yyyy') as hire_date
        ,d.dept_name
from emp e, dept d
where e.dept_id = d.dept_id; -- join���� <= where���� ���   -- where�� �����ϸ�, cross join���� �����(��� ����� ���� ��ġ�� ��...)


-- ������ ID(emp.emp_id)�� 100�� ������ ����_ID(emp.emp_id), �̸�(emp.emp_name), �Ի�⵵(emp.hire_date), �ҼӺμ��̸�(dept.dept_name)�� ��ȸ
-- �Ի�⵵�� �⵵�� ���
select e.emp_id
        ,e.emp_name
        ,to_char(e.hire_date, 'yyyy') as hire_date
        ,d.dept_name
from emp e, dept d
where e.dept_id  = d.dept_id  --join����
and e.emp_id = 100;    -- ����   -- where���� join����, ���ǵ� �����ָ��.


-- ����_ID(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), ��������(job.job_title), �ҼӺμ��̸�(dept.dept_name)�� ��ȸ
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,j.job_title
        ,d.dept_name
from emp e, dept d, job j
where e.dept_id = d.dept_id
and e.job_id = j.job_id;


--TODO 200����(200 ~ 299) ���� ID(emp.emp_id)�� ���� �������� ����_ID(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), 
--     �ҼӺμ��̸�(dept.dept_name), �μ���ġ(dept.loc)�� ��ȸ. ����_ID�� ������������ ����.
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,d.dept_name
        ,d.loc
from emp e, dept d
where e.dept_id = d.dept_id
and e.emp_id between 200 and 299
order by e.emp_id;


--TODO ����(emp.job_id)�� 'FI_ACCOUNT'�� ������ ID(emp.emp_id), �̸�(emp.emp_name), ����(emp.job_id), 
--     �ҼӺμ��̸�(dept.dept_name), �μ���ġ(dept.loc)�� ��ȸ.  ����_ID�� ������������ ����.
select e.emp_id
        ,e.emp_name
        ,e.job_id
        ,d.dept_name
        ,d.loc
from emp e, dept d
where e.dept_id = d.dept_id
and e.job_id = 'FI_ACCOUNT'
order by 1;


--TODO Ŀ�̼Ǻ���(emp.comm_pct)�� �ִ� �������� ����_ID(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), Ŀ�̼Ǻ���(emp.comm_pct), 
--     �ҼӺμ��̸�(dept.dept_name), �μ���ġ(dept.loc)�� ��ȸ. ����_ID�� ������������ ����.
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,e.comm_pct
        ,d.dept_name
        ,d.loc
from emp e, dept d
where e.dept_id = d.dept_id
and e.comm_pct is not null
order by 1;



--TODO 'New York'�� ��ġ��(dept.loc) �μ��� �μ�_ID(dept.dept_id), �μ��̸�(dept.dept_name), ��ġ(dept.loc), 
--     �� �μ��� �Ҽӵ� ����_ID(emp.emp_id), ���� �̸�(emp.emp_name), ����(emp.job_id)�� ��ȸ. �μ�_ID �� ������������ ����.
select d.dept_id
        ,d.dept_name
        ,d.loc
        ,e.emp_id
        ,e.emp_name
        ,e.job_id
from dept d, emp e
where d.dept_id = e.dept_id
and d.loc = 'New York'
order by 1;

--TODO ����_ID(emp.emp_id), �̸�(emp.emp_name), ����_ID(emp.job_id), ������(job.job_title) �� ��ȸ.
select e.emp_id
        ,e.emp_name
        ,e.job_id
        ,j.job_title
from emp e, job j
where e.job_id = j.job_id;


             
-- TODO: ���� ID �� 200 �� ������ ����_ID(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), 
--       ��������(job.job_title), �ҼӺμ��̸�(dept.dept_name)�� ��ȸ              
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,j.job_title
        ,d.dept_name
from emp e, dept d, job j
where e.dept_id = d.dept_id
and e.job_id = j.job_id;


-- TODO: 'Shipping' �μ��� �μ���(dept.dept_name), ��ġ(dept.loc), �Ҽ� ������ �̸�(emp.emp_name), ������(job.job_title)�� ��ȸ. 
--       �����̸� ������������ ����
select d.dept_name
        ,d.loc
        ,e.emp_name
        ,j.job_title
from emp e, dept d, job j
where e.dept_id = d.dept_id
and e.job_id = j.job_id
and d.dept_name = 'Shipping'
order by 3 desc;


-- TODO:  'San Francisco' �� �ٹ�(dept.loc)�ϴ� ������ id(emp.emp_id), �̸�(emp.emp_name), �Ի���(emp.hire_date)�� ��ȸ
--         �Ի����� 'yyyy-mm-dd' �������� ���
select d.loc
        ,e.emp_id
        ,e.emp_name
        ,to_char(e.hire_date,'yyyy')
from emp e, dept d
where e.dept_id = d.dept_id
and d.loc = 'San Francisco';
        


--TODO �μ��� �޿�(salary)�� ����� ��ȸ. �μ��̸�(dept.dept_name)�� �޿������ ���. �޿� ����� ���� ������ ����.
-- �޿��� , ���������ڿ� $ �� �ٿ� ���.
select d.dept_name
        ,to_char(avg(e.salary), '$999,999.99')
from dept d, emp e
where d.dept_id = e.dept_id
group by d.dept_name
order by 2 desc;


--TODO ������ ID(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), �޿����(salary_grade.grade) �� ��ȸ. ���� id ������������ ����
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,s.grade
from emp e, salary_grade s
where e.salary between s.low_sal and s.high_sal
order by 1;


--TODO ������ ID(emp.emp_id), �̸�(emp.emp_name), ������(job.job_title), �޿�(emp.salary), 
--     �޿����(salary_grade.grade), �ҼӺμ���(dept.dept_name)�� ��ȸ. ��� ������������ ����
select e.emp_id
        ,e.emp_name
        ,j.job_title
        ,e.salary
        ,s.grade
        ,d.dept_name
from emp e, job j, salary_grade s, dept d
where e.job_id = j.job_id
and e.dept_id = d.dept_id
and e.salary between s.low_sal and s.high_sal
order by 5 desc;


--TODO �μ��� �޿������(salary_grade.grade) 1�� �����ִ� �μ��̸�(dept.dept_name)�� 1����� ������ ��ȸ. �������� ���� �μ� ������� ����.
select d.dept_name
        ,count(*)
from dept d, emp e, salary_grade s
where e.dept_id = d.dept_id
and e.salary between s.low_sal and s.high_sal
and s.grade = 1
group by d.dept_name
order by 2 desc;


/* ****************************************************
Self ����   (�ڱⰡ �ڱ� ����)
- ���������� �ϳ��� ���̺��� �ΰ��� ���̺�ó�� �����ϴ� ��.
**************************************************** */
--������ ID(emp.emp_id), �̸�(emp.emp_name), ����̸�(emp.emp_name)�� ��ȸ  -- (���id -> ���� id -> ���� name)
-- oracle join ver.
select e.emp_id  "���� ID"
        ,e.emp_name "���� �̸�"
        ,e.mgr_id "������ ��� ID"
        ,m.emp_name "��� �̸�"
from emp e, emp m  -- e: ��������, m: ��� ��Ī
where e.mgr_id = m.emp_id;

-- ansi join
select e.emp_id  "���� ID"
        ,e.emp_name "���� �̸�"
        ,e.mgr_id "������ ��� ID"
        ,m.emp_name "��� �̸�"
from emp e join emp m on e.mgr_id = m.emp_id;


-- TODO : EMP ���̺��� ���� ID(emp.emp_id)�� 110�� ������ �޿�(salary)���� ���� �޴� �������� id(emp.emp_id), 
-- �̸�(emp.emp_name), �޿�(emp.salary)�� ���� ID(emp.emp_id) ������������ ��ȸ.
--���1: ������ ������� 2�� ��ȸ
select salary from emp where emp_id = 110;
select emp_id, emp_name, salary
from emp
where salary > 8200;

--���2: �������� �̿�
select emp_id, emp_name, salary
from emp
where salary > (select salary from emp where emp_id = 110);

--���3: self join
--e1: emp_id = 110�� ������ ������ ������ �ִ� emp ���̺�
--e2: emp_id= 110�� �������� salary�� ���� �������� ������ ������ �ִ� emp ���̺�
select e2.emp_id
        ,e2.emp_name
        ,e2.salary
from emp e1 join emp e2 on e1.salary < e2.salary
where e1.emp_id = 110;

/* ****************************************************
�ƿ��� ���� (Outer Join)

-����� ���� (���� ����� ������ ���� ����� �ص� ���̵���) 
- �ҽ�(�����ؾ��ϴ����̺�)�� '�����̸� left join, �������̸� right join �����̸� full outer join'
    -> join �������� main table�� ���ʿ� ���, �����ʿ� ��Ŀ� ���� ������ ����
        -> ex) ����/main tbale: emp
                from emp e 'left join' dept d on e.dept_id = d.dept_id
                = from dept d 'right join' emp e on d.dept_id = e.dept_id

-ANSI ����
from ���̺�a [LEFT | RIGHT | FULL] OUTER JOIN ���̺�b ON ��������
- OUTER�� ���� ����.

-����Ŭ JOIN ����
- FROM ���� ������ ���̺��� ����
- WHERE ���� ���� ������ �ۼ�
    - Ÿ�� ���̺� (+) �� ���δ�.
    - FULL OUTER JOIN (���� X)
- OUTER�� ���� �� �� �ִ�.	
**************************************************** */
-- ������ id(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary), �μ���(dept.dept_name), �μ���ġ(dept.loc)�� ��ȸ. 
-- �μ��� ���� ������ ������ �������� ��ȸ. (�μ������� null). dept_name�� ������������ �����Ѵ�.
--ANSI join
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,d.dept_name
        ,d.loc
from emp e left join dept d on e.dept_id = d.dept_id   -- emp �� ������(�μ� ���� ������ ������ ������)
order by d.dept_name desc;

--oracle join
select e.emp_id
        ,e.emp_name
        ,e.salary
        ,d.dept_name
        ,d.loc
from emp e, dept d
where e.dept_id = d.dept_id(+)   -- (+): 'dept�� �߰�����(Ÿ��)��!' ��� �˷���
order by d.dept_name desc;


-- ��� �μ������� �� �μ��� ���� ���� �̸��� ��ȸ. �� �μ������� �� �������� �Ѵ�.
select d.dept_id
        ,d.dept_name
        ,d.loc
        ,e.emp_name
from dept d left join emp e on d.dept_id = e.dept_id;    -- �μ��� �� ���;��ϴϰ� left join(�ҽ�: �θ����̺�, target: �ڽ����̺�)


-- ��� ������ id(emp.emp_id), �̸�(emp.emp_name), �μ�_id(emp.dept_id)�� ��ȸ�ϴµ�
-- �μ�_id�� 80 �� �������� �μ���(dept.dept_name)�� �μ���ġ(dept.loc) �� ���� ����Ѵ�. (�μ� ID�� 80�� �ƴϸ� null�� ��������)
-- ANSI join
select e.emp_id
        ,e.emp_name
        ,e.dept_id
        ,d.dept_name
        ,d.loc
from emp e left join dept d on e.dept_id = d.dept_id and d.dept_id = 80;
--where���� d.dept_id = 80 ������ 80�� �͸� ������, �������� �ȳ���.   --> on ���� and�ϰ� ���� �߰����ָ��!(80�� �͸� ��Ī/join�Ѵٰ� ����) 

--oracle join
select e.emp_id
        ,e.emp_name
        ,e.dept_id
        ,d.dept_name
        ,d.loc
from emp e, dept d 
where e.dept_id = d.dept_id(+)
and d.dept_id(+) = 80;    --(+)ǥ�÷�, join �������� ǥ��


--TODO: ����_id(emp.emp_id)�� 100, 110, 120, 130, 140�� ������ ID(emp.emp_id), �̸�(emp.emp_name), ������(job.job_title) �� ��ȸ. 
--      �������� ���� ��� '�̹���' ���� ��ȸ
--- ANSI join
select e.emp_id
        ,e.emp_name
        ,nvl(j.job_title,'�̹���')
from emp e left join job j on e.job_id = j.job_id
where e.emp_id in (100,110,120,130,140);


--- oracle join 
select e.emp_id
        ,e.emp_name
        ,nvl(j.job_title,'�̹���')
from emp e, job j
where e.job_id = j.job_id(+)
and e.emp_id in (100,110,120,130,140);


--TODO: �μ��� ID(dept.dept_id), �μ��̸�(dept.dept_name)�� �� �μ��� ���� �������� ���� ��ȸ. 
--      ������ ���� �μ��� 0�� �������� ��ȸ�ϰ� �������� ���� �μ� ������ ��ȸ.
select count(*) from emp where dept_id is null;
select count(dept_id) from emp where dept_id is null;

--- ANSI join
select d.dept_id
        ,d.dept_name
        ,count(e.emp_id) "������"  -- count(*)����ϸ�, ������ ���� null ���� ���⶧����, 1�̻��� ���� ����(0�� �ȳ���) -- ���ݱ����� null�ΰ� ��� count(*)������.(inner join�̴ϱ�)
from emp e right join dept d on e.dept_id = d.dept_id
group by d.dept_id, d.dept_name      -- group by  2��(�̸��� ���� �μ��� �ִٰ� ���� ex. 10���� ��ȹ��, 20���� ��ȹ��...)
order by 3 desc;

--- oracle join 
select d.dept_id
        ,d.dept_name
        ,count(e.emp_id)
from dept d, emp e
where d.dept_id = e.dept_id(+)
group by d.dept_id, d.dept_name
order by 3 desc;


-- TODO: EMP ���̺��� �μ�_ID(emp.dept_id)�� 90 �� �������� id(emp.emp_id), �̸�(emp.emp_name), ����̸�(emp.emp_name), �Ի���(emp.hire_date)�� ��ȸ. 
-- �Ի����� yyyy-mm-dd �������� ���
-- ��簡�� ���� ������ '��� ����' ���
--- ANSI join
select e.dept_id "�μ� id"
        ,e.emp_id "���� id"
        ,e.emp_name "���� �̸�"
        ,nvl(m.emp_name, '��� ����') "��� �̸�"
        ,to_char(e.hire_date,'yyyy') "�Ի���"
from emp e left join emp m on e.mgr_id = m.emp_id
where e.dept_id = 90;

--- oracle join 
select e.dept_id "�μ� id"
        ,e.emp_id "���� id"
        ,e.emp_name "���� �̸�"
        ,nvl(m.emp_name, '��� ����') "��� �̸�"
        ,to_char(e.hire_date,'yyyy') "�Ի���"
from emp e, emp m 
where e.mgr_id = m.emp_id(+)
and e.dept_id = 90;



--TODO 2003��~2005�� ���̿� �Ի��� ������ id(emp.emp_id), �̸�(emp.emp_name), ������(job.job_title), �޿�(emp.salary), �Ի���(emp.hire_date),
--     ����̸�(emp.emp_name), ������Ի���(emp.hire_date), �ҼӺμ��̸�(dept.dept_name), �μ���ġ(dept.loc)�� ��ȸ.
-- �� ��簡 ���� ������ ��� ����̸�, ������Ի����� null�� ���.
-- �μ��� ���� ������ ��� null�� ��ȸ
--- ANSI join
select e.emp_id "���� id"
        ,e.emp_name "���� �̸�"
        ,j.job_title "������"
        ,e.salary "�޿�"
        ,e.hire_date "�Ի���"
        ,m.emp_name "��� �̸�"
        ,m.hire_date "��� �Ի���"
        ,d.dept_name
        ,d.loc
from emp e left join emp m on e.mgr_id = m.emp_id
            left join dept d on e.dept_id = d.dept_id
            left join job j on e.job_id = j.job_id
where to_char(e.hire_date, 'yyyy') between '2003' and '2005';


--- oracle join 
select e.emp_id "���� id"
        ,e.emp_name "���� �̸�"
        ,j.job_title "������"
        ,e.salary "�޿�"
        ,e.hire_date "�Ի���"
        ,m.emp_name "��� �̸�"
        ,m.hire_date "��� �Ի���"
        ,d.dept_name
        ,d.loc
from emp e, emp m, dept d, job j
where e.mgr_id = m.emp_id(+)
and e.dept_id = d.dept_id(+)
and e.job_id = j.job_id(+)
and to_char(e.hire_date, 'yyyy') between '2003' and '2005';
