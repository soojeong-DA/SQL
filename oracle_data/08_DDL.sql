
/* ***********************************************************************************
DDL (Data Definition Language)  -  �����ͺ��̽����� ���Ǵ� ��ü(���̺�, �����, ������)�� �����ϴ� ���
creat(����) - drop(����) - alter(����)

���̺� ����
- ����
create table ���̺� �̸�(
  �÷� ����      --  �÷��̸�, ������Ÿ��, [default ��, ��������] ���� ����
)

- ������ Ÿ��
    - ���ڿ�: char/nchar - ��������, varchar2/nvarchar2/clob - ��������
    - ����: number, number(��ü�ڸ���, �Ҽ����ڸ���)
    - ��¥: date, timestamp
    - ����: blob  - ���ϰ��

��������
- primary key(PK) - �⺻Ű. ���ĺ� �÷�.
- 'unique' key(UK) - �ߺ����� �������� �÷�. null�� ���� �� �ִ�.
- not null (NN) - null�� �������� �÷�
- check key (CK) - �÷��� ���� ���� ������ ���� ����.
- foreign key (FK) - ���� �÷�. �θ����̺��� primary key�� ������ ������ �÷�. => �θ����̺� ����(����)�� �� ���.


�������� ���� 
- �÷� ���� ����
    - �÷� ������ ���� ����
- ���̺� ���� ����
    - �÷� �����ڿ� ���� ����

- �⺻ ���� : 'constraint' ���������̸� ��������Ÿ��
- ���̺� ���� ���� ��ȸ
    - USER_CONSTRAINTS ��ųʸ� �信�� ��ȸ
    
���̺� ����
- ����
DROP TABLE ���̺��̸� [CASCADE CONSTRAINTS]
*********************************************************************************** */
select * from user_constraints;  -- ���� ������ �������ǵ� ��Ƶ� ���̺� ��ȸ
--drop table dept cascade constraints;  -- ����������� �����༭, ���̺� �� ���� ����

---************************************************************************************
-- ���̺� ����
create table parent_tb(
    no   number constraint pk_parent_tb primary key,    -- �������� �̸�����: constraint ���̺��̸�+�������������    --�̸����� ��������
    name nvarchar2(50) not null, --NN: �÷����� ����.
    birthday date default sysdate, -- default �� => �⺻��. nullable �÷�.
    email  varchar2(100) constraint uk_parent_tb_email unique,  -- unique�� key ���̸�ȵ�
    gender char(1) not null constraint ck_parent_tb_gender check(gender in ('M','F'))  -- check(�÷��� ���� �� �ִ� �� ����/����)
);

select * from user_constraints where table_name = 'PARENT_TB';  -- ���⼭ ���̺�� ��ȸ�� �� �ݵ�� �빮�� ���
insert into parent_tb values(1, 'ȫ�浿','1990-10-20','a@a.com', 'M');
insert into parent_tb values(1, 'ȫ�浿','1990-10-20','a@a.com', 'A'); --'A' : check ���� �����
insert into parent_tb values(2, 'ȫ�浿','1990-10-20','a@a.com', 'M'); -- email: unique(UK) ���� ����
insert into parent_tb values(3, 'ȫ�浿','1990-10-20',null, 'M'); 
insert into parent_tb values(2, 'ȫ�浿', null, null, 'M'); 
insert into parent_tb (no, name, gender) values(5, '�̼���','M');  --� �÷��� �ش��ϴ� ������ �˷������

select * from parent_tb;

-- ���̺� ���� �������� ����.
-- ���ٿ� constraint����  �� �Ⱦ���, ���߿� �����ϴ� ver.
drop table parent_tb cascade constraint;    --  ��� �������� �����鼭, ������ ��� ����
create table child_tb(
    no        number, --PK
    jumin_num char(14), --UK
    age       number not null, --CK(10~90)
    p_no      number, -- FK(parent_tb) 
    constraint pk_child_tb primary key(no),
    constraint uk_child_tb_jumin_num unique(jumin_num),
    constraint ck_child_tb_age check(age between 10 and 90),
    --constraint fk_child_tb_parent_tb foreign key(p_no) references parent_tb(no)   -- no�÷� ��������.
    -- �θ����̺��� �����ϴ� ���� �����Ǹ�, �ڽ��� �൵ ���� ���� �ϰڴ�.  --�̰� �����ϸ�, �θ� ���̺��� no���ﶧ, �ڽ� ���̺��� p_no���� �����ְ�, no������ �ڵ�����
    --constraint fk_child_tb_parent_tb foreign key(p_no) references parent_tb on delete cascade,   
    -- �θ����̺��� �����ϴ� ���� �����Ǹ�, p_no(���� �÷�)�� ���� null�� update
    constraint fk_child_tb_parent_tb foreign key(p_no) references parent_tb on delete set null
);

