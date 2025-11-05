---
id: STLIT-001
title: Streamlit 대시보드 개발
domain: Education
type: Feature
status: Draft
priority: High
created: 2025-11-05
author: spec-builder
tags:
  - Streamlit
  - Dashboard
  - MySQL
  - Visualization
  - Interactive
---

# Streamlit 대시보드 개발

**@SPEC:STLIT-001**

## SUMMARY

This specification defines an interactive Streamlit dashboard for real-time MySQL data visualization and analysis. The dashboard targets data analysis beginners and demonstrates modern web-based analytics interfaces. Core features include MySQL connection management, interactive UI components (sidebar, tabs, columns), dynamic filtering based on user input, real-time visualizations using Plotly/Altair, and optional BigQuery integration for cloud data sources. The deliverable is a production-ready Streamlit app that transforms database queries into actionable insights through an intuitive web interface.

## 환경 (ENVIRONMENT)

**WHEN** 데이터 분석 입문자가 웹 기반 인터랙티브 대시보드를 개발할 때

**기술 환경:**
- Python 3.11+
- Streamlit >= 1.20
- MySQL 8.0 (classicmodels 데이터베이스)
- 주요 라이브러리:
  - streamlit
  - pandas
  - mysql-connector-python
  - plotly 또는 altair
  - (선택) google-cloud-bigquery

**배포 환경 (선택적):**
- Streamlit Community Cloud
- Docker 컨테이너
- 로컬 개발 서버

**학습 대상:**
- Python 기본 문법을 아는 입문자
- Pandas 데이터 처리 경험이 있는 학습자
- 웹 기반 대시보드 개발을 배우고자 하는 사용자

## 가정 (ASSUMPTIONS)

**환경 가정:**
- Python 가상 환경이 설정되어 있음
- MySQL 서버가 로컬 또는 원격에서 접근 가능
- classicmodels 데이터베이스가 로드됨
- 웹 브라우저에서 대시보드 접근 가능

**학습자 가정:**
- Python 기본 문법 (함수, 조건문, 반복문) 이해
- Pandas DataFrame 사용 경험
- SQL 기본 쿼리 작성 가능
- 한글 UI와 설명을 선호

**데이터 가정:**
- classicmodels의 8개 테이블에 충분한 샘플 데이터 존재
- 데이터 품질이 분석에 적합
- 실시간 업데이트는 필요하지 않음 (배치 쿼리 방식)

## 요구사항 (REQUIREMENTS)

### FR-STLIT-001: MySQL 연결 및 데이터 로드
**WHEN** 사용자가 대시보드를 실행할 때
**THE SYSTEM SHALL** MySQL 데이터베이스에 연결하여 데이터를 로드:
- `st.connection()` 또는 `mysql.connector`를 사용한 연결 관리
- 연결 설정을 `secrets.toml` 파일로 관리 (보안)
- 데이터 캐싱을 통한 성능 최적화 (`@st.cache_data`)
- 최소 3개 테이블 (customers, orders, orderdetails) 로드

### FR-STLIT-002: 인터랙티브 UI 구성
**WHEN** 사용자가 대시보드 UI를 조작할 때
**THE SYSTEM SHALL** 다양한 Streamlit 위젯을 제공:
- **사이드바 (Sidebar)**: 필터 옵션, 설정 메뉴
- **탭 (Tabs)**: 개요, 상세 분석, 시각화 등 섹션 구분
- **컬럼 (Columns)**: 지표 카드 나란히 배치
- **입력 위젯**: selectbox, multiselect, slider, date_input
- 한글 레이블 및 설명 제공

### FR-STLIT-003: 동적 필터링
**WHEN** 사용자가 필터를 변경할 때
**THE SYSTEM SHALL** 데이터를 동적으로 필터링:
- 국가별, 제품 라인별, 날짜 범위별 필터
- 필터 변경 시 자동으로 차트 및 테이블 업데이트
- 다중 필터 조합 가능 (AND 조건)
- 필터 적용 전후 데이터 개수 표시

### FR-STLIT-004: 실시간 시각화
**WHEN** 데이터가 로드 또는 필터링되었을 때
**THE SYSTEM SHALL** 시각화를 제공:
- **Plotly 차트**: 인터랙티브 막대 그래프, 선 그래프, 파이 차트
- **Altair 차트**: 선언형 시각화 (선택적)
- **지표 카드**: `st.metric()` 사용 (총 매출, 주문 건수 등)
- **데이터 테이블**: `st.dataframe()` 또는 `st.data_editor()` 사용
- 한글 제목/레이블 설정

### FR-STLIT-005: BigQuery 연동 (선택적)
**WHEN** 사용자가 클라우드 데이터 소스를 연결하고자 할 때
**THE SYSTEM SHALL** BigQuery 연동 예제를 제공:
- `google.cloud.bigquery` 라이브러리 사용
- 서비스 계정 인증 방법
- BigQuery 쿼리 → DataFrame 변환
- MySQL과 동일한 UI/UX 제공

## 명세 (SPECIFICATIONS)

