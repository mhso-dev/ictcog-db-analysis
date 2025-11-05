---
id: NOTION-002
title: Notion MCP 기반 교재 자동 생성 시스템 구현 계획
type: Implementation Plan
status: Draft
created: 2025-11-05
author: spec-builder
---

# Notion MCP 기반 교재 자동 생성 시스템 구현 계획

**@PLAN:NOTION-002**

## 개요

이 문서는 **@SPEC:NOTION-002**의 구현 계획을 정의합니다. 완전 자동화된 Notion 교재 생성 시스템을 4단계 파이프라인으로 구축하며, SQL 분석, AI 주석 생성, Notion MCP 통합, 검증의 순서로 진행합니다.

**구현 목표:**
- 단일 명령으로 SQL 파일 → Notion 페이지 자동 생성
- 28개 쿼리 처리 시간 < 5분
- 03~05번 교재에 동일 명령 재사용 가능
- 품질 검증 자동화 (MySQL EXPLAIN 통과율 100%)

## 마일스톤

### Milestone 1: 프로젝트 구조 및 환경 설정
**우선순위:** High
**의존성:** 없음

**목표:**
- Python 프로젝트 디렉토리 구조 생성
- 필요한 라이브러리 설치 (sqlparse, anthropic, notion-client)
- 환경 변수 설정 (ANTHROPIC_API_KEY, NOTION_TOKEN)
- Notion MCP 연결 테스트

**산출물:**
- `generate_tutorial.py` (진입점)
- `requirements.txt`
- `config.py` (환경 설정)
- `.env.example`

**검증 기준:**
- `python generate_tutorial.py --help` 실행 성공
- Notion MCP 서버 연결 성공

---

### Milestone 2: SQL 분석 및 변환 엔진 구현
**우선순위:** High
**의존성:** Milestone 1

**목표:**
- SQL 파서를 사용한 쿼리 추출
- AST 기반 예약어/함수 소문자 변환
- 문법 오류 자동 수정 (따옴표, LIMIT 위치, 테이블명)
- 그림 번호 추출 및 섹션 자동 분류

**산출물:**
- `sql_parser.py` (쿼리 파싱 및 변환)
- `sql_transformer.py` (소문자 변환 및 오류 수정)
- `section_classifier.py` (섹션 자동 분류)

**핵심 로직:**
```python
class SQLTransformer:
    def parse_sql_file(self, filepath: str) -> List[Query]:
        """SQL 파일에서 쿼리 추출"""
        pass

    def lowercase_keywords(self, query: str) -> str:
        """예약어, 함수, 테이블명 소문자 변환"""
        pass

    def fix_syntax_errors(self, query: str) -> str:
        """컬럼명 따옴표, LIMIT 위치, 테이블명 수정"""
        pass

    def extract_figure_number(self, query: str) -> str:
        """그림 번호 추출: [그림 5-1 결과] → 5-1"""
        pass
```

**검증 기준:**
- 28개 쿼리 모두 파싱 성공
- 소문자 변환 정확도 100%
- 문법 오류 15건 모두 수정
- 7개 섹션 자동 분류 성공

---

### Milestone 3: AI 주석 및 설명 생성 엔진 구현
**우선순위:** High
**의존성:** Milestone 2

**목표:**
- Claude API 연동
- 3줄 주석 자동 생성 (목적 + 결과)
- 섹션별 교재 설명 생성 (단계별 진화 과정)
- API 오류 처리 및 재시도 로직

**산출물:**
- `ai_annotator.py` (Claude API 연동)
- `prompts.py` (AI 프롬프트 템플릿)

**핵심 로직:**
```python
class AIAnnotator:
    def __init__(self, api_key: str):
        self.client = anthropic.Anthropic(api_key=api_key)

    def generate_query_comment(self, query: str, dataset_info: dict) -> dict:
        """
        쿼리 분석하여 3줄 주석 생성

        Returns:
            {
                "purpose": "DIVISION NAME별 평균 평점 계산...",
                "result": "각 부서 그룹의 평균 평점을 내림차순..."
            }
        """
        prompt = f"""다음 SQL 쿼리를 분석하여 교육적 설명을 생성하세요:

쿼리: {query}
데이터셋 컬럼: {dataset_info['columns']}
대상: 데이터 분석 입문자

출력 형식 (JSON):
{{
  "purpose": "쿼리가 수행하는 분석 내용 (50자 이내)",
  "result": "출력 데이터의 특징과 의미 (80자 이내)"
}}
"""
        response = self.client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=500,
            messages=[{"role": "user", "content": prompt}]
        )
        return json.loads(response.content[0].text)

    def generate_section_description(self, section: Section) -> str:
        """섹션별 교재 설명 생성"""
        pass
```

