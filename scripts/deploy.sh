#!/bin/bash

echo "🚀 Euroameri Car 자동 배포를 시작합니다..."

# Git 레포지토리 URL 설정
BACKEND_REPO="https://github.com/team-mission/euroameri-car-back.git"
FRONTEND_REPO="https://github.com/team-mission/euroameri-car-front.git"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 에러 처리 함수
handle_error() {
    echo -e "${RED}❌ 에러가 발생했습니다: $1${NC}"
    exit 1
}

# 성공 메시지 함수
success_msg() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 정보 메시지 함수
info_msg() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 경고 메시지 함수
warn_msg() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Docker 및 Docker Compose 확인
info_msg "Docker 환경을 확인합니다..."
if ! command -v docker &> /dev/null; then
    handle_error "Docker가 설치되어 있지 않습니다."
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    handle_error "Docker Compose가 설치되어 있지 않습니다."
fi

# 기존 컨테이너 정리
info_msg "기존 컨테이너를 정리합니다..."
docker-compose down --remove-orphans || docker compose down --remove-orphans

# 레포지토리 업데이트
info_msg "소스 코드를 업데이트합니다..."

# 백엔드 레포지토리 처리
if [ -d "euroameri-car-back" ]; then
    info_msg "백엔드 레포지토리를 업데이트합니다..."
    cd euroameri-car-back
    git fetch origin
    git reset --hard origin/main
    cd ..
else
    info_msg "백엔드 레포지토리를 클론합니다..."
    git clone $BACKEND_REPO euroameri-car-back || handle_error "백엔드 레포지토리 클론 실패"
fi

# 프론트엔드 레포지토리 처리
if [ -d "euroameri-car-front" ]; then
    info_msg "프론트엔드 레포지토리를 업데이트합니다..."
    cd euroameri-car-front
    git fetch origin
    git reset --hard origin/main
    cd ..
else
    info_msg "프론트엔드 레포지토리를 클론합니다..."
    git clone $FRONTEND_REPO euroameri-car-front || handle_error "프론트엔드 레포지토리 클론 실패"
fi

# Dockerfile 및 .dockerignore 복사
info_msg "Docker 설정 파일들을 복사합니다..."
cp dockerfiles/Dockerfile.backend euroameri-car-back/Dockerfile || handle_error "백엔드 Dockerfile 복사 실패"
cp dockerfiles/Dockerfile.frontend euroameri-car-front/Dockerfile || handle_error "프론트엔드 Dockerfile 복사 실패"

if [ -f "dockerfiles/.dockerignore.backend" ]; then
    cp dockerfiles/.dockerignore.backend euroameri-car-back/.dockerignore
fi

if [ -f "dockerfiles/.dockerignore.frontend" ]; then
    cp dockerfiles/.dockerignore.frontend euroameri-car-front/.dockerignore
fi

# 환경 변수 파일 확인
if [ ! -f .env ]; then
    warn_msg ".env 파일이 없습니다. env.example을 복사합니다..."
    cp env.example .env
    warn_msg ".env 파일을 확인하고 필요한 설정을 수정해주세요."
fi

# Docker 이미지 빌드 및 컨테이너 시작
info_msg "Docker 이미지를 빌드하고 컨테이너를 시작합니다..."
docker-compose build --no-cache || docker compose build --no-cache || handle_error "Docker 이미지 빌드 실패"

# 컨테이너 시작
info_msg "컨테이너를 시작합니다..."
docker-compose up -d || docker compose up -d || handle_error "컨테이너 시작 실패"

# 서비스 상태 확인
info_msg "서비스 상태를 확인합니다..."
sleep 10

# 컨테이너 상태 확인
if docker-compose ps | grep -q "Up" || docker compose ps | grep -q "running"; then
    success_msg "배포가 성공적으로 완료되었습니다!"
    echo ""
    echo "🌐 서비스 접속 정보:"
    echo "   - 웹사이트: http://localhost (포트 번호 없이 접속!)"
    echo "   - 백엔드 API: http://localhost:4000"
    echo ""
    echo "🚨 중요: 프론트엔드는 http://localhost로, 백엔드는 http://localhost:4000으로 접속하세요!"
    echo ""
    echo "📊 컨테이너 상태 확인:"
    docker-compose ps || docker compose ps
    echo ""
    echo "📝 로그 확인:"
    echo "   전체 로그: docker-compose logs -f"
    echo "   프론트엔드: docker-compose logs -f frontend"
    echo "   백엔드: docker-compose logs -f backend"
    echo "   Nginx: docker-compose logs -f nginx"
else
    handle_error "일부 컨테이너가 정상적으로 시작되지 않았습니다."
fi
