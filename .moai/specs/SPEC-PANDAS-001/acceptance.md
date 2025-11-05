---
id: PANDAS-001
title: Pandas 데이터 분석 실습 노트북 개발 - 수락 기준
type: Acceptance Criteria
status: Draft
created: 2025-11-05
---

# Pandas 데이터 분석 실습 노트북 개발 - 수락 기준

**@ACCEPTANCE:PANDAS-001**

## 개요 (OVERVIEW)

이 문서는 Pandas 데이터 분석 실습 노트북 개발의 완료 기준을 정의합니다. 모든 시나리오는 Given-When-Then 형식으로 작성되며, 각 요구사항이 올바르게 구현되었는지 검증합니다.

## 테스트 시나리오 (TEST SCENARIOS)

### AC-PANDAS-001-01: MySQL 데이터 로드 검증

**Given:**
- classicmodels 데이터베이스가 MySQL에 로드되어 있음
- Jupyter Notebook이 실행 중임
- `pandas_analysis.ipynb` 파일이 존재함

**When:**
- 노트북의 "MySQL 데이터 로드" 섹션을 실행할 때

**Then:**
- MySQL 연결이 성공적으로 수립되어야 함
- `customers`, `orders`, `products` 테이블이 DataFrame으로 로드되어야 함
- 각 DataFrame의 `shape` 출력이 정상적으로 표시되어야 함
- 연결 종료 코드가 실행되어야 함

**검증 방법:**
```python
# 노트북 실행 후 확인
assert df_customers.shape[0] > 0, "customers 테이블 로드 실패"
assert df_orders.shape[0] > 0, "orders 테이블 로드 실패"
assert df_products.shape[0] > 0, "products 테이블 로드 실패"
```

---

### AC-PANDAS-001-02: 데이터 탐색 기능 검증

**Given:**
- MySQL에서 DataFrame이 성공적으로 로드됨

**When:**
- "데이터 탐색" 섹션의 코드 셀을 실행할 때

**Then:**
- `df.head()` 출력이 상위 5개 행을 표시해야 함
- `df.info()` 출력이 데이터 타입 및 결측치 정보를 표시해야 함
- `df.describe()` 출력이 기술 통계량을 표시해야 함
- `df.shape`, `df.columns` 출력이 정상적으로 표시되어야 함
- 각 메서드 위에 한글 설명이 제공되어야 함

**검증 방법:**
- 노트북 실행 후 각 셀의 출력 결과 육안 확인
- 한글 설명이 마크다운 셀에 존재하는지 확인

---

### AC-PANDAS-001-03: 결측치 처리 검증

**Given:**
- DataFrame에 결측치가 포함되어 있음 (또는 의도적으로 생성됨)

**When:**
- "데이터 전처리" 섹션의 결측치 처리 코드를 실행할 때

**Then:**
- `df.isnull().sum()` 출력이 결측치 개수를 표시해야 함
- `df.fillna()` 실행 후 결측치가 채워져야 함
- `df.dropna()` 실행 후 결측치가 제거되어야 함
- 각 방법의 차이점이 한글로 설명되어야 함

**검증 방법:**
```python
# fillna 실행 전후 비교
before = df.isnull().sum().sum()
df_filled = df.fillna(df.mean(numeric_only=True))
after = df_filled.isnull().sum().sum()
assert after < before, "fillna가 제대로 작동하지 않음"
```

---

### AC-PANDAS-001-04: 데이터 타입 변환 검증

**Given:**
- DataFrame의 일부 컬럼이 잘못된 타입으로 로드됨

**When:**
- 데이터 타입 변환 코드를 실행할 때

**Then:**
- `df['column'].astype()` 실행 후 타입이 변경되어야 함
- `pd.to_datetime()` 실행 후 날짜 형식으로 변환되어야 함
- 변환 전후 타입을 비교하는 출력이 있어야 함

**검증 방법:**
```python
# 날짜 변환 예제
df['orderDate'] = pd.to_datetime(df['orderDate'])
assert df['orderDate'].dtype == 'datetime64[ns]', "날짜 변환 실패"
```

---

### AC-PANDAS-001-05: 그룹화 및 집계 검증

