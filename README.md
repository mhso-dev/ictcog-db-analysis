# Docker 기반 데이터 분석 실습 환경

MySQL과 Python(Jupyter Lab)을 Docker Compose로 구성한 데이터 분석 실습 환경입니다.

## 📋 구성 요소

- **MySQL 8.0**: 데이터베이스 서버
- **Python 3.11**: 데이터 분석 환경
- **Jupyter Lab**: 대화형 노트북 환경
- **한글 폰트**: matplotlib, seaborn, plotly 한글 지원
- **Streamlit**: 데이터 대시보드 개발
- **Google BigQuery**: 클라우드 데이터 웨어하우스 연동 지원

## 📁 디렉토리 구조

```
docker-practice/
├── docker-compose.yml       # Docker Compose 설정 파일
├── python/
│   ├── Dockerfile           # Python 이미지 설정
│   └── requirements.txt     # Python 패키지 목록
├── notebooks/               # Jupyter 노트북 저장 (로컬 동기화)
├── data/                    # 데이터 파일 저장 (로컬 동기화)
├── streamlit_apps/          # Streamlit 앱 저장 (로컬 동기화)
├── reset.ps1                # Windows 파워쉘 초기화 스크립트
├── reset.bat                # Windows 배치 파일
└── reset.sh                 # Linux/Mac 초기화 스크립트
```

## 🚀 시작하기

### 1. 컨테이너 실행

**Windows (파워쉘):**
```powershell
docker-compose up -d --build
```

**Linux/Mac:**
```bash
docker-compose up -d --build
```

### 2. 접속 정보

| 서비스 | URL | 비고 |
|--------|-----|------|
| Jupyter Lab | http://localhost:8888 | 토큰 없이 접속 가능 |
| Streamlit | http://localhost:8501 | 앱 실행 후 접속 |
| MySQL | localhost:3306 | 외부 클라이언트 접속용 |

### 3. MySQL 접속 정보

| 항목 | 값 |
|------|-----|
| Host | `localhost` (외부) / `mysql` (컨테이너 내부) |
| Port | 3306 |
| Database | analysis_db |
| Username | user |
| Password | 1111 |
| Root Password | 1111 |

## 📦 설치된 Python 패키지

- **데이터 분석**: pandas, numpy
- **시각화**: matplotlib, seaborn, plotly
- **데이터베이스**: pymysql, sqlalchemy, cryptography
- **웹 앱**: streamlit
- **클라우드**: google-cloud-bigquery, pandas-gbq
- **개발 환경**: jupyterlab

## 💻 사용 방법

### Jupyter Lab에서 MySQL 연결

```python
import pymysql
from sqlalchemy import create_engine
import pandas as pd

# PyMySQL 직접 연결
connection = pymysql.connect(
    host='mysql',
    port=3306,
    user='user',
    password='1111',
    database='analysis_db'
)

# 쿼리 실행
with connection.cursor() as cursor:
    cursor.execute("SELECT VERSION()")
    version = cursor.fetchone()
    print(f"MySQL 버전: {version[0]}")

connection.close()

# SQLAlchemy + Pandas
engine = create_engine('mysql+pymysql://user:1111@mysql:3306/analysis_db')

# 데이터 읽기
df = pd.read_sql("SELECT * FROM your_table", engine)

# 데이터 쓰기
df.to_sql('new_table', engine, if_exists='replace', index=False)
```

### 한글 폰트 설정

```python
import matplotlib.pyplot as plt

# 한글 폰트 설정
plt.rcParams['font.family'] = 'NanumGothic'
plt.rcParams['axes.unicode_minus'] = False

# 이제 한글이 정상적으로 표시됩니다
plt.figure(figsize=(10, 6))
plt.plot([1, 2, 3, 4], [1, 4, 2, 3])
plt.title('한글 제목 테스트')
plt.xlabel('X축')
plt.ylabel('Y축')
plt.show()
```

### Streamlit 앱 실행

```bash
# Python 컨테이너 내부로 접속
docker exec -it practice_python bash

# Streamlit 앱 실행
streamlit run streamlit_apps/your_app.py
```

그리고 브라우저에서 http://localhost:8501 접속

## 🔧 유용한 명령어

### 컨테이너 관리

```bash
# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f
docker-compose logs -f python
docker-compose logs -f mysql

# 컨테이너 재시작
docker-compose restart

# 컨테이너 중지
docker-compose stop

# 컨테이너 삭제 (볼륨 유지)
docker-compose down

# 컨테이너 및 볼륨 완전 삭제
docker-compose down -v
```

### 컨테이너 내부 접속

```bash
# Python 컨테이너
docker exec -it practice_python bash

# MySQL 컨테이너
docker exec -it practice_mysql bash

# MySQL 직접 접속
docker exec -it practice_mysql mysql -u user -p1111
docker exec -it practice_mysql mysql -u root -p1111
```

## 🔄 완전 초기화

MySQL 데이터를 완전히 초기화하고 새로 시작하려면:

**Windows (파워쉘):**
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\reset.ps1
```

**Linux/Mac:**
```bash
chmod +x reset.sh
bash ./reset.sh
```

**수동 실행:**
```bash
docker-compose down -v
docker volume rm docker-practice_mysql_data
docker-compose up -d --build
```

## 🐛 문제 해결

### MySQL 연결 오류

**문제**: `Access denied for user 'user'@'...'`

**해결**:
```bash
# 볼륨 삭제 후 재시작
docker-compose down -v
docker-compose up -d --build
```

### DBeaver 연결 오류

**문제**: `Public Key Retrieval is not allowed`

**해결**: DBeaver 연결 설정에서 다음 추가
- Driver properties → `allowPublicKeyRetrieval` = `true`
- Driver properties → `useSSL` = `false`

또는 URL에 추가:
```
jdbc:mysql://localhost:3306/analysis_db?allowPublicKeyRetrieval=true&useSSL=false
```

### 한글 깨짐 문제

**해결**: 노트북 상단에서 폰트 설정
```python
import matplotlib.pyplot as plt
plt.rcParams['font.family'] = 'NanumGothic'
plt.rcParams['axes.unicode_minus'] = False
```

### Jupyter Lab 접속 안 됨

**해결**:
1. 컨테이너 상태 확인: `docker-compose ps`
2. 로그 확인: `docker-compose logs python`
3. 포트 충돌 확인 후 docker-compose.yml에서 포트 변경

### 패키지 추가 설치

**방법 1**: 컨테이너 내부에서 직접 설치
```bash
docker exec -it practice_python bash
pip install package_name
```

**방법 2**: requirements.txt 수정 후 재빌드
```bash
# requirements.txt에 패키지 추가
docker-compose up -d --build python
```

## 📊 Google BigQuery 사용 (선택사항)

### 1. 서비스 계정 키 준비

1. Google Cloud Console에서 서비스 계정 키(JSON) 생성
2. 프로젝트 루트에 `credentials/` 디렉토리 생성
3. JSON 파일을 `credentials/` 디렉토리에 저장

### 2. docker-compose.yml 수정

```yaml
python:
  volumes:
    - ./credentials:/workspace/credentials
  environment:
    - GOOGLE_APPLICATION_CREDENTIALS=/workspace/credentials/your-key.json
```

### 3. 사용 예제

```python
from google.cloud import bigquery
import pandas_gbq

# BigQuery 클라이언트 생성
client = bigquery.Client()

# 쿼리 실행
query = """
SELECT name, SUM(number) as total
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year = 2000
GROUP BY name
ORDER BY total DESC
LIMIT 10
"""

df = client.query(query).to_dataframe()
print(df)
```