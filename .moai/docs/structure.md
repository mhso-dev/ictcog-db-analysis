# 프로젝트 아키텍처 및 구조

## 전체 아키텍처 개요

**database-data-analysis**는 Docker Compose 기반 마이크로서비스 아키텍처로 설계되었습니다. MySQL 데이터베이스 서비스와 Python 분석 환경 서비스가 독립적인 컨테이너로 분리되어 있으며, 볼륨 마운트를 통해 로컬 파일 시스템과 동기화됩니다.

### 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────┐
│                        Host Machine                          │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Docker Compose Network                    │  │
│  │                                                         │  │
│  │  ┌──────────────────┐      ┌──────────────────────┐   │  │
│  │  │  MySQL Service   │◄─────┤  Python Service      │   │  │
│  │  │                  │      │                      │   │  │
│  │  │  - MySQL 8.0     │      │  - Jupyter Lab       │   │  │
│  │  │  - classicmodels │      │  - Streamlit         │   │  │
│  │  │  - analysis_db   │      │  - pandas/numpy      │   │  │
│  │  │                  │      │  - visualization libs│   │  │
│  │  │  Port: 3306      │      │  Port: 8888, 8501    │   │  │
│  │  └────────┬─────────┘      └─────────┬────────────┘   │  │
│  │           │                          │                │  │
│  └───────────┼──────────────────────────┼────────────────┘  │
│              │                          │                   │
│  ┌───────────▼──────────────────────────▼────────────────┐  │
│  │              Volume Mounts (로컬 동기화)              │  │
│  │  - mysql_data (영구 저장)                             │  │
│  │  - ./mysql/init.sql → 초기화 스크립트                 │  │
│  │  - ./notebooks ↔ /workspace/notebooks                │  │
│  │  - ./data ↔ /workspace/data                          │  │
│  │  - ./streamlit_apps ↔ /workspace/streamlit_apps      │  │
│  └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 설계 원칙

1. **분리된 관심사 (Separation of Concerns)**: 데이터베이스와 애플리케이션 계층을 독립적인 컨테이너로 분리
2. **교육 우선 (Education-First)**: 프로덕션 보안보다 학습 편의성 우선 (간단한 비밀번호, 공개 포트)
3. **Zero Configuration**: 학생이 환경 변수나 설정 파일을 수정하지 않고도 즉시 사용 가능
4. **플랫폼 독립성**: Docker를 통해 Windows/Mac/Linux에서 동일한 환경 제공

## 디렉토리 구조

```
database-data-analysis/
├── .moai/                          # MoAI-ADK 프로젝트 관리
│   ├── config.json                 # 프로젝트 설정
│   ├── docs/                       # 프로젝트 문서
│   │   ├── product.md              # 비즈니스 요구사항
│   │   ├── structure.md            # 아키텍처 문서 (본 문서)
│   │   └── tech.md                 # 기술 스택 문서
│   ├── specs/                      # SPEC 문서 (TDD 개발 시)
│   └── reports/                    # 동기화 리포트
│
├── docker-compose.yml              # Docker Compose 설정 (핵심)
│
├── python/                         # Python 컨테이너 설정
│   ├── Dockerfile                  # Python 이미지 빌드 명세
│   ├── requirements.txt            # Python 패키지 목록
│   └── fonts/                      # 한글 폰트 파일
│       └── NanumGothic.ttf         # 나눔고딕 폰트
│
├── mysql/                          # MySQL 초기화 스크립트
│   ├── init.sql                    # 기본 DB 생성 스크립트
│   └── 01_car/                     # classicmodels 샘플 데이터
│       ├── schema_with_data.sql    # 테이블 스키마 + 데이터 삽입
│       └── car.sql                 # 예제 쿼리 모음
│
├── notebooks/                      # Jupyter 노트북 (학생 작업 공간)
│   ├── init_notebook.ipynb         # 환경 테스트 노트북
│   └── .ipynb_checkpoints/         # Jupyter 자동 체크포인트
│
├── data/                           # 데이터 파일 저장소
│   └── 01_car/                     # classicmodels CSV 데이터
│       ├── customers.csv
│       ├── employees.csv
│       ├── offices.csv
│       ├── orderdetails.csv
│       ├── orders.csv
│       ├── payments.csv
│       ├── productlines.csv
│       └── products.csv
│
├── streamlit_apps/                 # Streamlit 대시보드 (학생 프로젝트)
│   └── .ipynb_checkpoints/         # (예제 앱 추가 예정)
│
├── reset.ps1                       # Windows 환경 초기화 스크립트
├── reset.bat                       # Windows 배치 파일
├── reset.sh                        # Linux/Mac 초기화 스크립트
├── README.md                       # 프로젝트 사용 가이드
└── CLAUDE.md                       # Alfred SuperAgent 프로젝트 가이드
```

