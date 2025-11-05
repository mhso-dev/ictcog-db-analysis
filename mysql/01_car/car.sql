use classicmodels;

-- [그림 4-5 쿼리]
-- 목적: 주문 날짜별 각 주문 상세 항목의 매출액 계산
-- 결과: 주문일자와 개별 상품의 판매금액(단가 * 수량)을 행 단위로 출력
select a.orderdate,
       priceeach * quantityordered
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber;

-- [그림 4-6 쿼리]
-- 목적: 일별 총 매출 집계
-- 결과: 주문일자별로 그룹화하여 하루 전체 매출액 합계를 날짜순으로 출력
select a.orderdate,
       sum(priceeach * quantityordered) as sales
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
group by 1
order by 1;

-- [그림 4-8 결과]
-- 목적: SUBSTR 함수 사용법 예시
-- 결과: 'abcde' 문자열의 2번째 위치부터 3글자를 추출 ('bcd' 반환)
select substr('abcde', 2, 3);

-- [그림 4-9 결과]
-- 목적: 월별 매출 집계
-- 결과: 주문일자에서 년-월(YYYY-MM) 부분을 추출하여 월별 매출액 합계를 시간순으로 출력
select substr(a.orderdate, 1, 7) mm,
       sum(priceeach * quantityordered) as sales
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
group by 1
order by 1;

-- [그림 4-10 결과] 
-- 목적: 연도별 매출 집계
-- 결과: 주문일자에서 연도(YYYY) 부분을 추출하여 연도별 매출액 합계를 연도순으로 출력
select substr(a.orderdate, 1, 4) mm,
       sum(priceeach * quantityordered) as sales
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
group by 1
order by 1;

-- [그림 4-11 결과] 
-- 목적: 주문 테이블의 기본 정보 조회
-- 결과: 모든 주문의 주문일자, 고객번호, 주문번호를 출력
select orderdate,
       customernumber,
       ordernumber
from classicmodels.orders;

-- [그림 4-12 결과] 
-- 목적: COUNT와 DISTINCT의 차이 이해
-- 결과: 전체 주문 건수와 중복 제거한 주문번호 개수를 비교 (주문번호는 PK이므로 같은 값)
select count(ordernumber) n_orders,
       count(distinct ordernumber) n_orders_distinct
from classicmodels.orders;

-- [그림 4-13 결과] 
-- 목적: 일별 구매자 수와 주문 건수 분석
-- 결과: 날짜별로 구매한 고유 고객 수와 총 주문 건수를 날짜순으로 출력
select orderdate,
       count(distinct customernumber) n_purchaser,
       count(ordernumber) n_orders
from classicmodels.orders
group by 1
order by 1;

-- [그림 4-14 결과] 
-- 목적: 연도별 구매자 수와 매출 분석
-- 결과: 연도별로 구매한 고유 고객 수와 총 매출액을 연도순으로 출력
select substr(a.orderdate, 1, 4) yy,
       count(distinct a.customernumber) n_purchaser,
       sum(priceeach * quantityordered) as sales
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
group by 1
order by 1;

-- [그림 4-15 결과] 
-- 목적: 연도별 AMV(Average Member Value) 계산
-- 결과: 연도별 구매자 수, 총 매출, 고객당 평균 매출액(AMV)를 연도순으로 출력
select substr(a.orderdate, 1, 4) yy,
       count(distinct a.customernumber) n_purchaser,
       sum(priceeach * quantityordered) as sales,
       sum(priceeach * quantityordered) / count(distinct a.customernumber) amv
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
group by 1
order by 1;

-- [그림 4-16 결과] 
-- 목적: 연도별 ATV(Average Transaction Value) 계산
-- 결과: 연도별 주문 건수, 총 매출, 주문당 평균 거래액(ATV)을 연도순으로 출력
select substr(a.orderdate, 1, 4) yy,
       count(distinct a.ordernumber) n_purchaser,
       sum(priceeach * quantityordered) as sales,
       sum(priceeach * quantityordered) / count(distinct a.ordernumber) atv
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
group by 1
order by 1;

