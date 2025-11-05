---
id: NOTION-002
title: Notion MCP 기반 데이터베이스 교재 자동 생성 시스템
domain: Education
type: System
status: Draft
priority: High
created: 2025-11-05
author: spec-builder
tags:
  - MySQL
  - Notion MCP
  - AI Automation
  - Tutorial Generation
  - Claude API
---

# Notion MCP 기반 데이터베이스 교재 자동 생성 시스템

**@SPEC:NOTION-002**

## SUMMARY

This specification defines a fully automated tutorial generation system that transforms raw SQL files and CSV datasets into structured Notion pages using Notion MCP integration. The system automatically performs SQL syntax normalization (lowercase keywords, quote correction, error fixing), AI-powered comment generation (3-line format with purpose and results), intelligent section classification (28 queries → 7 logical sections), and comprehensive tutorial content creation with step-by-step progression explanations. The entire workflow executes with a single command and is designed for reusability across datasets 02 through 05, ensuring consistency, quality, and scalability across all educational materials.

**핵심 차별점:**
- 완전 자동화: 단일 명령으로 SQL 파일 → Notion 페이지 생성 완료
- AI 기반 주석 생성: Claude API로 각 쿼리 분석하여 교육적 설명 자동 생성
- Notion MCP 통합: mcp__notion__notion-create-pages와 mcp__notion__notion-update-page 활용
- 재사용성: 동일한 명령으로 02~05번 교재 모두 생성 가능

## 환경 (ENVIRONMENT)

**WHEN** SQL 실습 파일과 CSV 데이터셋을 Notion 교재로 자동 변환할 때

**기술 스택:**
- MySQL 8.0 (쿼리 실행 환경)
- Notion MCP Server (mcp__notion__notion-create-pages, mcp__notion__notion-update-page)
- Claude API (주석 및 설명 자동 생성)
- Python 3.11+ (시스템 오케스트레이션)
- Docker Compose (MySQL 컨테이너 환경)

**입력 자원:**
- SQL 파일: `mysql/02_product_review/product_review.sql` (28개 쿼리, 7개 섹션)
- CSV 데이터셋: `data/02_product_review/dataset2.csv` (10개 컬럼)
- 참조 스타일: `mysql/01_car/car.sql` (3줄 주석 형식)
- Notion 대상 페이지: https://www.notion.so/02-2a0562d8a6ca800687adc7369d455c5b

**데이터셋 구조 (dataset2.csv):**
- 10개 컬럼: Age, Rating, Review Text, Department Name, Clothing ID, Division Name, Positive Feedback Count, Recommended IND, Title, Class Name
- 의류 제품 리뷰 데이터 (고객 연령, 평점, 리뷰 텍스트, 부서 정보 등)

**실행 환경:**
- Claude Code 터미널에서 단일 명령 실행
- Notion MCP 서버 활성화 상태
- MySQL 컨테이너 실행 중 (docker-compose up)

## 가정 (ASSUMPTIONS)

**SQL 파일 구조 가정:**
- 모든 쿼리에 그림 번호 주석 존재 (`-- [그림 5-1 결과]`)
- 쿼리는 논리적으로 섹션별 그룹화 가능 (기초 → 고급)
- 그림 번호는 학습 진행 순서와 일치
- 쿼리 실행 가능 (문법 오류는 시스템이 자동 수정)

**문법 오류 패턴 가정:**
- 컬럼명에 작은따옴표 사용 (`'DIVISION NAME'` → `"DIVISION NAME"` 필요)
- LIMIT 절 위치 오류 (WHERE 조건 중간에 삽입)
- 테이블명 불일치 (DATA.DATASET2 vs MYDATA.DATASET2)
- 예약어 대소문자 혼용

**AI 주석 생성 가정:**
- Claude API를 통해 각 쿼리의 목적과 결과 분석 가능
- 3줄 형식: 1) 그림 번호, 2) 목적, 3) 결과 설명
- 교육적 맥락 이해 (초급자 대상 설명 스타일)

**Notion MCP 통합 가정:**
- mcp__notion__notion-create-pages로 페이지 생성 가능
- mcp__notion__notion-update-page로 콘텐츠 추가 가능
- 코드 블록, 헤더, 리스트, 토글 블록 모두 지원
- 한글 + SQL 코드 동시 표시 가능

