FROM python:3.11-slim

WORKDIR /workspace

# 한글 폰트 설치
RUN apt-get update && apt-get install -y fonts-nanum && rm -rf /var/lib/apt/lists/*

# Python 패키지 설치
COPY requirements.txt .
RUN pip install -r requirements.txt

EXPOSE 8888 8501

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--NotebookApp.token=''"]
