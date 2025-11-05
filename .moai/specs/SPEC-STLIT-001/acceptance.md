---
id: STLIT-001
title: Streamlit 대시보드 개발 - 수락 기준
type: Acceptance Criteria
status: Draft
created: 2025-11-05
---

# Streamlit 대시보드 개발 - 수락 기준

**@ACCEPTANCE:STLIT-001**

## 개요 (OVERVIEW)

이 문서는 Streamlit 대시보드 개발의 완료 기준을 정의합니다. 모든 시나리오는 Given-When-Then 형식으로 작성되며, 각 요구사항이 올바르게 구현되었는지 검증합니다.

## 테스트 시나리오 (TEST SCENARIOS)

### AC-STLIT-001-01: MySQL 연결 및 데이터 로드 검증

**Given:**
- classicmodels 데이터베이스가 MySQL에 로드되어 있음
- `.streamlit/secrets.toml` 파일에 연결 정보가 설정되어 있음
- Streamlit 앱이 실행 중임

**When:**
- 대시보드 페이지를 로드할 때

**Then:**
- MySQL 연결이 성공적으로 수립되어야 함
- `customers`, `orders`, `orderdetails` 테이블이 DataFrame으로 로드되어야 함
- 연결 오류 시 사용자에게 명확한 에러 메시지가 표시되어야 함
- 데이터 로드 시간이 5초 이내여야 함

**검증 방법:**
```bash
# 앱 실행
streamlit run streamlit_apps/dashboard.py

# 브라우저에서 페이지 로드 확인
# MySQL 연결 성공 메시지 또는 데이터 표시 확인
```

---

### AC-STLIT-001-02: 페이지 설정 검증

**Given:**
- Streamlit 앱이 실행 중임

**When:**
- 브라우저에서 대시보드를 열 때

**Then:**
- 페이지 제목이 "데이터 분석 대시보드"로 표시되어야 함
- 페이지 아이콘이 "📊"로 표시되어야 함
- 레이아웃이 와이드 모드(`layout="wide"`)로 설정되어야 함

**검증 방법:**
- 브라우저 탭 제목 확인
- 페이지 레이아웃 너비 확인 (와이드 모드)

---

### AC-STLIT-001-03: 사이드바 필터 구현 검증

**Given:**
- 대시보드가 로드되어 있음
- 데이터가 성공적으로 로드됨

**When:**
- 사이드바의 필터 옵션을 조작할 때

**Then:**
- 다음 필터가 제공되어야 함:
  - 국가 선택 (multiselect)
  - 날짜 범위 선택 (date_input)
  - 매출 범위 선택 (slider)
- 필터 변경 시 데이터가 즉시 업데이트되어야 함
- 필터 레이블이 한글로 표시되어야 함

**검증 방법:**
```python
# 사이드바에서 국가 필터 변경
# 메인 영역의 지표 카드 및 차트가 업데이트되는지 확인
```

---

### AC-STLIT-001-04: 탭 구성 검증

**Given:**
- 대시보드가 로드되어 있음

**When:**
- 탭을 클릭할 때

**Then:**
- 3개 탭이 제공되어야 함:
  - "개요" 탭
  - "상세 분석" 탭
  - "시각화" 탭
- 각 탭 클릭 시 해당 섹션이 표시되어야 함
- 탭 전환 시 페이지 리로드 없이 즉시 전환되어야 함

**검증 방법:**
- 각 탭을 클릭하여 콘텐츠 변경 확인

---

### AC-STLIT-001-05: 지표 카드 표시 검증

**Given:**
- "개요" 탭이 선택되어 있음
- 데이터가 로드됨

**When:**
- 개요 섹션을 확인할 때

**Then:**
- 4개의 지표 카드가 나란히 표시되어야 함:
  - 총 고객 수
  - 총 주문 건수
  - 총 매출
  - 평균 주문 금액
- 각 지표는 `st.metric()` 위젯으로 표시되어야 함
- 숫자는 천 단위 구분 기호(`,`)로 포맷되어야 함
- 델타 값 (증감률)이 표시되어야 함 (선택적)

**검증 방법:**
```python
# 개요 탭에서 지표 카드 확인
# 각 지표의 값이 정확한지 수동 검증
```

---

### AC-STLIT-001-06: 동적 필터링 검증

**Given:**
- 사이드바 필터가 기본 값으로 설정되어 있음

**When:**
- 국가 필터를 변경할 때 (예: "USA"만 선택)

**Then:**
- 지표 카드의 값이 필터링된 데이터를 반영하여 업데이트되어야 함
- 차트가 필터링된 데이터를 사용하여 다시 렌더링되어야 함
- 데이터 테이블이 필터링된 행만 표시해야 함
- 업데이트 시간이 2초 이내여야 함