-- [그림 4-18 결과]
-- 목적: 3개 테이블 조인하여 전체 데이터 구조 확인
-- 결과: 주문, 주문상세, 고객 정보를 모두 결합한 전체 데이터셋
select *
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
left join classicmodels.customers c
  on a.customernumber = c.customernumber;

-- [그림 4-19 결과]
-- 목적: 국가 및 도시별 주문 상세 데이터 조회
-- 결과: 각 주문의 국가, 도시, 개별 상품 판매금액을 행 단위로 출력
select country,
       city,
       priceeach * quantityordered
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
left join classicmodels.customers c
  on a.customernumber = c.customernumber;

-- [그림 4-20 결과]
-- 목적: 국가 및 도시별 매출 집계
-- 결과: 국가와 도시별로 그룹화하여 총 매출액 합계를 출력
select c.country,
       c.city,
       sum(priceeach * quantityordered) sales
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
left join classicmodels.customers c
  on a.customernumber = c.customernumber
group by 1, 2;

-- [그림 4-21 결과]
-- 목적: 국가 및 도시별 매출 집계 (정렬 추가)
-- 결과: 국가와 도시별 총 매출을 국가, 도시 순으로 정렬하여 출력
select c.country,
       c.city,
       sum(priceeach * quantityordered) sales
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
left join classicmodels.customers c
  on a.customernumber = c.customernumber
group by 1, 2
order by 1, 2;

-- [그림 4-22 결과]
-- 목적: CASE 문을 이용한 국가 그룹화 예시
-- 결과: 고객 국가를 'North America'(미국, 캐나다)와 'Others'로 분류하여 출력
select case when country in ('usa', 'canada') then 'north america'
            else 'others' end country_grp
from classicmodels.customers;

-- [그림 4-23 결과]
-- 목적: 국가-도시별 매출을 매출액 내림차순으로 정렬
-- 결과: 국가와 도시별 총 매출을 매출액이 높은 순으로 출력
select c.country,
       c.city,
       sum(priceeach * quantityordered) sales
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
left join classicmodels.customers c
  on a.customernumber = c.customernumber
group by 1, 2
order by 3 desc;

-- [그림 4-24 결과]
-- 목적: 지역 그룹별 매출 집계 및 비교
-- 결과: 북미(미국+캐나다)와 기타 지역의 매출을 비교하여 매출 내림차순으로 출력
select case when country in ('usa', 'canada') then 'north america'
            else 'others' end country_grp,
       sum(priceeach * quantityordered) sales
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
left join classicmodels.customers c
  on a.customernumber = c.customernumber
group by 1
order by 2 desc;

-- [그림 4-25 결과]
-- 목적: 국가별 매출 통계 테이블 생성
-- 결과: 국가별 총 매출을 계산하여 stat 테이블에 저장 (매출 내림차순)
create table classicmodels.stat as
select c.country,
       sum(priceeach * quantityordered) sales
from classicmodels.orders a
left join classicmodels.orderdetails b
  on a.ordernumber = b.ordernumber
left join classicmodels.customers c
  on a.customernumber = c.customernumber
group by 1
order by 2 desc;

-- [그림 4-26 결과]
-- 목적: 생성한 stat 테이블 조회
-- 결과: 국가별 매출 통계 전체 데이터 출력
select *
from classicmodels.stat;

-- [그림 4-27 결과]
-- 목적: DENSE_RANK 윈도우 함수를 이용한 순위 부여
-- 결과: 국가별 매출에 순위(RNK)를 매출액 내림차순으로 부여하여 출력
select country,
       sales,
       dense_rank() over (order by sales desc) rnk
from classicmodels.stat;

-- [그림 4-28 결과]
-- 목적: 순위가 포함된 stat_rnk 테이블 조회
-- 결과: 국가별 매출과 순위 정보가 포함된 테이블 전체 데이터 출력
select *
from classicmodels.stat_rnk;

-- [그림 4-29 결과]
-- 목적: TOP 5 국가 필터링
-- 결과: 매출 순위 1~5위 국가만 조회
select *
from classicmodels.stat_rnk
where rnk between 1 and 5;