**Given:**
- DataFrame이 로드되어 있음

**When:**
- "그룹화 및 집계" 섹션의 코드를 실행할 때

**Then:**
- `df.groupby()` 실행 후 그룹화된 결과가 표시되어야 함
- `.agg()` 실행 후 다중 집계 결과가 표시되어야 함
- `.pivot_table()` 실행 후 피벗 테이블이 생성되어야 함
- 다음 실무 예제가 포함되어야 함:
  - 국가별 고객 수
  - 제품 라인별 평균 가격
  - 월별 주문 건수

**검증 방법:**
```python
# 국가별 고객 수 예제
result = df_customers.groupby('country')['customerNumber'].count()
assert len(result) > 0, "groupby 실행 실패"
assert result.sum() == len(df_customers), "집계 결과 불일치"
```

---

### AC-PANDAS-001-06: matplotlib 시각화 검증

**Given:**
- 집계된 데이터가 존재함

**When:**
- matplotlib 시각화 코드를 실행할 때

**Then:**
- 선 그래프가 정상적으로 표시되어야 함
- 막대 그래프가 정상적으로 표시되어야 함
- 한글 제목/레이블이 깨지지 않고 표시되어야 함
- 그래프 크기가 `figsize=(10, 6)` 등으로 설정되어야 함

**검증 방법:**
- 노트북 실행 후 시각화 출력 육안 확인
- 한글 폰트가 설정되어 있는지 코드 검토

---

### AC-PANDAS-001-07: seaborn 시각화 검증

**Given:**
- DataFrame이 로드되어 있음

**When:**
- seaborn 시각화 코드를 실행할 때

**Then:**
- 박스플롯이 정상적으로 표시되어야 함
- 히트맵이 정상적으로 표시되어야 함
- 한글 제목/레이블이 깨지지 않고 표시되어야 함
- seaborn 스타일이 적용되어야 함 (예: `sns.set_style('whitegrid')`)

**검증 방법:**
- 노트북 실행 후 시각화 출력 육안 확인

---

### AC-PANDAS-001-08: plotly 인터랙티브 시각화 검증

**Given:**
- DataFrame이 로드되어 있음

**When:**
- plotly 시각화 코드를 실행할 때

**Then:**
- 인터랙티브 차트가 표시되어야 함
- 마우스 호버 시 데이터 값이 표시되어야 함
- 드릴다운 또는 줌 기능이 작동해야 함
- 한글 제목/레이블이 정상적으로 표시되어야 함

**검증 방법:**
- Jupyter Notebook에서 plotly 차트 인터랙션 테스트
- 브라우저에서 정상 렌더링 확인

---

### AC-PANDAS-001-09: 실습 문제 제공 검증

**Given:**
- 노트북의 모든 학습 섹션이 완료됨

**When:**
- "실습 문제" 섹션을 읽을 때

**Then:**
- 최소 3개의 실습 문제가 제공되어야 함
- 각 문제는 다음을 포함해야 함:
  - 문제 설명 (한글)
  - 힌트 (선택적)
  - 정답 코드 (주석 처리)
  - 예상 결과

**검증 방법:**
- 노트북에서 "실습 문제" 마크다운 셀 개수 카운트
- 각 문제에 정답 코드가 주석으로 제공되는지 확인

---

### AC-PANDAS-001-10: 실습 문제 정답 검증

**Given:**
- 실습 문제의 정답 코드가 주석으로 제공됨

**When:**
- 정답 코드의 주석을 해제하고 실행할 때

**Then:**
- 모든 정답 코드가 오류 없이 실행되어야 함
- 정답 코드의 결과가 "예상 결과"와 일치해야 함
- 문제 요구사항을 만족해야 함

**검증 방법:**
```python
# 각 실습 문제의 정답 코드를 주석 해제
# 실행 후 결과를 "예상 결과"와 비교
```

---

### AC-PANDAS-001-11: 노트북 전체 실행 검증

**Given:**
- `pandas_analysis.ipynb` 파일이 존재함
- classicmodels 데이터베이스가 MySQL에 로드되어 있음

**When:**
- Jupyter Notebook에서 "Run All Cells"를 실행할 때