**검증 방법:**
```python
# 필터 변경 전후 지표 값 비교
# 예: 전체 고객 수 122명 → USA만 36명
```

---

### AC-STLIT-001-07: Plotly 막대 그래프 검증

**Given:**
- "시각화" 탭이 선택되어 있음
- 데이터가 로드됨

**When:**
- 국가별 매출 막대 그래프를 확인할 때

**Then:**
- Plotly 인터랙티브 막대 그래프가 표시되어야 함
- 차트 제목이 한글로 표시되어야 함 (예: "국가별 총 매출")
- X축/Y축 레이블이 한글로 표시되어야 함
- 막대에 마우스를 호버하면 상세 정보가 표시되어야 함
- 차트가 `use_container_width=True`로 반응형이어야 함

**검증 방법:**
- 차트 인터랙션 테스트 (호버, 줌, 팬)
- 한글 레이블 깨짐 여부 확인

---

### AC-STLIT-001-08: Plotly 선 그래프 검증

**Given:**
- "시각화" 탭이 선택되어 있음
- 데이터가 로드됨

**When:**
- 월별 주문 추이 선 그래프를 확인할 때

**Then:**
- Plotly 선 그래프가 표시되어야 함
- X축이 날짜 형식으로 표시되어야 함
- Y축이 주문 건수를 표시해야 함
- 차트 제목 및 레이블이 한글로 표시되어야 함
- 인터랙티브 기능 (호버, 줌)이 작동해야 함

**검증 방법:**
- 차트 인터랙션 테스트
- 날짜 형식 확인 (YYYY-MM)

---

### AC-STLIT-001-09: Plotly 파이 차트 검증

**Given:**
- "시각화" 탭이 선택되어 있음
- 데이터가 로드됨

**When:**
- 제품 라인별 비율 파이 차트를 확인할 때

**Then:**
- Plotly 파이 차트가 표시되어야 함
- 각 섹션에 제품 라인 이름과 비율(%)이 표시되어야 함
- 차트 제목이 한글로 표시되어야 함
- 마우스 호버 시 상세 정보 (개수, 비율)가 표시되어야 함

**검증 방법:**
- 파이 차트 인터랙션 테스트
- 비율 합계가 100%인지 확인

---

### AC-STLIT-001-10: 데이터 테이블 표시 검증

**Given:**
- "상세 분석" 탭이 선택되어 있음
- 데이터가 필터링됨

**When:**
- 상세 데이터 테이블을 확인할 때

**Then:**
- `st.dataframe()` 또는 `st.data_editor()`로 테이블이 표시되어야 함
- 필터링된 데이터만 표시되어야 함
- 테이블이 정렬 가능해야 함 (컬럼 헤더 클릭)
- 한글 컬럼명이 정상적으로 표시되어야 함
- 10,000행 이상 데이터는 페이징 처리되어야 함

**검증 방법:**
```python
# 테이블 정렬 기능 테스트
# 컬럼 헤더 클릭하여 오름차순/내림차순 정렬 확인
```

---

### AC-STLIT-001-11: 데이터 캐싱 검증

**Given:**
- 대시보드가 실행 중임

**When:**
- 페이지를 새로고침할 때

**Then:**
- 데이터 로드 함수가 `@st.cache_data` 데코레이터를 사용해야 함
- 첫 로드 후 캐싱된 데이터를 사용하여 빠르게 로드되어야 함
- 캐시 TTL이 10분(600초)으로 설정되어야 함
- 캐시 적중 시 로드 시간이 1초 이내여야 함

**검증 방법:**
```python
# 첫 로드: 5초
# 새로고침: 1초 이내 (캐시 적중)
```

---

### AC-STLIT-001-12: secrets.toml 보안 검증

**Given:**
- 프로젝트에 `.streamlit/secrets.toml` 파일이 존재함

**When:**
- Git 리포지토리를 확인할 때

**Then:**
- `.gitignore` 파일에 `.streamlit/secrets.toml`이 포함되어야 함
- `git status` 실행 시 `secrets.toml`이 추적되지 않아야 함
- `secrets.toml`에는 민감한 정보 (비밀번호)가 포함되어 있어야 함

**검증 방법:**
```bash
# .gitignore 확인
cat .gitignore | grep secrets.toml

# Git 추적 여부 확인
git status
```

---

### AC-STLIT-001-13: BigQuery 연동 검증 (선택적)

**Given:**
- BigQuery 서비스 계정이 설정되어 있음
- `secrets.toml`에 GCP 인증 정보가 포함되어 있음

**When:**
- BigQuery 연동 섹션을 실행할 때

**Then:**
- BigQuery 클라이언트가 성공적으로 인증되어야 함
- 쿼리가 실행되어 DataFrame으로 변환되어야 함
- 결과 데이터가 Streamlit UI에 표시되어야 함
- MySQL과 동일한 UI/UX를 제공해야 함

