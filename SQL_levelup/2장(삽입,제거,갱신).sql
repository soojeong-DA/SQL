-- INSERT: 데이터/레코드를 삽입 (필드 리스트와 값 리스트는 같은 순서로 대응하게 입력해야함!!)
-- 데이터를 등록하는 단위는 레코드(행)
/*
INSERT INTO [테이블 이름] ([필드1],[필드2],[필드3],..)
				VALUES ([값1], [값2], [값3], .. 
*/	
-- -- ex. 인성을 address 테이블에 추가
INSERT INTO address (name, phone_nbr, address, sex, age)
			VALUES ('인성','080-3333-xxxx', '서울시','남',30);

-- -- ex. 9개의 레코드를 한번에 추가할 수도 있음
INSERT INTO address (name, phone_nbr, address, sex, age)
			VALUES ('인성','080-3333-xxxx', '서울시','남',30),
			('하진','080-3333-xxxx', '서울시','여',21),
			('준','080-3333-xxxx', '서울시','남',45),
			('민','080-3333-xxxx', '부산시','남',32),
			('하린', NULL, '부산시','여',55),
			('빛나래','080-3333-xxxx', '인천시','여',19),
			('인아', NULL, '인천시','여',20),
			('아린','080-3333-xxxx', '속초시','여',25),
			('기주','080-3333-xxxx', '서귀포시','남',32);
			
-- DELETE: 데이터 제거(삭제) (한번에 여러 개의 레코드 단위로 처리함)
-- 일부/부분적으로 레코드를 제거하고 싶을 때는 WHERE 구로 제거 대상을 선별하면됨!
-- 삭제 대상 = '레코드(행)' 이므로, 필드(컬럼)를 삭제하는 구문은 오류 발생
-- DELETE 구분으로 모든 데이터를 삭제해도, 테이블 틀은 남아있어, 데이터 추가 가능 (테이블 자체 제거: DROP TABLE)
/*
DELETE FROM [테이블 이름];
*/
DELETE FROM address;  -- 테이블의 모든 레코드 제거

DELETE FROM address
WHERE address = '인천시'; -- 일부 레코드만 제거

-- UPDATE: 데이터 갱신(데이터 변경)
-- 일부 레코드만 갱신하고 싶을 때는 WHERE구로 필터링!
/*
UPDATE [테이블 이름]
	SET [필드 이름] = [식];
*/
UPDATE address
	SET phone_nbr = '080-5849-xxxx'
WHERE name = '빛나래';

-- -- 여러 개의 필드 입력해, 한번에 여러 개의 값을 변경하기
UPDATE address
	SET phone_nbr = '080-5848-xxxx',
		age = 20
WHERE name = '빛나래';