**재사용성 가정:**
- 03~05번 SQL 파일도 유사한 구조 (그림 번호 + 섹션 구조)
- 동일한 명령으로 반복 작업 가능
- 데이터셋 구조가 달라도 쿼리 분석 로직 동일 적용

## 요구사항 (REQUIREMENTS)

### FR-NOTION-002-001: 단일 명령 실행 (Ubiquitous)
**THE SYSTEM SHALL** 다음 형식의 단일 명령으로 전체 워크플로우 실행:
```bash
python generate_tutorial.py \
  --sql mysql/02_product_review/product_review.sql \
  --data data/02_product_review/dataset2.csv \
  --notion-page "https://www.notion.so/02-2a0562d8a6ca800687adc7369d455c5b" \
  --reference mysql/01_car/car.sql
```

**실행 결과:**
- SQL 파일 분석 완료
- 문법 오류 자동 수정 완료
- AI 주석 자동 생성 완료
- Notion 페이지 생성 완료
- 검증 보고서 출력

**성공 기준:**
- 사용자 개입 없이 완전 자동 실행
- 오류 발생 시 명확한 오류 메시지 출력
- 실행 시간 < 5분 (28개 쿼리 기준)

### FR-NOTION-002-002: SQL 소문자 자동 변환 (Ubiquitous)
**THE SYSTEM SHALL** SQL 파일을 읽을 때 다음 요소를 자동으로 소문자로 변환:
- SQL 예약어: SELECT, FROM, WHERE, GROUP BY, ORDER BY, CASE WHEN, LIMIT, DISTINCT, AS 등
- 함수명: AVG, SUM, COUNT, FLOOR, ROW_NUMBER, LIKE, PARTITION BY, OVER 등
- 테이블명: MYDATA.DATASET2 → mydata.dataset2

**예외 규칙:**
- 컬럼명은 원본 유지 (DIVISION NAME, DEPARTMENT NAME, AGE 등)
- 문자열 상수는 원본 유지 ('SIZE%', 'Trend', 'fit' 등)
- 주석은 원본 유지

**구현 방법:**
- SQL 파서(sqlparse 라이브러리) 사용
- AST(Abstract Syntax Tree) 기반 변환
- 토큰별 타입 식별 후 선택적 변환

### FR-NOTION-002-003: 문법 오류 자동 수정 (Ubiquitous)
**THE SYSTEM SHALL** SQL 쿼리에서 다음 문법 오류를 자동 탐지 및 수정:

**1. 컬럼명 따옴표 오류:**
- 잘못됨: `'DIVISION NAME'`
- 수정됨: `"DIVISION NAME"` 또는 \`DIVISION NAME\`

**2. LIMIT 절 위치 오류:**
- 잘못됨: `WHERE ... AND ... LIMIT 10`
- 수정됨: WHERE 절 종료 후 별도 줄에 `LIMIT 10` 배치

**3. 테이블명 불일치:**
- 잘못됨: `DATA.DATASET2`
- 수정됨: `MYDATA.DATASET2`

**검증:**
- 수정된 쿼리를 MySQL 컨테이너에서 EXPLAIN 실행
- 오류 발생 시 수정 로그 출력

### FR-NOTION-002-004: AI 기반 3줄 주석 자동 생성 (Ubiquitous)
**THE SYSTEM SHALL** 각 쿼리에 대해 Claude API를 호출하여 3줄 주석 자동 생성:

**주석 형식:**
```sql
-- [그림 5-1 결과]  (원본 유지)
-- 목적: DIVISION NAME별 평균 평점 계산하여 부서 그룹 성과 비교
-- 결과: 각 부서 그룹의 평균 평점을 높은 순으로 정렬하여 출력 (소수점 2자리)
```

**AI 프롬프트 구조:**
```
다음 SQL 쿼리를 분석하여 교육적 설명을 생성하세요:

쿼리: {sql_query}
데이터셋: {dataset_columns}
대상: 데이터 분석 입문자

