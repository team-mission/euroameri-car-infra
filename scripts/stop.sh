#!/bin/bash

echo "🛑 Euroameri Car Docker 환경을 중지합니다..."

# Docker Compose 서비스 중지
if docker-compose down; then
    echo "✅ 모든 서비스가 중지되었습니다."
else
    echo "❌ 서비스 중지에 실패했습니다."
    exit 1
fi

# 선택적으로 볼륨도 제거
read -p "🗑️  데이터베이스 볼륨도 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  볼륨을 삭제합니다..."
    docker-compose down -v
    echo "✅ 모든 데이터가 삭제되었습니다."
fi

echo "🧹 사용하지 않는 Docker 리소스 정리..."
docker system prune -f

echo "✅ 정리가 완료되었습니다."
