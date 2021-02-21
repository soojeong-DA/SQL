describe dataset2;
SELECT * 
FROM dataset2;
/*Division별 평점 분포 계산*/
-- 1. Division Name별 평균 평점 
SELECT `Division Name`, -- 컬럼 이름에 공백이 있을 경우, 역따옴표(어포스트로피)로 묶어서 씀!
		AVG(rating)
FROM dataset2
GROUP BY 1
ORDER BY 2 DESC;

-- 2. Department별 평균 평점
SELECT `Department Name`,
		AVG(rating)
FROM dataset2
GROUP BY 1
ORDER BY 2 DESC;  -- Trend 평점이 상위 5개 Departments 대비 매우 낮게 나타남

-- 3-1. Trend의 평점 3점 이하 리뷰
SELECT *
FROM dataset2
WHERE `Department Name` = 'Trend'
AND `Rating` <= 3;

-- 3-2. Trend의 평점 3점 이하 리뷰 분포(연령대별)
-- 복잡한 CASE문 대신, FLOOR 함수를 통해 소수점을 버림하고, 다시 10을 곱해 => 연령대 쉽게 구하기
SELECT FLOOR(AGE/10)*10 AgeBand,
		COUNT(*)
FROM dataset2
WHERE `Department Name` = 'Trend'
AND `Rating` <= 3
GROUP BY 1
ORDER BY 2 DESC;  -- 50, 40대에서 3점이하 리뷰수가 가장 많음 != 가장많은 불만이 있음  => 50,40대 리뷰가 그냥 많은 것일 수도!

--  3-3. + Trend 전체 연령별 리뷰 수 구해보기
SELECT FLOOR(age/10)*10 AgeBand,
		COUNT(*)
FROM dataset2
WHERE `Department Name` = 'Trend' 
GROUP BY 1
ORDER BY 2 DESC;

-- 3-4. Trend의 3점이하 평점 리뷰 비중으로 살펴보기 (연령대별)
SELECT FLOOR(age/10)*10 AgeBand,
		COUNT(*) total_cnt,
        SUM(CASE WHEN rating <= 3 THEN 1 ELSE 0 END) lower_cnt,
		SUM(CASE WHEN rating <= 3 THEN 1 ELSE 0 END) / COUNT(*) lower_rating
FROM dataset2
WHERE `Department Name` = 'Trend' 
GROUP BY 1
ORDER BY 4 DESC; -- 3점이하 평점 비중이 50대가 가장 높고, 그 다음으로 60대, 40대 순으로 나타남

-- 3-5. 50대 Trend 3점이하 리뷰 살펴보기
SELECT *
FROM dataset2
WHERE `Department Name` = 'Trend'
AND rating <= 3
AND age BETWEEN 50 AND 59;  -- Size관련 불만이 많음

/*평점이 낮은 상품의 주요 Complain Check*/
-- Deparment, Clothing ID별 평점이 낮은 주요 10개 상품 조회(bottom10) + Department내에서 평균 평점 기준 순위 매기기(낮은순)
SELECT *
FROM (SELECT `Department Name`,
			`Clothing ID`,
			AVG(rating) AVG_RATE,
			ROW_NUMBER() OVER(PARTITION  BY `Department Name` ORDER BY AVG(rating)) RNK
		FROM dataset2
		GROUP BY 1,2) TMP
WHERE RNK BETWEEN 1 AND 10
;

-- 임시(TEMPORARY) 테이블 생성 (세션/연결 종료되면 자동으로 삭제됨)
CREATE TEMPORARY TABLE STAT AS
SELECT *
FROM (SELECT `Department Name`,
			`Clothing ID`,
			AVG(rating) AVG_RATE,
			ROW_NUMBER() OVER(PARTITION  BY `Department Name` ORDER BY AVG(rating)) RNK
		FROM dataset2
		GROUP BY 1,2) TMP
WHERE RNK BETWEEN 1 AND 10
;

SELECT *
FROM STAT;

-- STAT의 Clothing id를 이용해, 특정 department의 bottom 10 리뷰 조회
SELECT *
FROM dataset2
WHERE `Clothing ID` IN (SELECT `Clothing ID`
						FROM STAT
                        WHERE `Department Name` = 'Bottoms')
ORDER BY `Clothing ID`;  -- 주로 size, 소재에 대한 내용이 다수 확인됨

-- 추후, 리뷰 내용의 TF-IDF Score를 통해 가치 높은/도움이되는 단어(ex. size, texture, delivery,..) 파악 필요함

/*연령별 Worst Department*/
-- 연령대, Department별 평균 rating -> 가장 낮은 rating 점수를 가진 Department (RNK=1) 조회
SELECT *
FROM (SELECT FLOOR(age/10)*10 AGEBAND,
		`Department Name`,
        AVG(rating) age_rating,
        ROW_NUMBER() OVER(PARTITION BY FLOOR(age/10)*10 ORDER BY AVG(rating)) RNK
	FROM dataset2
	GROUP BY 1,2) TMP
WHERE RNK=1;

