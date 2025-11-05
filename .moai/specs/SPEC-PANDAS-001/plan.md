---
id: PANDAS-001
title: Pandas 데이터 분석 실습 노트북 개발 - 구현 계획
type: Implementation Plan
status: Draft
created: 2025-11-05
---

# Pandas 데이터 분석 실습 노트북 개발 - 구현 계획

**@PLAN:PANDAS-001**

## 목표 (OBJECTIVES)

MySQL classicmodels 데이터베이스를 활용한 Pandas 데이터 분석 실습 Jupyter Notebook을 개발하여 입문자가 데이터 로드부터 시각화까지 전체 워크플로우를 학습할 수 있도록 함

## 구현 마일스톤 (MILESTONES)

### Phase 1: 환경 설정 및 데이터 로드 (Primary Goal)

**목표:**
- Jupyter Notebook 생성
- 필요한 라이브러리 import
- MySQL 연결 및 DataFrame 로드 예제 작성

**산출물:**
- `notebooks/pandas_analysis.ipynb` (섹션 1-2)
- 연결 설정 예제 코드
- 3개 테이블 (customers, orders, products) 로드 예제

**의존성:**
- classicmodels 데이터베이스가 MySQL에 로드되어 있어야 함

### Phase 2: 데이터 탐색 및 전처리 (Primary Goal)

**목표:**
- EDA (탐색적 데이터 분석) 예제 작성
- 전처리 기법 시연 (결측치, 타입 변환, 중복 제거)

**산출물:**
- 노트북 섹션 3-4 완성
- 각 메서드의 출력 결과 및 한글 설명

**의존성:**
- Phase 1 완료 (DataFrame 로드 필요)

### Phase 3: 그룹화 및 집계 (Secondary Goal)

**목표:**
- groupby, agg, pivot_table 예제 작성
- 실무 비즈니스 질문 3가지 해결

**산출물:**
- 노트북 섹션 5 완성
- 국가별 고객 수, 제품 라인별 평균 가격, 월별 주문 건수 예제

**의존성:**
- Phase 2 완료 (전처리된 데이터 필요)

### Phase 4: 시각화 (Secondary Goal)

**목표:**
- matplotlib, seaborn, plotly 각 2개 예제 작성
- 한글 폰트 설정 (macOS/Windows 대응)

**산출물:**
- 노트북 섹션 6 완성
- 인터랙티브 차트 예제 (plotly)

**의존성:**
- Phase 3 완료 (집계 결과 시각화)

### Phase 5: 실습 문제 및 검증 (Final Goal)

**목표:**
- 3-5개 실습 문제 작성
- 정답 코드 제공 (주석 처리)
- 전체 노트북 실행 테스트

**산출물:**
- 노트북 섹션 7 완성
- 실행 가능한 최종 버전

**의존성:**
- Phase 4 완료 (전체 학습 내용 기반 문제 출제)

## 기술 접근 방식 (TECHNICAL APPROACH)

### 1. 데이터베이스 연결 방법

**옵션 1: mysql.connector (단순)**
```python
import mysql.connector
import pandas as pd

conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='your_password',
    database='classicmodels'
)

df = pd.read_sql("SELECT * FROM customers", conn)
conn.close()
```

**옵션 2: SQLAlchemy (권장)**
```python
from sqlalchemy import create_engine
import pandas as pd

engine = create_engine('mysql+mysqlconnector://root:password@localhost/classicmodels')
df = pd.read_sql("SELECT * FROM customers", engine)
engine.dispose()
```

**선택 기준:** SQLAlchemy는 연결 풀링 지원 및 ORM 확장 가능성이 있으므로 권장

### 2. 한글 폰트 설정 전략

**macOS:**
```python
plt.rcParams['font.family'] = 'AppleGothic'
plt.rcParams['axes.unicode_minus'] = False
```

**Windows:**
```python
plt.rcParams['font.family'] = 'Malgun Gothic'
plt.rcParams['axes.unicode_minus'] = False
```

**범용 설정:**
```python
import platform

if platform.system() == 'Darwin':  # macOS
    plt.rcParams['font.family'] = 'AppleGothic'
elif platform.system() == 'Windows':
    plt.rcParams['font.family'] = 'Malgun Gothic'
else:  # Linux
    plt.rcParams['font.family'] = 'NanumGothic'
```

