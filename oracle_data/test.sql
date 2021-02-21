-- dash2��: ���� �ּ�
-- select * from tabs;
/* �ּ�����
block �ּ�.
�ּ� ��*/
-- ����: control + enter  (���پ�, �� ���ļ�.. �� ���డ��)
-- F5: ���Ͼȿ� �ִ� ����ڵ� ��������


/*
���̺�: ȸ�� (member)
�Ӽ�
id: varchar2(10) primary key   -- not null + uniqe
password: varchar2(10) not null (�ʼ��Է�, ���� null�� �� ����)
name: nvarchar2(30)  not null (varchar�� ����������, �ѱ۵� ���ϰ� �Է��Ϸ���, varchar2)    
point: number(6,2) nullable (null�� ��� = not null�� �ƴϸ�, nullable)  <- �ִ� ����Ʈ(6) = 10**6 : -9999.99~9999.99 ���� ����  ex) $�޷�,Ű �� / �����̸� �׳� number
join_date: date not null   (type: date)    -- ���� char(��������)�� ���� 000-00-00
*/

--format
--�÷��� ���������� ��������
--��ǥ ����!
create table member(
 id         varchar2(10)  primary key,
 password   varchar2(10)  not null,
 name       nvarchar2(30) not null,
 point      number(6),
 join_date  date          not null
);

--���̺� �� ��������� Ȯ�� -- ���̺� ���� �� ����(�Ӽ�) ������  (�� �빮�ڷ� ����, but �������)
desc member;

--���̺� ����  & �ٽ� ����
drop table member;
create table member(
 id         varchar2(10)  primary key,
 password   varchar2(10)  not null,
 name       nvarchar2(30) not null,
 point      number(6),
 join_date  date          not null
);



-- ���� insert(�����͸� ����)  -- �÷� ������ ��� ������, �÷�-�� ��Ī? ������ ���������   -- �ѹ� �� �����ϸ� error�� because id(primery) �� �ߺ��Ǽ�.
insert into member(id, password, name, point, join_date) values('id-1','11111','�ڼ���',1000,'2020-05-20');

-- ��� column�� ���� �������, column ���� ��������!   (�̶��� �÷� ���� ���������.)
insert into member values('id-2','2252','�ڼ���',3000,'2018-11-11');

-- point ���� ������(�÷��� �ϳ��� �����Ǹ�), �Ϻ� column ���� �� ������� �÷� �����ؾ�
insert into member (id, password, name, join_date) values('id-3','3333','���ؼ�','2019-03-24');

-- join_date�� not null�̹Ƿ� �ݵ�� ���� �־���Ѵ�.
insert into member (id, password, name) values('id-4','433','���ؼ���');

-- null: null�� ǥ����.
insert into member values('id-5','2939','�ƾƾ�',null,'2019-05-28');



--------------���Ͽ� �ִ� �ڵ� �� ����
@C:\Users\Playdata\oracle_data\emp_table.sql;