출력 형식:
- 목적: {쿼리가 수행하는 분석 내용, 50자 이내}
- 결과: {출력 데이터의 특징과 의미, 80자 이내}
```

**품질 기준:**
- 목적은 분석 의도를 명확히 설명
- 결과는 출력 컬럼과 정렬 방식 포함
- 초급자가 이해 가능한 용어 사용

### FR-NOTION-002-005: 섹션 자동 분류 (Ubiquitous)
**THE SYSTEM SHALL** 28개 쿼리를 그림 번호 범위 기반으로 7개 섹션으로 자동 분류:

**섹션 분류 알고리즘:**
1. 그림 번호 추출: `-- [그림 5-1 결과]` → 5-1
2. 번호 범위 그룹화:
   - Section 1: 5-1 ~ 5-3 (3개)
   - Section 2: 5-4 ~ 5-8 (5개)
   - Section 3: 5-9 ~ 138페이지 (5개)
   - Section 4: 5-15 ~ 5-17 (3개)
   - Section 5: 표 5-2 ~ 5-20 (4개)
   - Section 6: 5-21 ~ 5-23 (2개)
   - Section 7: 5-25 ~ 151페이지 (3개)
3. 섹션 제목 자동 생성: AI로 핵심 개념 추출

**섹션 메타데이터:**
```json
{
  "section_id": 1,
  "title": "기초 집계 분석",
  "figure_range": "5-1 ~ 5-3",
  "query_count": 3,
  "concepts": ["AVG", "GROUP BY", "WHERE"],
  "description": "부서별 평균 평점 계산 및 필터링 기초"
}
```

### FR-NOTION-002-006: AI 기반 교재 설명 자동 생성 (Ubiquitous)
**THE SYSTEM SHALL** 각 섹션에 대해 단계별 진화 과정을 설명하는 교재 텍스트 생성:

**설명 생성 프롬프트:**
```
섹션 정보:
- 제목: {section_title}
- 쿼리 개수: {query_count}
- 핵심 개념: {concepts}
- 쿼리 목록: {query_summaries}

다음을 설명하세요:
1. 이 섹션의 학습 목표 (2-3문장)
2. 이전 섹션과의 연결점 (1문장)
3. 각 쿼리의 진화 과정 (쿼리별 1문장)
4. 실무 활용 예시 (1-2문장)

대상: 데이터 분석 입문자
스타일: 친절하고 구체적
```

**출력 위치:**
- 각 섹션 헤더 바로 아래에 배치
- Notion 텍스트 블록 형식

### FR-NOTION-002-007: Notion MCP 페이지 자동 생성 (Ubiquitous)
**THE SYSTEM SHALL** Notion MCP를 사용하여 다음 구조로 페이지 자동 생성:

**Phase 1: 페이지 구조 생성**
```python
mcp__notion__notion-create-pages(
    parent_page_id="2a0562d8a6ca800687adc7369d455c5b",
    children=[
        {"type": "heading_2", "content": "Section 1: 기초 집계 분석"},
        {"type": "paragraph", "content": "섹션 설명 텍스트"},
        {"type": "heading_3", "content": "그림 5-1: DIVISION NAME별 평균 평점"},
        {"type": "code", "language": "sql", "content": "변환된 SQL 쿼리"},
        ...
    ]
)
```

**Phase 2: 콘텐츠 추가**
- 각 섹션을 H2 헤더로 생성
- 섹션 설명을 일반 텍스트로 추가
- 각 쿼리를 H3 헤더 + 코드 블록으로 추가
- 쿼리 설명을 토글 블록으로 추가 (선택적 확장)

**구조 예시:**
```
## Section 1: 기초 집계 분석

이 섹션에서는 AVG 함수와 GROUP BY를 사용한 기초 집계를 학습합니다...

### 그림 5-1: DIVISION NAME별 평균 평점

```sql
-- [그림 5-1 결과]
-- 목적: DIVISION NAME별 평균 평점 계산
-- 결과: 각 부서 그룹의 평균 평점을 내림차순 출력
select "DIVISION NAME",
       avg(RATING) AVG_RATE
from mydata.dataset2
group by 1
order by 2 desc;
```

> **💡 설명**: AVG 함수는 그룹별 평균값을 계산합니다. GROUP BY 1은 첫 번째 컬럼(DIVISION NAME)으로 그룹화를 의미합니다.
```

### FR-NOTION-002-008: MySQL 쿼리 검증 (Event-driven)
**WHEN** 모든 쿼리 변환이 완료되었을 때
**THE SYSTEM SHALL** MySQL 컨테이너에서 각 쿼리 실행 가능 여부 검증:

**검증 단계:**
1. Docker Compose MySQL 컨테이너 연결
2. 각 쿼리에 EXPLAIN 실행
3. 오류 발생 시 로그 기록
4. 성공률 계산 (28개 중 성공한 쿼리 수)

**성공 기준:**
- 모든 쿼리 EXPLAIN 성공 (100%)
- 오류 발생 시 수정 제안 출력

### FR-NOTION-002-009: 재사용 가능 명령 인터페이스 (Ubiquitous)
**THE SYSTEM SHALL** 동일한 명령 구조로 03~05번 교재 생성 지원:

**03번 교재 생성 예시:**
```bash
python generate_tutorial.py \
  --sql mysql/03_xxx/xxx.sql \
  --data data/03_xxx/xxx.csv \
  --notion-page "https://www.notion.so/03-xxx"