### 핵심 파일 설명

#### docker-compose.yml
- **역할**: 전체 인프라 정의 (MySQL + Python 서비스)
- **주요 설정**:
  - MySQL: 포트 3306, 인증 플러그인 mysql_native_password, max_allowed_packet 64MB
  - Python: Jupyter Lab (8888), Streamlit (8501), 환경 변수로 MySQL 접속 정보 주입
  - 볼륨: mysql_data (영구 저장), 로컬 디렉토리 마운트 (notebooks, data, streamlit_apps)

#### python/Dockerfile
- **역할**: Python 3.11 기반 분석 환경 이미지 빌드
- **주요 작업**:
  - requirements.txt 기반 패키지 설치
  - 나눔고딕 폰트 시스템 설치 및 matplotlib 캐시 초기화
  - Jupyter Lab 설정 (토큰 비활성화, allow_root 허용)
  - 작업 디렉토리 /workspace 설정

#### mysql/init.sql
- **역할**: 컨테이너 초기 실행 시 자동으로 실행되는 초기화 스크립트
- **내용**: analysis_db 기본 데이터베이스 생성 (필요 시 추가 스키마 정의 가능)

#### mysql/01_car/schema_with_data.sql
- **역할**: classicmodels 샘플 데이터베이스 스키마 및 데이터 생성
- **내용**:
  - 8개 테이블 (productlines, products, offices, employees, customers, orders, orderdetails, payments)
  - 외래 키 관계로 연결된 정규화된 스키마
  - 수백 행의 샘플 데이터 (제품, 고객, 주문 정보)

## 모듈 관계 및 데이터 흐름

### 서비스 의존성

```
Python Service (분석 환경)
    │
    ├─ depends_on: MySQL Service (DB 컨테이너가 먼저 시작)
    │
    └─ 환경 변수를 통한 MySQL 접속 정보 주입
       - MYSQL_HOST=mysql
       - MYSQL_USER=user
       - MYSQL_PASSWORD=1111
       - MYSQL_DATABASE=analysis_db
```

### 데이터 흐름

```
1. 데이터 로드 (초기화)
   mysql/init.sql → MySQL Container (analysis_db 생성)
   mysql/01_car/schema_with_data.sql → classicmodels DB 생성

2. 데이터 분석 (학생 실습)
   Jupyter Notebook (Python Container)
      ↓ pymysql/SQLAlchemy
   MySQL Container (SELECT 쿼리)
      ↓ 결과 반환
   pandas DataFrame
      ↓ matplotlib/seaborn/plotly
   시각화 차트 (notebooks/ 디렉토리에 저장)

3. 대시보드 개발 (프로젝트)
   Streamlit App (Python Container)
      ↓ SQLAlchemy
   MySQL Container (실시간 데이터 조회)
      ↓ 결과 반환
   Streamlit 웹 인터페이스 (포트 8501)
      ↓ 브라우저 접속
   사용자 (http://localhost:8501)

4. 데이터 영속성
   MySQL Container (메모리 내 데이터)
      ↓ 볼륨 마운트
   Host: mysql_data (Docker Volume)
      → 컨테이너 재시작 시에도 데이터 유지
```

## 외부 시스템 통합

### MySQL 외부 클라이언트 접속

**접속 방식**:
- **Host**: localhost (호스트 머신에서 접속 시)
- **Port**: 3306 (docker-compose.yml에서 포트 포워딩)
- **Database**: analysis_db 또는 classicmodels
- **User**: user (비밀번호: 1111) 또는 root (비밀번호: 1111)

**지원 클라이언트**:
- DBeaver: JDBC URL에 `allowPublicKeyRetrieval=true&useSSL=false` 추가 필요
- MySQL Workbench: 연결 설정에서 SSL 비활성화
- VS Code (MySQL Extension): 표준 접속 정보로 연결
- PyCharm Database Tools: 드라이버 설정에서 allowPublicKeyRetrieval 활성화

### Google BigQuery 연동 (선택사항)

**연동 방식**:
1. Google Cloud 서비스 계정 키(JSON) 생성
2. 로컬 credentials/ 디렉토리에 저장
3. docker-compose.yml에 볼륨 마운트 및 환경 변수 추가:
   ```yaml
   python:
     volumes:
       - ./credentials:/workspace/credentials
     environment:
       - GOOGLE_APPLICATION_CREDENTIALS=/workspace/credentials/your-key.json
   ```
