/* 새로운 지표 정의
- 단순하게 숫자로 비교하면 숫치가 큰 데이터만 주목하게 되지만, 
'개인별' or '비율' 등의 지표를 사용하면 **다양한 관점**에서 데이터를 바라볼 수 있음 
- ex. 페이지뷰 / 방문자수 = '사용자 한 명이 페이지를 몇번이나 방문했는 가?' */

/* 1. 문자열 연결 */
-- CONCAT 함수 or ||
SELECT user_id,
	CONCAT(pref_name, ' ', city_name) AS pref_city1, -- 주소 연결
	pref_name||' '||city_name AS pref_city2
FROM mst_user_location;

/* 2. 여러 개의 값 비교 */
SELECT * FROM quarterly_sales;

-- 분기별 매출 증감 판정(q1, q2)
SELECT year,
	-- Q1, Q2의 매출 변화 평가
	CASE 
		WHEN q1 < q2 THEN '+'
		WHEN q1 = q2 THEN ' '
	ELSE '-' END AS judge_q1_q2,
	-- 매출액 차이 계산
	q2 - q1 AS diff_q2_q1,
	-- 매출 변화를 1,0,-1로 표현 	
	SIGN(q2 - q1) AS sign_q2_q1
FROM quarterly_sales
ORDER BY year;

-- 연간 최대/최소 분기 매출 찾기
-- greatest/least 함수 사용 (한 컬컴 안에서 비교는 MAX/MIN. but, 이 경우는 여러개 컬럼 값들을 비교하는 경우니까!)
SELECT year,
	greatest(q1,q2,q3,q4) AS greatest_sales,
	least(q1,q2,q3,q4) AS least_sales
FROM quarterly_sales
ORDER BY year;

/* 3. 2개의 값 비율 계산 */


/* 4. 두 값의 거리 계산 */


/* 5. 날짜/시간 계산 */


/* 6. IP 주소 다루기 */

