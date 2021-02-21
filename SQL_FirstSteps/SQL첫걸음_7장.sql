# 복수의 테이블 다루기
/*합집합 - UNION
- 세로 방향으로 결합됨
- 중복 제거됨
- 열 개수와 자료형이 같아야함
- 원하는 열만 따로 지정해서 합쳐도됨*/
select * from sample71_a
UNION
select * from sample71_b;    # 각 집합에서 중복되는 값은 중복 제거되고, 한개만 집합에 포함됨
    
# 원하는 열만 지정
select a from sample71_a
UNION
select b from sample71_b
UNION
select age from sample31;

# ORDER BY 정렬 - 가장 마지막 SELECT구 & 열에 별명을 붙여 열 이름 통일 시키기!
select a AS c from sample71_a
UNION
select b AS c from sample71_b ORDER BY c;

/*UNION ALL
- 중복 제거하지 않고 그대로 합쳐짐*/
select * from sample71_a
UNION ALL
select * from sample71_b;

/*교차결합(CROSS JOIN)
- 가로 방향으로 결합됨
- SELECT * FROM 테이블명1, 테이블명2,..
- FROM구에 복수의 테이블을 지정하면 교차결합 즉, 곱집합 계산이 일어남 M*N개*/
SELECT * FROM sample72_x, sample72_y;     # 모든 경우의 수 
SELECT * FROM sample72_x CROSS JOIN sample72_y;

/*내부 결합(Inner Join) -  구방식*/
select * from 상품;
select * from 재고수;

# 상품코드 같은 것 끼리 조인
select * from 상품, 재고수 
WHERE 상품.상품코드 = 재고수.상품코드;   # inner join/등결합

# 원하는 열지정, 조인조건 추가
select 상품.상품명, 재고수.재고수 from 상품, 재고수
WHERE 상품.상품코드 = 재고수.상품코드
AND 상품.상품분류 = '식료품';  # 상품 분류가 '식료품'인 것만

/*내부 결합(Inner Join) -  요즘 방식*/
SELECT 상품.상품명, 재고수.재고수
FROM 상품 INNER JOIN 재고수
ON 상품.상품코드 = 재고수.상품코드    # ON절에 결함 조건 지정
WHERE 상품.상품분류 = '식료품';


SELECT S.상품명, M.메이커명
FROM 상품2 S INNER JOIN 메이커 M
ON S.메이커코드 = M.메이커코드;

/*Self Join
- 같은 테이블에 별명을 붙여 구별*/
SELECT S1.상품명, S2.상품명
FROM 상품 S1 INNER JOIN 상품 S2
ON S1.상품코드=S2.상품코드;

/*LEFT JOIN/RIGHT JOIN*/
# LEFT JOIN으로 재고수 테이블에 없는 상품코드 009(추가상품)도 결과에 포함시키기
SELECT 상품3.상품명, 재고수.재고수
FROM 상품3 LEFT JOIN 재고수
ON 상품3.상품코드=재고수.상품코드
WHERE 상품3.상품분류='식료품';