4. Jupyter Notebook에서 google-cloud-bigquery 라이브러리 사용

**사용 사례**:
- 로컬 MySQL에서 분석한 후 BigQuery 공개 데이터셋과 비교
- 대용량 데이터 분석 실습 (BigQuery의 TB급 데이터 활용)
- 클라우드 데이터 웨어하우스 개념 학습

## 네트워크 구성

### 컨테이너 간 통신

Docker Compose가 자동으로 생성하는 브리지 네트워크를 사용합니다.

**네트워크 이름**: `database-data-analysis_default` (프로젝트 디렉토리명 기반)

**서비스 DNS**:
- MySQL: `mysql` (컨테이너 이름이 DNS 이름으로 자동 등록)
- Python: `python`

**예시**:
```python
# Python 컨테이너 내부에서 MySQL 접속
connection = pymysql.connect(
    host='mysql',  # 컨테이너 이름으로 접속
    port=3306,
    user='user',
    password='1111'
)
```

### 포트 매핑

| 서비스 | 컨테이너 내부 포트 | 호스트 포트 | 용도 |
|--------|-------------------|------------|------|
| MySQL | 3306 | 3306 | 데이터베이스 접속 |
| Jupyter Lab | 8888 | 8888 | 노트북 웹 인터페이스 |
| Streamlit | 8501 | 8501 | 대시보드 웹 인터페이스 |

**포트 충돌 시 해결**:
docker-compose.yml에서 호스트 포트 변경:
```yaml
ports:
  - "13306:3306"  # MySQL을 13306으로 변경
  - "18888:8888"  # Jupyter Lab을 18888로 변경
```

## 데이터베이스 스키마 (classicmodels)

### ERD (Entity-Relationship Diagram)

```
productlines (제품 카테고리)
    ├─ productLine (PK)
    └─ textDescription

products (제품)
    ├─ productCode (PK)
    ├─ productLine (FK → productlines)
    └─ buyPrice, MSRP

offices (사무소)
    ├─ officeCode (PK)
    └─ city, country

employees (직원)
    ├─ employeeNumber (PK)
    ├─ officeCode (FK → offices)
    ├─ reportsTo (FK → employees)
    └─ jobTitle

customers (고객)
    ├─ customerNumber (PK)
    ├─ salesRepEmployeeNumber (FK → employees)
    └─ customerName, city

orders (주문)
    ├─ orderNumber (PK)
    ├─ customerNumber (FK → customers)
    └─ orderDate, status

orderdetails (주문 상세)
    ├─ orderNumber (FK → orders)
    ├─ productCode (FK → products)
    ├─ quantityOrdered, priceEach
    └─ 복합 PK (orderNumber, productCode)

payments (결제)
    ├─ customerNumber (FK → customers)
    ├─ checkNumber (PK)
    └─ paymentDate, amount
```

### 테이블 관계 요약

- **1:N 관계**:
  - productlines → products (하나의 카테고리에 여러 제품)
  - offices → employees (하나의 사무소에 여러 직원)
  - employees → customers (한 영업사원이 여러 고객 담당)
  - customers → orders (한 고객이 여러 주문)
  - customers → payments (한 고객이 여러 결제)

- **N:M 관계** (orderdetails를 통한 다대다):
  - orders ↔ products (한 주문에 여러 제품, 한 제품이 여러 주문에 포함)

- **자기 참조**:
  - employees.reportsTo → employees (상사-부하 관계)

### 주요 실습 쿼리 패턴

```sql
-- JOIN 연습: 고객별 주문 내역
SELECT c.customerName, o.orderNumber, o.orderDate
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber;

-- 집계 함수: 제품별 총 판매 수량
SELECT p.productName, SUM(od.quantityOrdered) as total_sold
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productName;

-- 서브쿼리: 평균 이상 구매 고객
SELECT customerName
FROM customers
WHERE customerNumber IN (
    SELECT customerNumber
    FROM payments
    GROUP BY customerNumber
    HAVING SUM(amount) > (SELECT AVG(amount) FROM payments)
);
```

## 아키텍처 결정 기록 (ADR)

### ADR-001: Docker Compose 선택
**결정**: 단일 docker-compose.yml로 전체 인프라 관리
**이유**:
- Kubernetes는 교육 환경에 과도한 복잡성
- VM 기반 설치는 OS별 차이로 일관성 확보 어려움
- Docker Compose는 학습 곡선이 낮고 재현성 보장

