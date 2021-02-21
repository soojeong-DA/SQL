@"C:\Users\Playdata\oracle_data\join ����\order_ddl.sql";


/*
1. ��ǰ ���̺��� ��ǰ_ID �÷��� ___primary key (��Ű)____ �÷�(��������)���� �� ���� �ٸ� ��� �ĺ��� �� ���ȴ�.
2. ��ǰ ���̺��� ������ �÷��� Not Null(NN) �� ������ ���� _____NULL_____ �� ����(� ���� ������ �ִ��� ������)�� ���� ����.
3. �� ���̺��� �ٸ���� �ĺ��� �� ����ϴ� �÷��� __��_ID_(cust_id)____ �̴�. 
4. �� ���̺��� ��ȭ��ȣ �÷��� ������ Ÿ���� ___varchar2____ ���� _____���ڿ�_____����(���ڿ�,����,�Ǽ�,date)�� �� _15_����Ʈ ������ �� ������ NULL ���� ___���___.
5. �� ���̺��� ������ �÷��� ���� 4�� ó�� ������ ���ÿ�.
    - �� ���̺��� ������ �ķ��� ������ Ÿ���� date Ÿ������, ��¥(date) ������ ���� ������ �� ������, NULL���� ������� �ʴ´�.
6. �ֹ� ���̺��� �� 5�� �÷��� �ִ�. ���� Ÿ���� _3_���̰� ���ڿ� Ÿ���� _1_�� �̰� ��¥ Ÿ���� _1_���̴�.
7. �� ���̺�� �ֹ����̺��� ���� ���谡 �ִ� ���̺��Դϴ�.
    �θ����̺��� __�����̺�___ �̰� �ڽ� ���̺��� __�ֹ����̺�__�̴�.
    �θ����̺��� ___��_ID(cust_id)___�÷��� �ڽ����̺��� __��_ID(cust_id)__�÷��� �����ϰ� �ִ�.
    �����̺��� ������ �����ʹ� �ֹ����̺��� __0~N___ ��� ���谡 ���� �� �ִ�.
    �ֹ����̺��� ������ �����̺��� _1_��� ���谡 ���� �� �ִ�.
8. �ֹ� ���̺�� �ֹ�_��ǰ ���̺��� ���� ���谡 �ִ� ���̺��Դϴ�.
    �θ� ���̺��� __�ֹ� ���̺�(orders)__ �̰� �ڽ� ���̺��� __�ֹ���ǰ���̺�(order_items)__�̴�.
    �θ� ���̺��� __�ֹ�_ID(order_id)__�÷��� �ڽ� ���̺��� __�ֹ�_ID(order_id)__�÷��� �����ϰ� �ִ�.
    �ֹ� ���̺��� ������ �����ʹ� �ֹ�_��ǰ ���̺��� _0~N (���� ����)__ ��� ���谡 ���� �� �ִ�.
    �ֹ�_��ǰ ���̺��� ������ �ֹ� ���̺��� ___1__��� ���谡 ���� �� �ִ�.
9. ��ǰ�� �ֹ�_��ǰ�� ���� ���谡 �ִ� ���̺��Դϴ�. 
    �θ� ���̺��� __��ǰ ���̺�(product)__ �̰� �ڽ� ���̺��� __�ֹ���ǰ���̺�(order_items)___�̴�.
    �θ� ���̺��� __��ǰ_ID(product_id)__�÷��� �ڽ� ���̺��� __��ǰ_ID(product_id)___�÷��� �����ϰ� �ִ�.
    ��ǰ ���̺��� ������ �����ʹ� �ֹ�_��ǰ ���̺��� ___0~N___ ��� ���谡 ���� �� �ִ�.
    �ֹ�_��ǰ ���̺��� ������ ��ǰ ���̺��� __1___��� ���谡 ���� �� �ִ�.
*/

-- TODO: 4���� ���̺� � ������ �ִ��� Ȯ��.
select * from customers;
select * from orders;
select * from order_items;
select * from products;

-- TODO: �ֹ� ��ȣ�� 1�� �ֹ��� �ֹ��� �̸�, �ּ�, �����ȣ, ��ȭ��ȣ ��ȸ
select o.order_id
        ,c.cust_name
        ,c.address
        ,c.postal_code
        ,c.phone_number
