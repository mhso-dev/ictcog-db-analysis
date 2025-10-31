#!/bin/bash

echo "🔄 컨테이너 중지 및 삭제..."
docker-compose down -v

echo "🗑️ MySQL 볼륨 완전 삭제..."
docker volume rm docker-practice_mysql_data 2>/dev/null || true

echo "🚀 새로 시작..."
docker-compose up -d --build

echo "⏳ MySQL 초기화 대기 중..."
sleep 15

echo "✅ 완료! 이제 접속을 시도해보세요."
docker-compose ps