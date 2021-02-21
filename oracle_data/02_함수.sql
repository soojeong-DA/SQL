 /***********************
 ������ �Լ�: �� �ະ�� ó���ϴ� �Լ�
    - select ��, where ������ ���.
    - �����ϴ� �ֵ黩��, �� ������ �Լ���.
 ������ �Լ�: ���޵� �÷��� ������ ��� �ѹ��� ó��  - ��� 1��
            ���� �Լ�(���, �հ�, �ִ�/�ּҰ�, �л�, ǥ������), �׷� �Լ�.
    - select ��, having ������ ���. (where������ ��� ���� -> sub query(��������)�̿��ؾ� �� �� ����)
    ex) sum()
**************************/

/* *************************************
�Լ� - '���ڿ�'���� �Լ�
 UPPER()/ LOWER() : �빮��/�ҹ��� �� ��ȯ
 INITCAP(): �ܾ� ù���ڸ� �빮�� ������ �ҹ��ڷ� ��ȯ
 LENGTH() : ���ڼ� ��ȸ
 LPAD(��, ũ��, ä�ﰪ) : "��"�� ������ "ũ��"�� �������� ���ڿ��� ����� ���ڶ�� ���� ���ʺ��� "ä�ﰪ"���� ä���.
 RPAD(��, ũ��, ä�ﰪ) : "��"�� ������ "ũ��"�� �������� ���ڿ��� ����� ���ڶ�� ���� �����ʺ��� "ä�ﰪ"���� ä���.
 SUBSTR(��, ����index, ���ڼ�) - "��"���� "����index"��° ���ں��� ������ "���ڼ�" ��ŭ�� ���ڿ��� ����. ���ڼ� ������ ������. 
 REPLACE(��, ã�����ڿ�, �����ҹ��ڿ�) - "��"���� "ã�����ڿ�"�� "�����ҹ��ڿ�"�� �ٲ۴�.
 LTRIM(��): �ް��� ����
 RTRIM(��): �������� ����
 TRIM(��): ���� ���� ����
 ************************************* */
-- ����
select upper('abc'),lower('ABC'),initcap('abc def') from dual;
select length('�����ٶ�') from dual;  --���ڼ�

select lpad('test', 10, '-') from dual;  -- 4���ڸ� �������� 10���ڷ� ������, �������� '-'�� ä���. 
select rpad('test', 10, '-') from dual;  -- 4���ڸ� �������� 10���ڷ� ������, �������� '-'�� ä���.
-- lpad/rpad: ä����� �����ϸ�, �������� ä����

-- sub�� ����, �־��� ���ڿ��� �Ϻθ� �̾Ƴ��ڴ�. ��� ��
select substr('123456789',2,5) from dual;       -- 2��° ���� 5�� �̾ƶ�(- 5��° X)
-- 2: �ι�° ����(index�� 1���� ����), 5: 5����.(���ڼ�)

select replace('abc-def-hij', '-', '**') from dual;   -- '-'�� '**'���� �ٲ��.
select trim('       a          ') "A" from dual;   -- ���� ��������
select ltrim('       a          ') "A" from dual;   -- ���� ��������
select rtrim('       a          ') "A" from dual;   -- ������ ��������

-- �Լ��ȿ��� �Լ��� ȣ���ϴ� ���  ->  ���� �Լ��� ó���� ����� �ٱ��� �Լ��� ����.
select length(trim('     abc     ')) from dual;   -- ������ ������, ���ڼ� ����


-- �Լ� �����Ѱ� ��Ī ����  <- �Լ��� where���ǹ� �Ӹ��ƴ϶�, select�� �ҷ����� �� ��ü�� �ҷ��� �� ����.
select emp_name "�̸�"
        ,length(emp_name) "���ڼ�"
from emp
where length(emp_name) >= 7;

select lpad('$'||salary, 6, '-') "�޿�"   -- �ڸ��� ���߱�. �������� 6�ڸ�(���� �� ������)
from emp;


