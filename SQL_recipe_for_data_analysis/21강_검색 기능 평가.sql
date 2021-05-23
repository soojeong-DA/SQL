/* 21강. 검색 기능 평가하기
-  사용자가 무엇을 검색하고, 그 검색 결과에 어떤 행동(상세화면 이동, 이탈, 재검색 등)을 취하는지 파악해서, 검색기능 개선하기 ============= */

/* 21-1. NoMatch 비율과 키워드 집계 ======================================================================================= */

-- 1. NoMatch 바율 집계 (일별)
SELECT substring(stamp::text, 1, 10) AS dt,
	COUNT(*) AS search_count,
	SUM(CASE WHEN result_num = 0 THEN 1 ELSE 0 END) AS no_match_count,
	AVG(CASE WHEN result_num = 0 THEN 1.0 ELSE 0.0 END) AS no_match_rate
FROM access_log
WHERE action = 'search'
GROUP BY dt
;

-- 2. NoMatch 키워드 집계
WITH
search_keyword_stat AS (
	-- 검색 키워드 전체 집계 결과
	SELECT keyword,
		result_num,
		COUNT(*) AS search_count,
		100.0 * COUNT(*) / COUNT(*) OVER() AS search_share   -- 전체 검색에서 차지하는 비중
	FROM access_log
	WHERE action = 'search'
	GROUP BY keyword, result_num
)
-- nomatch keyword 집계 결과
SELECT keyword,
	search_count,
	search_share,
	100.0 * search_count / SUM(search_count) OVER() AS no_match_share  -- 전체 no match 검색에서 차지하는 비중
FROM search_keyword_stat
WHERE result_num = 0    -- no match만
;

/* 21-2. 재검색 비율과 키워드 집계 
- 검색 결과에 만족하지 못해서 새로운 키워드로 검색한 사용자의 행동은, 검색을 어떻게 개선하면 좋을지에 대한 좋은 지표가 됨 
- 재검색 키워드를 집계하면 '동의어 사전'이 흔들림을 잡기 못하는 범위를 쉽게 확인 후, 대처 할 수 있음 =============================== */

-- 1. 재검색 비율 집계 (검색 후 어떤 결과도 클릭하지 않고, 새로 검색을 실행한 비율)
-- 1-1. 검색 화면과 상세화면의 접근 로그에서 바로 다음 행의 액션 추출
WITH
access_log_with_next_action AS (
	SELECT stamp,
		session,
		action,
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action
	FROM access_log
)
SELECT *
FROM access_log_with_next_action
ORDER BY session, stamp
;

-- 1-2. '재검색 = action과 next_action 모두 search인 레코드' 비율 집계
WITH
access_log_with_next_action AS (
	SELECT stamp,
		session,
		action,
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action
	FROM access_log
)
SELECT substring(stamp::text, 1, 10) AS dt,
	COUNT(*) AS search_count,
	SUM(CASE WHEN next_action = 'search' THEN 1 ELSE 0 END) AS retry_count,
	AVG(CASE WHEN next_action = 'search' THEN 1.0 ELSE 0.0 END) AS retry_rate
FROM access_log_with_next_action
WHERE action = 'search'
GROUP BY dt
ORDER BY dt
;

-- 2. 재검색 키워드 집계
WITH
access_log_with_next_search AS (
	SELECT stamp,
		session,
		action,
		keyword,
		result_num,
		-- 다음 행의 액션, 키워드, 검색 결과 수 추출
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action,
		LEAD(keyword) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_keyword,
		LEAD(result_num) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_result_num
	FROM access_log
)
SELECT keyword,
	result_num,
	COUNT(*) AS retry_count,
	next_keyword,
	next_result_num
FROM access_log_with_next_search
WHERE action = 'search'
AND next_action = 'search'
GROUP BY keyword, result_num, next_keyword, next_result_num
ORDER BY retry_count DESC
;

/* 19-3. 재검색 키워드를 분류해서 집계 
- 어떤 상태와 동기로 재검색을 했는지 사용자의 패턴에 따라 분석해보자 ========================================================== */