-- [그림 4-31 결과]
-- 목적: 서브쿼리를 이용한 TOP 5 국가 매출 조회 (테이블 생성 없이)
-- 결과: 국가별 매출 집계 → 순위 부여 → TOP 5 필터링을 하나의 쿼리로 처리
select *
from (select country,
             sales,
             dense_rank() over (order by sales desc) rnk
      from (select c.country,
                   sum(priceeach * quantityordered) sales
            from classicmodels.orders a
            left join classicmodels.orderdetails b
              on a.ordernumber = b.ordernumber
            left join classicmodels.customers c
              on a.customernumber = c.customernumber
            group by 1) a) a
where rnk <= 5;

-- [109 페이지 과정1]
-- 목적: 서브쿼리를 이용한 TOP 5 국가 매출 조회 (동일 쿼리 반복 - 학습용)
-- 결과: 국가별 매출 TOP 5를 중첩 서브쿼리로 조회
select *
from (select country,
             sales,
             dense_rank() over (order by sales desc) rnk
      from (select c.country,
                   sum(priceeach * quantityordered) sales
            from classicmodels.orders a
            left join classicmodels.orderdetails b
              on a.ordernumber = b.ordernumber
            left join classicmodels.customers c
              on a.customernumber = c.customernumber
            group by 1) a) a
where rnk <= 5;

-- [110 페이지 과정2]
-- 목적: 서브쿼리를 이용한 TOP 5 국가 매출 조회 (동일 쿼리 반복 - 학습용)
-- 결과: 국가별 매출 TOP 5를 중첩 서브쿼리로 조회
select *
from (select country,
             sales,
             dense_rank() over (order by sales desc) rnk
      from (select c.country,
                   sum(priceeach * quantityordered) sales
            from classicmodels.orders a
            left join classicmodels.orderdetails b
              on a.ordernumber = b.ordernumber
            left join classicmodels.customers c
              on a.customernumber = c.customernumber
            group by 1) a) a
where rnk <= 5;

-- [그림 4-32 결과]
-- 목적: 셀프 조인을 통한 고객의 전년도-당해년도 주문 매칭
-- 결과: 각 고객의 연도별 주문을 전년도 주문과 매칭하여 재구매 여부 확인용 데이터 생성
select a.customernumber,
       a.orderdate,
       b.customernumber,
       b.orderdate
from classicmodels.orders a
left join classicmodels.orders b
  on a.customernumber = b.customernumber
     and substr(a.orderdate, 1, 4) = substr(b.orderdate, 1, 4) - 1;

-- [그림 4-33 결과]
-- 목적: 국가별 연도별 재구매율(Retention Rate) 계산
-- 결과: 국가와 연도별로 전년도 구매자 수(BU_1), 당해년도 재구매자 수(BU_2), 재구매율 출력
select c.country,
       substr(a.orderdate, 1, 4) yy,
       count(distinct a.customernumber) bu_1,
       count(distinct b.customernumber) bu_2,
       count(distinct b.customernumber) / count(distinct a.customernumber) retention_rate
from classicmodels.orders a
left join classicmodels.orders b
  on a.customernumber = b.customernumber
     and substr(a.orderdate, 1, 4) = substr(b.orderdate, 1, 4) - 1
left join classicmodels.customers c
  on a.customernumber = c.customernumber
group by 1, 2;

-- [그림 4-35 결과]
-- 목적: 미국 시장에서의 상품별 매출 테이블 생성 및 TOP 5 조회
-- 결과: 미국 고객의 상품별 매출을 집계하여 테이블 생성 후, 매출 TOP 5 상품 조회
create table classicmodels.product_sales as
select d.productname,
       sum(quantityordered * priceeach) sales
from classicmodels.orders a
left join classicmodels.customers b
  on a.customernumber = b.customernumber
left join classicmodels.orderdetails c
  on a.ordernumber = c.ordernumber
left join classicmodels.products d
  on c.productcode = d.productcode
where b.country = 'usa'
group by 1;