### 3. 실습 문제 설계 원칙

**점진적 난이도:**
- 문제 1-2: 단일 테이블 그룹화 및 집계
- 문제 3-4: 다중 테이블 조인 및 분석
- 문제 5: 시각화 포함 종합 분석

**실무 연관성:**
- "상위 10개 제품 찾기"
- "국가별 매출 분석"
- "고객 세그먼트별 주문 패턴"

**즉시 피드백:**
- 정답 코드를 주석으로 제공
- 학습자가 주석 해제하여 비교

### 4. 시각화 라이브러리 비교

| 라이브러리 | 장점 | 단점 | 사용 예제 |
|-----------|------|------|-----------|
| **matplotlib** | 기본 라이브러리, 커스터마이징 자유도 높음 | 코드가 길어질 수 있음 | 선 그래프, 막대 그래프 |
| **seaborn** | 통계 시각화 특화, 간결한 코드 | 인터랙티브 기능 없음 | 박스플롯, 히트맵 |
| **plotly** | 인터랙티브, 드릴다운 가능 | 대용량 데이터 시 느림 | 산점도, 시계열 차트 |

## 아키텍처 설계 (ARCHITECTURE DESIGN)

### 파일 구조
```
notebooks/
├── pandas_analysis.ipynb (메인 실습 노트북)
└── data/ (선택적: 샘플 CSV 파일)
```

### 노트북 섹션 구조
```markdown
1. 환경 설정 및 라이브러리 import (1개 코드 셀)
2. MySQL 데이터 로드 (3개 코드 셀)
3. 데이터 탐색 (5개 코드 셀)
4. 데이터 전처리 (6개 코드 셀)
5. 그룹화 및 집계 (4개 코드 셀)
6. 시각화 (6개 코드 셀: matplotlib 2 + seaborn 2 + plotly 2)
7. 실습 문제 (5개 마크다운 셀 + 5개 코드 셀)
```

## 위험 요소 및 대응 (RISKS AND MITIGATION)

### 위험 1: MySQL 연결 실패
**대응:**
- 연결 설정 예제에 오류 처리 추가
- 대체 방법으로 CSV 파일 로드 예제 제공
- 연결 문제 해결 가이드 링크

### 위험 2: 한글 폰트 깨짐
**대응:**
- OS별 폰트 설정 코드 제공
- 폰트 설치 가이드 링크
- 영문 레이블로도 동작하도록 이중 설정

### 위험 3: 대용량 데이터로 인한 성능 저하
**대응:**
- `df.head(1000)` 등으로 샘플링 사용
- `chunksize` 파라미터 사용 예제 제공
- 시각화는 10,000행 이하 데이터 권장

### 위험 4: 라이브러리 버전 충돌
**대응:**
- `requirements.txt` 파일 제공
- 노트북 첫 셀에 버전 확인 코드 추가
- 호환성 이슈가 있는 버전 명시

## 품질 보증 (QUALITY ASSURANCE)

### 검증 항목
- [ ] 모든 코드 셀이 오류 없이 실행됨
- [ ] 한글 설명이 명확하고 이해하기 쉬움
- [ ] 시각화가 정상적으로 표시됨 (한글 폰트 포함)
- [ ] 실습 문제의 정답이 정확함
- [ ] MySQL 연결이 정상적으로 작동함

### 테스트 방법
1. **실행 테스트:** Jupyter Notebook에서 "Run All Cells" 실행
2. **출력 확인:** 각 셀의 출력 결과가 예상과 일치하는지 검증
3. **시각화 테스트:** 모든 차트가 정상적으로 렌더링되는지 확인
4. **한글 테스트:** 제목/레이블이 깨지지 않고 표시되는지 확인

## 다음 단계 (NEXT STEPS)

1. **Phase 1 시작:** 노트북 생성 및 MySQL 연결 예제 작성
2. **테스트 환경 준비:** classicmodels 데이터베이스 로드 확인
3. **@CODE:PANDAS-001 생성:** `notebooks/pandas_analysis.ipynb` 작성
4. **@TEST:PANDAS-001 실행:** 전체 노트북 실행 검증
5. **@DOC:PANDAS-001 작성:** 사용 가이드 및 troubleshooting 문서
