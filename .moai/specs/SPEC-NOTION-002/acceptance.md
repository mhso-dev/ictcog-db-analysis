---
id: NOTION-002
title: Notion MCP 기반 교재 자동 생성 시스템 수락 기준
type: Acceptance Criteria
status: Draft
created: 2025-11-05
author: spec-builder
---

# Notion MCP 기반 교재 자동 생성 시스템 수락 기준

**@ACCEPT:NOTION-002**

## 개요

이 문서는 **@SPEC:NOTION-002**의 수락 기준과 테스트 시나리오를 정의합니다. 모든 테스트는 Given-When-Then 형식으로 작성되며, 자동화된 Notion 교재 생성 시스템의 품질을 보장합니다.

**Definition of Done (DoD):**
- [ ] 모든 기능 요구사항 구현 완료
- [ ] 모든 테스트 시나리오 통과
- [ ] 02번 교재 실제 생성 성공
- [ ] 03~05번 재사용 가능성 검증
- [ ] 사용자 가이드 문서 작성 완료
- [ ] 코드 리뷰 완료

---

## 수락 기준 (Acceptance Criteria)

### AC-001: 단일 명령 실행
**관련 요구사항:** FR-NOTION-002-001

**Given:** SQL 파일, CSV 데이터셋, Notion 대상 페이지 URL이 준비됨
**When:** 다음 명령을 실행:
```bash
python generate_tutorial.py \
  --sql mysql/02_product_review/product_review.sql \
  --data data/02_product_review/dataset2.csv \
  --notion-page "https://www.notion.so/02-2a0562d8a6ca800687adc7369d455c5b"
```
**Then:**
- 사용자 개입 없이 자동 실행 완료
- 실행 시간 < 5분
- Notion 페이지 URL 출력
- 성공 보고서 출력

**검증 방법:**
- 명령 실행 후 exit code = 0
- 보고서에 "성공" 메시지 포함
- Notion 페이지 URL 클릭 가능

---

### AC-002: SQL 소문자 변환
**관련 요구사항:** FR-NOTION-002-002

**Given:** 대문자 SQL 쿼리:
```sql
SELECT 'DIVISION NAME', AVG(RATING) FROM MYDATA.DATASET2 GROUP BY 1;
```
**When:** SQL 변환 수행
**Then:** 다음과 같이 변환됨:
```sql
select "DIVISION NAME", avg(RATING) from mydata.dataset2 group by 1;
```

**검증 포인트:**
- [x] SELECT → select
- [x] AVG → avg
- [x] FROM → from
- [x] GROUP BY → group by
- [x] MYDATA.DATASET2 → mydata.dataset2
- [x] 'DIVISION NAME' → "DIVISION NAME"

**검증 방법:**
- 변환된 SQL 텍스트 비교
- 정규표현식 매칭: `^select\s+`

---

### AC-003: 문법 오류 자동 수정
**관련 요구사항:** FR-NOTION-002-003

**시나리오 3-1: 컬럼명 따옴표 수정**

**Given:** 잘못된 쿼리:
```sql
select 'DIVISION NAME' from mydata.dataset2;
```
**When:** 문법 수정 수행
**Then:**
```sql
select "DIVISION NAME" from mydata.dataset2;
```

**검증 방법:**
- 작은따옴표가 큰따옴표로 변경됨
- MySQL EXPLAIN 성공

---

**시나리오 3-2: LIMIT 위치 수정**

**Given:** 잘못된 쿼리:
```sql
select * from mydata.dataset2 where AGE > 30 and LIMIT 10;
```
**When:** 문법 수정 수행
**Then:**
```sql
select * from mydata.dataset2 where AGE > 30
limit 10;
```

**검증 방법:**
- LIMIT이 WHERE 절 다음 줄로 이동
- MySQL EXPLAIN 성공

---

**시나리오 3-3: 테이블명 수정**

**Given:** 잘못된 쿼리:
```sql
select * from DATA.DATASET2;
```
**When:** 문법 수정 수행
**Then:**
```sql
select * from mydata.dataset2;
```

**검증 방법:**
- DATA → mydata 변경
- MySQL EXPLAIN 성공

---

### AC-004: AI 기반 3줄 주석 생성
**관련 요구사항:** FR-NOTION-002-004

**Given:** 쿼리:
```sql
select "DIVISION NAME", avg(RATING) AVG_RATE
from mydata.dataset2
group by 1
order by 2 desc;
```
**When:** AI 주석 생성 호출
**Then:** 다음 형식의 주석 생성:
```sql
-- [그림 5-1 결과]
-- 목적: DIVISION NAME별 평균 평점 계산하여 부서 그룹 성과 비교
-- 결과: 각 부서 그룹의 평균 평점을 높은 순으로 정렬하여 출력
```

