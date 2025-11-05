---
id: PANDAS-001
title: Pandas 데이터 분석 실습 노트북 개발
domain: Education
type: Feature
status: Draft
priority: High
created: 2025-11-05
author: spec-builder
tags:
  - Pandas
  - Python
  - Data Analysis
  - Jupyter
  - Visualization
---

# Pandas 데이터 분석 실습 노트북 개발

**@SPEC:PANDAS-001**

## SUMMARY

This specification defines a comprehensive Jupyter Notebook tutorial for Pandas-based data analysis using MySQL classicmodels database. The notebook targets data analysis beginners and covers the complete workflow: MySQL to DataFrame data loading, exploratory data analysis (head, info, describe), data preprocessing (missing values, type conversion), grouping and aggregation operations, and multi-library visualizations (matplotlib, seaborn, plotly). Each section includes executable code cells, Korean explanations, and immediate visual feedback to facilitate self-paced learning.

## 환경 (ENVIRONMENT)

**WHEN** 데이터 분석 입문자가 Pandas를 사용하여 MySQL 데이터를 분석할 때

**기술 환경:**
- Python 3.11+
- Jupyter Lab
- MySQL 8.0 (classicmodels 데이터베이스)
- 주요 라이브러리:
  - pandas >= 2.0
  - mysql-connector-python
  - matplotlib >= 3.5
  - seaborn >= 0.12
  - plotly >= 5.0

**학습 대상:**
- Python 기초 문법을 아는 입문자
- SQL 기본 개념을 이해하는 학습자
- 데이터 분석 워크플로우를 배우고자 하는 사용자

## 가정 (ASSUMPTIONS)

**환경 가정:**
- Jupyter Lab이 설치되어 있음
- MySQL 서버가 로컬 또는 원격에서 접근 가능
- classicmodels 데이터베이스가 로드됨

**학습자 가정:**
- Python 기본 문법 (변수, 함수, 반복문) 이해
- Jupyter Notebook 사용 경험
- 한글 설명과 코드를 함께 보면서 학습 선호

**데이터 가정:**
- classicmodels의 8개 테이블에 충분한 샘플 데이터 존재
- 데이터 품질이 분석에 적합 (결측치는 학습용으로 의도적으로 존재할 수 있음)

## 요구사항 (REQUIREMENTS)

### FR-PANDAS-001: MySQL 데이터 로드
**WHEN** 학습자가 노트북을 실행할 때
**THE SYSTEM SHALL** MySQL 데이터베이스에 연결하여 DataFrame으로 데이터를 로드:
- `mysql.connector` 또는 `sqlalchemy`를 사용한 연결
- `pd.read_sql()` 함수로 쿼리 결과를 DataFrame으로 변환
- 연결 설정 예제 (host, user, password, database)
- 최소 3개 테이블 (customers, orders, products) 로드 예제 제공

### FR-PANDAS-002: 데이터 탐색
**WHEN** DataFrame이 로드되었을 때
**THE SYSTEM SHALL** 기본적인 데이터 탐색 기능을 시연:
- `df.head()`: 상위 N개 행 확인
- `df.info()`: 데이터 타입 및 결측치 정보
- `df.describe()`: 기술 통계량 (평균, 표준편차, 최소/최대값)
- `df.shape`: 행/열 개수
- `df.columns`: 컬럼 목록
- 각 메서드의 출력 결과에 대한 한글 설명

### FR-PANDAS-003: 데이터 전처리
**WHEN** 데이터 품질 문제를 발견했을 때
**THE SYSTEM SHALL** 전처리 방법을 시연:
- 결측치 처리:
  - `df.isnull().sum()`: 결측치 확인
  - `df.fillna()`: 평균/최빈값으로 채우기
  - `df.dropna()`: 결측치 행 제거
- 데이터 타입 변환:
  - `df['column'].astype()`: 타입 변경
  - `pd.to_datetime()`: 날짜 형식 변환
- 중복 제거:
  - `df.duplicated()`: 중복 확인
  - `df.drop_duplicates()`: 중복 제거

### FR-PANDAS-004: 그룹화 및 집계
**WHEN** 비즈니스 질문에 답하기 위해 데이터를 분석할 때
**THE SYSTEM SHALL** 그룹화 및 집계 기능을 시연:
- `df.groupby()`: 그룹화
- `.agg()`: 다중 집계 함수 적용
- `.pivot_table()`: 피벗 테이블 생성
- 실무 예제:
  - 국가별 고객 수
  - 제품 라인별 평균 가격
  - 월별 주문 건수