-- 1. NoMatch에서의 조건 변경한 경우
--> 해당 재검색 키워드는 동의어 사전과 사용자 사전에 추가할 키워드 후보가 됨
-- NoMatch에서 재검색 키워드 집계
WITH
access_log_with_next_search AS (
	SELECT stamp,
		session,
		action,
		keyword,
		result_num,
		-- 다음 행의 액션, 키워드, 검색 결과 수 추출
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action,
		LEAD(keyword) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_keyword,
		LEAD(result_num) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_result_num
	FROM access_log
)
SELECT keyword,
	result_num,
	COUNT(*) AS retry_count,
	next_keyword,
	next_result_num
FROM access_log_with_next_search
WHERE action = 'search'
AND next_action = 'search'
AND result_num = 0
GROUP BY keyword, result_num, next_keyword, next_result_num
;

-- 2. 검색 결과 필터링한 경우
--> 재검색한 검색 키워드가 원래의 검색 키워드를 포함하고 있는 경우, 검색을 조금 더 필터링하고 싶다는 의미
--> 자주 사용되는 필터링 키워드를 연관 검색어 등으로 출력해서, 사용자가 원하는 콘텐츠를 빠르게 찾을 수 있게 해야
-- 검색 결과 필터링 시의 재검색 키워드  집계
WITH
access_log_with_next_search AS (
	SELECT stamp,
		session,
		action,
		keyword,
		result_num,
		-- 다음 행의 액션, 키워드, 검색 결과 수 추출
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action,
		LEAD(keyword) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_keyword,
		LEAD(result_num) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_result_num
	FROM access_log
)
SELECT keyword,
	result_num,
	COUNT(*) AS retry_count,
	next_keyword,
	next_result_num
FROM access_log_with_next_search
WHERE action = 'search'
AND next_action = 'search'
AND next_keyword LIKE CONCAT('%', keyword, '%')   -- 다음 검색 키워드가 기존 검색 키워드를 포함하고 있는 경우만
GROUP BY keyword, result_num, next_keyword, next_result_num
;

-- 3. 검색 키워드를 변경한 경우
--> 완전히 다른 검색 키워드를 사용해 재검색을 한 경우, 기존 검색 키워드를 사용한 검색 결과에 원하는 내용이 없다는 의미
--> 동의어 사전이 제대로 기능하지 못했거나 다른 이유 등 어떤 이유로 행했는지 집계해보자
-- 검색 키워드 변경한 경우의 재검색 집계
WITH
access_log_with_next_search AS (
	SELECT stamp,
		session,
		action,
		keyword,
		result_num,
		-- 다음 행의 액션, 키워드, 검색 결과 수 추출
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action,
		LEAD(keyword) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_keyword,
		LEAD(result_num) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_result_num
	FROM access_log
)
SELECT keyword,
	result_num,
	COUNT(*) AS retry_count,
	next_keyword,
	next_result_num
FROM access_log_with_next_search
WHERE action = 'search'
AND next_action = 'search'
AND next_keyword NOT LIKE CONCAT('%', keyword, '%')   -- 다음 검색 키워드가 기존 검색 키워드를 포함하지 않은 경우만
GROUP BY keyword, result_num, next_keyword, next_result_num
;

/* 21-4. 검색 이탈 비율과 키워드 집계 
- 검색 결과가 출력된 이후, 어떠한 액션도 취하지 않고 이탈한 사용자 => 결과에 만족하지 못한 경우 =========================== */

-- 검색 이탈 비율 집계
WITH
access_log_with_next_action AS (
	SELECT stamp,
		session,
		action,
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action
	FROM access_log
)
SELECT substring(stamp::text, 1, 10) AS dt,
	COUNT(*) AS search_count,
	SUM(CASE WHEN next_action IS NULL THEN 1 ELSE 0 END) AS exit_count,
	AVG(CASE WHEN next_action IS NULL THEN 1.0 ELSE 0.0 END) AS exit_rate
FROM access_log_with_next_action
WHERE action = 'search'
GROUP BY dt
ORDER BY dt
;

