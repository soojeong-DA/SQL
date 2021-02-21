# mysql과 R을 연동해주는 패키지 설치
install.packages('RMySQL')
# 전처리에 필요한 패키지 설치
install.packages('dplyr')

# 필요 라이브러리 불러오기
library(RMySQL)
library(dplyr)

# 접속 정보 입력
conn <- dbConnect(MySQL(),
                 user='root',
                 password='clxk140',
                 dbname='mydata',
                 host='localhost'
                 )
# 테이블 확인
dbListTables(conn)

# 데이터
data <- dbGetQuery(mydb, 'select * from mydata.dataset4')