```

**재사용 보장:**
- SQL 파일 경로만 변경
- 동일한 변환 로직 적용
- 동일한 Notion 형식 생성
- 설정 파일 없이 명령줄 인자만으로 실행

### FR-NOTION-002-010: 실행 보고서 자동 생성 (Ubiquitous)
**THE SYSTEM SHALL** 실행 완료 시 다음 정보를 포함한 보고서 출력:

**보고서 구조:**
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
- 생성된 블록 수: 84개 (헤더 7 + 쿼리 28 + 설명 28 + 코드 21)

품질 검증:
- MySQL 실행 성공률: 100% (28/28)
- 주석 형식 검증: 통과
- 섹션 구조 검증: 통과

실행 시간: 4분 32초
========================================
```

### EB-NOTION-002-001: 문법 오류 복구 (Unwanted Behaviors)
**IF** SQL 파서가 쿼리를 파싱하지 못할 때
**THE SYSTEM SHALL** 다음 복구 절차 수행:
1. 오류 메시지 로그 기록
2. 원본 쿼리 보존 (백업)
3. 수동 검토 필요 표시
4. 해당 쿼리 건너뛰고 나머지 계속 처리
5. 최종 보고서에 실패 쿼리 목록 출력

**복구 불가 조건:**
- 전체 쿼리의 50% 이상 파싱 실패 → 전체 프로세스 중단

### EB-NOTION-002-002: Claude API 오류 처리 (Unwanted Behaviors)
**IF** Claude API 호출이 실패할 때
**THE SYSTEM SHALL**:
1. 3회까지 재시도 (지수 백오프)
2. 재시도 실패 시 기본 주석 템플릿 사용:
   ```sql
   -- 목적: 데이터 분석 수행
   -- 결과: 쿼리 결과 출력
   ```
3. API 오류를 보고서에 기록

**기본 템플릿 조건:**
- API 응답 시간 > 30초
- API 오류 코드: 429 (Rate Limit), 500 (Server Error)

### EB-NOTION-002-003: Notion MCP 연결 실패 (Unwanted Behaviors)
**IF** Notion MCP 서버에 연결할 수 없을 때
**THE SYSTEM SHALL**:
1. 명확한 오류 메시지 출력:
   ```
   오류: Notion MCP 서버에 연결할 수 없습니다.
   해결 방법:
   1. Notion MCP 서버가 실행 중인지 확인
   2. ~/.config/claude/mcp.json 설정 확인
   3. Notion API 토큰 유효성 확인
   ```
2. 변환된 SQL과 주석을 로컬 파일로 저장:
   - `output/02_product_review_transformed.sql`
   - `output/02_product_review_report.json`
3. 프로세스 종료 (Notion 생성 불가)

## 명세 (SPECIFICATIONS)

### SPEC-NOTION-002-01: 시스템 아키텍처

**4-Phase 파이프라인:**

```
Phase 1: SQL 분석 및 변환
├─ SQL 파서(sqlparse) → AST 생성
├─ 토큰별 타입 분류 (예약어/함수/컬럼/상수)
├─ 소문자 변환 (예약어, 함수, 테이블명)
├─ 문법 오류 탐지 및 수정
└─ 출력: transformed_queries[]

Phase 2: AI 주석 및 설명 생성
├─ Claude API 호출 (쿼리당 1회)
├─ 3줄 주석 생성 (목적 + 결과)
├─ 섹션별 교재 설명 생성
└─ 출력: annotated_queries[], section_descriptions[]

Phase 3: Notion 페이지 생성
├─ Notion MCP 연결
├─ mcp__notion__notion-create-pages 호출
├─ 7개 섹션 생성 (H2 헤더)
├─ 28개 쿼리 블록 생성 (H3 + 코드)
└─ 출력: notion_page_url

Phase 4: 검증 및 보고서
├─ MySQL 컨테이너 연결
├─ 각 쿼리 EXPLAIN 실행
├─ 성공률 계산
└─ 출력: validation_report.json
```

