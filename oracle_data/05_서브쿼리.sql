/* **************************************************************************
��������(Sub Query)
- �����ȿ��� select ������ ����ϴ� ��.
- ���� ���� - ��������
- �ݵ�� ��ȣ��( ) ���������!

���������� ���Ǵ� ��
 - select��, from��, where��, having��
 
���������� ����
- ��� ������ ���Ǿ������� ���� ����
    - ��Į�� �������� - select ���� ���. �ݵ�� �������� ����� 1�� 1��(�� �ϳ�-��Į��) 0���� ��ȸ�Ǹ� null�� ��ȯ -- '�÷� ����'
    - �ζ��� �� - from ���� ���Ǿ� '���̺��� ����'�� �Ѵ�.
�������� ��ȸ��� ����� ���� ����    (����/���߿����� �ڵ尡 �� �ٸ�)
    - ������ �������� - ���������� ��ȸ'��� ���� ~����~'�� ��. 
    - ������ �������� - ���������� ��ȸ'��� ���� ~������~'�� ��.
���� ��Ŀ� ���� ����  (�������� �ܵ����� ���� �Ǵ���  - ����   / �ƴϸ�, �������� �ٱ��� ���� �޾ƾ�? ����Ǵ���)   => ���� ������ ��κ�, ��� ������ ���� ����
    - ����(�񿬰�) �������� - ���������� '���������� �÷�'�� ������ �ʴ´�. ���������� ����� ���� ���������� �����ϴ� ������ �Ѵ�.
    - ���(����) �������� - ������������ '���������� �÷�'�� ����Ѵ�. 
                            ���������� ���� ����Ǿ� ������ �����͸� ������������ ������ �´��� Ȯ���ϰ��� �Ҷ� �ַ� ����Ѵ�.
************************************************************************** */
--������ ��������  ==========================================================================================================================

-- ����_ID(emp.emp_id)�� 120���� ������ ���� ����(emp.job_id)����    <- �������� Ȱ��� ���
-- ������ id(emp_id),�̸�(emp.emp_name), ����(emp.job_id), �޿�(emp.salary) ��ȸ
--- �������� Ȱ�� X ver.
select job_id from emp where emp_id = 120;
select emp_id
        ,emp_name
        ,job_id
        ,salary
from emp
where job_id = 'ST_MAN';

--- �������� Ȱ�� ver.   �ݵ�� (��ȣ)�� ���������!
-- ���������� ���� �����ϰ�, �� ��ȸ����� ������ �������� ����.
select emp_id
        ,emp_name
        ,job_id
        ,salary
from emp
where job_id = (select job_id from emp where emp_id = 120);


-- ����_id(emp.emp_id)�� 115���� ������ ���� ����(emp.job_id)�� �ϰ� ���� �μ�(emp.dept_id)�� ���� �������� ��ȸ�Ͻÿ�.
--- �������� Ȱ�� X ver.
select job_id, dept_id from emp where emp_id = 115;  -- PU_MAN, 30
select *
from emp
where job_id = 'PU_MAN'
and dept_id = 30;

--- �������� Ȱ�� ver.
select *
from emp
where (job_id, dept_id) = (select job_id, dept_id from emp where emp_id = 115);    -- ���������϶��� ����!! Ʃ�� ������, �������� ����� ���Ե�. (���� ����, 2���̻� ����)  
/*�̰Ŵ� �ȵ�!! ���������϶��� �����Ѱ���.     where (job_id, dept_id) = 'PU_MAN', 30*/

-- ������ �� �޿�(emp.salary)�� ��ü ������ ��� �޿����� ���� 
-- �������� id(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary)�� ��ȸ. �޿�(emp.salary) �������� ����.
select emp_id
        ,emp_name
        ,salary
from emp
where salary < (select avg(salary) from emp)
order by 3 desc;



-- ��ü ������ ��� �޿�(emp.salary) �̻��� �޴� �μ���  �̸�(dept.dept_name), �Ҽ��������� ��� �޿�(emp.salary) ���. 
-- ��ձ޿��� �Ҽ��� 2�ڸ����� ������ ��ȭǥ��($)�� ���� ������ ���
select dept_name
        ,to_char(avg(salary), '$999,999.99')
from dept d left join emp e on d.dept_id = e.dept_id
group by dept_name
having avg(salary) >= (select avg(salary) from emp)    -- ��ü��� ���ϴ� ��������
order by 2;  


