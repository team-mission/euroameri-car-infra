#!/bin/bash

echo "🔧 폴더 구조 정리 중..."

# 백엔드 폴더 안의 중첩된 프론트엔드 폴더 제거
if [ -d "euroameri-car-back/euroameri-car-front" ]; then
    echo "⚠️  백엔드 폴더 안의 중첩된 프론트엔드 폴더를 제거합니다..."
    rm -rf euroameri-car-back/euroameri-car-front
fi

# Dockerfile 복사
echo "📋 Dockerfile들을 복사합니다..."
cp dockerfiles/Dockerfile.backend euroameri-car-back/Dockerfile
cp dockerfiles/Dockerfile.frontend euroameri-car-front/Dockerfile

# .dockerignore 파일도 복사 (있다면)
if [ -f "dockerfiles/.dockerignore.backend" ]; then
    cp dockerfiles/.dockerignore.backend euroameri-car-back/.dockerignore
fi

if [ -f "dockerfiles/.dockerignore.frontend" ]; then
    cp dockerfiles/.dockerignore.frontend euroameri-car-front/.dockerignore
fi

echo "✅ 폴더 구조 정리 완료!"
