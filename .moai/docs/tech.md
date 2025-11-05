# 기술 스택 및 개발 가이드

## 기술 스택 개요

**database-data-analysis** 프로젝트는 교육 목적으로 최적화된 기술 스택을 사용합니다. 프로덕션 환경의 복잡성을 제거하고 학습 효율성을 극대화하는 것을 목표로 합니다.

### 전체 스택 요약

```
┌─────────────────────────────────────────────────────┐
│               Infrastructure Layer                   │
│  - Docker 24.0+                                      │
│  - Docker Compose 2.20+                              │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│               Database Layer                         │
│  - MySQL 8.0 (Community Edition)                     │
│  - classicmodels 샘플 데이터베이스                   │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│            Application Layer (Python 3.11)           │
│  - Jupyter Lab 4.x (노트북 환경)                     │
│  - Streamlit 1.x (대시보드 프레임워크)                │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│               Data Analysis Stack                    │
│  - pandas 2.x (데이터 조작)                          │
│  - numpy 1.x (수치 연산)                             │
│  - matplotlib 3.x (정적 시각화)                      │
│  - seaborn 0.x (통계 시각화)                         │
│  - plotly 5.x (인터랙티브 시각화)                    │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│            Database Connectivity Stack               │
│  - pymysql 1.x (MySQL 드라이버)                      │
│  - SQLAlchemy 2.x (ORM/쿼리 빌더)                    │
│  - cryptography 41.x (보안 연결)                     │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│          Cloud Integration (Optional)                │
│  - google-cloud-bigquery 3.x                         │
│  - pandas-gbq 0.x                                    │
└─────────────────────────────────────────────────────┘
```

## 상세 기술 스택

### 1. 인프라 스택

#### Docker 24.0+
**선택 이유**:
- 플랫폼 독립적 환경 제공 (Windows, Mac, Linux 동일)
- 이미지 기반 재현성 보장 (모든 학생이 동일한 환경)
- 컨테이너 격리로 호스트 시스템 오염 방지

**버전 요구사항**:
- Docker Desktop 24.0 이상 (Windows 10+, macOS 10.15+)
- Docker Engine 24.0 이상 (Linux)

**설정 파일**: `docker-compose.yml`
```yaml
version: '3.8'  # Compose 파일 포맷 버전 (안정화된 3.8 사용)
```

#### Docker Compose 2.20+
**선택 이유**:
- 단일 명령으로 멀티 컨테이너 애플리케이션 관리
- 서비스 의존성 자동 처리 (MySQL → Python 순서)
- 네트워크 자동 생성 및 DNS 설정

**주요 기능 사용**:
- `depends_on`: Python 컨테이너가 MySQL 컨테이너 후 시작
- `volumes`: 로컬 파일 시스템과 컨테이너 동기화
- `environment`: 환경 변수를 통한 설정 주입

### 2. 데이터베이스 스택

#### MySQL 8.0 (Community Edition)
**선택 이유**:
- 업계 표준 오픈소스 RDBMS (프로덕션 환경과 동일)
- Window Functions, CTEs 등 최신 SQL 기능 지원
- 안정성과 성능이 검증된 8.0 LTS 버전

**버전 세부사항**:
- **이미지**: `mysql:8.0` (Docker Hub 공식 이미지)
- **인증 플러그인**: `mysql_native_password` (DBeaver 호환성)
- **문자셋**: utf8mb4 (한글 및 이모지 지원)

**주요 설정**:
```dockerfile
command: --default-authentication-plugin=mysql_native_password --max_allowed_packet=64M
```
- `mysql_native_password`: 레거시 클라이언트 호환성 (교육 환경 편의성)
- `max_allowed_packet=64M`: 대용량 쿼리 결과 및 BLOB 데이터 지원

**설치된 데이터베이스**:
- `analysis_db`: 기본 작업 데이터베이스 (학생 자유 사용)
- `classicmodels`: 샘플 데이터베이스 (8개 테이블, 관계형 모델 학습용)

