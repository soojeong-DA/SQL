/* 여러 개의 테이블을 세로로 결합 (UNION [ALL]) 
- 결합시 테이블의 컬럼이 완전히 일치해야함
=> 한쪽 테이블에만 존재하는 컬럼은 SELECT 구문에서 제외 or default값을 지정해야함 */
SELECT 'app1' AS app_name, -- 결합 후 데이터가 어떤 테이블의 데이터 였는지 식별할 수 있게 app_name열 추가
	user_id,
	name,
	email
FROM app1_mst_users
UNION ALL
SELECT 'app2' AS app_name,
	user_id,
	name,
	NULL AS email -- app2에는 email 데이터가 없어, default 값으로 NULL 지정해줌
FROM app2_mst_users;