### FR-PANDAS-005: 시각화
**WHEN** 분석 결과를 시각적으로 표현할 때
**THE SYSTEM SHALL** 3가지 시각화 라이브러리를 시연:
- **matplotlib**: 기본 차트 (선 그래프, 막대 그래프, 히스토그램)
- **seaborn**: 통계 시각화 (박스플롯, 히트맵, 페어플롯)
- **plotly**: 인터랙티브 차트 (드릴다운, 호버 정보)
- 각 라이브러리의 장단점 설명
- 한글 제목/레이블 설정 예제

## 명세 (SPECIFICATIONS)

### SPEC-PANDAS-001-01: 노트북 구조
```markdown
# Pandas 데이터 분석 실습

## 1. 환경 설정 및 라이브러리 import
- 필요한 라이브러리 설치 안내
- import 문

## 2. MySQL 데이터 로드
- 데이터베이스 연결
- 테이블 → DataFrame 변환
- 연결 종료

## 3. 데이터 탐색 (EDA)
- head, info, describe
- 데이터 구조 이해

## 4. 데이터 전처리
- 결측치 처리
- 타입 변환
- 중복 제거

## 5. 그룹화 및 집계
- groupby 기본
- 다중 집계
- pivot_table

## 6. 시각화
- matplotlib 예제
- seaborn 예제
- plotly 예제

## 7. 실습 문제
- 3-5개 실습 과제
```

### SPEC-PANDAS-001-02: 코드 셀 템플릿
```python
# ============================================
# [섹션 제목]
# ============================================

# [설명: 이 코드가 하는 일]

# 코드 실행
result = df.groupby('country')['customerNumber'].count()

# 결과 확인
print(result)

# [해석: 결과가 의미하는 바]
```

### SPEC-PANDAS-001-03: 시각화 예제 형식
```python
import matplotlib.pyplot as plt
import seaborn as sns

# 한글 폰트 설정 (macOS, Windows 대응)
plt.rcParams['font.family'] = 'AppleGothic'  # macOS
# plt.rcParams['font.family'] = 'Malgun Gothic'  # Windows

# 그래프 그리기
plt.figure(figsize=(10, 6))
sns.barplot(data=df, x='productLine', y='quantityInStock')
plt.title('제품 라인별 재고 수량')
plt.xlabel('제품 라인')
plt.ylabel('재고 수량')
plt.xticks(rotation=45)
plt.show()
```

### SPEC-PANDAS-001-04: 실습 문제 형식
```markdown
## 실습 문제 1: 국가별 주문 금액 합계

**문제:**
`orders`와 `orderdetails` 테이블을 조인하여 국가별 총 주문 금액을 계산하세요.

**힌트:**
- `pd.merge()` 사용
- `groupby('country')['amount'].sum()`

**정답:**
(코드 셀에 주석 처리)
```

## 제약사항 (CONSTRAINTS)

### 기술 제약사항
- Python 3.11+ 문법 사용
- Jupyter Notebook (.ipynb) 형식
- MySQL 연결은 로컬호스트 기본 설정
- 한글 폰트 설정은 macOS/Windows 모두 대응

### 교육 제약사항
- 각 코드 셀은 독립적으로 실행 가능해야 함 (순서 의존성 최소화)
- 실습 문제는 노트북 내 선행 학습 내용으로 해결 가능
- 출력 결과는 즉시 확인 가능하도록 `print()` 또는 `display()` 사용

### 성능 제약사항
- 대용량 데이터 처리 시 `chunksize` 사용 권장
- 시각화는 10,000행 이하 데이터로 제한 (샘플링 권장)

## 추적성 (TRACEABILITY)

- **@SPEC:PANDAS-001** → 이 명세서
- **@TEST:PANDAS-001** → 테스트 케이스 (노트북 실행 검증)
- **@CODE:PANDAS-001** → `notebooks/pandas_analysis.ipynb` (실습 노트북)
- **@DOC:PANDAS-001** → 사용 가이드 문서

## 변경 이력 (HISTORY)

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| 1.0 | 2025-11-05 | spec-builder | 초안 작성 |