select *
from (select *,
             row_number() over (order by sales desc) rnk
      from classicmodels.product_sales) a
where rnk <= 5
order by rnk;

-- [그림 4-37 결과]
-- 목적: 전체 데이터의 최종 주문 날짜 확인
-- 결과: 데이터셋에서 가장 최근 주문일자를 조회 (기준일 설정에 활용)
select max(orderdate) mx_order
from classicmodels.orders;

-- [그림 4-38 결과]
-- 목적: 전체 데이터의 최종 주문 날짜 확인 (동일 쿼리)
-- 결과: 데이터셋에서 가장 최근 주문일자를 조회
select max(orderdate) mx_order
from classicmodels.orders;

-- [그림 4-39 결과]
-- 목적: 고객별 마지막 주문 이후 경과 일수 계산
-- 결과: 각 고객의 마지막 주문일, 기준일(2005-06-01), 경과 일수를 출력
select customernumber,
       mx_order,
       '2005-06-01',
       datediff('2005-06-01', mx_order) diff
from (select customernumber,
             max(orderdate) mx_order
      from classicmodels.orders
      group by 1) base;

-- [그림 4-40 결과]
-- 목적: 고객별 이탈(Churn) 여부 판단
-- 결과: 마지막 주문 이후 90일 이상 경과한 고객은 'Churn', 그렇지 않으면 'Non-Churn'으로 분류
select *,
       case when diff >= 90 then 'churn' else 'non-churn' end churn_type
from (select customernumber,
             mx_order,
             '2005-06-01' end_point,
             datediff('2005-06-01', mx_order) diff
      from (select customernumber,
                   max(orderdate) mx_order
            from classicmodels.orders
            group by 1) base) base;

-- [그림 4-41 결과]
-- 목적: 이탈 고객과 활성 고객 수 집계
-- 결과: Churn/Non-Churn 그룹별 고객 수를 카운트하여 이탈률 분석 가능
select case when diff >= 90 then 'churn' else 'non-churn' end churn_type,
       count(distinct customernumber) n_cus
from (select customernumber,
             mx_order,
             '2005-06-01' end_point,
             datediff('2005-06-01', mx_order) diff
      from (select customernumber,
                   max(orderdate) mx_order
            from classicmodels.orders
            group by 1) base) base
group by 1;

-- [121 페이지, Churn table 생성]
-- 목적: 고객별 이탈 여부 정보를 테이블로 저장
-- 결과: 각 고객의 이탈 여부(Churn/Non-Churn)를 저장한 테이블 생성 (후속 분석에 활용)
create table classicmodels.churn_list as
select case when diff >= 90 then 'churn' else 'non-churn' end churn_type,
       customernumber
from (select customernumber,
             mx_order,
             '2005-06-01' end_point,
             datediff('2005-06-01', mx_order) diff
      from (select customernumber,
                   max(orderdate) mx_order
            from classicmodels.orders
            group by 1) base) base;

-- [그림 4-43 결과]
-- 목적: 제품 라인별 구매 고객 수 분석
-- 결과: 각 제품 라인(Motorcycles, Classic Cars 등)별로 구매한 고유 고객 수를 집계
select c.productline,
       count(distinct b.customernumber) bu
from classicmodels.orderdetails a
left join classicmodels.orders b
  on a.ordernumber = b.ordernumber
left join classicmodels.products c
  on a.productcode = c.productcode
group by 1;

-- [그림 4-44 결과]
-- 목적: 이탈 여부에 따른 제품 라인별 구매 고객 수 비교
-- 결과: Churn/Non-Churn 고객이 각 제품 라인별로 얼마나 구매했는지 분석하여 이탈 고객의 선호 제품 파악
select d.churn_type,
       c.productline,
       count(distinct b.customernumber) bu
from classicmodels.orderdetails a
left join classicmodels.orders b
  on a.ordernumber = b.ordernumber
left join classicmodels.products c
  on a.productcode = c.productcode
left join classicmodels.churn_list d
  on b.customernumber = d.customernumber
group by 1, 2
order by 1, 3 desc;