**검증 포인트:**
- [x] 3줄 주석 생성됨
- [x] 1줄: 그림 번호 (원본 유지)
- [x] 2줄: "목적:" 접두사 + 분석 내용 (50자 이내)
- [x] 3줄: "결과:" 접두사 + 출력 특징 (80자 이내)

**검증 방법:**
- 주석 라인 수 = 3
- 정규표현식: `^-- 목적: .{10,50}$`
- 정규표현식: `^-- 결과: .{10,80}$`

---

### AC-005: 섹션 자동 분류
**관련 요구사항:** FR-NOTION-002-005

**Given:** 28개 쿼리 (그림 5-1 ~ 그림 5-25 + 표 5-2 등)
**When:** 섹션 분류 수행
**Then:** 7개 섹션으로 분류됨:

| Section | 그림 번호 범위 | 쿼리 수 | 제목 |
|---------|---------------|--------|------|
| 1 | 5-1 ~ 5-3 | 3 | 기초 집계 분석 |
| 2 | 5-4 ~ 5-8 | 5 | 연령 그룹화 |
| 3 | 5-9 ~ 138p | 5 | 상품별 평점 분석 |
| 4 | 5-15 ~ 5-17 | 3 | 연령-부서 교차 분석 |
| 5 | 표 5-2 ~ 5-20 | 4 | 텍스트 마이닝 기초 |
| 6 | 5-21 ~ 5-23 | 2 | 다차원 텍스트 분석 |
| 7 | 5-25 ~ 151p | 3 | 상품별 종합 분석 |

**검증 포인트:**
- [x] 총 섹션 수 = 7
- [x] 총 쿼리 수 = 28
- [x] 모든 쿼리가 섹션에 할당됨
- [x] 섹션 제목 자동 생성됨

**검증 방법:**
- `len(sections) == 7`
- `sum(len(s.queries) for s in sections) == 28`
- 각 섹션 제목이 비어있지 않음

---

### AC-006: AI 기반 교재 설명 생성
**관련 요구사항:** FR-NOTION-002-006

**Given:** Section 1 정보:
- 제목: 기초 집계 분석
- 쿼리 수: 3개
- 핵심 개념: AVG, GROUP BY, WHERE

**When:** 섹션 설명 생성 호출
**Then:** 다음 내용을 포함한 설명 생성 (200~400자):
- 학습 목표 (2-3문장)
- 이전 섹션과의 연결점 (1문장, Section 1은 제외)
- 각 쿼리의 진화 과정 (쿼리별 1문장)
- 실무 활용 예시 (1-2문장)

**검증 포인트:**
- [x] 설명 길이 200~400자
- [x] "학습 목표", "쿼리", "활용" 키워드 포함
- [x] 초급자가 이해 가능한 용어 사용

**검증 방법:**
- `200 <= len(description) <= 400`
- 키워드 포함 여부 확인

---

### AC-007: Notion MCP 페이지 생성
**관련 요구사항:** FR-NOTION-002-007

**Given:** 7개 섹션, 28개 쿼리, AI 생성 설명
**When:** Notion 페이지 생성 수행
**Then:**
- Notion 페이지 URL 반환
- 84개 블록 생성 (H2 7 + 설명 7 + H3 28 + 코드 28 + Callout 14)
- 한글 + SQL 코드 정상 표시

**Notion 구조 검증:**
```
## Section 1: 기초 집계 분석  [H2]
이 섹션에서는...              [Paragraph]

### 그림 5-1: ...              [H3]
```sql                        [Code Block]
-- [그림 5-1 결과]
...
```
> 💡 설명: ...                [Callout]

### 그림 5-2: ...              [H3]
...
```

**검증 방법:**
- Notion API로 페이지 블록 수 확인
- 각 블록 타입 검증 (heading_2, paragraph, heading_3, code, callout)
- 한글 인코딩 정상 (UTF-8)

---

### AC-008: MySQL 쿼리 검증
**관련 요구사항:** FR-NOTION-002-008

**Given:** 28개 변환된 쿼리
**When:** MySQL 검증 수행
**Then:**
- 모든 쿼리 EXPLAIN 성공 (100%)
- 오류 발생 시 로그 기록
- 검증 결과 보고서 포함

**검증 포인트:**
- [x] 성공률 = 100% (28/28)
- [x] 오류 쿼리 목록 = []
- [x] EXPLAIN 결과 저장

**검증 방법:**
- MySQL 컨테이너 연결 성공
- 각 쿼리에 `EXPLAIN {query}` 실행
- 예외 발생하지 않음

---

### AC-009: 재사용 가능 명령 인터페이스
**관련 요구사항:** FR-NOTION-002-009