**보안 설정 (교육 환경)**:
- Root 비밀번호: `1111` (간단한 설정, 외부 노출 없음)
- User 계정: `user` / 비밀번호 `1111` (학생 공통 계정)
- ⚠️ **주의**: 프로덕션 환경에서는 강력한 비밀번호 및 권한 분리 필수

### 3. 애플리케이션 스택

#### Python 3.11
**선택 이유**:
- 최신 안정화 버전 (2023년 LTS, 2028년까지 지원)
- 성능 개선 (3.10 대비 10-60% 빠름)
- 향상된 에러 메시지 (초보자 학습에 유리)

**이미지**: `python:3.11-slim` (Docker Hub 공식 이미지)
- `slim` 변형: 불필요한 패키지 제거로 이미지 크기 축소 (~150MB)

**작업 디렉토리**: `/workspace`
```dockerfile
WORKDIR /workspace
```

#### Jupyter Lab 4.x
**선택 이유**:
- 최신 세대 노트북 IDE (Jupyter Notebook 대체)
- 파일 브라우저, 터미널, 확장 기능 통합
- 실시간 협업 기능 (JupyterHub 연동 시)

**버전**: 최신 안정화 버전 (requirements.txt에서 자동 설치)

**설정**:
```python
# Dockerfile CMD
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root \
  --NotebookApp.token='' --NotebookApp.password=''
```
- `--ip=0.0.0.0`: 모든 네트워크 인터페이스에서 접속 허용
- `--allow-root`: 컨테이너 내 root 사용자 실행 허용
- `--NotebookApp.token=''`: 토큰 인증 비활성화 (교육 환경 편의성)

**접속 URL**: `http://localhost:8888`

#### Streamlit 1.x
**선택 이유**:
- 순수 Python으로 웹 대시보드 개발 (HTML/CSS/JS 불필요)
- 학습 곡선이 낮음 (pandas DataFrame → 차트 자동 생성)
- 실시간 데이터 업데이트 및 인터랙티브 위젯 지원

**버전**: 최신 안정화 버전 (requirements.txt에서 자동 설치)

**실행 방법**:
```bash
# Python 컨테이너 내부에서
streamlit run streamlit_apps/your_app.py
```

**접속 URL**: `http://localhost:8501`

**주요 기능**:
- `st.dataframe()`: pandas DataFrame 자동 렌더링
- `st.line_chart()`, `st.bar_chart()`: 간단한 차트 생성
- `st.selectbox()`, `st.slider()`: 사용자 입력 위젯

### 4. 데이터 분석 스택

#### pandas 2.x
**역할**: 데이터 조작 및 분석의 핵심 라이브러리

**선택 이유**:
- 업계 표준 데이터 분석 도구 (Python Data Science Stack의 중심)
- DataFrame 자료구조로 SQL 테이블과 자연스럽게 매핑
- SQL 결과를 pandas로 변환: `pd.read_sql()`

**주요 기능**:
- 데이터 필터링, 정렬, 그룹화 (SQL 개념과 유사)
- 결측치 처리, 데이터 타입 변환
- Excel, CSV, JSON 등 다양한 포맷 입출력

**설치 버전**: 최신 안정화 버전 (2.x 시리즈)
- pandas 2.0+: 성능 개선 (PyArrow 백엔드 지원)

#### numpy 1.x
**역할**: 수치 연산 및 배열 처리

**선택 이유**:
- pandas의 기반 라이브러리 (pandas는 numpy 배열을 내부적으로 사용)
- 빠른 수학 연산 (C 언어로 구현된 코어)
- 행렬 연산, 통계 함수 제공

**주요 기능**:
- `np.array()`: 다차원 배열 생성
- `np.mean()`, `np.std()`: 통계 함수
- `np.linspace()`, `np.arange()`: 수열 생성

**설치 버전**: 최신 안정화 버전 (1.x 시리즈)
- numpy 1.24+: Python 3.11 완전 지원