from orders o join customers c on o.cust_id = c.cust_id
where o.order_id = 1;

-- TODO : �ֹ� ��ȣ�� 2�� �ֹ��� �ֹ���, �ֹ�����, �ѱݾ�, �ֹ��� �̸�, �ֹ��� �̸��� �ּ� ��ȸ
select o.order_date
        ,o.order_status
        ,o.order_total
        ,c.cust_name
        ,c.cust_email
from orders o join customers c on o.cust_id = c.cust_id
where o.order_id = 2;

-- TODO : �� ID�� 120�� ���� �̸�, ����, �����ϰ� ���ݱ��� �ֹ��� �ֹ������� �ֹ�_ID, �ֹ���, �ѱݾ��� ��ȸ
select c.cust_name
        ,c.gender
        ,c.join_date
        ,o.order_id
        ,o.order_date
        ,o.order_total
from orders o join customers c on o.cust_id = c.cust_id
where c.cust_id = 120;

-- TODO : �� ID�� 110�� ���� �̸�, �ּ�, ��ȭ��ȣ, �װ� ���ݱ��� �ֹ��� �ֹ������� �ֹ�_ID, �ֹ���, �ֹ����� ��ȸ
 select c.cust_name
        ,c.address
        ,c.phone_number
        ,o.order_id
        ,o.order_date
        ,o.order_status
from orders o join customers c on o.cust_id = c.cust_id
where c.cust_id = 110;

-- TODO : �� ID�� 120�� ���� ������ ���ݱ��� �ֹ��� �ֹ������� ��� ��ȸ.
 select c.*
        ,o.*
from orders o join customers c on o.cust_id = c.cust_id
where c.cust_id = 120;

-- TODO : '2017/11/13'(�ֹ���¥) �� �ֹ��� �ֹ��� �ֹ����� ��_ID, �̸�, �ֹ�����, �ѱݾ��� ��ȸ
select c.cust_id
        ,c.cust_name
        ,o.order_status
        ,o.order_total
from orders o join customers c on o.cust_id = c.cust_id
where o.order_date = '2017/11/13';

-- TODO : �ֹ��� ID�� xxxx�� �ֹ���ǰ�� ��ǰ�̸�, �ǸŰ���, ��ǰ������ ��ȸ.
select oi.order_item_id
        ,p.product_name
        ,oi.sell_price
        ,p.price
from order_items oi join products p on oi.product_id = p.product_id
where oi.order_item_id = 10;

select order_item_id from order_items;


-- TODO : �ֹ� ID�� 4�� �ֹ��� �ֹ� ���� �̸�, �ּ�, �����ȣ, �ֹ���, �ֹ�����, �ѱݾ�, �ֹ� ��ǰ�̸�, ������, ��ǰ����, �ǸŰ���, ��ǰ������ ��ȸ.
-- �ᱹ�� �� ���ľ���
-- �ָ��ϴ� ������ �׳� outer join�ϸ��. ��ó�� �ƴϿ����� ��� �Ȱ����ϱ�.
select c.cust_name
        ,c.address
        ,c.postal_code
        ,o.order_date
        ,o.order_status
        ,o.order_total
        ,p.product_name
        ,p.maker
        ,p.price
        ,oi.quantity
from orders o left join customers c on o.cust_id = c.cust_id
              left join order_itmes oi on o.order_id = oi.order_id
              left join products p on oi.product_id = p.product_id
where o.order_id = 4;


-- TODO : ��ǰ ID�� 200�� ��ǰ�� 2017�⿡ � �ֹ��Ǿ����� ��ȸ.
select count(*)
from order_items oi join orders o on oi.order_id = o.order_id
where oi.product_id = 200
and to_char(o.order_date,'yyyy') = '2017';


-- TODO : ��ǰ�з��� �� �ֹ����� ��ȸ
select p.category
        ,count(*)  "�� ��� �ȷȴ���"
        ,nvl(sum(oi.quantity),0) "�� � �ȷȴ���"
from products p left join order_items oi on p.product_id = oi.product_id
group by p.category
order by 3 desc;