--EMP ���̺��� ������ �̸�(emp_name)�� ��� �빮��, �ҹ���, ù���� �빮��, �̸� ���ڼ��� ��ȸ
select upper(emp_name) "�빮�� �̸�"
        ,lower(emp_name) "�ҹ��� �̸�"
        ,initcap(emp_name) "ù���� �빮��"
        ,length(emp_name)  "���ڼ�"
from emp;

-- TODO: EMP ���̺��� ������ ID(emp_id), �̸�(emp_name), �޿�(salary), �μ�(dept_name)�� ��ȸ. �� �����̸�(emp_name)�� ��� �빮��, �μ�(dept_name)�� ��� �ҹ��ڷ� ���.
-- UPPER/LOWER
select emp_id
        ,upper(emp_name)
        ,salary
        ,lower(dept_name)
from emp;


--(�Ʒ� 2���� �񱳰��� ��ҹ��ڸ� Ȯ���� �𸣴� ����)
--TODO: EMP ���̺��� ������ �̸�(emp_name)�� PETER�� ������ ��� ������ ��ȸ�Ͻÿ�.
select *
from emp
where upper(emp_name) = 'PETER';


--TODO: EMP ���̺��� ����(job)�� 'Sh_Clerk' �� ��������  ID(emp_id), �̸�(emp_name), ����(job), �޿�(salary)�� ��ȸ
select emp_id
        ,emp_name
        ,job
        ,salary
from emp
where initcap(job) = 'Sh_Clerk';


--TODO: ���� �̸�(emp_name) �� �ڸ����� 15�ڸ��� ���߰� ���ڼ��� ���ڶ� ��� ������ �տ� �ٿ� ��ȸ. ���� �µ��� ��ȸ
select lpad(emp_name, 15) 
from emp;

    
--TODO: EMP ���̺��� ��� ������ �̸�(emp_name)�� �޿�(salary)�� ��ȸ.
--(��, "�޿�(salary)" ���� ���̰� 7�� ���ڿ��� �����, ���̰� 7�� �ȵ� ��� ���ʺ��� �� ĭ�� '_'�� ä��ÿ�. EX) ______5000) -LPAD() �̿�
select emp_name
        ,lpad(salary, 7, '_')
from emp;


-- TODO: EMP ���̺��� �̸�(emp_name)�� 10���� �̻��� �������� �̸�(emp_name)�� �̸��� ���ڼ� ��ȸ
select emp_name "�̸�"
        ,length(emp_name) "���ڼ�"
from emp
where length(emp_name) >= 10;


-- ���� ���ְ� ���ڼ� ����
select emp_name, length(replace(emp_name, ' ', ''))
from emp
where length(replace(emp_name, ' ', '')) >= 10;


/* *************************************
�Լ� - ���ڰ��� �Լ�
 round(��, �ڸ���) : �ڸ��� ���Ͽ��� �ݿø� (��� - �Ǽ���, ���� - ������)
 trunc(��, �ڸ���) : �ڸ��� ���Ͽ��� ����(��� - �Ǽ���, ���� - ������)
 - ������ ������ �ø�/����
     - ceil(��) : �ø�
     - floor(��) : ���� 
 mod(�����¼�, �����¼�) : �������� ������ ����
 
************************************* */
-- ceil/floor(): ����� ������ ���´�.
select ceil(50.123) "�ø�"  -- �ݿø� X ������ �ø�!!
        ,floor(50.567) "����"
from dual;

-- �ݿø� (�Ҽ��� �ڸ��� ���� ����)
select round(50.12)
        ,round(50.79)
        ,round(50.123456, 2)   -- �Ҽ��� 2�ڸ� ������ 3��°���� �ݿø���
        ,round(50.123456, 5)
        ,round(567.123456, -1)  -- -1: ���� �����ڸ����� �ݿø�
from dual;

-- ���� (�Ҽ��� �ڸ��� ���� ����)
select trunc(50.12)
        ,trunc(50.79)
        ,trunc(50.123456, 2)   
        ,trunc(50.123456, 5)
        ,trunc(567.123456, -1) 
from dual;

select mod(10,3) from dual;   -- ���� ������ ��

select comm_pct
        ,round(comm_pct,1) 
from emp;


/*=====================================================================================*/

