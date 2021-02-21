/*전반적인 bussiness 현황 파악 ==========================================================================*/
/*전체 주문 건수*/
describe orders;
SELECT *
FROM orders;
-- 중복 존재 여부 확인
SELECT COUNT(order_id),
		COUNT(DISTINCT(order_id))
FROM orders; -- 중복 없음
-- 전체 주문 건수
SELECT COUNT(order_id)
FROM orders;

/*구매자 수*/
SELECT COUNT(DISTINCT(user_id))
FROM orders;

/*상품별 주문 건수*/
-- product_id로 group by
describe order_products__prior;
SELECT * FROM order_products__prior;
SELECT B.product_name,
		B.product_id,
		COUNT(DISTINCT(A.order_id))
FROM order_products__prior A LEFT JOIN products B ON A.product_id = B.product_id
GROUP BY B.product_name;

/*장바구니에 가장 먼저 넣는 상품 상위 10개*/
-- add_to_cart_order = 1 <- count + order by + table join <- product_name 
-- WHERE 조건절 이용
SELECT 	A.product_id,
	B.product_name,
	COUNT(A.product_id) AS cnt
FROM order_products__prior A LEFT JOIN products B ON A.product_id = B.product_id
WHERE add_to_cart_order = 1
GROUP BY A.product_id
ORDER BY 3 DESC
LIMIT 10;
-- CASE구 조건절로 활용
SELECT 	A.product_id,
	B.product_name,
	SUM(CASE WHEN add_to_cart_order = 1 THEN 1 ELSE 0 END) AS cnt
FROM order_products__prior A LEFT JOIN products B ON A.product_id = B.product_id
GROUP BY A.product_id
ORDER BY 3 DESC
LIMIT 10;
-- LIMIT 사용하지 않고, RANKING이용하기
SELECT *
FROM (SELECT *,
		ROW_NUMBER() OVER(ORDER BY cnt DESC) AS RNK
	FROM(SELECT 	A.product_id,
					B.product_name,
					SUM(CASE WHEN add_to_cart_order = 1 THEN 1 ELSE 0 END) AS cnt
		FROM order_products__prior A LEFT JOIN products B ON A.product_id = B.product_id
		GROUP BY A.product_id) TMP ) TMP2
WHERE RNK BETWEEN 1 AND 10;

/*시간별 주문 건수*/
SELECT * FROM orders;
SELECT order_hour_of_day AS Time,
		COUNT(DISTINCT(order_id)) AS order_cnt
FROM orders
GROUP BY order_hour_of_day;

/*첫 구매 후, 다음 구매까지 걸린 평균 일수*/
SELECT AVG(days_since_prior_order)
FROM orders
WHERE order_number = 2;
     
/*주문 건당 평균 구매 상품 수 (UPT: Unit Per Transaction)*/
SELECT * FROM order_products__prior;
-- 비효율적 예시
SELECT AVG(per_order_cnt)
FROM (SELECT COUNT(product_id) AS per_order_cnt
		FROM order_products__prior
		GROUP BY order_id) TMP
;
-- 정상 예시
SELECT COUNT(product_id) / COUNT(DISTINCT(order_id)) AS UPT
FROM order_products__prior;

/*인당 평균 주문 건수*/
SELECT COUNT(DISTINCT(order_id)) / COUNT(distinct(user_id)) as avg_f
FROM orders;

/*재구매율이 가장 높은 상품 10개*/
SELECT product_id,
		SUM(CASE WHEN reordered = 1 THEN 1 ELSE 0 END) / COUNT(*) AS RET_RATIO
FROM order_products__prior
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*Department별 재구매율이 가장 높은 상품 10개*/
-- row_number() over(partition by department order by 재구매율 desc) -> 각 dp별 1~10
-- order_products__prior, products, departments
-- department별 1~10순위 각각
SELECT *
FROM (SELECT *,
		ROW_NUMBER() OVER(PARTITION BY department ORDER BY RET_RATIO DESC) AS RNK
	FROM (SELECT C.department,
				B.product_id,
                B.product_name,
				SUM(CASE WHEN reordered = 1 THEN 1 ELSE 0 END) / COUNT(*) AS RET_RATIO
		FROM order_products__prior A LEFT JOIN products B ON A.product_id = B.product_id
									LEFT JOIN departments C ON B.department_id = C.department_id
		GROUP BY 1,2) TMP) TMP2