**프롬프트 구조:**
```python
QUERY_COMMENT_PROMPT = """다음 SQL 쿼리를 분석하여 교육적 설명을 생성하세요:

쿼리: {query}
데이터셋: {dataset_columns}
대상: 데이터 분석 입문자

출력 형식:
- 목적: {쿼리가 수행하는 분석 내용, 50자 이내}
- 결과: {출력 데이터의 특징과 의미, 80자 이내}
"""

SECTION_DESCRIPTION_PROMPT = """섹션 정보:
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
"""
```

**검증 기준:**
- 28개 쿼리 주석 생성 성공 (목적 + 결과)
- 7개 섹션 설명 생성 성공
- API 호출 실패 시 재시도 로직 작동
- 총 API 호출 < 40회

---

### Milestone 4: Notion MCP 통합 구현
**우선순위:** High
**의존성:** Milestone 3

**목표:**
- Notion MCP를 사용한 페이지 생성
- 7개 섹션 헤더 생성 (H2)
- 28개 쿼리 블록 생성 (H3 + 코드)
- 섹션 설명 및 쿼리 설명 추가

**산출물:**
- `notion_builder.py` (Notion MCP 연동)

**핵심 로직:**
```python
class NotionBuilder:
    def __init__(self, mcp_client):
        self.mcp = mcp_client

    def create_tutorial_page(self, parent_page_id: str, sections: List[Section]) -> str:
        """
        Notion 페이지 생성

        Returns:
            Notion 페이지 URL
        """
        blocks = []

        for section in sections:
            # Section 헤더 (H2)
            blocks.append({
                "type": "heading_2",
                "content": f"Section {section.id}: {section.title}"
            })

            # Section 설명
            blocks.append({
                "type": "paragraph",
                "content": section.description
            })

            # 각 쿼리 블록
            for query in section.queries:
                # 쿼리 제목 (H3)
                blocks.append({
                    "type": "heading_3",
                    "content": f"{query.figure_number}: {query.title}"
                })

                # SQL 코드 블록
                sql_with_comment = f"""-- {query.figure_number}
-- 목적: {query.comment['purpose']}
-- 결과: {query.comment['result']}
{query.transformed_sql}"""

                blocks.append({
                    "type": "code",
                    "language": "sql",
                    "content": sql_with_comment
                })

                # 쿼리 설명 (Callout, 선택적)
                if query.explanation:
                    blocks.append({
                        "type": "callout",
                        "icon": "💡",
                        "content": query.explanation
                    })

        # Notion MCP 호출
        page_url = self.mcp.create_pages(
            parent_page_id=parent_page_id,
            children=blocks
        )

        return page_url
```

**Notion 블록 구조:**
```
H2: Section 1: 기초 집계 분석
  Paragraph: AI 생성 섹션 설명
  H3: 그림 5-1: DIVISION NAME별 평균 평점
    Code(sql): 변환된 SQL 쿼리 (주석 포함)
    Callout: 쿼리 설명 (선택적)
  H3: 그림 5-2: DEPARTMENT NAME별 평균 평점
    Code(sql): ...
  ...
H2: Section 2: 연령 그룹화
  ...
```

**검증 기준:**
- Notion 페이지 생성 성공
- 84개 블록 생성 (H2 7 + 설명 7 + H3 28 + 코드 28 + Callout 14)
- 페이지 URL 반환 성공
- 한글 + SQL 코드 정상 표시

---

### Milestone 5: MySQL 검증 및 보고서 생성
**우선순위:** Medium
**의존성:** Milestone 2

**목표:**
- MySQL 컨테이너 연결
- 각 쿼리 EXPLAIN 실행
- 성공률 계산
- 실행 보고서 생성

**산출물:**
- `mysql_validator.py` (쿼리 검증)
- `report_generator.py` (보고서 생성)