/*Size Complain*/
-- 리뷰에 'Size' 가 포함된 것
-- 전체 중 'size'가 포함된 리뷰 수, 비중 구하기
SELECT COUNT(*) total_cnt,
		SUM(CASE WHEN `Review Text` LIKE '%size%' THEN 1 ELSE 0 END) size_cnt,
        SUM(CASE WHEN `Review Text` LIKE '%size%' THEN 1 ELSE 0 END) / COUNT(*) size_rate
FROM dataset2; -- 약 30%의 리뷰에 SIZE 포함됨

-- 상세 사이즈 키워드별 COUNT
SELECT 
	SUM(CASE WHEN `Review Text` LIKE '%size%' THEN 1 ELSE 0 END) N_SIZE,
	SUM(CASE WHEN `Review Text` LIKE '%large%' THEN 1 ELSE 0 END) N_LARGE,
	SUM(CASE WHEN `Review Text` LIKE '%loose%' THEN 1 ELSE 0 END) N_LOOSE,
	SUM(CASE WHEN `Review Text` LIKE '%small%' THEN 1 ELSE 0 END) N_SMALL,
	SUM(CASE WHEN `Review Text` LIKE '%tight%' THEN 1 ELSE 0 END) N_TIGHT,
	SUM(1) N_TOTAL -- 총 리뷰(ROW)수! COUNT(*)와 같음
FROM dataset2;

-- + Department별
SELECT `Department Name`,
	SUM(CASE WHEN `Review Text` LIKE '%size%' THEN 1 ELSE 0 END) N_SIZE,
	SUM(CASE WHEN `Review Text` LIKE '%large%' THEN 1 ELSE 0 END) N_LARGE,
	SUM(CASE WHEN `Review Text` LIKE '%loose%' THEN 1 ELSE 0 END) N_LOOSE,
	SUM(CASE WHEN `Review Text` LIKE '%small%' THEN 1 ELSE 0 END) N_SMALL,
	SUM(CASE WHEN `Review Text` LIKE '%tight%' THEN 1 ELSE 0 END) N_TIGHT,
	SUM(1) N_TOTAL 
FROM dataset2
GROUP BY 1; -- Dresses, Bottoms, Tops에서 size 관련 reivew가 많음

-- + 연령대별 추가 그루핑
SELECT floor(age/10)*10 AGEBAND, 
	`Department Name`,
	SUM(CASE WHEN `Review Text` LIKE '%size%' THEN 1 ELSE 0 END) N_SIZE,
	SUM(CASE WHEN `Review Text` LIKE '%large%' THEN 1 ELSE 0 END) N_LARGE,
	SUM(CASE WHEN `Review Text` LIKE '%loose%' THEN 1 ELSE 0 END) N_LOOSE,
	SUM(CASE WHEN `Review Text` LIKE '%small%' THEN 1 ELSE 0 END) N_SMALL,
	SUM(CASE WHEN `Review Text` LIKE '%tight%' THEN 1 ELSE 0 END) N_TIGHT,
	SUM(1) N_TOTAL 
FROM dataset2
GROUP BY 1,2
ORDER BY 1,2;

-- '비중'으로 구해서, 직관적인 파악 가능하게 하기 (SUM(1) = COUNT(*))
SELECT floor(age/10)*10 AGEBAND, 
	`Department Name`,
	SUM(CASE WHEN `Review Text` LIKE '%size%' THEN 1 ELSE 0 END) / SUM(1) N_SIZE,
	SUM(CASE WHEN `Review Text` LIKE '%large%' THEN 1 ELSE 0 END) / SUM(1) N_LARGE,
	SUM(CASE WHEN `Review Text` LIKE '%loose%' THEN 1 ELSE 0 END) / SUM(1) N_LOOSE,
	SUM(CASE WHEN `Review Text` LIKE '%small%' THEN 1 ELSE 0 END) / SUM(1) N_SMALL,
	SUM(CASE WHEN `Review Text` LIKE '%tight%' THEN 1 ELSE 0 END) / SUM(1) N_TIGHT 
FROM dataset2
GROUP BY 1,2
ORDER BY 1,2; 

/*어떤 상품(Clothing ID)이 SIZE와 관련된 리뷰 내용이 많은지 더 세부적으로 살펴보기*/
SELECT `Clothing ID`,
	SUM(CASE WHEN `Review Text` LIKE '%size%' THEN 1 ELSE 0 END) N_SIZE,
	SUM(CASE WHEN `Review Text` LIKE '%size%' THEN 1 ELSE 0 END) / COUNT(*) R_SIZE,
	SUM(CASE WHEN `Review Text` LIKE '%large%' THEN 1 ELSE 0 END) / SUM(1) R_LARGE,
	SUM(CASE WHEN `Review Text` LIKE '%loose%' THEN 1 ELSE 0 END) / SUM(1) R_LOOSE,
	SUM(CASE WHEN `Review Text` LIKE '%small%' THEN 1 ELSE 0 END) / SUM(1) R_SMALL,
	SUM(CASE WHEN `Review Text` LIKE '%tight%' THEN 1 ELSE 0 END) / SUM(1) R_TIGHT 
FROM dataset2
GROUP BY 1
ORDER BY 3 DESC; 