**Given:** 03~05번 SQL 파일 준비
**When:** 동일한 명령 구조로 실행:
```bash
python generate_tutorial.py \
  --sql mysql/03_xxx/xxx.sql \
  --data data/03_xxx/xxx.csv \
  --notion-page "https://www.notion.so/03-xxx"
```
**Then:**
- 동일한 변환 로직 적용
- 동일한 Notion 형식 생성
- 성공 보고서 출력

**검증 방법:**
- 02~05번 모두 동일 명령으로 실행 성공
- 설정 파일 없이 명령줄 인자만으로 실행

---

### AC-010: 실행 보고서 생성
**관련 요구사항:** FR-NOTION-002-010

**Given:** 전체 파이프라인 완료
**When:** 보고서 생성
**Then:** 다음 정보 포함:
- 입력 파일 정보 (SQL, 데이터)
- 처리 결과 (쿼리 수, 섹션 수, 문법 수정, AI 주석)
- Notion 페이지 URL 및 블록 수
- 품질 검증 결과 (MySQL 성공률)
- 실행 시간

**보고서 예시:**
```
========================================
Notion 교재 자동 생성 완료
========================================

입력 파일:
- SQL: mysql/02_product_review/product_review.sql
- 데이터: data/02_product_review/dataset2.csv

처리 결과:
- 총 쿼리 수: 28개
- 섹션 수: 7개
- 문법 수정: 15건
- AI 주석 생성: 28건

Notion 페이지:
- URL: https://www.notion.so/02-2a0562d8a6ca800687adc7369d455c5b
- 생성된 블록 수: 84개

품질 검증:
- MySQL 실행 성공률: 100% (28/28)

실행 시간: 4분 32초
========================================
```

**검증 방법:**
- 보고서 필수 필드 모두 포함
- JSON 형식 및 텍스트 형식 모두 출력
- 실행 시간 < 5분

---

## 오류 처리 테스트 시나리오

### EB-001: SQL 파싱 실패
**관련 요구사항:** EB-NOTION-002-001

**Given:** 파싱 불가능한 SQL 쿼리 (심각한 문법 오류)
**When:** SQL 변환 시도
**Then:**
- 오류 메시지 로그 기록
- 원본 쿼리 백업 저장
- 해당 쿼리 건너뛰고 나머지 계속 처리
- 최종 보고서에 실패 쿼리 목록 출력

**복구 불가 조건:**
- 전체 쿼리의 50% 이상 파싱 실패 → 전체 프로세스 중단

**검증 방법:**
- 실패 쿼리 목록 확인
- 백업 파일 존재 확인
- 나머지 쿼리는 정상 처리 확인

---

### EB-002: Claude API 오류
**관련 요구사항:** EB-NOTION-002-002

**Given:** Claude API가 응답하지 않음 (timeout 또는 500 error)
**When:** AI 주석 생성 호출
**Then:**
- 3회까지 재시도 (지수 백오프: 1초, 2초, 4초)
- 재시도 실패 시 기본 주석 템플릿 사용:
  ```sql
  -- 목적: 데이터 분석 수행
  -- 결과: 쿼리 결과 출력
  ```
- API 오류를 보고서에 기록

**검증 방법:**
- 재시도 로그 확인 (3회)
- 기본 템플릿 사용 확인
- 보고서에 API 오류 기록 확인

---

### EB-003: Notion MCP 연결 실패
**관련 요구사항:** EB-NOTION-002-003

**Given:** Notion MCP 서버가 실행되지 않음
**When:** Notion 페이지 생성 시도
**Then:**
- 명확한 오류 메시지 출력:
  ```
  오류: Notion MCP 서버에 연결할 수 없습니다.
  해결 방법:
  1. Notion MCP 서버가 실행 중인지 확인
  2. ~/.config/claude/mcp.json 설정 확인
  3. Notion API 토큰 유효성 확인
  ```
- 변환된 SQL과 주석을 로컬 파일로 저장:
  - `output/02_product_review_transformed.sql`
  - `output/02_product_review_report.json`
- 프로세스 종료 (exit code = 1)

**검증 방법:**
- 오류 메시지 출력 확인
- 로컬 파일 저장 확인
- exit code = 1

---

## E2E 테스트 시나리오

### E2E-001: 02번 교재 완전 자동 생성
**목표:** 실제 product_review.sql로 Notion 페이지 생성

**Given:**
- `mysql/02_product_review/product_review.sql` (28개 쿼리)
- `data/02_product_review/dataset2.csv`
- Notion 대상 페이지: https://www.notion.so/02-2a0562d8a6ca800687adc7369d455c5b

**When:**
```bash
python generate_tutorial.py \
  --sql mysql/02_product_review/product_review.sql \
  --data data/02_product_review/dataset2.csv \
  --notion-page "https://www.notion.so/02-2a0562d8a6ca800687adc7369d455c5b"
```

**Then:**
1. **Phase 1 완료:**
   - 28개 쿼리 파싱 성공
   - 소문자 변환 100% 완료
   - 문법 오류 15건 수정
   - 7개 섹션 분류 완료