**핵심 로직:**
```python
class MySQLValidator:
    def __init__(self, host: str, port: int, user: str, password: str, database: str):
        self.connection = mysql.connector.connect(
            host=host, port=port, user=user, password=password, database=database
        )

    def validate_query(self, query: str) -> dict:
        """
        쿼리 EXPLAIN 실행

        Returns:
            {
                "success": True/False,
                "error": None or error_message,
                "explain": EXPLAIN 결과
            }
        """
        cursor = self.connection.cursor()
        try:
            cursor.execute(f"EXPLAIN {query}")
            explain_result = cursor.fetchall()
            return {"success": True, "error": None, "explain": explain_result}
        except Exception as e:
            return {"success": False, "error": str(e), "explain": None}
        finally:
            cursor.close()

    def validate_all_queries(self, queries: List[Query]) -> dict:
        """
        모든 쿼리 검증

        Returns:
            {
                "total": 28,
                "success": 28,
                "failed": 0,
                "success_rate": 1.0,
                "failed_queries": []
            }
        """
        pass
```

**보고서 형식:**
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
- 주석 형식 검증: 통과
- 섹션 구조 검증: 통과

실행 시간: 4분 32초
========================================
```

**검증 기준:**
- MySQL 연결 성공
- 모든 쿼리 EXPLAIN 통과 (100%)
- 보고서 JSON 및 텍스트 형식 출력

---

### Milestone 6: 명령줄 인터페이스 및 오케스트레이션
**우선순위:** High
**의존성:** Milestone 4, 5

**목표:**
- argparse 기반 CLI 구현
- 4단계 파이프라인 오케스트레이션
- 오류 처리 및 복구 로직
- 진행 상황 표시

**산출물:**
- `generate_tutorial.py` (진입점 및 오케스트레이터)
- `pipeline.py` (4단계 파이프라인)

**핵심 로직:**
```python
class TutorialPipeline:
    def __init__(self, config: Config):
        self.config = config
        self.transformer = SQLTransformer()
        self.annotator = AIAnnotator(config.anthropic_api_key)
        self.builder = NotionBuilder(config.mcp_client)
        self.validator = MySQLValidator(**config.mysql_config)

    def run(self, sql_file: str, data_file: str, notion_page: str) -> dict:
        """
        4단계 파이프라인 실행

        Phase 1: SQL 분석 및 변환
        Phase 2: AI 주석 및 설명 생성
        Phase 3: Notion 페이지 생성
        Phase 4: 검증 및 보고서

        Returns:
            {
                "success": True/False,
                "notion_url": "...",
                "report": {...}
            }
        """
        print("Phase 1: SQL 분석 및 변환...")
        queries = self.transformer.parse_sql_file(sql_file)
        transformed_queries = [self.transformer.transform(q) for q in queries]
        sections = self.transformer.classify_sections(transformed_queries)

        print("Phase 2: AI 주석 및 설명 생성...")
        dataset_info = self._load_dataset_info(data_file)
        for query in transformed_queries:
            query.comment = self.annotator.generate_query_comment(
                query.sql, dataset_info
            )
        for section in sections:
            section.description = self.annotator.generate_section_description(section)

        print("Phase 3: Notion 페이지 생성...")
        notion_url = self.builder.create_tutorial_page(notion_page, sections)

        print("Phase 4: 검증 및 보고서 생성...")
        validation = self.validator.validate_all_queries(transformed_queries)
        report = self._generate_report(
            sql_file, data_file, notion_url, transformed_queries, validation
        )

        return {
            "success": validation["success_rate"] == 1.0,
            "notion_url": notion_url,
            "report": report
        }
```

**CLI 인터페이스:**
```python
def main():
    parser = argparse.ArgumentParser(
        description="Notion MCP 기반 데이터베이스 교재 자동 생성"
    )
    parser.add_argument("--sql", required=True, help="SQL 파일 경로")
    parser.add_argument("--data", required=True, help="CSV 데이터셋 경로")
    parser.add_argument("--notion-page", required=True, help="Notion 대상 페이지 URL")
    parser.add_argument("--reference", default="mysql/01_car/car.sql",
                        help="참조 스타일 SQL 파일")
    parser.add_argument("--validate", type=bool, default=True,
                        help="MySQL 검증 활성화")
    parser.add_argument("--verbose", action="store_true", help="상세 로그 출력")
    parser.add_argument("--output-dir", default="output/",
                        help="중간 파일 출력 디렉토리")

    args = parser.parse_args()

    config = Config.from_env()
    pipeline = TutorialPipeline(config)

    result = pipeline.run(args.sql, args.data, args.notion_page)

    if result["success"]:
        print(f"\n✅ 성공: {result['notion_url']}")
    else:
        print(f"\n❌ 실패: {result['report']['errors']}")