**Then:**
- 모든 코드 셀이 순서대로 오류 없이 실행되어야 함
- 모든 출력 결과가 정상적으로 표시되어야 함
- 시각화가 모두 렌더링되어야 함
- 전체 실행 시간이 5분 이내여야 함 (성능 요구사항)

**검증 방법:**
```bash
# Jupyter에서 "Kernel → Restart & Run All" 실행
# 모든 셀이 성공적으로 실행되는지 확인
```

---

### AC-PANDAS-001-12: 한글 인코딩 및 폰트 검증

**Given:**
- 노트북에 한글 설명 및 시각화 레이블이 포함됨

**When:**
- 노트북을 macOS, Windows, Linux에서 실행할 때

**Then:**
- 모든 한글 텍스트가 정상적으로 표시되어야 함
- matplotlib/seaborn/plotly 차트의 한글 제목/레이블이 깨지지 않아야 함
- OS별 폰트 설정 코드가 제공되어야 함

**검증 방법:**
```python
# 폰트 설정 코드 확인
import platform
if platform.system() == 'Darwin':
    assert 'AppleGothic' in plt.rcParams['font.family']
elif platform.system() == 'Windows':
    assert 'Malgun Gothic' in plt.rcParams['font.family']
```

---

## 완료 조건 (DEFINITION OF DONE)

다음 모든 조건이 충족되어야 SPEC-PANDAS-001이 완료된 것으로 간주합니다:

- [ ] AC-PANDAS-001-01: MySQL 데이터가 DataFrame으로 로드됨
- [ ] AC-PANDAS-001-02: 데이터 탐색 기능이 정상 작동함
- [ ] AC-PANDAS-001-03: 결측치 처리 예제가 제공됨
- [ ] AC-PANDAS-001-04: 데이터 타입 변환 예제가 제공됨
- [ ] AC-PANDAS-001-05: 그룹화 및 집계 예제가 제공됨
- [ ] AC-PANDAS-001-06: matplotlib 시각화가 정상 작동함
- [ ] AC-PANDAS-001-07: seaborn 시각화가 정상 작동함
- [ ] AC-PANDAS-001-08: plotly 인터랙티브 차트가 정상 작동함
- [ ] AC-PANDAS-001-09: 최소 3개 실습 문제가 제공됨
- [ ] AC-PANDAS-001-10: 모든 실습 문제의 정답이 정확함
- [ ] AC-PANDAS-001-11: 전체 노트북이 오류 없이 실행됨
- [ ] AC-PANDAS-001-12: 한글 폰트가 모든 OS에서 정상 표시됨

## 테스트 도구 및 방법 (TESTING TOOLS)

### 수동 테스트
- Jupyter Notebook: "Run All Cells" 실행 및 출력 확인
- MySQL Workbench: 데이터베이스 연결 확인

### 자동화 테스트 (선택적)
```python
# pytest를 사용한 노트북 실행 테스트
import nbformat
from nbconvert.preprocessors import ExecutePreprocessor

def test_notebook_execution():
    with open('notebooks/pandas_analysis.ipynb') as f:
        nb = nbformat.read(f, as_version=4)

    ep = ExecutePreprocessor(timeout=600, kernel_name='python3')
    ep.preprocess(nb, {'metadata': {'path': 'notebooks/'}})

    # 모든 셀이 성공적으로 실행되면 통과
```

## 품질 기준 (QUALITY GATES)

### 기능 완성도
- 모든 AC 시나리오 통과: 100%

### 코드 품질
- 코드 셀 실행 성공률: 100%
- 한글 설명 가독성: 입문자 피드백 기준

### 교육 효과
- 학습 순서 논리성: 전문가 리뷰 통과
- 실습 문제 적절성: 입문자 해결 가능

## 추적성 (TRACEABILITY)

- **@SPEC:PANDAS-001** → 요구사항 명세
- **@PLAN:PANDAS-001** → 구현 계획
- **@ACCEPTANCE:PANDAS-001** → 이 문서 (수락 기준)
- **@CODE:PANDAS-001** → `notebooks/pandas_analysis.ipynb` (구현 결과)
- **@TEST:PANDAS-001** → 노트북 실행 테스트 스크립트