-- oracle ver.
select dept_name
        ,to_char(avg(salary), '$999,999.99')
from dept d, emp e
where d.dept_id = e.dept_id(+)
group by dept_name
having avg(salary) >= (select avg(salary) from emp)  
order by 2; 


-- TODO: ������ ID(emp.emp_id)�� 145�� �������� ���� ������ �޴� �������� �̸�(emp.emp_name)�� �޿�(emp.salary) ��ȸ.
-- �޿��� ū ������� ��ȸ
select emp_name
        ,salary
from emp
where salary > (select salary from emp where emp_id = 145)
order by 2 desc;


-- TODO: ������ ID(emp.emp_id)�� 150�� ������ ���� ����(emp.job_id)�� �ϰ� ���� ���(emp.mgr_id)�� ���� �������� 
-- id(emp.emp_id), �̸�(emp.emp_name), ����(emp.job_id), ���(emp.mgr_id) �� ��ȸ
select emp_id
        ,emp_name
        ,job_id
        ,mgr_id
from emp
where (job_id, mgr_id) = (select job_id, mgr_id from emp where emp_id =150);  --SQ_REP, 145



-- TODO : EMP ���̺��� ���� �̸���(emp.emp_name)��  'John'�� ������ �߿��� �޿�(emp.salary)�� ���� ���� ������ salary(emp.salary)���� ���� �޴� 
-- �������� id(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary)�� ���� ID(emp.emp_id) ������������ ��ȸ.
select emp_id
        ,emp_name
        ,salary
        ,emp_id
from emp
where salary > (select max(salary) 
                from emp 
                where emp_name = 'John');  -- 14000


-- TODO: �޿�(emp.salary)�� ���� ���� ������ ���� �μ��� �̸�(dept.dept_name), ��ġ(dept.loc)�� ��ȸ.
select d.dept_name
        ,d.loc
from emp e join dept d on e.dept_id = d.dept_id
where emp_id = (select emp_id from emp where salary = (select max(salary) from emp));



-- TODO: �޿�(emp.salary)�� ���� ���� �޴� �������� �̸�(emp.emp_name), �μ���(dept.dept_name), �޿�(emp.salary) ��ȸ. 
--       �޿��� �տ� $�� ���̰� ���������� , �� ���
select e.emp_name
        ,d.dept_name
        ,to_char(e.salary, '$999,999')
from emp e left join dept d on e.dept_id = d.dept_id   -- �μ�_id 
���� ����� �޿��� ����޴� ����� ���� �����ϱ�. �ٵ� ���⼭�� null ��� �������
where e.salary = (select max(salary) from emp);


-- TODO: ��� ����ID(emp.job_id) �� 'ST_CLERK'�� �������� ��� �޿����� ���� �޿��� �޴� �������� ��� ������ ��ȸ. �� ���� ID�� 'ST_CLERK'�� �ƴ� �����鸸 ��ȸ. 
select *
from emp
where salary < (select avg(salary) from emp where job_id = 'ST_CLERK')
and (job_id != 'ST_CLERK'
or job_id is null);        --�̷��� is null ���� �Ⱥ��̸�, �⺻������ null���� �ȳ���(���� �ֳ� ���ĸ� �Ǵ��ϴ� ���̱⶧����).   => null���� ���Եǰ� �Ϸ��� �߰���.
/*and nvl(job_id,' ') != 'ST_CLERK'*/   -- null���� ���鰪�̵Ǿ�(���� �ְԵ�), ��� ����   

-- TODO: 30�� �μ�(emp.dept_id) �� ��� �޿�(emp.salary)���� �޿��� ���� �������� ��� ������ ��ȸ.
select *
from emp
where salary > (select avg(salary) from emp where dept_id = 30) --5150
order by salary;


-- TODO: EMP ���̺��� ����(emp.job_id)�� 'IT_PROG' �� �������� ��� �޿� �̻��� �޴� 
-- �������� id(emp.emp_id), �̸�(emp.emp_name), �޿�(emp.salary)�� �޿� ������������ ��ȸ.
select emp_id
        ,emp_name
        ,salary
from emp
where salary >= (select avg(salary) from emp where job_id = 'IT_PROG')
order by 3 desc;