--TODO: EMP ���̺��� �� ������ ���� ����ID(emp_id), �̸�(emp_name), �޿�(salary) �׸��� 15% �λ�� �޿�(salary)�� ��ȸ�ϴ� ���Ǹ� �ۼ��Ͻÿ�.
--(��, 15% �λ�� �޿��� �ø��ؼ� ������ ǥ���ϰ�, ��Ī�� "SAL_RAISE"�� ����.)
select emp_id
        ,emp_name
        ,ceil(salary*1.15) "SAL_RAISE"
from emp;


--TODO: ���� SQL������ �λ� �޿�(sal_raise)�� �޿�(salary) ���� ������ �߰��� ��ȸ (����ID(emp_id), �̸�(emp_name), 15% �λ�޿�, �λ�� �޿��� ���� �޿�(salary)�� ����)
select emp_id
        ,emp_name
        ,ceil(salary*1.15) "SAL_RAISE"
        ,ceil(salary*1.15) - salary "����"    -- ������ table�� �ִ� �÷�/������ ����ؾ���. ��ȸ��(SAL_RAISE)�� ���� table�� �ִ� ���� �ƴϹǷ� ��� �Ұ�.
from emp;


-- TODO: EMP ���̺��� 'Ŀ�̼��� �ִ�' �������� ����_ID(emp_id), �̸�(emp_name), Ŀ�̼Ǻ���(comm_pct), Ŀ�̼Ǻ���(comm_pct)�� 8% �λ��� ����� ��ȸ.
--(�� Ŀ�̼��� 8% �λ��� ����� �Ҽ��� ���� 2�ڸ����� �ݿø��ϰ� ��Ī�� comm_raise�� ����)
select emp_id
        ,emp_name
        ,comm_pct
        ,round(comm_pct*1.08, 2) "comm_raise"
from emp
where comm_pct is not null;



/* *************************************
�Լ� - ��¥���� ��� �� �Լ�
Date +- ���� : ��¥ ���.
months_between(d1, d2) -����� ������(d1�� �ֱ�, d2�� ����)
add_months(d1, ����) - �������� ���� ��¥. ������ ��¥�� 1���� �Ĵ� ���� ������ ���� �ȴ�. 
next_day(d1, '����') - d1���� ù��° ������ ������ ��¥. ������ �ѱ�(locale)�� �����Ѵ�.
last_day(d) - d ���� ��������.
extract(year|month|day from date) - date���� year/month/day�� ����
************************************* */
-- day
select sysdate + 10 "10�� ��"
        ,sysdate - 10 "10�� ��"
from dual;

--month
select add_months(sysdate, 10)
        ,add_months(sysdate, -10)
        ,add_months(sysdate, 12)
from dual;

-- ��� ������(�ֽ�, ����)
select months_between(sysdate, '2019-05-26')
from dual;

-- sysdate(����)���� ù��°�� ���� '�Է� ����'�� ��¥
select next_day(sysdate, '�����') from dual;

-- �ش� ���� �������� ��¥ 
select last_day('2020-02-03') from dual;

-- - date���� year/month/day�� ����
select extract(year from sysdate) "�⵵"
        ,extract(month from sysdate) "��"
        ,extract(day from sysdate) "��"
from dual;

select hire_date
        ,hire_date + 3
        ,add_months(hire_date, 3)
from emp
where extract(year from hire_date) = 2004; 


/*=======================================================*/
--TODO: EMP ���̺��� �μ��̸�(dept_name)�� 'IT'�� �������� '�Ի���(hire_date)�� ���� 10����', �Ի��ϰ� '�Ի��Ϸ� ���� 10����',  �� ��¥�� ��ȸ. 
select dept_name
        ,hire_date - 10 "10�� ��"
        ,hire_date + 10 "10�� ��"
from emp
where dept_name = 'IT';

--TODO: �μ��� 'Purchasing' �� ������ �̸�(emp_name), �Ի� 6�������� �Ի���(hire_date), 6������ ��¥�� ��ȸ.
select emp_name
        ,add_months(hire_date, -6)
        ,add_months(hire_date, 6)
from emp
where dept_name = 'Purchasing';