### ADR-002: MySQL 8.0 선택
**결정**: MySQL 5.7이 아닌 8.0 사용
**이유**:
- 8.0이 2023년 기준 최신 LTS 버전
- Window Functions (ROW_NUMBER, RANK) 기본 지원
- 인증 플러그인 개선 (caching_sha2_password → mysql_native_password 설정)

### ADR-003: Jupyter Lab vs Jupyter Notebook
**결정**: Jupyter Lab 선택
**이유**:
- 파일 브라우저, 터미널, 확장 기능 등 통합 IDE 환경
- Notebook보다 최신 기술이며 향후 Notebook 대체 예정
- 학생들이 실무 환경에 가까운 도구 경험

### ADR-004: 보안 설정 간소화
**결정**: root 비밀번호 1111, 공개 포트 3306
**이유**:
- 교육 환경으로 외부 네트워크 노출 없음
- 학생들이 비밀번호를 잊어버려 수업 중단 방지
- 강사가 모든 학생 환경에 동일한 접속 정보로 지원 가능
- **주의**: 프로덕션 환경에서는 절대 사용 금지

### ADR-005: 한글 폰트 사전 설치
**결정**: Dockerfile에서 NanumGothic 시스템 설치
**이유**:
- matplotlib 기본 폰트는 한글 미지원 (깨진 문자 출력)
- 학생들이 개별적으로 폰트 설정하는 것은 고난이도 작업
- 시스템 레벨 설치로 matplotlib, seaborn, plotly 모두 자동 적용

## 비기능적 요구사항 (NFR)

### 성능 요구사항
- **Jupyter Lab 응답 속도**: < 2초 (셀 실행 시작 시간)
- **MySQL 쿼리 응답**: < 100ms (classicmodels 데이터베이스, 단순 SELECT)
- **컨테이너 시작 시간**: < 30초 (초기 빌드 후 재시작)
- **메모리 사용량**: Python 컨테이너 < 1GB, MySQL 컨테이너 < 500MB (정상 작동 시)

### 가용성 요구사항
- **컨테이너 재시작**: docker-compose restart로 10초 내 복구
- **데이터 영속성**: mysql_data 볼륨을 통해 컨테이너 삭제 후에도 데이터 유지
- **초기화 스크립트**: reset.sh/reset.ps1로 완전 초기화 후 재구축 가능

### 확장성 고려사항
- **동시 사용자**: 각 학생이 개별 로컬 환경에서 실행 (서버 공유 없음)
- **데이터 크기**: classicmodels는 <1MB, 추가 데이터셋 로드 시 mysql_data 볼륨 크기 증가
- **BigQuery 확장**: 로컬 환경의 한계를 넘어 클라우드 데이터 분석 가능

### 보안 요구사항
**교육 환경 전제**:
- SQL Injection 방어: sqlalchemy parameterized queries 사용 권장 (교육 내용)
- 컨테이너 격리: Docker 네트워크로 외부 접근 차단 (기본 설정)
- 비밀번호 관리: 환경 변수로 주입 (하드코딩 방지 교육)

**프로덕션 전환 시 필수 변경사항**:
- 강력한 비밀번호 설정 (mysql_root_password, mysql_password)
- SSL/TLS 통신 활성화
- 포트 3306 외부 노출 차단 (방화벽 설정)
- 최소 권한 원칙 적용 (user 계정 권한 축소)

## 운영 및 모니터링

### 로그 관리
```bash
# 전체 서비스 로그 확인
docker-compose logs -f

# 특정 서비스 로그
docker-compose logs -f python
docker-compose logs -f mysql

# 로그 저장 (문제 해결 시)
docker-compose logs > logs.txt
```

### 상태 확인
```bash
# 컨테이너 상태
docker-compose ps

# 리소스 사용량
docker stats
```

### 백업 및 복구
```bash
# MySQL 데이터 백업
docker exec practice_mysql mysqldump -u root -p1111 classicmodels > backup.sql

# 데이터 복구
docker exec -i practice_mysql mysql -u root -p1111 classicmodels < backup.sql
```

## 향후 확장 계획

### 단기 (3개월)
- notebooks/ 디렉토리에 주제별 실습 노트북 추가 (10개 목표)
- streamlit_apps/ 디렉토리에 예제 대시보드 1-2개 추가

### 장기 (12개월 이상)
- 시스템 안정성 유지 (무리한 기능 추가 없음)
- Docker 이미지 정기 업데이트 (보안 패치)
- 학생 피드백 기반 문서 개선
