#!/bin/bash

echo "🚀 Euroameri Car 인프라 설정을 시작합니다..."

# 현재 디렉토리가 맞는지 확인
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml 파일이 없습니다. 올바른 디렉토리에서 실행해주세요."
    exit 1
fi

# 백엔드 레포지토리 클론 (이미 있으면 업데이트)
BACKEND_REPO="https://github.com/team-mission/euroameri-car-back.git"
if [ ! -d "euroameri-car-back" ]; then
    echo "📥 백엔드 레포지토리를 클론합니다..."
    echo "🔗 백엔드 레포지토리: $BACKEND_REPO"
    git clone $BACKEND_REPO euroameri-car-back
else
    echo "🔄 백엔드 레포지토리를 업데이트합니다..."
    cd euroameri-car-back
    git pull
    cd ..
fi

# 프론트엔드 레포지토리 클론 (이미 있으면 업데이트)
FRONTEND_REPO="https://github.com/team-mission/euroameri-car-front.git"
if [ ! -d "euroameri-car-front" ]; then
    echo "📥 프론트엔드 레포지토리를 클론합니다..."
    echo "🔗 프론트엔드 레포지토리: $FRONTEND_REPO"
    git clone $FRONTEND_REPO euroameri-car-front
else
    echo "🔄 프론트엔드 레포지토리를 업데이트합니다..."
    cd euroameri-car-front
    git pull
    cd ..
fi

# Dockerfile들을 복사
echo "📋 Dockerfile들을 복사합니다..."
cp dockerfiles/Dockerfile.backend euroameri-car-back/Dockerfile
cp dockerfiles/Dockerfile.frontend euroameri-car-front/Dockerfile
cp dockerfiles/.dockerignore.backend euroameri-car-back/.dockerignore
cp dockerfiles/.dockerignore.frontend euroameri-car-front/.dockerignore

# 환경 변수 파일 설정
if [ ! -f .env ]; then
    echo "⚙️  환경 변수 파일을 설정합니다..."
    cp env.example .env
    echo "✅ .env 파일이 생성되었습니다. 필요한 경우 수정해주세요."
fi

echo "✅ 설정이 완료되었습니다!"
echo ""
echo "🚀 다음 명령어로 서비스를 시작할 수 있습니다:"
echo "   ./scripts/start.sh"
echo ""
echo "📋 레포지토리 업데이트는 다음 명령어로:"
echo "   ./update-repos.sh"
