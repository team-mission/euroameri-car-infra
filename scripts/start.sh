#!/bin/bash

echo "🚀 Euroameri Car Docker 환경을 시작합니다..."

# 환경 변수 파일 확인
if [ ! -f .env ]; then
    echo "⚠️  .env 파일이 없습니다. env.example에서 복사합니다..."
    cp env.example .env
    echo "✅ .env 파일이 생성되었습니다. 필요한 경우 수정해주세요."
fi

# Docker와 Docker Compose 설치 확인
if ! command -v docker &> /dev/null; then
    echo "❌ Docker가 설치되지 않았습니다."
    echo "Docker를 설치하고 다시 실행해주세요: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose가 설치되지 않았습니다."
    echo "Docker Compose를 설치하고 다시 실행해주세요: https://docs.docker.com/compose/install/"
    exit 1
fi

# Docker 서비스 상태 확인
if ! docker info &> /dev/null; then
    echo "❌ Docker 서비스가 실행되지 않았습니다."
    echo "Docker Desktop을 시작하거나 Docker 서비스를 시작해주세요."
    exit 1
fi

echo "📦 Docker 이미지를 빌드하고 컨테이너를 시작합니다..."

# 기존 컨테이너 정리 (선택사항)
echo "🧹 기존 컨테이너를 정리합니다..."
docker-compose down 2>/dev/null

# 빌드 및 실행
echo "🔨 서비스를 빌드합니다..."
if docker-compose build; then
    echo "✅ 빌드가 완료되었습니다."
else
    echo "❌ 빌드에 실패했습니다."
    exit 1
fi

echo "🚀 서비스를 시작합니다..."
if docker-compose up -d; then
    echo "✅ 모든 서비스가 시작되었습니다!"
    echo ""
    echo "🌐 서비스 접속 정보:"
    echo "   웹사이트: http://localhost"
    echo "   API: http://localhost/api/"
    echo "   MySQL: localhost:3306"
    echo ""
    echo "📊 로그 확인: docker-compose logs -f"
    echo "🛑 서비스 중지: docker-compose down"
    echo ""
    echo "⏳ 서비스가 완전히 시작될 때까지 잠시 기다려주세요..."
    
    # 서비스 상태 확인
    echo "🔍 서비스 상태를 확인합니다..."
    sleep 10
    
    # 헬스 체크
    if curl -s http://localhost/health > /dev/null; then
        echo "✅ Nginx 프록시 서버가 정상 작동 중입니다."
    else
        echo "⚠️  서비스가 아직 시작 중일 수 있습니다. 잠시 후 다시 확인해주세요."
    fi
    
else
    echo "❌ 서비스 시작에 실패했습니다."
    echo "📋 로그 확인: docker-compose logs"
    exit 1
fi
