/*행추가*/
# INSERT INTO 테이블명 VALUES(값1, 값2,..)
# 열 지정x -> 전체 열에 값 추가
select * from sample41;
DESC sample41;   # 테이블 구조/속성 확인
insert into sample41 values(1, 'ABC','2014-01-25');
select * from sample41;
insert into sample41 values(3, null, null);

# 열 지정
insert into sample41 (a, no) values('XYZ',2);
select * from sample41;

# 기본값(Default)
desc sample411;
insert into sample411 (no, d) values (1,1);
select * from sample411;
insert into sample411 (no) values(2);   # 디폴트값이 있는 열을 생략하면, 알아서 기본값으로 채워서 넣어줌. default라고 명시적으로 값 줘도 됨

/*삭제*/
# DELETE FROM 테이블명 [WHERE 조건식]   -> 조건식 지정 안하면, 모든 행 삭제.
SET SQL_SAFE_UPDATES = 0;    # safe mode로 되어있으면, 삭제 안됨. => 변경!

select * from sample41;
delete from sample41 where no = 3;
delete from sample41 where no = 1 or no = 2;
delete from sample41;   # 모든행 삭제

/*갱신/수정*/
# UPDATE 테이블명 SET 열1=값1, 열2=값2,.. [WHERE 조건식]   -> 조건식 지정 안하면, 모든 행 update.
select * from sample41;
update sample41 set b = '2014-09-07' where no = 2;
update sample41 set b = '2014-09-07' where b is null;   

# 모든 행 갱신. 식에 열이 포함되도 됨.
update sample41 set no = no + 1;   # 증가 연산
select * from sample41;
 
# 복수열 갱신
update sample41 set a = 'xxx', b = '2014-01-01' where no = 2;
select * from sample41;

/* 물리삭제 vs 논리삭제
- 물리삭제: delete 명령어로 삭제하는 것
	- ex. 탈퇴 회원의 개인정보 -> 바로 삭제하는 편이 좋음
- 논리삭제: 삭제된 것 처럼 보이게 하는 것
	- 삭제플래그 열을 생성해, 삭제할 행에 1표시 -> 나중에 select 등의 구문 실행할 때, where조건문에 'where 삭제플래그 <> 1' 넣어서 뽑기.
    - ex. 쇼핑몰 고객의 '주문 취소' -> 주문이 취소되었다고 해당 정보가 아예 필요없는 게 아님. 주문 통계 등에 사용될 수도
    - 하지만, 메모리 증가, 혼란 등의 위험 요소 고려해야함.
    

# SET구의 갱신 순서에 따라, 결과가 달라짐  (but, Oracle에서는 순서가 결과에 영향을 미치지 않음)
update sample41 set no = no + 1, a = no;
update sample41 set a = no, no = no + 1;

# NULL값으로도 갱신 가능 (null 초기화)
update sample41 set a = null;