-- 검색 이탈 키워드 집계 (동의어 사전 추가 등의 조치를 취해 검색을 개선할 수 있음)
WITH
access_log_with_next_search AS (
	SELECT stamp,
		session,
		action,
		keyword,
		result_num,
		-- 다음 행의 액션, 키워드, 검색 결과 수 추출
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action,
		LEAD(keyword) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_keyword,
		LEAD(result_num) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_result_num
	FROM access_log
)
SELECT keyword,
	COUNT(*) AS search_count,
	SUM(CASE WHEN next_action IS NULL THEN 1 ELSE 0 END) AS exit_count,
	AVG(CASE WHEN next_action IS NULL THEN 1.0 ELSE 0.0 END) AS exit_rate,
	result_num
FROM access_log_with_next_search
WHERE action = 'search'
GROUP BY keyword, result_num
HAVING SUM(CASE WHEN next_action IS NULL THEN 1 ELSE 0 END) > 0   -- 이탈률이 0보다 큰 키워드만 추출
;

/* 21-5. 검색 키워드 관련 지표의 집계 효율화 ====================================================================== */
-- 검색과 관련된 지표 집계 효율화를 위해 중간 데이터 생성
WITH
access_log_with_next_search AS (
	SELECT stamp,
		session,
		action,
		keyword,
		result_num,
		-- 다음 행의 액션, 키워드, 검색 결과 수 추출
		LEAD(action) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_action,
		LEAD(keyword) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_keyword,
		LEAD(result_num) OVER(PARTITION BY session ORDER BY stamp ASC) AS next_result_num
	FROM access_log
),
search_log_with_next_action AS (
	SELECT * 
	FROM access_log_with_next_search
	WHERE action = 'search'
)
SELECT *
FROM search_log_with_next_action
ORDER BY session, stamp
;

/* 21-6. 검색 결과의 포괄성 지표화
- 사용자 검색 로그가 아닌, 검색 키워드에 대한 지표를 사용해 검색 엔진 자체의 정밀도를 평가해보자 ================================== */

-- 1. 재현율(Recall)을 사용해 검색의 포괄성 평가
-- 재현율: 어떤 키워드의 검색 결과에서 미리 준비한 정답 아이템이 얼마나 나왔는 지 비율로 나타낸 것

-- 1-1. 검색 결과와 정답 아이템 결합
WITH
search_result_with_correct_items AS (
	SELECT COALESCE(r.keyword, c.keyword) AS keyword,
		r.rank,
		COALESCE(r.item, c.item) AS item,
		CASE WHEN c.item IS NOT NULL THEN 1 ELSE 0 END AS correct  -- flag가 1인 item이 정답 item에 포함된 item
	FROM search_result r FULL OUTER JOIN correct_result c ON r.keyword = c.keyword AND r.item = c.item
)
SELECT * 
FROM search_result_with_correct_items
ORDER BY keyword, rank
;

