SELECT *
FROM dataset4
LIMIT 10;

/*요인별 생존 여부 관계*/
-- 1-1. 성별에 따른 승객 수와 생존자 수 + 생존자 비율
SELECT Sex,
	COUNT(PassengerID) AS N_PASSENGERS,
    SUM(Survived) AS N_SERVIVED,
    SUM(Survived) / COUNT(PassengerID) as Servived_Rate
FROM dataset4
GROUP BY 1;  -- 남성의 탑승객 수가 가장 많았지만, 생존율은 여성보다 현저히 낮았음(차이 55%p)

-- 1-2. 연령대에 따른 생존율
SELECT FLOOR(AGE/10)*10 AS AGEBAND,
		COUNT(PassengerId),
        SUM(Survived),
		SUM(Survived) / COUNT(PassengerId) AS Survived_Rate
FROM dataset4
GROUP BY 1
ORDER BY 1; -- 20대 탑승객 수가 가장 많았으며, 60대의 생존률이 가장 낮았음. 0~9세 아동의 생존률이 가장 높았음 

-- 2-1. 연령별x성별에따른 탭승객 수, 생존자 수, 생존률
SELECT FLOOR(AGE/10)*10 AS AGEBAND,
		Sex,
		COUNT(PassengerId) N_PASSENGERS,
        SUM(Survived) N_SURVIVED,
		ROUND(SUM(Survived) / COUNT(PassengerId),2) AS Survived_Rate
FROM dataset4
GROUP BY 1,2
ORDER BY 1,2;

-- 2-2. 동일 연연대별 성별에 따른 생존율 차이 비교 (남,여 서브쿼리 join 및 차이 계산)
SELECT B.AGEBAND,
		B.Survived_Rate AS MALE_SR,
        A.Survived_Rate AS FEMALE_SR,
        (A.Survived_Rate - B.Survived_Rate) AS SR_DIFF
FROM (SELECT FLOOR(AGE/10)*10 AS AGEBAND,
			Sex,
			ROUND(SUM(Survived) / COUNT(PassengerId),2) AS Survived_Rate
		FROM dataset4
		GROUP BY 1,2
        HAVING Sex = 'female') A
RIGHT JOIN
	(SELECT FLOOR(AGE/10)*10 AS AGEBAND,
			Sex,
			ROUND(SUM(Survived) / COUNT(PassengerId),2) AS Survived_Rate
		FROM dataset4
		GROUP BY 1,2
		HAVING Sex = 'male') B
ON A.AGEBAND = B.AGEBAND
ORDER BY 1;

-- 3. 객실 등급(Pclass)
SELECT DISTINCT Pclass
FROM dataset4;
-- 3-1. 객실 등급별 승객수, 생존자수, 생존율
SELECT Pclass,
		COUNT(PassengerId),
        SUM(Survived),
        SUM(Survived) / COUNT(PassengerId) AS SERVIVED_RATE
FROM dataset4
GROUP BY 1
ORDER BY 1;

-- 3-2. 객실 등급, 성별에 따른 생존율
SELECT Pclass,
        Sex,
		COUNT(PassengerId),
        SUM(Survived),
        SUM(Survived) / COUNT(PassengerId) AS SERVIVED_RATE
FROM dataset4
GROUP BY 1,2
ORDER BY 1,2;

-- 3-3. 객실 등급, 연령, 성별에 따른 생존율
SELECT Pclass,
        Sex,
        FLOOR(AGE/10)*10 AS AGEBAND,
		COUNT(PassengerId),
        SUM(Survived),
        SUM(Survived) / COUNT(PassengerId) AS SERVIVED_RATE
FROM dataset4
GROUP BY 1,2,3
ORDER BY 1,2;

/*EMBARKED(승선 항구)*/
-- 1. 승선 항구별 승객 수
SELECT Embarked,
		COUNT(PassengerId)
FROM dataset4
GROUP BY 1; -- S항구에서 가장 많이 탑승, Q항구가 가장 적음

-- 2. 항구별, 성별별 승객 수
SELECT Embarked,
		Sex,
		COUNT(PassengerId)
FROM dataset4
GROUP BY 1,2
ORDER BY 1;

-- 2. 항구별, 성별별 승객 비중
SELECT Embarked,
		 SUM(CASE WHEN Sex = 'male' THEN 1 ELSE 0 END) / COUNT(PassengerId) AS Male_Rate,
		 SUM(CASE WHEN Sex = 'female' THEN 1 ELSE 0 END) / COUNT(PassengerId) AS Female_Rate
FROM dataset4
GROUP BY 1
ORDER BY 1;

/*탑승객 분석=============================================================*/
-- 1. 출발지, 도착지별 승객 수
SELECT Boarded,
		Destination,
        COUNT(PassengerId)
FROM dataset4
GROUP BY 1,2
ORDER BY 3 DESC;

-- 2. 출발지, 도착지별 승객 수의 상위 5개 경로를 선택한 승객들의 이름 추출!!!!
-- 2-1. 출발지, 도착지별 승객 수 정렬 기준으로 순위 매긴 후, 상위 5개 경로 LIST Table 생성
CREATE TEMPORARY TABLE ROUTE AS
SELECT Boarded,
		Destination
FROM (SELECT Boarded,
			Destination,
			COUNT(PassengerId),
			ROW_NUMBER() OVER(ORDER BY COUNT(PassengerId) DESC) AS RNK
	FROM dataset4
	GROUP BY 1,2) BASE
WHERE RNK BETWEEN 1 AND 5;

-- 2-2. LIST TABLE과 기존 TABLE JOIN(INNER JOIN=일치하는 것만)
SELECT A.NAME,  -- OR A.NAME_WIKI
		A.Boarded,
        A.Destination
FROM dataset4 A INNER JOIN ROUTE B
				ON A.Boarded = B.Boarded 
                AND A.Destination = B.Destination
;

-- 3-1. Hometown별 탑승객 수 및 생존률
SELECT Hometown,
		COUNT(PassengerId),
        SUM(Survived) / COUNT(PassengerId) AS SURVIVED_RATE
FROM dataset4
GROUP BY 1
ORDER BY 3 DESC;

-- 3-2. Hometown별 탑승객 수 및 생존률 (탑승객수 10명이상 & 생존율이 0.5이상인 HOMETOWN 출력)  --HAVING조건절 이용!!
SELECT Hometown,
		COUNT(PassengerId),
        SUM(Survived) / COUNT(PassengerId) AS SURVIVED_RATE
FROM dataset4
GROUP BY 1
HAVING COUNT(PassengerId) >= 10
AND SURVIVED_RATE >= 0.5
ORDER BY 3 DESC;






