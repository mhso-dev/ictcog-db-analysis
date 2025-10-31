Write-Host "🔄 기존 컨테이너 중지 및 삭제..." -ForegroundColor Cyan
docker-compose down

Write-Host "`n🗑️ MySQL 볼륨 완전 삭제..." -ForegroundColor Cyan
docker volume rm docker-practice_mysql_data 2>$null

Write-Host "`n🚀 컨테이너 시작..." -ForegroundColor Cyan
docker-compose up -d --build

Write-Host "`n⏳ MySQL 초기화 대기 중 (20초)..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Write-Host "`n✅ 초기화 완료!`n" -ForegroundColor Green

Write-Host "📊 컨테이너 상태:" -ForegroundColor Cyan
docker-compose ps

Write-Host "`n✨ 이제 Jupyter에서 접속을 시도해보세요!" -ForegroundColor Green
Write-Host "   Jupyter Lab: http://localhost:8888" -ForegroundColor White