-- TODO: 'IT' �μ�(dept.dept_name)�� �ִ� �޿����� ���� �޴� ������ ID(emp.emp_id), �̸�(emp.emp_name), �Ի���(emp.hire_date), �μ� ID(emp.dept_id), �޿�(emp.salary) ��ȸ
-- �Ի����� "yyyy�� mm�� dd��" �������� ���
-- �޿��� �տ� $�� ���̰� ���������� , �� ���
select e.emp_id
        ,e.emp_name
        ,to_char(e.hire_date, 'yyyy"��" mm"��" dd"��"')
        ,e.dept_id
        ,to_char(e.salary, '$999,999')
from emp e join dept d on e.dept_id = d.dept_id
where e.salary > (select max(e.salary) from emp e join dept d on e.dept_id = d.dept_id where d.dept_name = 'IT') -- 9000
order by 5;


/* ----------------------------------------------
 ������ ��������      =====================================================================================================================
 - ���������� ��ȸ ����� '������'�� ���
 - where�� ������ ������
	- in       (��ȸ��� ���� �߿� �ϳ�)
	- �񱳿����� any : ��ȸ�� ���� �� �ϳ��� ���̸� �� (where �÷� > any(��������) )
	- �񱳿����� all : ��ȸ�� ���� ��ο� ���̸� �� (where �÷� > all(��������) )
------------------------------------------------*/
select * from emp
where emp_id in (145,146,147,148);

select * from emp
where emp_id < any(145,146,147,148);   -- ��ȣ���� �����߿� �ϳ��� �����ϸ�   --but, min ������ ��ü�Ǵ� ��쵵 ����.  

select * from emp
where emp_id > all(145,146,147,148);   -- ��ȣ���� ���� ���� True�϶�, ��ȸ   --but, 'max ������ ū' �������� ��ü�Ǵ� ��쵵 ����. Ȱ�뼺 ����


--'Alexander' �� �̸�(emp.emp_name)�� ���� ������(emp.mgr_id)�� 
-- ���� �������� ID(emp_id), �̸�(emp_name), ����(job_id), �Ի�⵵(hire_date-�⵵�����), �޿�(salary)�� ��ȸ
-- �޿��� �տ� $�� ���̰� ���������� , �� ���
select emp_id
        ,emp_name
        ,to_char(hire_date,'yyyy')
        ,to_char(salary, '$999,999')
        ,mgr_id
from emp
where mgr_id in (select emp_id from emp where emp_name = 'Alexander');   -- 'Alexander' 2��(103,115)


-- ���� ID(emp.emp_id)�� 101, 102, 103 �� ������ ���� '�޿�(emp.salary)�� ���� �޴�' ������ ��� ������ ��ȸ.
select *
from emp
where salary > all(select salary 
                    from emp 
                    where emp_id in (101, 102, 103));   --max�� ��ü����


-- ���� ID(emp.emp_id)�� 101, 102, 103 �� ������ �� �޿��� '���� ���� �������� �޿��� ���� �޴�' ������ ��� ������ ��ȸ.
select *
from emp
where salary > any(select salary 
                    from emp 
                    where emp_id in (101, 102, 103));


-- TODO : �μ� ��ġ(dept.loc) �� 'New York'�� �μ��� �Ҽӵ� ������ ID(emp.emp_id), �̸�(emp.emp_name), �μ�_id(emp.dept_id) �� sub query�� �̿��� ��ȸ.
select emp_id
        ,emp_name
        ,dept_id
from emp
where dept_id in (select dept_id from dept where loc = 'New York');


-- TODO : �ִ� �޿�(job.max_salary)�� 6000������ ������ ����ϴ� ����(emp)�� ��� ������ sub query�� �̿��� ��ȸ.
select *
from emp
where job_id in (select job_id from job where max_salary <= 6000);


-- TODO: �μ�_ID(emp.dept_id)�� 20�� �μ��� ������ ���� �޿�(emp.salary)�� ���� �޴� �������� ������  sub query�� �̿��� ��ȸ.
select *
from emp
where salary > all(select salary from emp where dept_id = 20)  --13000, 6000    <= max�� ��ü����. 
order by salary;


-- TODO: �μ��� �޿��� ����� ���� ���� �μ��� ��� �޿����� ���� ���� �޴� �������� �̸�, �޿�, ������ sub query�� �̿��� ��ȸ
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


-- TODO: ���� id(job_id)�� 'SA_REP' �� �������� ���� ���� �޿��� �޴� �������� ���� �޿��� �޴� �������� �̸�(emp_name), �޿�(salary), ����(job_id) �� sub query�� �̿��� ��ȸ.
select emp_name
        ,salary
        ,job_id
from emp
where salary > (select max(salary) from emp where job_id = 'SA_REP');  --11500  --9��

select emp_name
        ,salary
        ,job_id
from emp
where salary > all(select salary from emp where job_id = 'SA_REP');  --11500  --9��
-- max: all, min: any ���ٰ� �����ϸ��.

select emp_name
        ,salary
        ,job_id
from emp
where emp_id in (select emp_id from emp where salary > (select max(salary) from emp where job_id = 'SA_REP'));  --11500  --9��


/* ****************************************************************
���(����) ����   ==================================================================================================================
������������ ��ȸ���� ���������� ���ǿ��� ����ϴ� ����.
���������� �����ϰ� �� ����� �������� ���������� �������� ���Ѵ�.
* ****************************************************************/
-- �μ���(DEPT) �޿�(emp.salary)�� ���� ���� �޴� �������� id(emp.emp_id), �̸�(emp.emp_name), ����(emp.salary), �ҼӺμ�ID(dept.dept_id) ��ȸ
select *
from emp e
where salary = (select max(salary)
                from emp
                where dept_id = e.dept_id); -- �ٱ��� ���� �����Ű�鼭, ���྿ ������. -- e.dept_id(���� �ٱ��ʿ��� ��ȸ�ϰ��ִ� dept_id)���� max(salary ��)
-- ���� ��ȸ�ϰ� �ִ� 90�� �μ�(e.dept_id => dept_id)�� �ִ� ��(max (salary))�̶� ���� �� ��(salary)�̶� ���� ��
-- ���྿ �� ���ϱ� ������ ��ü��(107��) �����. �ϳ��� ���ؼ�, ��� ���� ������ ���� ����. 

/* ******************************************************************************************************************
EXISTS, NOT EXISTS ������ (���(����)������ ���� ���ȴ�)  '���� �ֳ� ����'
-- ���������� ����� �����ϴ� '���� �����ϴ��� ����'�� Ȯ���ϴ� ����. ������ �����ϴ� ���� �������� '���ุ ������ ���̻� �˻����� �ʴ´�'.

-- where exists(����(���)����)
**********************************************************************************************************************/

-- ������ �Ѹ��̻� �ִ� �μ��� �μ�ID(dept.dept_id)�� �̸�(dept.dept_name), ��ġ(dept.loc)�� ��ȸ
select d.dept_id
        ,d.dept_name
        ,d.loc
from dept d
where exists(select emp_name from emp where dept_id = d.dept_id);  -- ������ ������ ������, ������ �ȳ����״�.  emp_name�� ���� ���߷��� �׳� ������(�ƹ����̳� �־��. 1 �־��


-- ������ �Ѹ� ���� �μ��� �μ�ID(dept.dept_id)�� �̸�(dept.dept_name), ��ġ(dept.loc)�� ��ȸ
select d.dept_id
        ,d.dept_name
        ,d.loc
from dept d
where not exists(select emp_name from emp e where e.dept_id = d.dept_id);


-- �μ�(dept)���� ����(emp.salary)�� 13000�̻��� �Ѹ��̶� �ִ� �μ��� �μ�ID(dept.dept_id)�� �̸�(dept.dept_name), ��ġ(dept.loc)�� ��ȸ
select d.dept_id
        ,d.dept_name
        ,d.loc
from dept d
where exists(select emp_id 
            from emp e 
            where e.dept_id = d.dept_id 
            and e.salary >= 13000);



/* ******************************
�ֹ� ���� ���̺�� �̿�.
******************************* */

--TODO: ��(customers) �� �ֹ�(orders)�� �ѹ� �̻� �� ������ ��ȸ.
select c.cust_id
        ,c.cust_name
from customers c
where exists(select order_id from orders o where o.cust_id = c.cust_id);


--TODO: ��(customers) �� �ֹ�(orders)�� �ѹ��� ���� ���� ������ ��ȸ.
select c.cust_id
        ,c.cust_name
from customers c
where not exists(select order_id from orders o where o.cust_id = c.cust_id);


--TODO: ��ǰ(products) �� �ѹ��̻� �ֹ��� ��ǰ ���� ��ȸ
select p.product_id
        ,p.product_name
from products p
where exists(select order_id from order_items oi where oi.product_id = p.product_id);

--TODO: ��ǰ(products)�� �ֹ��� �ѹ��� �ȵ� ��ǰ ���� ��ȸ
select p.product_id
        ,p.product_name
from products p
where not exists(select order_id from order_items oi where oi.product_id = p.product_id);