**데이터 흐름:**
```
product_review.sql → SQL Parser → Transformer → Claude API → Notion MCP → Notion Page
                                        ↓
                                  MySQL Validator
                                        ↓
                                   Final Report
```

### SPEC-NOTION-002-02: SQL 변환 예시

**입력 (원본):**
```sql
-- [그림 5-1 결과]
SELECT 'DIVISION NAME',
       AVG(RATING) AVG_RATE
FROM DATA.DATASET2
GROUP BY 1
ORDER BY 2 DESC;
```

**출력 (변환됨):**
```sql
-- [그림 5-1 결과]
-- 목적: DIVISION NAME별 평균 평점 계산하여 부서 그룹 성과 비교
-- 결과: 각 부서 그룹의 평균 평점을 높은 순으로 정렬하여 출력
select "DIVISION NAME",
       avg(RATING) AVG_RATE
from mydata.dataset2
group by 1
order by 2 desc;
```

**변경 사항:**
- SELECT → select, FROM → from, GROUP BY → group by, ORDER BY → order by, DESC → desc
- AVG → avg
- 'DIVISION NAME' → "DIVISION NAME"
- DATA.DATASET2 → mydata.dataset2
- 3줄 주석 추가 (AI 생성)

### SPEC-NOTION-002-03: 섹션별 쿼리 매핑

| Section | 제목 | 그림 번호 범위 | 쿼리 수 | 핵심 개념 | AI 설명 생성 |
|---------|------|---------------|--------|----------|------------|
| 1 | 기초 집계 분석 | 5-1 ~ 5-3 | 3 | AVG, GROUP BY, WHERE | ✅ |
| 2 | 연령 그룹화 | 5-4 ~ 5-8 | 5 | CASE WHEN, FLOOR | ✅ |
| 3 | 상품별 평점 분석 | 5-9 ~ 138p | 5 | ROW_NUMBER, 서브쿼리 | ✅ |
| 4 | 연령-부서 교차 분석 | 5-15 ~ 5-17 | 3 | 다차원 GROUP BY | ✅ |
| 5 | 텍스트 마이닝 기초 | 표 5-2 ~ 5-20 | 4 | LIKE, CASE WHEN | ✅ |
| 6 | 다차원 텍스트 분석 | 5-21 ~ 5-23 | 2 | 교차 분석, 비율 | ✅ |
| 7 | 상품별 종합 분석 | 5-25 ~ 151p | 3 | CREATE TABLE | ✅ |

**총 쿼리:** 28개
**총 AI 호출:** 28 (주석) + 7 (섹션 설명) = 35회

### SPEC-NOTION-002-04: Notion 페이지 블록 구조

**생성되는 블록 타입:**
```json
{
  "blocks": [
    {"type": "heading_2", "content": "Section 1: 기초 집계 분석"},
    {"type": "paragraph", "content": "AI 생성 섹션 설명"},
    {"type": "heading_3", "content": "그림 5-1: DIVISION NAME별 평균 평점"},
    {"type": "code", "language": "sql", "content": "변환된 SQL 쿼리"},
    {"type": "callout", "icon": "💡", "content": "쿼리 설명 (선택적)"},
    ...
  ],
  "total_blocks": 84
}
```

**블록 계산:**
- H2 헤더: 7개 (섹션)
- 섹션 설명: 7개 (일반 텍스트)
- H3 헤더: 28개 (쿼리 제목)
- 코드 블록: 28개 (SQL 쿼리)
- Callout 블록: 14개 (주요 쿼리 설명, 선택적)
- **총 84개**

### SPEC-NOTION-002-05: 명령 인터페이스 상세

**필수 인자:**
```bash
--sql PATH           # SQL 파일 경로 (필수)
--data PATH          # CSV 데이터셋 경로 (필수)
--notion-page URL    # Notion 대상 페이지 URL (필수)
```

**선택적 인자:**
```bash
--reference PATH     # 참조 스타일 SQL 파일 (기본: mysql/01_car/car.sql)
--validate           # MySQL 검증 활성화 (기본: True)
--verbose            # 상세 로그 출력 (기본: False)
--output-dir DIR     # 중간 파일 출력 디렉토리 (기본: output/)
```