insert into child_tb values(100, '801010-1010101', 20, 1);

delete from parent_tb where no = 1;    -- ���� on delete ���� ���ϸ�, �����ϰ��ֱ⶧���� ��������. but, on delete ���� �߱⶧����, �����ϰ� �ִ��� ������

select * from parent_tb;


-- ��� �������� �����鼭, ������ ��� ����
select * from user_constraints where table_name = 'CHILD_TB';   -- ������ ��ȸ
drop table parent_tb cascade constraint;   -- ���� ���̺� ����� �� ���� ���� �־���.




/* ************************************************************************************
ALTER : ���̺� ����

�÷� ���� ����

- �÷� �߰�
  ALTER TABLE ���̺��̸� ADD (�߰��� �÷����� [, �߰��� �÷�����])
  - �ϳ��� �÷��� �߰��� ��� ( ) �� ��������

- �÷� ����
  ALTER TABLE ���̺��̸� MODIFY (�������÷���  ���漳�� [, �������÷���  ���漳��])
	- �ϳ��� �÷��� ������ ��� ( )�� ���� ����
	- ����/���ڿ� �÷��� ũ�⸦ �ø� �� �ִ�.
		- ũ�⸦ ���� �� �ִ� ��� : ���� ���� ���ų� ��� ���� ���̷��� ũ�⺸�� ���� ���
	- �����Ͱ� ��� NULL�̸� ������Ÿ���� ������ �� �ִ�. (�� CHAR<->VARCHAR2 �� ����.)

- �÷� ����	
  ALTER TABLE ���̺��̸� DROP COLUMN �÷��̸� [CASCADE CONSTRAINTS]
    - CASCADE CONSTRAINTS : �����ϴ� �÷��� Primary Key�� ��� �� �÷��� �����ϴ� �ٸ� ���̺��� Foreign key ������ ��� �����Ѵ�.
	- �ѹ��� �ϳ��� �÷��� ���� ����.
	
  ALTER TABLE ���̺��̸� SET UNUSED (�÷��� [, ..])
  ALTER TABLE ���̺��̸� DROP UNUSED COLUMNS
	- SET UNUSED ������ �÷��� �ٷ� �������� �ʰ� ���� ǥ�ø� �Ѵ�. 
	- ������ �÷��� ����� �� ������ ���� ��ũ���� ����� �ִ�. �׷��� �ӵ��� ������.
	- DROP UNUSED COLUMNS �� SET UNUSED�� �÷��� ��ũ���� �����Ѵ�. 

- �÷� �̸� �ٲٱ�
  ALTER TABLE ���̺��̸� RENAME COLUMN �����̸� TO �ٲ��̸�;

**************************************************************************************  
���� ���� ���� ����
-�������� �߰�
  ALTER TABLE ���̺�� ADD CONSTRAINT �������� ����

- �������� ����
  ALTER TABLE ���̺�� DROP CONSTRAINT ���������̸�
  PRIMARY KEY ����: ALTER TABLE ���̺�� DROP PRIMARY KEY [CASCADE]
	- CASECADE : �����ϴ� Primary Key�� Foreign key ���� �ٸ� ���̺��� Foreign key ������ ��� �����Ѵ�.

- NOT NULL <-> NULL ��ȯ�� �÷� ������ ���� �Ѵ�.
   - ALTER TABLE ���̺�� MODIFY (�÷��� NOT NULL),  - ALTER TABLE ���̺�� MODIFY (�÷��� NULL)  
************************************************************************************ */
/*
- ���� ���̺��� �����ؼ� ���̺� ����.
- �÷�, ������ ���� ����. ���������� not null�� ������ ���������� ������� �ʴ´�.
create table ���̺� �̸�
as
select ��
*/

create table cust
as
select * from customers;

select * from cust;
select * from user_constraints 
where table_name = 'CUST';

--
create table ord
as
select * from orders
where 1 != 1;  -- ������ False�� �����̶�, ������ ����������, data�� �ƹ��͵� �������� ����

select * from ord;

--PK �������� �߰�: add constraint
alter table cust add constraint pk_cust primary key(cust_id);
alter table ord add constraint fk_ord_cust foreign key(cust_id) references cust;


-- �÷� ����
- �߰�: add      
alter table cust add(age number(2) default 0);  -- age�÷� �߰�, �⺻��: 0
alter table cust add(age number(2) not null);  --(������ �����Ͱ� �ִ� �÷��� not null�� �߰��Ϸ���, �ݵ�� �⺻�� �����ؾ���. �������ϸ� null �����µ� not null�̶� null ����;)
select * from cust;
-����: modify
desc cust;
alter table cust modify (cust_name nvarchar2(200));
alter table cust modify (address varchar2(10));   -- error: '�Ϻ� ���� �ʹ� Ŀ�� �� ���̸� ���� �� ����'  -> �ּұ��̰� 10�Ѵ°� �־, 10���� ������
alter table cust modify (cust_name null
                            ,address null
                            ,postal_code null);