```

**검증 기준:**
- `python generate_tutorial.py --help` 출력 성공
- 필수 인자 누락 시 오류 메시지 출력
- 전체 파이프라인 < 5분 실행
- 오류 발생 시 명확한 오류 메시지

---

### Milestone 7: 테스트 및 문서화
**우선순위:** Medium
**의존성:** Milestone 6

**목표:**
- 단위 테스트 작성 (각 모듈)
- 통합 테스트 작성 (파이프라인)
- E2E 테스트 작성 (실제 Notion 생성)
- 사용자 가이드 작성

**산출물:**
- `tests/test_sql_transformer.py`
- `tests/test_ai_annotator.py`
- `tests/test_notion_builder.py`
- `tests/test_pipeline.py`
- `docs/USER_GUIDE.md`

**테스트 커버리지 목표:**
- 단위 테스트 커버리지 > 80%
- 통합 테스트: 4단계 파이프라인 모두 검증
- E2E 테스트: 02번 교재 실제 생성 성공

**검증 기준:**
- 모든 테스트 통과
- 사용자 가이드 완성 (설치, 사용법, 문제 해결)

---

## 기술 스택

### 핵심 라이브러리
```python
# requirements.txt
sqlparse==0.4.4          # SQL 파싱 및 변환
anthropic==0.18.0        # Claude API 연동
mysql-connector-python==8.3.0  # MySQL 검증
python-dotenv==1.0.0     # 환경 변수 관리
```

### Notion MCP 통합
```python
# Notion MCP는 Claude Code 내장 MCP 서버 사용
# mcp__notion__notion-create-pages
# mcp__notion__notion-update-page
```

### 환경 변수
```bash
# .env
ANTHROPIC_API_KEY=sk-ant-...
NOTION_TOKEN=secret_...
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=1234
MYSQL_DATABASE=mydata
```

---

## 리스크 및 대응 방안

### 리스크 1: SQL 파싱 실패
**발생 가능성:** Medium
**영향도:** High

**대응 방안:**
- sqlparse 라이브러리 대신 정규표현식 기반 백업 파서 준비
- 파싱 실패 시 원본 쿼리 보존 및 수동 검토 표시
- 파싱 실패율 > 50% 시 전체 프로세스 중단

### 리스크 2: Claude API Rate Limit
**발생 가능성:** Low
**영향도:** Medium

**대응 방안:**
- 지수 백오프 재시도 로직 (3회)
- API 호출 간 1초 대기
- 실패 시 기본 주석 템플릿 사용

### 리스크 3: Notion MCP 연결 실패
**발생 가능성:** Low
**영향도:** High

**대응 방안:**
- MCP 연결 전 사전 검증 (health check)
- 연결 실패 시 변환된 SQL을 로컬 파일로 저장
- 오류 메시지에 해결 방법 명시

### 리스크 4: MySQL 검증 실패
**발생 가능성:** Medium
**영향도:** Low

**대응 방안:**
- 검증은 선택적 기능 (--validate=false 옵션)
- 검증 실패해도 Notion 생성은 계속 진행
- 실패한 쿼리 목록을 보고서에 기록

---

## 다음 단계

### 구현 후 테스트 계획
1. **02번 교재 생성 테스트** (product_review.sql)
2. **03~05번 교재 재사용 테스트**
3. **오류 시나리오 테스트** (API 실패, MCP 연결 실패 등)

### 향후 개선 사항
- 섹션 분류 알고리즘 개선 (AI 기반 자동 분류)
- 쿼리 실행 결과 스크린샷 자동 생성
- Notion 페이지 템플릿 커스터마이징 지원
- 다국어 지원 (영어 교재 생성)

---

## 추적성

- **@SPEC:NOTION-002** → 요구사항 정의
- **@PLAN:NOTION-002** → 이 구현 계획
- **@ACCEPT:NOTION-002** → 수락 기준 및 테스트 시나리오
- **@CODE:NOTION-002** → 구현 코드