**예시 1: 기본 실행**
```bash
python generate_tutorial.py \
  --sql mysql/02_product_review/product_review.sql \
  --data data/02_product_review/dataset2.csv \
  --notion-page "https://www.notion.so/02-2a0562d8a6ca800687adc7369d455c5b"
```

**예시 2: 검증 없이 실행 (빠른 테스트)**
```bash
python generate_tutorial.py \
  --sql mysql/02_product_review/product_review.sql \
  --data data/02_product_review/dataset2.csv \
  --notion-page "https://www.notion.so/02-2a0562d8a6ca800687adc7369d455c5b" \
  --validate=false
```

**예시 3: 상세 로그 + 중간 파일 저장**
```bash
python generate_tutorial.py \
  --sql mysql/02_product_review/product_review.sql \
  --data data/02_product_review/dataset2.csv \
  --notion-page "https://www.notion.so/02-2a0562d8a6ca800687adc7369d455c5b" \
  --verbose \
  --output-dir debug/
```

### SPEC-NOTION-002-06: 품질 체크리스트

**자동 검증 항목:**
- [ ] 모든 SQL 예약어가 소문자로 변환됨
- [ ] 모든 쿼리에 3줄 주석이 생성됨
- [ ] 컬럼명 따옴표 오류 수정됨 (' → ")
- [ ] LIMIT 위치 오류 수정됨
- [ ] 테이블명 불일치 수정됨 (DATA → MYDATA)
- [ ] 7개 섹션이 자동 분류됨
- [ ] 28개 쿼리가 MySQL EXPLAIN 통과
- [ ] Notion 페이지 URL 생성됨

**수동 확인 항목:**
- [ ] AI 생성 주석의 교육적 적절성
- [ ] 섹션 설명의 논리적 흐름
- [ ] Notion 페이지 레이아웃 확인
- [ ] 03~05번 교재에 동일 명령 재사용 가능 여부

## 제약사항 (CONSTRAINTS)

### 기술 제약사항
- MySQL 8.0 문법 준수 (윈도우 함수, CTE 지원)
- UTF-8 인코딩 필수 (한글 주석)
- Notion MCP 서버 필수 (mcp__notion 네임스페이스)
- Claude API 키 필수 (주석 생성용)
- Python 3.11+ 환경 (타입 힌팅 및 async 지원)

### 성능 제약사항
- 전체 실행 시간 < 5분 (28개 쿼리 기준)
- Claude API 호출 < 40회 (주석 28 + 섹션 설명 7 + 예비 5)
- Notion MCP 호출 < 100회 (블록 생성 84 + 페이지 메타데이터)
- MySQL 검증 시간 < 1분 (EXPLAIN 28회)

### 품질 제약사항
- AI 생성 주석 길이: 목적 < 50자, 결과 < 80자
- 섹션 설명 길이: 200~400자
- 쿼리 파싱 성공률 > 95% (28개 중 최소 27개)
- MySQL 검증 성공률 = 100% (모든 쿼리 실행 가능)

### 재사용성 제약사항
- SQL 파일 형식: UTF-8 인코딩, LF 줄바꿈
- 그림 번호 주석 필수: `-- [그림 X-Y 결과]` 형식
- CSV 데이터셋 필수 (컬럼 메타데이터 추출용)
- Notion 대상 페이지 사전 생성 필요

## 추적성 (TRACEABILITY)

- **@SPEC:NOTION-002** → 이 명세서
- **@PLAN:NOTION-002** → 구현 계획 및 아키텍처 설계
- **@ACCEPT:NOTION-002** → 수락 기준 및 테스트 시나리오
- **@CODE:NOTION-002** → generate_tutorial.py 및 관련 모듈
- **@TEST:NOTION-002** → 단위 테스트, 통합 테스트, E2E 테스트
- **@DOC:NOTION-002** → 사용자 가이드 및 API 문서

**연관 SPEC:**
- **@SPEC:NOTION-001** → 수동 워크플로우 (이 SPEC의 자동화 대상)
- **@SPEC:SQL-001** → MySQL 쿼리 학습 가이드

**외부 의존성:**
- Notion MCP: mcp__notion__notion-create-pages, mcp__notion__notion-update-page
- Claude API: 주석 및 설명 생성
- MySQL 8.0: 쿼리 검증

## 변경 이력 (HISTORY)

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| 1.0 | 2025-11-05 | spec-builder | 초안 작성 - Notion MCP 기반 완전 자동화 시스템 정의 |