#### matplotlib 3.x
**역할**: 정적 시각화의 표준 라이브러리

**선택 이유**:
- Python 시각화의 사실상 표준 (20년 이상 개발)
- 세밀한 커스터마이징 가능 (논문/리포트용 그래프)
- 한글 폰트 설정으로 한글 차트 생성 가능

**주요 기능**:
- `plt.plot()`: 선 그래프
- `plt.bar()`: 막대 그래프
- `plt.scatter()`: 산점도
- `plt.hist()`: 히스토그램

**한글 폰트 설정**:
```python
import matplotlib.pyplot as plt
plt.rcParams['font.family'] = 'NanumGothic'
plt.rcParams['axes.unicode_minus'] = False
```

**설치 버전**: 최신 안정화 버전 (3.x 시리즈)

#### seaborn 0.x
**역할**: 통계적 데이터 시각화 라이브러리

**선택 이유**:
- matplotlib 기반으로 더 아름다운 기본 스타일
- 통계 차트 (박스플롯, 바이올린플롯, 히트맵) 간편 생성
- pandas DataFrame과 자연스럽게 통합

**주요 기능**:
- `sns.barplot()`: 카테고리별 막대 그래프 + 신뢰구간
- `sns.heatmap()`: 상관관계 행렬 시각화
- `sns.pairplot()`: 변수 간 관계 다중 플롯

**설치 버전**: 최신 안정화 버전 (0.12+)

#### plotly 5.x
**역할**: 인터랙티브 시각화 라이브러리

**선택 이유**:
- 마우스 오버, 줌, 팬 등 인터랙티브 기능 제공
- Streamlit과 완벽 통합 (웹 대시보드에 적합)
- 3D 그래프, 지리 정보 시각화 지원

**주요 기능**:
- `px.bar()`: 인터랙티브 막대 그래프
- `px.line()`: 시계열 차트
- `px.scatter()`: 산점도 + 애니메이션
- `px.choropleth()`: 지도 시각화

**설치 버전**: 최신 안정화 버전 (5.x 시리즈)

### 5. 데이터베이스 연결 스택

#### pymysql 1.x
**역할**: 순수 Python MySQL 드라이버

**선택 이유**:
- 외부 C 라이브러리 의존성 없음 (설치 간편)
- MySQL 8.0 완벽 지원
- DB-API 2.0 표준 준수

**사용 패턴**:
```python
import pymysql

connection = pymysql.connect(
    host='mysql',
    port=3306,
    user='user',
    password='1111',
    database='analysis_db'
)

with connection.cursor() as cursor:
    cursor.execute("SELECT * FROM table")
    result = cursor.fetchall()

connection.close()
```

**설치 버전**: 최신 안정화 버전 (1.1+)

#### SQLAlchemy 2.x
**역할**: SQL 툴킷 및 ORM (Object-Relational Mapping)

**선택 이유**:
- pandas와 완벽 통합 (`pd.read_sql()`, `df.to_sql()`)
- SQL 인젝션 방어 (parameterized queries)
- 데이터베이스 독립적 (MySQL, PostgreSQL, SQLite 동일 코드)

**사용 패턴**:
```python
from sqlalchemy import create_engine
import pandas as pd

engine = create_engine('mysql+pymysql://user:1111@mysql:3306/analysis_db')

# 데이터 읽기
df = pd.read_sql("SELECT * FROM table", engine)

# 데이터 쓰기
df.to_sql('new_table', engine, if_exists='replace', index=False)
```

**설치 버전**: 최신 안정화 버전 (2.0+)
- SQLAlchemy 2.0: 성능 개선, 타입 힌트 지원

#### cryptography 41.x
**역할**: 보안 연결을 위한 암호화 라이브러리

**선택 이유**:
- MySQL SSL/TLS 연결 지원 (프로덕션 환경 필수)
- SQLAlchemy의 의존성 (자동 설치)