-- 1-2. 검색 결과의 상위 n개(rank)의 재현율을 계산
WITH
search_result_with_correct_items AS (
	SELECT COALESCE(r.keyword, c.keyword) AS keyword,
		r.rank,
		COALESCE(r.item, c.item) AS item,
		CASE WHEN c.item IS NOT NULL THEN 1 ELSE 0 END AS correct
	FROM search_result r FULL OUTER JOIN correct_result c ON r.keyword = c.keyword AND r.item = c.item
)
,search_result_with_recall AS (
	SELECT *,
		-- 검색 결과 상위에서 정갑 데이터에 포함되는 아이템 수의 누계 구하기
		SUM(correct) OVER(PARTITION BY keyword ORDER BY COALESCE(rank, 100000) ASC  -- rank null -> 편의상 큰 값으로 변환
						 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS cum_correct,
		-- 검색 결과에 포함되지 않은 아이템은 0으로
		CASE 
			WHEN rank IS NULL THEN 0.0 
			ELSE 100.0 
				* SUM(correct) OVER(PARTITION BY keyword ORDER BY COALESCE(rank, 100000) ASC
										  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
				/ SUM(correct) OVER(PARTITION BY keyword)
		END AS recall
	FROM search_result_with_correct_items
)
SELECT *
FROM search_result_with_recall
ORDER BY keyword, rank
;

-- 2. 재현율의 값을 집약해서 비교하기 더 쉽게 만들기
-- 검색 결과 전체 레코드에 대한 재현율이 아닌, 첫 페이지에 노출되는 아이템 개수 기준으로 한정하여 검색 엔진 평가하기

-- 2-1. 검색 결과 상위 5개의 재현율을 키워드별로 추출
WITH
search_result_with_correct_items AS (
	SELECT COALESCE(r.keyword, c.keyword) AS keyword,
		r.rank,
		COALESCE(r.item, c.item) AS item,
		CASE WHEN c.item IS NOT NULL THEN 1 ELSE 0 END AS correct
	FROM search_result r FULL OUTER JOIN correct_result c ON r.keyword = c.keyword AND r.item = c.item
)
,search_result_with_recall AS (
	SELECT *,
		-- 검색 결과 상위에서 정갑 데이터에 포함되는 아이템 수의 누계 구하기
		SUM(correct) OVER(PARTITION BY keyword ORDER BY COALESCE(rank, 100000) ASC  -- rank null -> 편의상 큰 값으로 변환
						 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS cum_correct,
		-- 검색 결과에 포함되지 않은 아이템은 0으로
		CASE 
			WHEN rank IS NULL THEN 0.0 
			ELSE 100.0 
				* SUM(correct) OVER(PARTITION BY keyword ORDER BY COALESCE(rank, 100000) ASC
										  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
				/ SUM(correct) OVER(PARTITION BY keyword)
		END AS recall
	FROM search_result_with_correct_items
)
, recall_over_rank_5 AS (
	SELECT keyword,
		rank,
		recall,
		-- 검색 결과 순위가 높은 순서로 번호 붙이기 (검색 결과에 나오지 않는 item은 0으로)
		ROW_NUMBER() OVER(PARTITION BY keyword ORDER BY COALESCE(rank, 0) DESC) AS desc_number
	FROM search_result_with_recall
	WHERE COALESCE(rank, 0) <= 5  -- 검색결과 삼위 5개 이하 or 검색 결과에 포함되지 않은 item만 출력
)
SELECT keyword,
	recall AS recall_at_5
FROM recall_over_rank_5
WHERE desc_number = 1  -- 가장 순위가 높은 레코드만 추출
;

-- 2-2. 검색 엔진 전체의 평균 재현율 계산
WITH
search_result_with_correct_items AS (
	SELECT COALESCE(r.keyword, c.keyword) AS keyword,
		r.rank,
		COALESCE(r.item, c.item) AS item,
		CASE WHEN c.item IS NOT NULL THEN 1 ELSE 0 END AS correct
	FROM search_result r FULL OUTER JOIN correct_result c ON r.keyword = c.keyword AND r.item = c.item
)
,search_result_with_recall AS (
	SELECT *,
		-- 검색 결과 상위에서 정갑 데이터에 포함되는 아이템 수의 누계 구하기
		SUM(correct) OVER(PARTITION BY keyword ORDER BY COALESCE(rank, 100000) ASC  -- rank null -> 편의상 큰 값으로 변환
						 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS cum_correct,
		-- 검색 결과에 포함되지 않은 아이템은 0으로
		CASE 
			WHEN rank IS NULL THEN 0.0 
			ELSE 100.0 
				* SUM(correct) OVER(PARTITION BY keyword ORDER BY COALESCE(rank, 100000) ASC
										  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
				/ SUM(correct) OVER(PARTITION BY keyword)
		END AS recall
	FROM search_result_with_correct_items
)
, recall_over_rank_5 AS (
	SELECT keyword,
		rank,
		recall,
		-- 검색 결과 순위가 높은 순서로 번호 붙이기 (검색 결과에 나오지 않는 item은 0으로)
		ROW_NUMBER() OVER(PARTITION BY keyword ORDER BY COALESCE(rank, 0) DESC) AS desc_number
	FROM search_result_with_recall
	WHERE COALESCE(rank, 0) <= 5  -- 검색결과 삼위 5개 이하 or 검색 결과에 포함되지 않은 item만 출력
)
SELECT AVG(recall) AS average_recall_at_5
FROM recall_over_rank_5
WHERE desc_number = 1
;