--TODO: EMP ���̺��� �Ի��ϰ� �Ի��� 2�� ��, �Ի��� 2�� �� ��¥�� ��ȸ.
select hire_date
        ,add_months(hire_date, 2)
        ,add_months(hire_date, -2)
from emp;


-- TODO: �� ������ �̸�(emp_name), �ٹ� ������ (�Ի��Ͽ��� ��������� �� ��)�� ����Ͽ� ��ȸ.
--(�� �ٹ� �������� �Ǽ� �� ��� ������ �ݿø�. '�ٹ������� ������������ ����'.)
select emp_name
        ,round(months_between(sysdate,hire_date),0)||'����' as "�ٹ� ������"
        ,round(sysdate - hire_date)||'��' as "�ٹ� �ϼ�"
from emp
order by "�ٹ� ������" desc;
/*order by 2 desc*/

--TODO: ���� ID(emp_id)�� 100 �� ������ �Ի��� ���� ù��° �ݿ����� ��¥�� ���Ͻÿ�.
select next_day(hire_date, '�ݿ���')
from emp
where emp_id = 100;



/* *************************************
> ������ Ÿ�� review
����: number
����: char, varchar
��¥: date
- ���� -> <- '����' -> <- ��¥     =>  '���� -> <- ��¥'�� �Ұ���

> �Լ� - (������ Ÿ��)��ȯ �Լ�
to_char() : ������, ��¥����  -> ���������� ��ȯ   ex) Ư�� ���� ���ڿ��� ��ȯ:  '20,000,000', '2020/03/24', '2020��03��24��'
to_number() : �������� -> ���������� ��ȯ         ex) �Լ�, ������ ����: '2000'+5000 = (x)  -> 2000 + 5000
to_date() : �������� -> ��¥������ ��ȯ           ex) ��¥ ����� ����: add_months(...)

- ȣ�� ����
    - �Լ�(��ȯ��, ����)
    - ����: ��ȯ�� ���� � �������� �Ǿ� �ִ����� ����

���Ĺ��� 
���� : 0, 9, - �ڸ��� ����.
        . , ',', 'L', '$'
�Ͻ� : yyyy, mm, dd, hh24, mi, ss, day(����), am �Ǵ� pm )
************************************* */
select to_char(20000000, '99,999,999') from dual;     -- 9: �ڸ��� ǥ��,  ','���Ĺ���
select to_char(20000000, '00,000,000') from dual;     -- 0: �ڸ��� ǥ��,  ','���Ĺ���

/*���Ĺ��ڰ� ������ �ʰ����� ��(���� �ڸ��� ������):
- 9: �������� ���� �ڸ��� �������� ä���.
- 0: �������� ���� �ڸ��� 0���� ä���.
- �Ѵ� �Ǽ����� ���� �ڸ��� 0���� ä���.*/
select to_char(20000000, '999,999,999') from dual;     
select to_char(20000000, '000,000,000') from dual; 

select to_char(20000000, 'fm999999,999,999') from dual;     -- fm�� ���̸� ���� �ȵ���.  (fm �׻� �Ǿտ� ����)
select to_char(20000000, '0000000,000,000') from dual;     -- fm�� ���̸� ���� �ȵ���.


-- ���Ĺ��� ������ �������� ���ڸ���:   ###���� ǥ����.  => �ִ���� ���� �����, ���ڸ��� �ͺ��� �ʰ��Ǵ°� ����.
select to_char(20000000, '00,000') from dual; 


