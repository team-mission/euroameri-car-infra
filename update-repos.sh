#!/bin/bash

echo "🔄 레포지토리들을 업데이트합니다..."

# Git 레포지토리 URL 설정
BACKEND_REPO="https://github.com/team-mission/euroameri-car-back.git"
FRONTEND_REPO="https://github.com/team-mission/euroameri-car-front.git"

# 백엔드 업데이트
if [ -d "euroameri-car-back" ]; then
    echo "📦 백엔드 레포지토리 업데이트 중..."
    cd euroameri-car-back
    git pull
    cd ..
    
    # Dockerfile 업데이트
    cp dockerfiles/Dockerfile.backend euroameri-car-back/Dockerfile
    cp dockerfiles/.dockerignore.backend euroameri-car-back/.dockerignore
    echo "✅ 백엔드 업데이트 완료"
else
    echo "⚠️  백엔드 레포지토리가 없습니다. ./setup.sh를 먼저 실행해주세요."
fi

# 프론트엔드 업데이트
if [ -d "euroameri-car-front" ]; then
    echo "📦 프론트엔드 레포지토리 업데이트 중..."
    cd euroameri-car-front
    git pull
    cd ..
    
    # Dockerfile 업데이트
    cp dockerfiles/Dockerfile.frontend euroameri-car-front/Dockerfile
    cp dockerfiles/.dockerignore.frontend euroameri-car-front/.dockerignore
    echo "✅ 프론트엔드 업데이트 완료"
else
    echo "⚠️  프론트엔드 레포지토리가 없습니다. ./setup.sh를 먼저 실행해주세요."
fi

echo "🎉 모든 레포지토리 업데이트가 완료되었습니다!"