**검증 방법:**
```python
# BigQuery 쿼리 실행
df_bq = load_bigquery_data("SELECT * FROM dataset.table LIMIT 100")
assert len(df_bq) > 0, "BigQuery 데이터 로드 실패"
```

---

### AC-STLIT-001-14: 앱 전체 실행 검증

**Given:**
- `streamlit_apps/dashboard.py` 파일이 존재함
- MySQL 데이터베이스가 로드되어 있음
- `.streamlit/secrets.toml` 파일이 설정되어 있음

**When:**
- `streamlit run streamlit_apps/dashboard.py` 명령을 실행할 때

**Then:**
- 앱이 오류 없이 실행되어야 함
- 브라우저에서 `http://localhost:8501`로 접근 가능해야 함
- 모든 기능이 정상적으로 작동해야 함
- 페이지 로드 시간이 5초 이내여야 함

**검증 방법:**
```bash
# 앱 실행
streamlit run streamlit_apps/dashboard.py

# 브라우저에서 접근
# 모든 탭 및 필터 테스트
```

---

### AC-STLIT-001-15: 한글 UI 검증

**Given:**
- 대시보드가 실행 중임

**When:**
- 모든 UI 요소를 확인할 때

**Then:**
- 사이드바 제목 및 필터 레이블이 한글로 표시되어야 함
- 탭 이름이 한글로 표시되어야 함
- 지표 카드 레이블이 한글로 표시되어야 함
- 차트 제목/축 레이블이 한글로 표시되어야 함
- 한글이 깨지거나 깨지지 않아야 함

**검증 방법:**
- 모든 UI 요소 육안 확인
- 한글 폰트 깨짐 여부 확인

---

## 완료 조건 (DEFINITION OF DONE)

다음 모든 조건이 충족되어야 SPEC-STLIT-001이 완료된 것으로 간주합니다:

- [ ] AC-STLIT-001-01: MySQL 연결 및 데이터 로드 성공
- [ ] AC-STLIT-001-02: 페이지 설정이 올바르게 구성됨
- [ ] AC-STLIT-001-03: 사이드바 필터가 정상 작동함
- [ ] AC-STLIT-001-04: 3개 탭이 구현됨
- [ ] AC-STLIT-001-05: 4개 지표 카드가 표시됨
- [ ] AC-STLIT-001-06: 동적 필터링이 정상 작동함
- [ ] AC-STLIT-001-07: Plotly 막대 그래프가 정상 표시됨
- [ ] AC-STLIT-001-08: Plotly 선 그래프가 정상 표시됨
- [ ] AC-STLIT-001-09: Plotly 파이 차트가 정상 표시됨
- [ ] AC-STLIT-001-10: 데이터 테이블이 정상 표시됨
- [ ] AC-STLIT-001-11: 데이터 캐싱이 적용됨
- [ ] AC-STLIT-001-12: secrets.toml이 `.gitignore`에 포함됨
- [ ] AC-STLIT-001-13: BigQuery 연동 예제 제공됨 (선택적)
- [ ] AC-STLIT-001-14: 앱이 오류 없이 실행됨
- [ ] AC-STLIT-001-15: 모든 한글 UI가 정상 표시됨

## 테스트 도구 및 방법 (TESTING TOOLS)

### 수동 테스트
- **Streamlit 앱 실행:** `streamlit run streamlit_apps/dashboard.py`
- **브라우저 테스트:** 모든 기능 수동 확인
- **성능 측정:** 크롬 개발자 도구 (Network 탭)

### 자동화 테스트 (선택적)
```python
# Selenium을 사용한 UI 자동화 테스트
from selenium import webdriver

def test_streamlit_app():
    driver = webdriver.Chrome()
    driver.get("http://localhost:8501")

    # 페이지 제목 확인
    assert "데이터 분석 대시보드" in driver.title

    # 필터 조작
    # ...

    driver.quit()
```

## 품질 기준 (QUALITY GATES)

### 기능 완성도
- 모든 AC 시나리오 통과: 100%

### 성능 기준
- 페이지 로드 시간: < 5초 (첫 로드)
- 필터 업데이트 시간: < 2초
- 캐시 적중 시 로드 시간: < 1초

### 보안 기준
- secrets.toml이 Git에 추적되지 않음: 필수

### UI/UX 기준
- 한글 UI 깨짐 없음: 필수
- 인터랙티브 차트 작동: 필수

## 추적성 (TRACEABILITY)

- **@SPEC:STLIT-001** → 요구사항 명세
- **@PLAN:STLIT-001** → 구현 계획
- **@ACCEPTANCE:STLIT-001** → 이 문서 (수락 기준)
- **@CODE:STLIT-001** → `streamlit_apps/dashboard.py` (구현 결과)
- **@TEST:STLIT-001** → 앱 실행 및 기능 테스트
