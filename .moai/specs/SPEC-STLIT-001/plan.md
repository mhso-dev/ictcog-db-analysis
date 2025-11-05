---
id: STLIT-001
title: Streamlit 대시보드 개발 - 구현 계획
type: Implementation Plan
status: Draft
created: 2025-11-05
---

# Streamlit 대시보드 개발 - 구현 계획

**@PLAN:STLIT-001**

## 목표 (OBJECTIVES)

MySQL classicmodels 데이터베이스를 연동한 Streamlit 대시보드를 개발하여 데이터 분석 입문자가 인터랙티브한 웹 기반 분석 인터페이스를 학습하고 실무에 활용할 수 있도록 함

## 구현 마일스톤 (MILESTONES)

### Phase 1: 기본 앱 구조 및 MySQL 연결 (Primary Goal)

**목표:**
- Streamlit 앱 파일 생성 (`streamlit_app.py`)
- 페이지 설정 및 레이아웃 구성
- MySQL 연결 및 데이터 로드 함수 구현
- `secrets.toml` 설정 파일 생성

**산출물:**
- `streamlit_apps/dashboard.py`
- `.streamlit/secrets.toml` (연결 설정)
- 기본 "Hello World" 앱 실행 가능

**의존성:**
- classicmodels 데이터베이스가 MySQL에 로드되어 있어야 함

### Phase 2: 사이드바 및 필터 구현 (Primary Goal)

**목표:**
- 사이드바 UI 구성
- 국가별, 제품 라인별, 날짜 범위 필터 구현
- 필터 적용 후 데이터 동적 업데이트

**산출물:**
- 사이드바 필터 섹션 완성
- 필터링된 DataFrame 생성 로직

**의존성:**
- Phase 1 완료 (데이터 로드 필요)

### Phase 3: 탭 및 지표 카드 구현 (Secondary Goal)

**목표:**
- 3개 탭 구성 (개요, 상세 분석, 시각화)
- 지표 카드 4개 구현 (고객 수, 주문 건수, 총 매출, 평균 주문 금액)
- 컬럼 레이아웃 사용

**산출물:**
- 탭 기반 UI 완성
- `st.metric()` 지표 카드

**의존성:**
- Phase 2 완료 (필터링된 데이터 필요)

### Phase 4: 시각화 구현 (Secondary Goal)

**목표:**
- Plotly 차트 3개 구현 (막대 그래프, 선 그래프, 파이 차트)
- 인터랙티브 기능 (호버, 줌, 드릴다운)
- 한글 제목/레이블 설정

**산출물:**
- 시각화 섹션 완성
- 국가별 매출, 월별 주문 추이, 제품 라인별 비율 차트

**의존성:**
- Phase 3 완료 (집계 데이터 필요)

### Phase 5: BigQuery 연동 및 최종 검증 (Final Goal)

**목표:**
- BigQuery 연동 예제 작성 (선택적)
- 전체 앱 성능 최적화 (캐싱, 페이징)
- 배포 가이드 문서 작성

**산출물:**
- BigQuery 연동 섹션 (선택적)
- 배포 준비 완료 (Streamlit Cloud 또는 Docker)
- 사용 가이드 문서

**의존성:**
- Phase 4 완료 (전체 앱 기능 구현)

## 기술 접근 방식 (TECHNICAL APPROACH)

### 1. MySQL 연결 전략

**옵션 1: mysql.connector (권장)**
```python
@st.cache_resource
def get_connection():
    return mysql.connector.connect(
        host=st.secrets["mysql"]["host"],
        user=st.secrets["mysql"]["user"],
        password=st.secrets["mysql"]["password"],
        database=st.secrets["mysql"]["database"]
    )
```

**옵션 2: st.connection (Streamlit 1.28+)**
```python
conn = st.connection('mysql', type='sql')
df = conn.query('SELECT * FROM customers', ttl=600)
```

**선택 기준:** Streamlit 1.28+ 사용 시 `st.connection()` 권장 (간결성, 내장 캐싱)

### 2. 데이터 캐싱 전략

**전체 데이터 캐싱:**
```python
@st.cache_data(ttl=600)  # 10분 캐싱
def load_customers():
    query = "SELECT * FROM customers"
    return pd.read_sql(query, get_connection())
```

**필터링 캐싱:**
```python
# 필터 파라미터를 함수 인자로 전달
@st.cache_data(ttl=300)
def filter_data(df, countries, date_range):
    filtered = df[df['country'].isin(countries)]
    # ...
    return filtered
```

### 3. UI 레이아웃 설계

**페이지 레이아웃:**
- `layout="wide"`: 와이드 모드 (전체 화면 활용)
- 사이드바: 필터 및 설정
- 메인 영역: 탭 구조 (개요, 상세, 시각화)