### SPEC-STLIT-001-01: 애플리케이션 구조
```python
# streamlit_app.py

import streamlit as st
import pandas as pd
import mysql.connector
import plotly.express as px

# 페이지 설정
st.set_page_config(
    page_title="데이터 분석 대시보드",
    page_icon="📊",
    layout="wide"
)

# 사이드바
st.sidebar.header("필터 옵션")
# ...

# 메인 영역
st.title("📊 데이터 분석 대시보드")
tab1, tab2, tab3 = st.tabs(["개요", "상세 분석", "시각화"])

with tab1:
    # 개요 섹션
    pass

with tab2:
    # 상세 분석 섹션
    pass

with tab3:
    # 시각화 섹션
    pass
```

### SPEC-STLIT-001-02: MySQL 연결 관리
```python
# .streamlit/secrets.toml
[mysql]
host = "localhost"
port = 3306
user = "root"
password = "your_password"
database = "classicmodels"

# streamlit_app.py
@st.cache_resource
def get_connection():
    return mysql.connector.connect(
        host=st.secrets["mysql"]["host"],
        user=st.secrets["mysql"]["user"],
        password=st.secrets["mysql"]["password"],
        database=st.secrets["mysql"]["database"]
    )

@st.cache_data(ttl=600)  # 10분 캐싱
def load_data(query):
    conn = get_connection()
    df = pd.read_sql(query, conn)
    return df
```

### SPEC-STLIT-001-03: 사이드바 필터 예제
```python
st.sidebar.header("🔍 필터 옵션")

# 국가 필터
countries = df_customers['country'].unique()
selected_countries = st.sidebar.multiselect(
    "국가 선택",
    options=countries,
    default=countries[:5]
)

# 날짜 범위 필터
date_range = st.sidebar.date_input(
    "주문 날짜 범위",
    value=(pd.to_datetime("2003-01-01"), pd.to_datetime("2005-12-31"))
)

# 매출 범위 필터
min_amount, max_amount = st.sidebar.slider(
    "매출 범위",
    min_value=0,
    max_value=100000,
    value=(0, 50000)
)
```

### SPEC-STLIT-001-04: 지표 카드 예제
```python
col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric(
        label="총 고객 수",
        value=f"{len(filtered_customers):,}명",
        delta="+15%"
    )

with col2:
    st.metric(
        label="총 주문 건수",
        value=f"{len(filtered_orders):,}건",
        delta="-5%"
    )

with col3:
    st.metric(
        label="총 매출",
        value=f"${total_sales:,.0f}",
        delta="+20%"
    )

with col4:
    st.metric(
        label="평균 주문 금액",
        value=f"${avg_order:,.0f}",
        delta="+8%"
    )
```

### SPEC-STLIT-001-05: Plotly 시각화 예제
```python
# 국가별 매출 막대 그래프
fig = px.bar(
    country_sales,
    x='country',
    y='total_sales',
    title='국가별 총 매출',
    labels={'country': '국가', 'total_sales': '총 매출 ($)'},
    color='total_sales',
    color_continuous_scale='Blues'
)

st.plotly_chart(fig, use_container_width=True)
```

### SPEC-STLIT-001-06: BigQuery 연동 예제 (선택적)
```python
from google.cloud import bigquery

@st.cache_data(ttl=600)
def load_bigquery_data(query):
    client = bigquery.Client()
    df = client.query(query).to_dataframe()
    return df

# 사용 예제
query = """
SELECT country, COUNT(*) as customer_count
FROM `project.dataset.customers`
GROUP BY country
"""
df_bq = load_bigquery_data(query)
```

## 제약사항 (CONSTRAINTS)

### 기술 제약사항
- Python 3.11+ 문법 사용
- Streamlit 1.20+ 버전 호환
- MySQL 연결은 로컬호스트 기본 설정
- 대용량 데이터는 페이징 처리 필요 (10,000행 이상)

### 성능 제약사항
- 데이터 로드 시 캐싱 적용 (`@st.cache_data`)
- 필터 변경 시 전체 데이터 재로드 방지
- 시각화는 1초 이내 렌더링 권장

### 보안 제약사항
- MySQL 연결 정보는 `secrets.toml`에 저장
- `.gitignore`에 `secrets.toml` 포함
- 배포 시 환경 변수 또는 Streamlit Cloud Secrets 사용

### UI/UX 제약사항
- 모바일 반응형 디자인 (선택적)
- 한글 UI 레이블 일관성 유지
- 로딩 상태 표시 (`st.spinner()`)

## 추적성 (TRACEABILITY)

- **@SPEC:STLIT-001** → 이 명세서
- **@TEST:STLIT-001** → 테스트 케이스 (앱 실행 검증)
- **@CODE:STLIT-001** → `streamlit_apps/dashboard.py` (대시보드 앱)
- **@DOC:STLIT-001** → 사용 가이드 및 배포 문서

## 변경 이력 (HISTORY)

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| 1.0 | 2025-11-05 | spec-builder | 초안 작성 |