select to_char(1234.567, '0,000.000') from dual;
select to_char(1234.567, '000,000.00000') from dual;
select to_char(1234.567, '999,999.99999') from dual;
-- �Ǽ��ο��� �ڸ����� ���ڶ� ��� �ݿø� ó��. (�����ΰ� ���ڶ� ��� #���� ǥ��)
select to_char(1234.567, '0,000.0') from dual;

select to_char(3000, 'fm$9,999') from dual;
-- L: local ��ȭ ǥ��
select to_char(3000, 'fmL9,999') from dual;   -- �ѱ��̴ϱ� ��ǥ��

-- ���ڿ� -> number
select to_number('2,000,000','9,999,999') + 100000 from dual;  -- '9,999,999': ���� ���ڿ��� � �������� �˷���� number�� ��ȯ�� �� ����.
-- '10' ���ڿ��ε��� �ұ��ϰ� ����.  => '10'dmf 10(����)�� ��ȯ �� ���  => �ڵ� ����ȯ.
select '10' + 20 from dual;    -- ǥ������? ������ ������ �ڵ� ����ȯ.

-- ��¥/�ð�
select sysdate
    ,to_char(sysdate, 'yyyy-mm-dd hh:mi:ss am') "12�ð���"   -- mm: 05, m: 5, hh: �����̵� ���ĵ� ������ �ȵ�,am/pm: �����ϳ� ����, �������� �������� �˷��޶�
    ,to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss day') "24�ð���"   -- hh24: ����/���� ���е� 24�ð����ϱ�.  --day: ���� ��ȯ
    ,to_char(sysdate, 'yyyy"�⵵" mm"��" dd"��"') "�����"   -- ���Ĺ��� �ȿ� ���� ������� "" �ֵ���ǥ�� ���ξ�.
from dual;

-- '2020-10' ��� ��¥����('yyyy-mm-dd')�� ���� �ʾ� ������ => ��¥ �������� ��ȯ ��, add_months ����ؾ���.
select add_months(to_date('2020-10', 'yyyy-mm'), 2) from dual;

select add_months('2020-10-20', 3) from dual;   -- �Ʊ� ���� => ���ڷ� �ڵ� ����ȯó��. ���� => ��¥�� �ڵ� ����ȯ��.


/*==========================================================================================*/
-- EMP ���̺��� ����(job)�� "CLERK"�� ���� �������� ID(emp_id), �̸�(name), ����(job), �޿�(salary)�� ��ȸ
--(�޿��� ���� ������ , �� ����ϰ� �տ� $�� �ٿ��� ���.)
select emp_id
        ,emp_name
        ,job
        ,salary
        ,to_char(salary, '$99,999.99') salary2    -- ���� data���� ���� (7,2) �� 7�ڸ� ��, �Ҽ��ڸ� 2,=> �����ڸ� 5
        ,to_char(salary, 'fm$99,999.99') salary3
        ,to_char(salary, '$00,000.00') salary4
from emp
where job like '%CLERK%';


-- ���ڿ� '20030503' �� 2003�� 05�� 03�� �� ���.
-- ���ڿ� -> date -> ���ڿ�
select to_char(to_date('20030503', 'yyyymmdd'), 'yyyy"��" mm"��" dd"��"') from dual;

/* ��¥�� ���ڿ��� �����Ҷ�, �Ϲ����� ����
'yyyymmdd' -> char(8)
'yyyymmddhh24miss' -> char(15)
*/


-- TODO: �μ���(dept_name)�� 'Finance'�� �������� ID(emp_id), �̸�(emp_name)�� �Ի�⵵(hire_date) 4�ڸ��� ����Ͻÿ�. (ex: 2004);
--to_char()
select emp_id
        ,emp_name
        ,to_char(hire_date, 'yyyy')   -- ���1
        ,extract(year from hire_date)  -- ���2
from emp
where dept_name = 'Finance'
order by hire_date;


--TODO: �������� 11���� �Ի��� �������� ����ID(emp_id), �̸�(emp_name), �Ի���(hire_date)�� ��ȸ
--to_char()
select emp_id
        ,emp_name
        ,hire_date
from emp
where to_char(hire_date,'mm') = '11';


--TODO: 2006�⿡ �Ի��� ��� ������ �̸�(emp_name)�� �Ի���(yyyy-mm-dd ����)�� �Ի���(hire_date)�� ������������ ��ȸ
--to_char()
select emp_name
        ,to_char(hire_date,'yyyy-mm-dd') hire_date    -- ��Ī�� ""�Ⱥٿ��� ������,  ��/�빮�� �״��, ���� ���� �� �Ҷ��� �����ֱ� 
from emp
where to_char(hire_date,'yyyy') = '2006'
order by hire_date;


--TODO: 2004�� 01�� ���� �Ի��� ���� ��ȸ�� �̸�(emp_name)�� �Ի���(hire_date) ��ȸ
select emp_name
        ,hire_date
from emp
where to_char(hire_date,'yyyymm') > '200401';    -- 'yyy-mm' or 'yyyymm' or ... ����


--TODO: ���ڿ� '20100107232215' �� 2010�� 01�� 07�� 23�� 22�� 15�� �� ���. (dual ���Ժ� ���)
select to_char(to_date('20100107232215','yyyy-mm-dd-hh24-mi-ss'),    -- 'yyyymmddhh24miss' ����
                                                            'yyyy"��" mm"��" dd"��" hh24"��" mi"��" ss"��"') 
from dual;  


/* *************************************
�Լ� - null ���� �Լ� 
    - null: ���� ����. �𸣴� ��.
NVL(expr, �⺻��)  - expr�� null�̸� ������ �⺻���� ��ȯ****
NVL2(expr, nn, null) - expr�� null�� �ƴϸ� nn, ���̸� ����°
nullif(ex1, ex2) ���� ������ null, �ٸ��� ex1

************************************* */
select comm_pct from emp;
-- NVL: �⺻������ comm_pct type�� ���� �����Ѵ�.(��� �� type�� ���ƾ���!)
select nvl(comm_pct, 0) from emp;   -- null�̸� 0 ��ȯ.
select nvl(comm_pct, '����') from emp;   --(X) null�̸� '����' ��ȯ  but, comm_pct =  number type, '����' = string type  => ���� �� �������� type�� ���ƾ���.

select * from emp
where nvl(comm_pct, 0) != 0;
/*where comm_pct is not null;*/

--NVL2: comm_pct type�� �ƴ�, ��� �� type�� ���ƾ���!  => ����� '����' or '����' ���� �ϳ�  => ���� type
select nvl2(comm_pct,'����','����')
from emp;

--  -1: �ڵ� ����ȯ �Ͼ��, ���ڿ� '-1'�� ��ȯ�� 
    -- (���� ���� '����' ���ڿ� �������� type ����)  => (1,'����')�̸� '����'���ڿ��� number type���� �ٲ� �� ���� ������ error��.  
-- ��� type�� ���ڿ��� �ٲ� �� �ֱ� ������, �� type�� �޶�, �ϳ���(ù��°����) ���ڿ��̸� ����.
select nvl2(comm_pct,'����',-1)   
from emp;

-- nullif
select nullif(10,10) from dual;  -- ���� �����ϱ� null ��ȯ
select nullif(10,5) from dual;   -- ���� �ٸ��ϱ� ù��° �� ��ȯ
-- �Ϲ��� ����: select nullif(2010���ǸŰ����÷�, 2011���ǸŰ����÷�) from �Ǹ����̺�;


/*===========================================================*/
-- EMP ���̺��� ���� ID(emp_id), �̸�(emp_name), �޿�(salary), Ŀ�̼Ǻ���(comm_pct)�� ��ȸ. �� Ŀ�̼Ǻ����� NULL�� ������ 0�� ��µǵ��� �Ѵ�..
select emp_id
        ,emp_name
        ,salary
        ,nvl(comm_pct, 0)
from emp;


--TODO: EMP ���̺��� ������ ID(emp_id), �̸�(emp_name), ����(job), �μ�(dept_name)�� ��ȸ. �μ��� ���� ��� '�μ��̹�ġ'�� ���.
select emp_id
        ,emp_name
        ,job
        ,nvl(dept_name,'�μ��̹�ġ')
from emp;


--TODO: EMP ���̺��� ������ ID(emp_id), �̸�(emp_name), �޿�(salary), Ŀ�̼� (salary * comm_pct)�� ��ȸ. Ŀ�̼��� ���� ������ 0�� ��ȸ�Ƿ� �Ѵ�.
select emp_id
        ,emp_name
        ,salary
        ,nvl(salary*comm_pct,0)
        ,to_char(nvl(salary*comm_pct,0),'L99,999')
from emp;


/* *************************************
DECODE(����Ŭ���� �ִ� �Լ�)�Լ��� CASE ��
    -- CASE���� �̿��ؼ� ���ǹ��� �����. (like python if/else)
decode(�÷�, [�񱳰�, ��°�,�񱳰�, ��°�, ...] , else���) 
        == decode(�÷�, �񱳰�, ��°�,�񱳰�, ��°�, ... , else���) : ���ȣ ��� ��.

case�� ����� (���� �÷� ��)
case �÷� when �񱳰� then ��°�
              [when �񱳰� then ��°�]
              [else ��°�]
              end
              
case�� ���ǹ� (�÷� ���������� ��)
case when ���� then ��°�
       [when ���� then ��°�]
       [else ��°�]
       end

************************************* */
--nvl() -> decode()
select decode(dept_name, null, '�μ�����'        -- decode���� null�� ���������� ó����.
                        ,'IT','�����'
                        ,'Finance','ȸ���'
                        ,dept_name) dept_name2
        ,dept_name
from emp;

select case dept_name /*when null then '�μ�����'   -> �̷����ϸ� null�� ������ */   -- case�������� null ������ ó�� x
                      when 'IT' then '�����'
                      when 'Finance' then 'ȸ���'
                      else nvl(dept_name, '�μ�����') end as "DEPT_NAME2"
            ,dept_name
from emp;

select case when dept_name is null then '�μ�����'    -- is null
            else dept_name  end
from emp
order by 1 desc;


/*==================================================================================*/
--EMP���̺��� �޿��� �޿��� ����� ��ȸ�ϴµ� �޿� ����� 10000�̻��̸� '1���', 10000�̸��̸� '2���' ���� �������� ��ȸ
select salary
        ,case when salary >= 10000 then '1���'
            else '2���' end "SALARY_GRADE"
from emp;


--decode()/case �� �̿��� ����  (�� �Ⱦ���)
-- �������� ��� ������ ��ȸ�Ѵ�. �� ������ ����(job)�� 'ST_CLERK', 'IT_PROG', 'PU_CLERK', 'SA_MAN' ������� ������������ �Ѵ�. (������ JOB�� �������)
-- decode�� order by�� ������ ��.
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
                  else 5 end, salary desc;    -- salary�� 2�� ����.


--TODO: EMP ���̺��� ����(job)�� 'AD_PRES'�ų� 'FI_ACCOUNT'�ų� 'PU_CLERK'�� �������� ID(emp_id), �̸�(emp_name), ����(job)�� ��ȸ. 
-- ����(job)�� 'AD_PRES'�� '��ǥ', 'FI_ACCOUNT'�� 'ȸ��', 'PU_CLERK'�� ��� '����'�� ��µǵ��� ��ȸ
select emp_id
        ,emp_name
        ,job
        ,case job when 'AD_PRES' then '��ǥ'
                  when 'FI_ACCOUNT' then 'ȸ��'
                  when 'PU_CLERK' then '����' end
from emp
where job in ('AD_PRES', 'FI_ACCOUNT', 'PU_CLERK');



--TODO: EMP ���̺��� �μ��̸�(dept_name)�� �޿� �λ���� ��ȸ. 
--�޿� �λ���� �μ��̸��� 'IT' �̸� �޿�(salary)�� 10%�� 'Shipping' �̸� �޿�(salary)�� 20%�� 'Finance'�̸� 30%�� �������� 0�� ���
-- decode �� case���� �̿��� ��ȸ
select dept_name
        ,case dept_name when 'IT' then salary*0.1
                        when 'Shipping' then salary*0.2
                        when 'Finance' then salary*0.3
                        else 0 end
from emp;
                        


--TODO: EMP ���̺��� ������ ID(emp_id), �̸�(emp_name), �޿�(salary), �λ�� �޿��� ��ȸ�Ѵ�. 
--�� �޿� �λ����� �޿��� 5000 �̸��� 30%, 5000�̻� 10000 �̸��� 20% 10000 �̻��� 10% �� �Ѵ�.
select emp_id
        ,emp_name
        ,salary
        ,case when salary < 5000 then salary*1.3
              when salary between 5000 and 10000 then salary*1.2
              else salary*1.1 end
from emp;