**설치 버전**: 최신 안정화 버전 (41.0+)

### 6. 클라우드 통합 스택 (선택사항)

#### google-cloud-bigquery 3.x
**역할**: Google BigQuery API 클라이언트

**선택 이유**:
- 대용량 데이터 분석 학습 (TB급 공개 데이터셋)
- SQL 문법이 MySQL과 유사 (학습 전이 용이)
- 서버리스 데이터 웨어하우스 개념 학습

**사용 사례**:
- 로컬 MySQL 분석 → BigQuery 공개 데이터셋 비교
- 수백만 행 이상 데이터 분석 실습

**설치 버전**: 최신 안정화 버전 (3.x)

#### pandas-gbq 0.x
**역할**: pandas와 BigQuery 통합

**선택 이유**:
- `pd.read_gbq()`: BigQuery 쿼리 결과를 DataFrame으로 직접 로드
- pandas 사용 경험이 있다면 추가 학습 부담 없음

**설치 버전**: 최신 안정화 버전 (0.19+)

### 7. 폰트 스택

#### NanumGothic
**역할**: 한글 폰트 (시각화 한글 깨짐 방지)

**선택 이유**:
- 오픈소스 무료 폰트 (상업적 이용 가능)
- 가독성이 뛰어난 고딕체
- matplotlib, seaborn, plotly 모두 지원

**설치 방법**: Dockerfile에서 시스템 레벨 설치
```dockerfile
RUN apt-get update && apt-get install -y fonts-nanum
RUN fc-cache -fv
RUN rm -rf ~/.cache/matplotlib
```

**적용 방법**:
```python
import matplotlib.pyplot as plt
plt.rcParams['font.family'] = 'NanumGothic'
plt.rcParams['axes.unicode_minus'] = False
```

## 개발 환경 설정

### 로컬 개발 환경 구축

#### 1. Docker Desktop 설치
**Windows**:
1. https://www.docker.com/products/docker-desktop 다운로드
2. WSL 2 활성화 (Windows 11 권장)
3. 설치 후 재부팅

**macOS**:
1. https://www.docker.com/products/docker-desktop 다운로드 (Intel/Apple Silicon 구분)
2. 설치 후 Docker Desktop 실행

**Linux (Ubuntu)**:
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -aG docker $USER
```

#### 2. 프로젝트 클론 및 실행
```bash
git clone <repository-url>
cd database-data-analysis
docker-compose up -d --build
```

#### 3. 접속 확인
- Jupyter Lab: http://localhost:8888
- MySQL: localhost:3306 (DBeaver, MySQL Workbench 등)

### 추가 패키지 설치

#### 방법 1: 컨테이너 내부에서 직접 설치 (일시적)
```bash
docker exec -it practice_python bash
pip install scikit-learn
```
⚠️ 컨테이너 재시작 시 사라짐

#### 방법 2: requirements.txt 수정 (영구적)
```bash
# python/requirements.txt에 패키지 추가
echo "scikit-learn" >> python/requirements.txt

# Python 컨테이너 재빌드
docker-compose up -d --build python
```

## 빌드 및 배포

### 빌드 프로세스

#### Python 이미지 빌드
```dockerfile
# python/Dockerfile
FROM python:3.11-slim

