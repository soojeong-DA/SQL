/* **********************************************************************************************
���� ������ (���� ����)
- �� �̻��� select ����� ������ �ϴ� ����.
- ����
 select��  ���տ����� select�� [���տ����� select�� ...] [order by �����÷� ���Ĺ��]

-������  (union all�� �ߺ����, �������� �ߺ� ����)
  - UNION: �� select ����� �ϳ��� �����Ѵ�. �� �ߺ��Ǵ� ���� �����Ѵ�. (������)  -  �ߺ� �˻�� performance�� ������
  - UNION ALL : �� select ����� �ϳ��� �����Ѵ�. �ߺ��Ǵ� ���� �����Ѵ�. (������) - �ߺ� �˻� ���ص� �Ǵϱ� performnace ����
  - INTERSECT: �� select ����� ������ ����ุ �����Ѵ�. (������)   - ���� ��������, �ߺ� �� �����ϰ� ����
  - MINUS: ���� ��ȸ������� ������ ��ȸ����� ���� �ุ �����Ѵ�. (������)  - ���� ��������, �ߺ� �� �����ϰ� ����
   
 - ��Ģ
  - ������ select ���� �÷� ���� ���ƾ� �Ѵ�. 
  - ������ select ���� �÷��� Ÿ���� ���ƾ� �Ѵ�.
  - ���� ����� �÷��̸��� ù��° ���� select���� ���� ������.
  - order by ���� ������ �������� ���� �� �ִ�.
  - UNION ALL�� ������ ������ ������ �ߺ��Ǵ� ���� �����Ѵ�.
*************************************************************************************************/

-- emp ���̺��� salary �ִ밪�� salary �ּҰ�, salary ��հ� ��ȸ    (���� �ϴ� ���ó���ϸ�, ���྿ �ش� ���� ������ ���� �ƴ϶�, �� 3���� ���� )
-- ���� ����� �÷��̸��� ù��° ���� select���� ���� ������.  
-- '���̸�'�� �÷� �տ� ���̰� '��ǥ'�� ���δ�.  '�ִ�޿�' as "label",...
select '�ִ�޿�' as "label", max(salary) as "����" from emp   
union all
select '�ּұ޿�', min(salary) from emp
union all
select '��ձ޿�', round(avg(salary),2) from emp;


-- emp ���̺��� ������(emp.job_id) �޿� �հ�� ��ü ������ �޿��հ踦 ��ȸ.
select job_id
        ,sum(salary) as "�޿��հ�"
from emp
group by job_id
union all
select '�ѱ޿��հ�', sum(salary)
from emp;

----------------------------------------------------------------------------
-- ������ - �ߺ� ����
select * from emp where dept_id in (10,20)
union all
select * from emp where dept_id in (20,30)
order by 8;

-- ������ - �ߺ� ����
select * from emp where dept_id in (10,20)
union
select * from emp where dept_id in (20,30)
order by 8;

-- ������: �� ��ȸ ������� �������� �ִ� �͸�����. - �ߺ� ����
select * from emp where dept_id in (10,20)
intersect
select * from emp where dept_id in (20,30)
order by 8;

-- ������: ù��° ��ȸ ������� �ι�° ��ȸ ����� ���� �͸� ����.  - �ߺ� ����
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
--�ѱ� ������ ���� ǰ�� ��ŷ
drop table export_rank;
create table export_rank(
    year char(4) not null,
    ranking number(2) not null,
    item varchar2(60) not null
);
insert into export_rank values(1990, 1, '�Ƿ�');
insert into export_rank values(1990, 2, '�ݵ�ü');
insert into export_rank values(1990, 3, '����');
insert into export_rank values(1990, 4, '������');
insert into export_rank values(1990, 5, '�����ؾ籸�����׺�ǰ');
insert into export_rank values(1990, 6, '��ǻ��');
insert into export_rank values(1990, 7, '������');
insert into export_rank values(1990, 8, 'ö����');
insert into export_rank values(1990, 9, '�����弶������');
insert into export_rank values(1990, 10, '�ڵ���');

insert into export_rank values(2000, 1, '�ݵ�ü');
insert into export_rank values(2000, 2, '��ǻ��');
insert into export_rank values(2000, 3, '�ڵ���');
insert into export_rank values(2000, 4, '������ǰ');
insert into export_rank values(2000, 5, '�����ؾ籸�����׺�ǰ');
insert into export_rank values(2000, 6, '������ű��');
insert into export_rank values(2000, 7, '�ռ�����');
insert into export_rank values(2000, 8, 'ö����');
insert into export_rank values(2000, 9, '�Ƿ�');
insert into export_rank values(2000, 10, '������');