WHERE RNK BETWEEN 1 AND 10;
-- 전체 1 ~ 10
SELECT *
FROM (SELECT *,
		ROW_NUMBER() OVER(ORDER BY RET_RATIO DESC) AS RNK
	FROM (SELECT C.department,
				B.product_id,
                B.product_name,
				SUM(CASE WHEN reordered = 1 THEN 1 ELSE 0 END) / COUNT(*) AS RET_RATIO
		FROM order_products__prior A LEFT JOIN products B ON A.product_id = B.product_id
									LEFT JOIN departments C ON B.department_id = C.department_id
		GROUP BY 1,2) TMP) TMP2
WHERE RNK BETWEEN 1 AND 10;

/*구매자 분석 ==========================================================================*/
/*10분위 분석 - 고객별 주문 수를 통해 각 고객이 어떤 그룹에 속하는지 구하기 -> 각 분위수별 주문 건수의 합 => 어떤 그룹에 얼마나 집중되어있는지*/
-- 고객별 주문 수 기준 순위
SELECT *,
		ROW_NUMBER() OVER(ORDER BY F DESC) AS RNK
FROM (SELECT user_id,
		COUNT(DISTINCT(order_id)) AS F
	FROM orders
	GROUP BY 1) TMP
;
-- 전체 고객 수
SELECT COUNT(DISTINCT(user_id))
FROM orders; -- 3159명

SELECT ROUND(3159*0.1,0); -- 0~10%
SELECT CEIL(3159*0.2); -- 10~20%  

-- 등수에 따른 10분위 구하기 및 테이블 임시 저장
CREATE TEMPORARY TABLE USER_QUANTILE AS
SELECT *,
	CASE 
		WHEN RNK <= ROUND(3159*0.1,0) THEN 'Q1'
		WHEN RNK <= ROUND(3159*0.2,0) THEN 'Q2'
        WHEN RNK <= ROUND(3159*0.3,0) THEN 'Q3'
        WHEN RNK <= ROUND(3159*0.4,0) THEN 'Q4'
        WHEN RNK <= ROUND(3159*0.5,0) THEN 'Q5'
        WHEN RNK <= ROUND(3159*0.6,0) THEN 'Q6'
        WHEN RNK <= ROUND(3159*0.7,0) THEN 'Q7'
        WHEN RNK <= ROUND(3159*0.8,0) THEN 'Q8'
        WHEN RNK <= ROUND(3159*0.9,0) THEN 'Q9'
    ELSE 'Q10' END AS Quantile
FROM (SELECT *,
			ROW_NUMBER() OVER(ORDER BY F DESC) AS RNK
		FROM (SELECT user_id,
					COUNT(DISTINCT(order_id)) AS F
			FROM orders
			GROUP BY 1) TMP ) TMP2;

-- 분위수별 주문건 수
SELECT quantile,
		SUM(F)
FROM USER_QUANTILE
GROUP BY 1;
-- 분위수별 주문 비중
SELECT SUM(F) 
FROM USER_QUANTILE; -- 3220건
SELECT quantile,
		SUM(F) / 3220 AS F_RATIO
FROM USER_QUANTILE
GROUP BY 1; -- 각 분위수별 주문 건수가 거의 고르게 분포되어 있음 
-- => 해당 서비스는 매출이 VIP에 집중되지 않고, 전체 고객에 고르게 분포되어 있음을 알 수 있음

/*상품 분석 ====================================================================================*/
describe order_products__prior;
-- 상품별 재구매 비중과 주문 건수
SELECT product_id,
		SUM(reordered) / COUNT(*) AS REORDER_RATE, -- SUM(1) = COUNT(*)
        COUNT(DISTINCT(order_id)) AS F
FROM order_products__prior
GROUP BY 1
ORDER BY 2 DESC;
-- 상품별 재구매 비중과 주문 건수 + 10건 이하인 것 제외
SELECT product_id,
		SUM(reordered) / COUNT(*) AS REORDER_RATE, -- SUM(1) = COUNT(*)
        COUNT(DISTINCT(order_id)) AS F
FROM order_products__prior
GROUP BY 1
HAVING F > 10
ORDER BY 2 DESC;

-- + 어떤 상품인지 상품 이름도 같이
SELECT A.product_id,
		B.product_name,
		SUM(A.reordered) / COUNT(*) AS REORDER_RATE, -- SUM(1) = COUNT(*)
        COUNT(DISTINCT(A.order_id)) AS F
