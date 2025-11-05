---
id: SQL-001
title: MySQL 쿼리 학습 가이드 개발
domain: Education
type: Feature
status: Draft
priority: High
created: 2025-11-05
author: spec-builder
tags:
  - MySQL
  - SQL
  - Tutorial
  - Education
---

# MySQL 쿼리 학습 가이드 개발

**@SPEC:SQL-001**

## SUMMARY

This specification defines an educational MySQL query learning guide that enhances existing car.sql practice file with Korean explanations, difficulty classifications, and structured exercises. The guide targets data analysis beginners using the classicmodels database (8 tables). Features include purpose/result explanations for each query, difficulty-based categorization (Basic/Intermediate/Advanced), practice problems with answer sets, and comprehensive SQL function documentation. The deliverable transforms a raw SQL file into a self-paced learning resource with progressive difficulty levels and immediate feedback mechanisms.

## 환경 (ENVIRONMENT)

**WHEN** 데이터 분석 입문자가 MySQL 쿼리 학습을 시작할 때

**기술 환경:**
- MySQL 8.0
- classicmodels 데이터베이스 (8개 테이블)
- 기존 파일: `mysql/01_car/car.sql`

**학습 대상:**
- SQL 기초 문법을 처음 배우는 학습자
- 실무 쿼리 작성 경험이 필요한 입문자
- 체계적인 단계별 학습을 원하는 사용자

## 가정 (ASSUMPTIONS)

**데이터베이스 가정:**
- classicmodels 데이터베이스가 MySQL에 로드되어 있음
- 8개 테이블이 정상적으로 조회 가능
- 샘플 데이터가 충분히 존재

**학습자 가정:**
- 기본적인 SQL 문법(SELECT, FROM, WHERE)을 이해
- MySQL Workbench 또는 CLI 사용 가능
- 한글 설명 자료가 학습에 효과적

**환경 가정:**
- UTF-8 인코딩으로 한글 주석 처리 가능
- 쿼리 실행 결과를 즉시 확인 가능한 환경

## 요구사항 (REQUIREMENTS)

### FR-SQL-001: 한글 설명 추가
**WHEN** 기존 car.sql 파일의 각 쿼리를 읽을 때
**THE SYSTEM SHALL** 각 쿼리문 위에 다음 정보를 한글 주석으로 제공:
- 쿼리의 목적 (무엇을 조회하는가)
- 예상 결과 (어떤 데이터가 나오는가)
- 주요 학습 포인트 (어떤 SQL 개념을 배우는가)

### FR-SQL-002: 난이도 분류
**WHEN** 쿼리 목록을 탐색할 때
**THE SYSTEM SHALL** 모든 쿼리를 3단계로 분류:
- **기초 (Basic)**: SELECT, WHERE, ORDER BY, LIMIT
- **중급 (Intermediate)**: JOIN, GROUP BY, HAVING, 서브쿼리
- **고급 (Advanced)**: 윈도우 함수, CTE, 복합 서브쿼리

각 섹션은 명확히 구분되며 학습 순서를 제시

### FR-SQL-003: 실습 문제 제공
**WHEN** 학습자가 특정 난이도의 학습을 완료했을 때
**THE SYSTEM SHALL** 각 난이도별로 3-5개의 실습 문제를 제공:
- 문제 설명 (한글)
- 힌트 (선택적)
- 정답 쿼리 (주석 처리)
- 예상 결과 행 수 또는 주요 컬럼

### FR-SQL-004: SQL 함수 설명
**WHEN** 쿼리에서 SQL 함수를 사용할 때
**THE SYSTEM SHALL** 주요 함수에 대한 설명 제공:
- 집계 함수: COUNT, SUM, AVG, MIN, MAX
- 문자열 함수: CONCAT, SUBSTRING, UPPER, LOWER
- 날짜 함수: DATE_FORMAT, YEAR, MONTH, DATEDIFF
- 조건 함수: IF, CASE WHEN

## 명세 (SPECIFICATIONS)

### SPEC-SQL-001-01: 파일 구조
```sql
-- ============================================
-- MySQL 쿼리 학습 가이드
-- 데이터베이스: classicmodels
-- 버전: 1.0
-- ============================================

-- [기초 (Basic)]
-- 이 섹션에서는 기본적인 SELECT 문법을 학습합니다.

-- 쿼리 1: 전체 고객 목록 조회
-- 목적: customers 테이블의 모든 데이터를 확인
-- 학습 포인트: SELECT *, FROM 기본 문법
-- 예상 결과: 122개 행
SELECT * FROM customers;

-- [중급 (Intermediate)]
-- ...

-- [고급 (Advanced)]
-- ...

-- [실습 문제 - 기초]
-- ...
```

### SPEC-SQL-001-02: 난이도별 쿼리 분포
- 기초: 10-15개 쿼리
- 중급: 15-20개 쿼리
- 고급: 5-10개 쿼리

### SPEC-SQL-001-03: 주석 템플릿
```sql
-- 쿼리 N: [쿼리 제목]
-- 목적: [무엇을 조회/분석하는가]
-- 학습 포인트: [배울 수 있는 SQL 개념]
-- 예상 결과: [행 수 또는 주요 특징]
-- [힌트: 선택적 힌트 메시지]
[SQL 쿼리문]
```

### SPEC-SQL-001-04: 실습 문제 템플릿
```sql
-- [실습 문제 N]
-- 문제: [해결해야 할 과제]
-- 힌트: [선택적 힌트]
-- 예상 결과: [행 수 또는 주요 컬럼]
-- 정답:
-- [정답 쿼리 - 주석 처리]
```

## 제약사항 (CONSTRAINTS)

### 기술 제약사항
- MySQL 8.0 문법 준수
- UTF-8 인코딩 사용 (한글 주석)
- 기존 car.sql 파일의 쿼리 순서 유지

### 교육 제약사항
- 각 쿼리는 독립적으로 실행 가능해야 함
- 실습 문제는 선행 학습 내용으로 해결 가능해야 함
- 정답은 즉시 확인 가능하도록 제공 (주석 해제 방식)

### 품질 제약사항
- 모든 한글 설명은 명확하고 간결해야 함
- 학습 포인트는 구체적이고 실용적이어야 함
- 쿼리 실행 시 오류가 없어야 함

## 추적성 (TRACEABILITY)

- **@SPEC:SQL-001** → 이 명세서
- **@TEST:SQL-001** → 테스트 케이스 (쿼리 실행 검증)
- **@CODE:SQL-001** → `mysql/01_car/car.sql` (개선된 학습 가이드)
- **@DOC:SQL-001** → 사용 가이드 문서

## 변경 이력 (HISTORY)

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| 1.0 | 2025-11-05 | spec-builder | 초안 작성 |