# 시스템 패키지 설치 (한글 폰트)
RUN apt-get update && apt-get install -y fonts-nanum && rm -rf /var/lib/apt/lists/*

# matplotlib 폰트 캐시 초기화
RUN fc-cache -fv && rm -rf ~/.cache/matplotlib

# Python 패키지 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 작업 디렉토리 설정
WORKDIR /workspace

# Jupyter Lab 실행
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=", "--NotebookApp.password="]
```

#### 빌드 명령
```bash
# 전체 재빌드
docker-compose build --no-cache

# 특정 서비스만 빌드
docker-compose build python
```

### 배포 전략

**교육 환경 특성**:
- 중앙 서버 배포 없음 (각 학생이 로컬 실행)
- Git을 통한 코드 배포
- Docker Hub 사용 고려 (사전 빌드 이미지 배포)

**배포 체크리스트**:
1. docker-compose.yml 업데이트
2. README.md 사용 가이드 작성
3. 예제 노트북 (notebooks/) 추가
4. 샘플 데이터 (data/) 준비
5. Git 저장소에 푸시
6. 학생들에게 `git clone` 및 `docker-compose up` 안내

## 품질 보증

### 테스트 전략

**교육 환경 테스트**:
- 환경 초기화 테스트 (`reset.sh` 실행 후 정상 작동 확인)
- 예제 노트북 실행 테스트 (모든 셀 순차 실행 성공)
- 한글 폰트 테스트 (차트에 한글 정상 표시)

**테스트 노트북**: `notebooks/init_notebook.ipynb`
```python
# 테스트 항목
1. ✅ 라이브러리 임포트 성공
2. ✅ 한글 폰트 설정 성공
3. ✅ PyMySQL 연결 성공
4. ✅ SQLAlchemy 연결 성공
5. ✅ 시각화 라이브러리 (matplotlib, seaborn, plotly) 작동
6. ✅ MySQL 데이터 읽기/쓰기 성공
```

### 코드 품질 기준

**교육 코드 가이드라인**:
- 명확한 주석 (학생이 이해할 수 있는 한글 주석)
- 단계별 설명 (복잡한 작업을 세분화)
- 에러 메시지 한글 출력 (디버깅 편의성)

**예시**:
```python
# ✅ 좋은 예
try:
    connection = pymysql.connect(host='mysql', user='user', password='1111')
    print("✅ MySQL 연결 성공!")
except Exception as e:
    print(f"❌ MySQL 연결 실패: {e}")

# ❌ 나쁜 예
connection = pymysql.connect(host='mysql', user='user', password='1111')
```

### 성능 최적화

**교육 환경 최적화 전략**:
- 불필요한 패키지 제거 (`python:3.11-slim` 사용)
- Docker 이미지 레이어 캐싱 활용
- matplotlib 폰트 캐시 사전 생성

**측정 지표**:
- Docker 이미지 크기: < 1GB (Python 컨테이너)
- 컨테이너 시작 시간: < 30초
- Jupyter Lab 응답 속도: < 2초

## 보안 정책

### 교육 환경 보안 설정

**현재 설정 (교육 최적화)**:
- Root 비밀번호: `1111` (간단한 설정)
- Jupyter Lab 토큰: 비활성화 (인증 없음)
- MySQL 포트: 공개 (3306)

**보안 가정**:
- 외부 네트워크 노출 없음 (로컬 환경)
- 학생 PC 방화벽 활성화
- Docker 네트워크 격리 (컨테이너 간 통신만)

### 프로덕션 전환 시 필수 변경

**⚠️ 절대 프로덕션에 사용 금지**

**필수 변경사항**:
1. **강력한 비밀번호 설정**:
   ```yaml
   environment:
     MYSQL_ROOT_PASSWORD: <strong-password>  # 16자 이상
     MYSQL_PASSWORD: <strong-password>
   ```

2. **Jupyter Lab 인증 활성화**:
   ```bash
   jupyter lab --NotebookApp.token='<random-token>'
   ```

3. **포트 노출 제한**:
   ```yaml
   ports:
     - "127.0.0.1:3306:3306"  # 로컬 접속만 허용
   ```

4. **SSL/TLS 활성화**:
   ```yaml
   command: --default-authentication-plugin=mysql_native_password --require_secure_transport=ON
   ```

5. **최소 권한 원칙**:
   ```sql
   GRANT SELECT, INSERT, UPDATE ON analysis_db.* TO 'user'@'%';
   -- DELETE, DROP 권한 제거
   ```

## 운영 가이드

### 컨테이너 관리

```bash
# 시작
docker-compose up -d

# 중지
docker-compose stop

# 재시작
docker-compose restart

# 로그 확인
docker-compose logs -f

# 컨테이너 내부 접속
docker exec -it practice_python bash
docker exec -it practice_mysql bash
```

### 데이터 백업 및 복구

```bash
# MySQL 백업
docker exec practice_mysql mysqldump -u root -p1111 classicmodels > backup.sql

# MySQL 복구
docker exec -i practice_mysql mysql -u root -p1111 classicmodels < backup.sql

# Jupyter 노트북 백업 (Git 권장)
git add notebooks/
git commit -m "Add: 실습 노트북 백업"
git push
```

### 문제 해결

#### 자주 발생하는 문제

**문제 1: MySQL 연결 실패**
```
Error: Access denied for user 'user'@'...'
```
**해결**:
```bash
docker-compose down -v  # 볼륨 삭제
docker-compose up -d --build  # 재시작
```

**문제 2: 한글 깨짐**
```python
# 노트북 상단에 추가
import matplotlib.pyplot as plt
plt.rcParams['font.family'] = 'NanumGothic'
plt.rcParams['axes.unicode_minus'] = False
```

**문제 3: 포트 충돌**
```
Error: Bind for 0.0.0.0:3306 failed: port is already allocated
```
**해결**: docker-compose.yml에서 포트 변경
```yaml
ports:
  - "13306:3306"  # 호스트 포트를 13306으로 변경
```

## 라이브러리 버전 관리

### requirements.txt (고정 버전)
```txt
jupyterlab==4.0.5
pandas==2.1.1
numpy==1.25.2
matplotlib==3.8.0
seaborn==0.12.2
plotly==5.17.0
pymysql==1.1.0
sqlalchemy==2.0.21
cryptography==41.0.4
streamlit==1.27.0
google-cloud-bigquery==3.11.4
pandas-gbq==0.19.2
```

**버전 고정 이유**:
- 학생 간 환경 일관성 보장
- 예제 코드 호환성 유지
- 버전 업그레이드 시 예상치 못한 오류 방지

**업데이트 주기**:
- 학기 중: 버전 고정 (변경 금지)
- 학기 말: 최신 버전으로 업데이트 및 테스트

### 패키지 업데이트 절차

1. 테스트 환경에서 업데이트
   ```bash
   pip install --upgrade pandas
   pip freeze > requirements.txt
   ```

2. 예제 노트북 전체 재실행 (호환성 확인)

3. 문제 없으면 docker-compose 재빌드
   ```bash
   docker-compose build --no-cache python
   ```

4. Git 커밋 및 배포
   ```bash
   git add python/requirements.txt
   git commit -m "Update: pandas 2.1.1 → 2.2.0"
   git push
   ```

## 향후 기술 로드맵

### 단기 (3개월)
- **현재 스택 유지**: 무리한 기능 추가 없음
- **예제 개발**: notebooks/ 디렉토리 충실화
- **문서 개선**: README.md 문제 해결 섹션 확장

### 장기 (12개월 이상)
- **보안 패치**: Docker 이미지 정기 업데이트
- **Python 3.12 전환**: 2024년 말 안정화 시 고려
- **JupyterHub 도입**: 다중 사용자 환경 (선택적)
- **PostgreSQL 추가**: 다중 DBMS 학습 경로 (선택적)

## 참고 자료

### 공식 문서
- Docker: https://docs.docker.com
- MySQL 8.0: https://dev.mysql.com/doc/refman/8.0/en/
- Jupyter Lab: https://jupyterlab.readthedocs.io
- pandas: https://pandas.pydata.org/docs/
- SQLAlchemy: https://docs.sqlalchemy.org/

### 학습 자료
- classicmodels Database: http://www.mysqltutorial.org/mysql-sample-database.aspx
- pandas Cheat Sheet: https://pandas.pydata.org/Pandas_Cheat_Sheet.pdf
- Streamlit Gallery: https://streamlit.io/gallery