2. **Phase 2 완료:**
   - 28개 AI 주석 생성
   - 7개 섹션 설명 생성
   - Claude API 호출 < 40회

3. **Phase 3 완료:**
   - Notion 페이지 생성
   - 84개 블록 생성
   - 페이지 URL 반환

4. **Phase 4 완료:**
   - MySQL 검증 100% 성공 (28/28)
   - 보고서 출력

**검증 방법:**
- Notion 페이지 수동 확인:
  - 7개 섹션 존재
  - 28개 쿼리 코드 블록 존재
  - 한글 설명 정상 표시
  - SQL 코드 정상 표시
- 보고서 확인:
  - 성공률 100%
  - 실행 시간 < 5분

---

### E2E-002: 03~05번 재사용 테스트
**목표:** 동일 명령으로 다른 교재 생성 가능 여부 검증

**Given:**
- `mysql/03_xxx/xxx.sql`
- `data/03_xxx/xxx.csv`
- Notion 대상 페이지: https://www.notion.so/03-xxx

**When:**
```bash
python generate_tutorial.py \
  --sql mysql/03_xxx/xxx.sql \
  --data data/03_xxx/xxx.csv \
  --notion-page "https://www.notion.so/03-xxx"
```

**Then:**
- 동일한 4단계 파이프라인 실행
- 성공 보고서 출력
- Notion 페이지 생성 성공

**검증 방법:**
- 03, 04, 05번 모두 동일 명령으로 실행 성공
- 각 페이지의 구조 일관성 확인

---

## 성능 테스트 시나리오

### PERF-001: 실행 시간 검증
**목표:** 28개 쿼리 처리 시간 < 5분

**Given:** 02번 교재 (28개 쿼리)
**When:** 전체 파이프라인 실행
**Then:**
- Phase 1 (SQL 변환): < 30초
- Phase 2 (AI 주석): < 3분 (Claude API 호출 35회)
- Phase 3 (Notion 생성): < 1분 (블록 생성 84회)
- Phase 4 (MySQL 검증): < 30초
- **총 실행 시간: < 5분**

**검증 방법:**
- 각 Phase 시작/종료 시간 로그
- 총 실행 시간 계산

---

### PERF-002: Claude API 호출 최적화
**목표:** API 호출 < 40회

**Given:** 28개 쿼리, 7개 섹션
**When:** AI 주석 생성
**Then:**
- 쿼리 주석: 28회
- 섹션 설명: 7회
- 예비 (재시도 등): < 5회
- **총 호출: < 40회**

**검증 방법:**
- API 호출 카운터 로그
- 총 호출 수 확인

---

## 품질 게이트 (Quality Gates)

모든 수락 기준을 통과하기 위한 최종 검증:

### QG-001: 기능 완성도
- [ ] AC-001 ~ AC-010 모두 통과
- [ ] EB-001 ~ EB-003 오류 처리 검증 완료
- [ ] E2E-001, E2E-002 실제 생성 성공

### QG-002: 성능 기준
- [ ] PERF-001: 실행 시간 < 5분
- [ ] PERF-002: API 호출 < 40회

### QG-003: 품질 기준
- [ ] MySQL 검증 성공률 = 100%
- [ ] AI 주석 형식 검증 통과
- [ ] Notion 페이지 구조 검증 통과
- [ ] 코드 커버리지 > 80%

### QG-004: 문서 완성도
- [ ] 사용자 가이드 작성 완료
- [ ] API 문서 작성 완료
- [ ] 문제 해결 가이드 작성 완료

---

## 테스트 실행 체크리스트

### 단위 테스트
- [ ] `test_sql_parser.py` 통과
- [ ] `test_sql_transformer.py` 통과
- [ ] `test_section_classifier.py` 통과
- [ ] `test_ai_annotator.py` 통과
- [ ] `test_notion_builder.py` 통과
- [ ] `test_mysql_validator.py` 통과

### 통합 테스트
- [ ] `test_pipeline.py` 통과 (4단계 파이프라인)
- [ ] `test_error_handling.py` 통과 (오류 처리)

### E2E 테스트
- [ ] E2E-001: 02번 교재 실제 생성 성공
- [ ] E2E-002: 03번 재사용 테스트 성공

### 성능 테스트
- [ ] PERF-001: 실행 시간 기준 만족
- [ ] PERF-002: API 호출 최적화 기준 만족

---

## 추적성

- **@SPEC:NOTION-002** → 요구사항 정의
- **@PLAN:NOTION-002** → 구현 계획
- **@ACCEPT:NOTION-002** → 이 수락 기준 문서
- **@TEST:NOTION-002** → 테스트 코드 및 결과
- **@CODE:NOTION-002** → 구현 코드