FROM order_products__prior A LEFT JOIN products B ON A.product_id = B.product_id
GROUP BY 1,2
HAVING F > 10
ORDER BY 3 DESC;

/*다음 구매까지의 소요 기간과 재구매의 관계 =================================*/
/*상품별 재구매율 계산 및 순위*/
SELECT *,
		ROW_NUMBER() OVER(ORDER BY REODER_RATE DESC) AS RNK
FROM (SELECT product_id,
		SUM(reordered)/COUNT(*) AS REODER_RATE
	FROM order_products__prior
	GROUP BY 1) TMP ;

/*순위에 따른 그룹 10개로 나누기 (10분위)*/
-- 전체 개수 구하기 => 9288
SELECT COUNT(product_id)
FROM (SELECT *,
		ROW_NUMBER() OVER(ORDER BY REODER_RATE DESC) AS RNK
FROM (SELECT product_id,
		SUM(reordered)/COUNT(*) AS REODER_RATE
FROM order_products__prior
GROUP BY 1) TMP ) TMP2 ;
-- 순위에 따른 그룹 10개로 나누기 (10분위) => product_id별 분위수만 남기기 => 임시 TABLE 생성
CREATE TEMPORARY TABLE PRODUCT_REPURCHASE_QUANTILE AS
SELECT product_id,
	CASE
		WHEN RNK <= ROUND(9288*0.1, 0) THEN 'Q1'
        WHEN RNK <= ROUND(9288*0.2, 0) THEN 'Q2'
        WHEN RNK <= ROUND(9288*0.3, 0) THEN 'Q3'
        WHEN RNK <= ROUND(9288*0.4, 0) THEN 'Q4'
        WHEN RNK <= ROUND(9288*0.5, 0) THEN 'Q5'
        WHEN RNK <= ROUND(9288*0.6, 0) THEN 'Q6'
        WHEN RNK <= ROUND(9288*0.7, 0) THEN 'Q7'
        WHEN RNK <= ROUND(9288*0.8, 0) THEN 'Q8'
        WHEN RNK <= ROUND(9288*0.9, 0) THEN 'Q9'
	ELSE 'Q10' END RNK_GROUP
FROM (SELECT *,
		ROW_NUMBER() OVER(ORDER BY REODER_RATE DESC) AS RNK
FROM (SELECT product_id,
		SUM(reordered)/COUNT(*) AS REODER_RATE
FROM order_products__prior
GROUP BY 1) TMP ) TMP2 
GROUP BY 1,2;

-- RNK_GROUP별 데이터 수 확인
SELECT RNK_GROUP,
		COUNT(*)
FROM PRODUCT_REPURCHASE_QUANTILE
GROUP BY 1;

/*각 분위수별 재구매 소요 시간의 분산 구하기*/
SELECT * FROM orders;
SELECT * FROM order_products__prior;
SELECT * FROM PRODUCT_REPURCHASE_QUANTILE;
-- 분위수별X상품별 재구매 소요 시간의 분산
SELECT C.RNK_GROUP,
		A.product_id,
        VARIANCE(B.days_since_prior_order) AS VAR_DAYS
FROM order_products__prior A INNER JOIN orders B ON A.order_id = B.order_id
							LEFT JOIN PRODUCT_REPURCHASE_QUANTILE C ON A.product_id = C.product_id
GROUP BY 1,2
ORDER BY 1;

-- 분위수별 평균/중위수 분산 구한뒤 비교 (재구매율이 높은 상품군은 구매 주기가 일정한가?)
SELECT RNK_GROUP,
		ROUND(AVG(VAR_DAYS),2)
FROM (SELECT C.RNK_GROUP,
			A.product_id,
			VARIANCE(B.days_since_prior_order) AS VAR_DAYS
		FROM order_products__prior A INNER JOIN orders B ON A.order_id = B.order_id
									LEFT JOIN PRODUCT_REPURCHASE_QUANTILE C ON A.product_id = C.product_id
		GROUP BY 1,2) TMP
GROUP BY 1
ORDER BY 1; -- 분위수에 따른 재구매 주기의 분산 평균값이 차이가 없는 것으로 보임
-- => 재구매율이 높은 상품이라고 해서, 구매 주기가 평균에 집중(분산이 비교적 작음)되지 않음을 확인할 수 있음