**반응형 디자인:**
```python
# 모바일/데스크톱 대응
if st.sidebar.checkbox("모바일 뷰"):
    col1, col2 = st.columns(1)
else:
    col1, col2, col3, col4 = st.columns(4)
```

### 4. 시각화 라이브러리 선택

| 라이브러리 | 장점 | 단점 | 사용 예제 |
|-----------|------|------|-----------|
| **Plotly** | 인터랙티브, Streamlit 통합 우수 | 대용량 데이터 느림 | 막대 그래프, 선 그래프, 파이 차트 |
| **Altair** | 선언형, 간결한 코드 | 인터랙티브 기능 제한적 | 산점도, 히트맵 |
| **st.line_chart** | 내장, 빠름 | 커스터마이징 제한적 | 간단한 시계열 차트 |

**권장:** Plotly (인터랙티브 기능 + Streamlit 통합)

### 5. BigQuery 연동 설계 (선택적)

**서비스 계정 인증:**
```python
from google.cloud import bigquery
from google.oauth2 import service_account

credentials = service_account.Credentials.from_service_account_info(
    st.secrets["gcp_service_account"]
)
client = bigquery.Client(credentials=credentials)
```

**쿼리 실행:**
```python
@st.cache_data(ttl=600)
def load_bigquery_data(query):
    df = client.query(query).to_dataframe()
    return df
```

## 아키텍처 설계 (ARCHITECTURE DESIGN)

### 파일 구조
```
streamlit_apps/
├── dashboard.py (메인 앱)
├── .streamlit/
│   └── secrets.toml (연결 설정)
├── utils/
│   ├── data_loader.py (데이터 로드 함수)
│   └── visualizations.py (시각화 함수)
└── requirements.txt (의존성)
```

### 앱 흐름도
```
1. 페이지 로드
   ↓
2. MySQL 연결 (캐싱)
   ↓
3. 전체 데이터 로드 (캐싱)
   ↓
4. 사이드바 필터 입력
   ↓
5. 데이터 필터링
   ↓
6. 지표 계산 및 표시
   ↓
7. 시각화 렌더링
```

## 위험 요소 및 대응 (RISKS AND MITIGATION)

### 위험 1: MySQL 연결 실패
**대응:**
- `try-except` 블록으로 연결 오류 처리
- 연결 실패 시 사용자에게 명확한 에러 메시지 표시
- 대체 방법으로 샘플 CSV 파일 사용 옵션 제공

### 위험 2: 대용량 데이터로 인한 성능 저하
**대응:**
- 데이터 로드 시 캐싱 적용 (`@st.cache_data`)
- 필터링된 데이터만 시각화
- 10,000행 이상 데이터는 샘플링 또는 페이징

### 위험 3: 한글 폰트 깨짐
**대응:**
- Plotly는 기본적으로 한글 지원
- 필요 시 Plotly 레이아웃에서 폰트 설정
- `fig.update_layout(font_family="NanumGothic")`

### 위험 4: secrets.toml 노출
**대응:**
- `.gitignore`에 `.streamlit/secrets.toml` 추가
- 배포 시 Streamlit Cloud의 Secrets 관리 기능 사용
- 사용 가이드에 보안 주의사항 명시

### 위험 5: BigQuery 인증 실패 (선택적)
**대응:**
- 서비스 계정 JSON을 `secrets.toml`에 안전하게 저장
- 인증 실패 시 명확한 에러 메시지 및 해결 가이드 제공

## 품질 보증 (QUALITY ASSURANCE)

### 검증 항목
- [ ] MySQL 연결이 정상적으로 작동함
- [ ] 모든 필터가 데이터를 올바르게 필터링함
- [ ] 지표 카드가 정확한 값을 표시함
- [ ] 시각화가 정상적으로 렌더링됨
- [ ] 한글 레이블이 깨지지 않음
- [ ] 앱이 5초 이내 로드됨
- [ ] secrets.toml이 `.gitignore`에 포함됨

### 테스트 방법
1. **로컬 테스트:** `streamlit run dashboard.py` 실행
2. **기능 테스트:** 각 필터 및 시각화 수동 확인
3. **성능 테스트:** 페이지 로드 시간 측정 (크롬 개발자 도구)
4. **보안 테스트:** `git status`로 secrets.toml 추적 여부 확인

## 다음 단계 (NEXT STEPS)

1. **Phase 1 시작:** Streamlit 앱 기본 구조 생성
2. **테스트 환경 준비:** classicmodels 데이터베이스 로드 확인
3. **@CODE:STLIT-001 생성:** `streamlit_apps/dashboard.py` 작성
4. **@TEST:STLIT-001 실행:** 앱 실행 및 기능 검증
5. **@DOC:STLIT-001 작성:** 사용 가이드 및 배포 문서
