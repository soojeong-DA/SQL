--DML: modify languge
---insert, delet, update
/* *********************************************************************
INSERT �� - �� �߰�
����
 - �����߰� :
   - INSERT INTO ���̺�� (�÷� [, �÷�]) VALUES (�� [, ��[])
   - ��� �÷��� ���� ���� ��� �÷� ���������� '���� �� �� �ִ�'.

 - ��ȸ����� INSERT �ϱ� (subquery �̿�)
   - INSERT INTO ���̺�� (�÷� [, �÷�])  SELECT ����         <- select���� ��ȸ�� ���� �� �־���
	- INSERT�� �÷��� ��ȸ��(subquery) �÷��� ������ Ÿ���� �¾ƾ� �Ѵ�.  <- ������ �¾ƾ���
	- ��� �÷��� �� ���� ��� �÷� ������ ������ �� �ִ�.
	
************************************************************************ */
-- ��� �÷��� �� �ֱ�
insert into dept (dept_id, dept_name, loc) values(500,'��ȹ��','����');    -- ��ȣ���� �������� (��, ��� �÷� ������ �� ���� ��쿡��)
insert into dept values(501,'���ź�','��õ');      -- ��ȣ ����

-- �Ϻ� �÷����� �� �ֱ�
insert into dept (dept_id, dept_name) values(502,'�����');     -- error �߻�. ���������δ� ������, loc �÷� �Ӽ��� NOT NULL�̱� ������ ������


select * from dept order by dept_id desc;
desc dept;    -- table ���� �˷���


-- ���̺� ����  ----------------------------------------------------------------------------------------------------------------
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

--��� �÷��� �� ���� ��� �÷� ���� ����() �� ���� ����
insert into emp_copy
select emp_id, emp_name, salary
from emp
where dept_id = 50;

select * from emp_copy;

insert into emp_copy (emp_id, emp_name)
select emp_id, emp_name --,salary ���ܵ�     -> salary �κ��� NULL������ ��
from emp
where dept_id = 30;

select * from emp_copy;




/*======================================================================================================*/
--TODO: �μ��� ������ �޿��� ���� ��� ���̺� ����. 
--      ��ȸ����� insert. ����: �հ�, ���, �ִ�, �ּ�, �л�, ǥ������
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

delete from salary_stat;    -- ���̺� ��ü �� ����

select * from salary_stat;

/* *********************************************************************
UPDATE : ���̺��� �÷��� ���� '����'

UPDATE ���̺��                  -- ���̺��� �ϳ��� ���� ����
SET    ������ '�÷�' = ������ ��  [, ������ �÷� = ������ ��]
[WHERE ��������]   <- ������ '��'������ ��������  (�� �������� �����ϸ�, �ش� �÷��� ��� ���� �����!!!)

-- update�� join��ü�� ���, �������� ����ؾ���

 - UPDATE: ������ '���̺�' ����
 - SET: ������ '�÷�'�� ���� ����
 - WHERE: ������ '��'�� ����. 
************************************************************************ */
update emp
set salary = 5000
where emp_id = 200;   -- emp_id�� 200�� �ุ ����


select * from emp;

rollback;     -- ������ commit ���� ������ ������ ó�� ���·� ������.   -- �����۾� �߸��������, �����ϱ� �� ���·� �ǵ����� (like control + z)
commit;      -- ���ݰ��� �� �۾��� DB�� �����Ѵ�.(�߰� ���� ����)


/*==================================================================================================================*/
-- ���� ID�� 200�� ������ �޿��� 5000���� ����
update emp
set salary = 5000
where emp_id = 200;

select * from emp where emp_id =200;

-- ���� ID�� 200�� ������ �޿��� 10% �λ��� ������ ����.
update emp
set salary = salary*1.1
where emp_id = 200;

select * from emp where emp_id =200;

-- �μ� ID�� 100�� ������ Ŀ�̼� ������ 0.2�� salary�� 3000�� ���� ������ ����.
update emp
set comm_pct = 0.2
        ,salary = salary + 3000
        ,mgr_id = 100
where dept_id = 100;

select * from emp where dept_id =100;

-- �μ� ID�� 100�� ������ Ŀ�̼� ������ null�� ����
update emp
set comm_pct = null
where dept_id = 100;

select * from emp where dept_id =100;

-- TODO: �μ� ID�� 100�� �������� �޿��� 100% �λ�
update emp
set salary = salary*2
where dept_id = 100;

select * from emp where dept_id =100;

-- TODO: IT �μ��� �������� �޿��� 3�� �λ�
update emp
set salary = salary*3
where dept_id in (select dept_id from dept where dept_name = 'IT');

-- TODO: EMP2 ���̺��� ��� �����͸� MGR_ID�� NULL�� HIRE_DATE �� �����Ͻ÷� COMM_PCT�� 0.5�� ����.
update emp
set mgr_id = null
    ,hire_date = sysdate
    ,comm_pct = 0.5;

/* *********************************************************************
DELETE : ���̺��� '��'�� ����       -- �÷��� ���� ����!! �÷� ������ error!
���� 
 - DELETE FROM '���̺��' [WHERE ��������]  -- Ư�� �� ���� ���ϸ�, ���̺� ��ü data ����.
   - WHERE: ������ ���� ����
************************************************************************ */
delete from emp;
select * from emp;

rollback;   -- ������ commit ������ rollback

delete from emp
where dept_id = 100;

select * from emp where dept_id = 100; 

-- �ڽ����̺��� �����ϴ� ���� ������ �� ����.  (���Ἲ �������� �����)
-- �����ϴ� �ڽ����̺��� ���� �����ϰų� ���� �÷��� ���� NULL�� �ٲ۵� �����Ѵ�.    (�����ϴ� ����� ��� ���־���..)

delete from dept
where dept_id = 10;

select * from dept where dept_id = 10;

/*===================================================================================================================*/
-- TODO: �μ� ID�� ���� �������� ����
delete from emp
where dept_id is null;


-- TODO: ��� ����(emp.job_id)�� 'SA_MAN'�̰� �޿�(emp.salary) �� 12000 �̸��� �������� ����.
delete from emp
where job_id = 'SA_MAN'
and salary < 12000;

-- TODO: comm_pct �� null�̰� job_id �� IT_PROG�� �������� ����
rollback;

delete from emp
where job_id = 'IT_PROG'
and comm_pct is null;


-- ��ü �����͸� ����
delete from emp_copy;    => rollback ����
truncate table emmp_copt;  => rollback �Ұ���!!!!  �ѹ� �����ϸ� �ǵ��� �� ����...

