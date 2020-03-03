# scrn-viewer v1.0.0
scrn-viewer는 scrn 플랫폼에서 검색하고픈 조건을 CDM 데이터베이스에서 해당 환자를 조회하는 scrn플랫폼의 front-end 프로그램

## 주요 기능
+ scrn 플랫폼 UI
+ scrn 플랫폼 조건을 기반으로 CDM 데이터베이스에서 환자검색
+ 검색된 환자에 대한 일반 통계자료 분석

## 사전설치사항
+ [scrn-finder](https://github.com/jbcp/scrn-finder.git)
+ tomcat

## 설치 및 실행

### 1. repo 복제하기
scrn-viewer를 복제할 폴더에 복사:
```
git clone https://github.com/jbcp/scrn-finder.git
```

### 2. DB 설정
scrn DB정보 설정:
```
./dbsource/server_mssql.ini 파일 열기
```

scrn DB 정보입력
```
ip: '',       // db server ip address
port: '',     // db server port
id: '',       // db server id
password: '', // db server password
dbname: '',   // db schema
```
CDM DB정보 설정:
```
./dbsource/cdm.ini 파일 열기
```

CDM DB 정보 입력
```
ip: '',       // cdm server ip address
port: '',     // cdm server port
id: '',       // cdm server id
password: '', // cdm server password
dbname: '',   // cdm server schema
```

## Contact to developer(s)
MINJI KIM - mjkimg@jbcp.kr