-- �÷� �� ����: rename column
alter table cust rename column cust_name to name; -- cust_name�� name���� ����
select * from cust;

-- �÷� ����: drop column
alter table cust drop column age;

-- �������� ����
alter table ord drop constraint fk_ord_cust; -- �������� �̸�
alter table cust drop primary key; -- �׳� �������� �����ε� ���� ���� --alter table cust drop consstraint pk_cust;


--TODO: emp ���̺��� ī���ؼ� emp2�� ����(Ʋ�� ī��)
create table emp2
as
select * from emp
where 1 != 1;

desc emp2;
select * from emp2;

--TODO: gender �÷��� �߰�: type char(1)
alter table emp2 add(gender char(1));
desc emp2;

--TODO: email �÷� �߰�. type: varchar2(100),  not null  �÷�
--TODO: jumin_num(�ֹι�ȣ) �÷��� �߰�. type: char(14), null ���. ������ ���� ������ �÷�.
alter table emp2 add(email varchar2(100) not null,
                    jumin_num char(14) constraint ck_emp2_jumin unique);
                    
desc emp2;
select * from user_constraints
where table_name = 'EMP2';


--TODO: emp_id �� primary key �� ����
alter table emp2 add primary key(emp_id);
/*alter table emp2 add constraint pk_emp_id primary key(emp_id);*/

  
--TODO: gender �÷��� M, F �����ϵ���  �������� �߰�
alter table emp2 add constraint ck_emp_gender check(gender in ('M','F'));

 
--TODO: salary �÷��� 0�̻��� ���鸸 ������ �������� �߰�
alter table emp2 add constraint ck_emp_salary check(salary >= 0);


--TODO: email �÷��� null�� ���� �� �ֵ� �ٸ� ��� ���� ���� ������ ���ϵ��� ���� ���� ����
alter table emp2 add constraint uk_emp_email unique(email);


--TODO: emp_name �� ������ Ÿ���� varchar2(100) ���� ��ȯ
alter table emp2 modify(emp_name varchar2(100));
desc emp2;


--TODO: job_id�� not null �÷����� ����
alter table emp2 modify(job_id not null);

desc emp2;
--TODO: dept_id�� not null �÷����� ����
alter table emp2 modify(dept_id not null);


--TODO: job_id  �� null ��� �÷����� ����
--TODO: dept_id  �� null ��� �÷����� ����
alter table emp2 modify(job_id null,
                        dept_id null);

--TODO: ������ ������ emp2_email_uk ���� ������ ����
alter table emp2 drop constraint uk_emp_email;


--TODO: ������ ������ emp2_salary_ck ���� ������ ����
alter table emp2 drop constraint ck_emp_salary;


--TODO: primary key �������� ����
alter table emp2 drop primary key;


--TODO: gender �÷�����
alter table emp2 drop column gender;


--TODO: email �÷� ����
alter table emp2 drop column email;


/* **************************************************************************************************************
������ : SEQUENCE
- '�ڵ������ϴ� ����'�� �����ϴ� ����Ŭ ��ü
- ���̺� �÷��� �ڵ������ϴ� ������ȣ�� ������ ����Ѵ�.
	- �ϳ��� �������� ���� ���̺��� �����ϸ� �߰��� �� ������ �� �� �ִ�.

���� ����
CREATE SEQUENCE sequence�̸�
	[INCREMENT BY n]	
	[START WITH n]                		  
	[MAXVALUE n | NOMAXVALUE]   
	[MINVALUE n | NOMINVALUE]	
	[CYCLE | NOCYCLE(�⺻)]		
	[CACHE n | NOCACHE]		  

- INCREMENT BY n: ����ġ ����. ������ 1
- START WITH n: ���� �� ����. ������ 0
	- ���۰� ������
	 - ����: MINVALUE ���� ũĿ�� ���� ���̾�� �Ѵ�.
	 - ����: MAXVALUE ���� �۰ų� ���� ���̾�� �Ѵ�.
- MAXVALUE n: �������� ������ �� �ִ� �ִ밪�� ����
- NOMAXVALUE : �������� ������ �� �ִ� �ִ밪�� ���������� ��� 10^27 �� ��. ���������� ��� -1�� �ڵ����� ����. 
- MINVALUE n :�ּ� ������ ���� ����
- NOMINVALUE :�������� �����ϴ� �ּҰ��� ���������� ��� 1, ���������� ��� -(10^26)���� ����
- CYCLE �Ǵ� NOCYCLE : �ִ�/�ּҰ����� ������ ��ȯ�� �� ����. NOCYCLE�� �⺻��(��ȯ�ݺ����� �ʴ´�.)
- CACHE|NOCACHE : ĳ�� ��뿩�� ����.(����Ŭ ������ �������� ������ ���� �̸� ��ȸ�� �޸𸮿� ����) NOCACHE�� �⺻��(CACHE�� ������� �ʴ´�. )


������ �ڵ������� ��ȸ
 - sequence�̸�.nextval  : ���� ����ġ ��ȸ
 - sequence�̸�.currval  : ���� �������� ��ȸ


������ ����
ALTER SEQUENCE ������ �������̸�
	[INCREMENT BY n]	               		  
	[MAXVALUE n | NOMAXVALUE]   
	[MINVALUE n | NOMINVALUE]	
	[CYCLE | NOCYCLE(�⺻)]		
	[CACHE n | NOCACHE]	

������ �����Ǵ� ������ ������ �޴´�. (�׷��� start with ���� ��������� �ƴϴ�.)	  


������ ����
DROP SEQUENCE sequence�̸�
	
************************************************************************************************************** */
---�������� table���� �ٸ� ��ü��
-- 1���� 1�� '�ڵ�����'�ϴ� ������
create sequence dept_id_seq;  --dept_id: �� �������� ����� �÷� �̸�.  ���� ���� _seq�� ����

select dept_id_seq.nextval from dual;   --������ ������ 1�� ����

insert into dept values (dept_id_seq.nextval, '������', '�λ�');

select * from dept;

-- 1���� 50���� 10�� �ڵ����� �ϴ� ������
create sequence ex1_seq 
increment by 10 
maxvalue 50;

select ex1_seq.nextval from dual;


-- 100 ���� 150���� 10�� �ڵ������ϴ� ������
create sequence ex2_seq
increment by 10
start with 100
maxvalue 150;

select ex2_seq.nextval from dual;
-- 100 ���� 150���� 2�� �ڵ������ϵ� �ִ밪�� �ٴٸ��� ��ȯ�ϴ� ������
-- ��ȯ�ϰ� �Ǹ� ���� �� ��쿡�� minvalue���� ����. minvalue ���� ���ϸ� �⺻��: 1
--             ���� �� ��쿡�� maxvalue���� ����. maxvalue ���� ���ϸ� �⺻��: -1
create sequence ex3_seq
increment by 2
start with 100
maxvalue 150
cycle;

select ex3_seq.nextval from dual;


-- -1���� �ڵ� �����ϴ� ������
create sequence ex4_seq
increment by -1;

select ex4_seq.nextval from dual;


-- -1���� -50���� -10�� �ڵ� �����ϴ� ������
create sequence ex5_seq
increment by -10
minvalue -50;

select ex5_seq.nextval from dual;


-- 100 ���� -100���� -100�� �ڵ� �����ϴ� ������
-- ���� : maxvalue �⺻��: -1. start with�� maxvalue���� ũ�� �ȵȴ�.
-- ���� : start with�� minvalue���� ������ �ȵȴ�.
create sequence ex6_seq
increment by -100
start with 100
minvalue -100
maxvalue 100;

select ex6_seq.nextval from dual;


-- 15���� -15���� 1�� �����ϴ� ������ �ۼ�
create sequence ex7_seq
increment by -2
start with 15
minvalue -15
maxvalue 30
cycle;

select ex7_seq.nextval from dual;

-- -10 ���� 1�� �����ϴ� ������ �ۼ�
create sequence ex8_seq
increment by 1
start with -10
minvalue -10;

--��ȯ�ϴ� �������� ��� �����ϴ� ���� ������ cache �������� ���ƾ� �Ѵ�.
--cache�� �⺻�� 6

create sequence ex9_seq
increment by 10
maxvalue 50
cycle
cache 3;


-- Sequence�� �̿��� �� insert



-- TODO: �μ�ID(dept.dept_id)�� ���� �ڵ����� ��Ű�� sequence�� ����. 10 ���� 10�� �����ϴ� sequence
-- ������ ������ sequence�� ����ؼ�  dept_copy�� 5���� ���� insert.
create table dept_copy
as 
select * from dept
where 1 = 0;

create sequence dept_id_seq2
increment by 10
start with 10;

insert into dept_copy values (dept_id_seq2.nextval, 
                                '���μ�'||ex9_seq.nextval,
                                '����');

select * from dept_copy;


-- TODO: ����ID(emp.emp_id)�� ���� �ڵ����� ��Ű�� sequence�� ����. 10 ���� 1�� �����ϴ� sequence
-- ������ ������ sequence�� ����� emp_copy�� ���� 5�� insert


