import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
import pymysql
from sqlalchemy import create_engine
import os

# 한글 폰트 설정
plt.rcParams['font.family'] = 'NanumGothic'
plt.rcParams['axes.unicode_minus'] = False

# 페이지 설정
st.set_page_config(
    page_title="데이터 분석 대시보드",
    page_icon="📊",
    layout="wide"
)

# 제목
st.title("📊 MySQL 데이터 분석 대시보드")
st.markdown("---")

# MySQL 연결 함수
@st.cache_resource
def get_engine():
    MYSQL_HOST = os.getenv('MYSQL_HOST', 'mysql')
    MYSQL_PORT = os.getenv('MYSQL_PORT', '3306')
    MYSQL_DATABASE = os.getenv('MYSQL_DATABASE', 'analysis_db')
    MYSQL_USER = os.getenv('MYSQL_USER', 'user')
    MYSQL_PASSWORD = os.getenv('MYSQL_PASSWORD', '1111')
    
    return create_engine(
        f'mysql+pymysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DATABASE}'
    )

# 데이터 로드 함수
@st.cache_data
def load_data():
    engine = get_engine()
    try:
        df = pd.read_sql("SELECT * FROM test_products", engine)
        return df
    except:
        st.warning("테이블이 없습니다. init_notebook.ipynb를 먼저 실행해주세요.")
        return None

# 사이드바
st.sidebar.header("📋 메뉴")
menu = st.sidebar.radio(
    "선택하세요:",
    ["데이터 보기", "시각화", "통계 분석"]
)

# 데이터 로드
df = load_data()

if df is not None:
    if menu == "데이터 보기":
        st.header("📄 데이터 테이블")
        st.dataframe(df, use_container_width=True)
        
        st.subheader("데이터 정보")
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("전체 행 수", len(df))
        with col2:
            st.metric("전체 열 수", len(df.columns))
        with col3:
            st.metric("총 판매량", df['판매량'].sum())
    
    elif menu == "시각화":
        st.header("📈 데이터 시각화")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("제품별 판매량")
            fig1, ax1 = plt.subplots(figsize=(8, 5))
            ax1.bar(df['제품명'], df['판매량'], color='skyblue')
            ax1.set_xlabel('제품명')
            ax1.set_ylabel('판매량')
            ax1.set_title('제품별 판매량 비교')
            plt.xticks(rotation=45)
            st.pyplot(fig1)
        
        with col2:
            st.subheader("제품별 가격")
            fig2, ax2 = plt.subplots(figsize=(8, 5))
            ax2.bar(df['제품명'], df['가격'], color='lightcoral')
            ax2.set_xlabel('제품명')
            ax2.set_ylabel('가격 (원)')
            ax2.set_title('제품별 가격 비교')
            plt.xticks(rotation=45)
            st.pyplot(fig2)
        
        st.subheader("가격과 판매량의 관계")
        fig3, ax3 = plt.subplots(figsize=(10, 5))
        ax3.scatter(df['가격'], df['판매량'], s=100, alpha=0.6, color='green')
        ax3.set_xlabel('가격 (원)')
        ax3.set_ylabel('판매량')
        ax3.set_title('가격과 판매량의 상관관계')
        st.pyplot(fig3)
    
    elif menu == "통계 분석":
        st.header("📊 통계 분석")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("판매량 통계")
            st.write(f"평균: {df['판매량'].mean():.2f}")
            st.write(f"중앙값: {df['판매량'].median():.2f}")
            st.write(f"최대값: {df['판매량'].max()}")
            st.write(f"최소값: {df['판매량'].min()}")
            st.write(f"표준편차: {df['판매량'].std():.2f}")
        
        with col2:
            st.subheader("가격 통계")
            st.write(f"평균: {df['가격'].mean():.2f}원")
            st.write(f"중앙값: {df['가격'].median():.2f}원")
            st.write(f"최대값: {df['가격'].max()}원")
            st.write(f"최소값: {df['가격'].min()}원")
            st.write(f"표준편차: {df['가격'].std():.2f}원")
        
        st.subheader("전체 통계 요약")
        st.dataframe(df.describe(), use_container_width=True)

else:
    st.error("데이터를 불러올 수 없습니다. MySQL 연결과 테이블을 확인해주세요.")

# 푸터
st.markdown("---")
st.markdown("💡 **실행 방법**: `streamlit run streamlit_apps/app.py`")
