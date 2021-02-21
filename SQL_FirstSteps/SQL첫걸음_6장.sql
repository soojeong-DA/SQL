/* 테이블 생성, 변경, 삭제 */
# 테이블 생성
CREATE TABLE sample62 (
	no INTEGER NOT NULL,
    a VARCHAR(30),
    b DATE
);
DESC sample62;

# 테이블 삭제
 # DROP TABLE 테이블명
 # TRUNCATE TABLE 테이블명
 # DELETE TABLE 테이블명 [WHERE 조건]
 
# 테이블 변경
 # 열추가: ALTER TABLE 테이블명 ADD 열정의 
ALTER TABLE sample62 ADD newcol INTEGER;
DESC sample62;
 # 열 속성 변경: ALTER TABLE 테이블명 MODIFY 열정의
ALTER TABLE sample62 MODIFY newcol VARCHAR(20);
DESC sample62;

 # 열 이름 변경: ALTER TABLE 테이블명 CHANGE [기존열이름][신규 열 정의]
ALTER TABLE sample62 CHANGE newcol c VARCHAR(20);
DESC sample62;

 # 열 삭제: ALTER TABLE 테이블명 DROP 열명
ALTER TABLE sample62 DROP c;
DESC sample62;


/*테이블 제약 설정 - CREATE*/
# 열 제약: NOT NULL, UNIQUE 제약 등
CREATE TABLE sample631(
	a INTEGER NOT NULL,
    b INTEGER NOT NULL UNIQUE,
	c VARCHAR(30)
    );
DESC sample631;

# 테이블 제약: PRIMARY KEY 등
CREATE TABLE sample632(
	no INTEGER NOT NULL,
    sub_no INTEGER NOT NULL,
    name VARCHAR(30),
    PRIMARY KEY(no, sub_no)
    );
DESC sample632;

# 테이블 제약에 이름 붙이기: CONSTRAINT
CREATE TABLE sample633(
	no INTEGER NOT NULL,
    sub_no INTEGER NOT NULL,
    name VARCHAR(30),
    CONSTRAINT pkey_samp PRIMARY KEY(no, sub_no)
    );
DESC sample632;

/*테이블 제약 설정, 삭제 - ALTER*/
# 열 제약 추가/변경
ALTER TABLE sample631 MODIFY c VARCHAR(30) NOT NULL;   # c 열에 NOT NULL 제약조건 추가

# 테이블 제약 추가
alter table sample631 ADD CONSTRAINT pkey_sample631 PRIMARY KEY(a);

# 열 제약 삭제 (열 정의 변경)
alter table sample631 MODIFY c VARCHAR(30);

# 테이블 제약 삭제: DROP 하부 명령
alter table sample631 DROP PRIMARY KEY;    # 기본키 제약 삭제
alter table sample631 DROP CONSTRAINT pkey_sample631;  # 기본키 제약을 '제약명'을 사용해서 삭제

/*여러개(복수) 열을 기본키로 지정가능!
- 지정된 모든 기본키 열의 조합?에 대해 중복값이 있으면 안됨*/


/*인덱스 작성, 삭제*/
# 작성: CREATE INDEX 인덱스명 ON 테이블명(열명1, 열명2,...)
CREATE INDEX isample65 ON sample62(no);

# 삭제: DROP INDEX 인덱스명 [ON 테이블명]
DROP INDEX isample65 ON sample62;

# EXPLAIN: 뒤에 SQL명령을 지정해서 실행하면, 어떤 상태로 실행되는지 데이터베이스가 설명해줌 (실제 실행되지는 않음)
EXPLAIN SELECT * FROM sample62 WHERE no>10;


/*뷰 작성, 삭제
- 뷰(view): from절에 기술된 서브쿼리에 이름 붙이고, 데이터베이스 객체화하여 쓰기 쉽게 한 것*/
# 작성: CREATE VIEW 뷰명 AS SELECT명령
CREATE VIEW sample_view_67 AS SELECT * FROM sample54;
select * from sample_view_67;

# 열 지정해서 뷰 작성 (열명1, 열명2,...)
CREATE VIEW sample_view_672(n, v, v2) AS SELECT no, a, a*2 FROM sample54;
select * from sample_view_672;

# 뷰 삭제: DROP VIEW 뷰명
DROP VIEW sample_view_67;