insert into export_rank values(2018, 1, '�ݵ�ü');
insert into export_rank values(2018, 2, '������ǰ');
insert into export_rank values(2018, 3, '�ڵ���');
insert into export_rank values(2018, 4, '���ǵ��÷��̹׼���');
insert into export_rank values(2018, 5, '�ռ�����');
insert into export_rank values(2018, 6, '�ڵ�����ǰ');
insert into export_rank values(2018, 7, 'ö����');
insert into export_rank values(2018, 8, '�����ؾ籸�����׺�ǰ');
insert into export_rank values(2018, 9, '������ű��');
insert into export_rank values(2018, 10, '��ǻ��');

--�⵵�� ���� ǰ�� ��ŷ
drop table import_rank;
create table import_rank(
    year char(4) not null,
    ranking number(2) not null,
    item varchar2(60) not null
);
insert into import_rank values(1990, 1, '����');
insert into import_rank values(1990, 2, '�ݵ�ü');
insert into import_rank values(1990, 3, '������ǰ');
insert into import_rank values(1990, 4, '������ȭ�б��');
insert into import_rank values(1990, 5, '����');
insert into import_rank values(1990, 6, '��ǻ��');
insert into import_rank values(1990, 7, 'ö����');
insert into import_rank values(1990, 8, '�װ���׺�ǰ');
insert into import_rank values(1990, 9, '�����');
insert into import_rank values(1990, 10, '��������м���');

insert into import_rank values(2000, 1, '����');
insert into import_rank values(2000, 2, '�ݵ�ü');
insert into import_rank values(2000, 3, '��ǻ��');
insert into import_rank values(2000, 4, '������ǰ');
insert into import_rank values(2000, 5, 'õ������');
insert into import_rank values(2000, 6, '�ݵ�ü���������');
insert into import_rank values(2000, 7, '�����׹��');
insert into import_rank values(2000, 8, '������ű��');
insert into import_rank values(2000, 9, 'ö����');
insert into import_rank values(2000, 10, '����ȭ�п���');

insert into import_rank values(2018, 1, '����');
insert into import_rank values(2018, 2, '�ݵ�ü');
insert into import_rank values(2018, 3, 'õ������');
insert into import_rank values(2018, 4, '������ǰ');
insert into import_rank values(2018, 5, '�ݵ�ü���������');
insert into import_rank values(2018, 6, '��ź');
insert into import_rank values(2018, 7, '��ǻ��');
insert into import_rank values(2018, 8, '����ȭ�п���');
insert into import_rank values(2018, 9, '�ڵ���');
insert into import_rank values(2018, 10, '������ű��');

commit;

select * from import_rank;
select * from export_rank;


--TODO:  2018��(year) ����(export_rank)�� ����(import_rank)�� ���ÿ� ������ ǰ��(item)�� ��ȸ
-- ���ʿ� �ִ� ��. intersect
select item from export_rank where year = 2018
intersect
select item from import_rank where year = 2018;


--TODO:  2018��(export_rank.year) �ֿ� ���� ǰ��(export_rank.item)�� 2000�⿡�� ���� ǰ�� ��ȸ
-- 2018-2000
select item from export_rank where year = 2018
minus
select item from export_rank where year = 2000;


--TODO: 1990 ����(export_rank)�� ����(import_rank) ��ŷ�� ���Ե�  ǰ��(item)���� ���ļ� ��ȸ. �ߺ��� ǰ�� �������� ��ȸ
--union all
select '����' as "label", item from export_rank where year = 1990
union all
select '����', item from import_rank where year = 1990;


--TODO: 1990 ����(export_rank)�� ����(import_rank) ��ŷ�� ���Ե�  ǰ��(item)���� ���ļ� ��ȸ. �ߺ��� ǰ���� �ȳ������� ��ȸ
--union
select item from export_rank where year = 1990
union
select item from import_rank where year = 1990;



--TODO: 1990��� 2018���� ���� �ֿ� ���� ǰ��(export_rank.item) ��ȸ
-- intersect
select item from export_rank where year = 1990
intersect
select item from export_rank where year = 2018;


--TODO: 1990�� �ֿ� ���� ǰ��(export_rank.item)�� 2018��� 2000�⿡�� ���� ǰ�� ��ȸ
--1990 - 2018 - 2000
select item from export_rank where year = 1990
minus
select item from export_rank where year = 2018
minus
select item from export_rank where year = 2000;


--TODO: 2000�� ����ǰ����(import_rank.item) 2018�⿡�� ���� ǰ���� ��ȸ.
-- 2000 - 2018
select item from import_rank where year = 2000
minus
select item from import_rank where year = 2018;


