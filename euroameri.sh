#!/bin/bash

# ============================================
# 🚀 Euroameri Car 통합 관리 스크립트
# ============================================

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Git 레포지토리 URL
BACKEND_REPO="https://github.com/team-mission/euroameri-car-back.git"
FRONTEND_REPO="https://github.com/team-mission/euroameri-car-front.git"

# 메시지 함수들
info_msg() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

warn_msg() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error_msg() {
    echo -e "${RED}❌ $1${NC}"
}

success_msg() {
    echo -e "${GREEN}✅ $1${NC}"
}

title_msg() {
    echo -e "${PURPLE}🎯 $1${NC}"
}

# Docker 상태 확인
check_docker() {
    if ! docker ps >/dev/null 2>&1; then
        error_msg "Docker가 실행되지 않고 있습니다."
        echo "Docker Desktop을 시작해주세요: open -a Docker"
        exit 1
    fi
}

# 초기 설정
setup() {
    title_msg "초기 설정을 시작합니다..."
    
    # 백엔드 레포지토리 처리
    if [ ! -d "euroameri-car-back" ]; then
        info_msg "백엔드 레포지토리를 클론합니다..."
        git clone $BACKEND_REPO euroameri-car-back
    else
        info_msg "백엔드 레포지토리를 업데이트합니다..."
        cd euroameri-car-back && git pull && cd ..
    fi
    
    # 프론트엔드 레포지토리 처리
    if [ ! -d "euroameri-car-front" ]; then
        info_msg "프론트엔드 레포지토리를 클론합니다..."
        git clone $FRONTEND_REPO euroameri-car-front
    else
        info_msg "프론트엔드 레포지토리를 업데이트합니다..."
        cd euroameri-car-front && git pull && cd ..
    fi
    
    # Dockerfile 복사
    info_msg "Dockerfile을 복사합니다..."
    [ -f "dockerfiles/Dockerfile.backend" ] && cp dockerfiles/Dockerfile.backend euroameri-car-back/Dockerfile
    [ -f "dockerfiles/Dockerfile.frontend" ] && cp dockerfiles/Dockerfile.frontend euroameri-car-front/Dockerfile
    [ -f "dockerfiles/.dockerignore.backend" ] && cp dockerfiles/.dockerignore.backend euroameri-car-back/.dockerignore
    [ -f "dockerfiles/.dockerignore.frontend" ] && cp dockerfiles/.dockerignore.frontend euroameri-car-front/.dockerignore
    
    # 환경 변수 파일
    if [ ! -f .env ]; then
        info_msg ".env 파일을 생성합니다..."
        cp env.example .env
    fi
    
    success_msg "초기 설정 완료!"
}

# 일반 시작
start() {
    title_msg "서비스를 시작합니다..."
    check_docker
    
    # MySQL이 실행 중인지 확인
    if ! docker-compose ps mysql | grep -q "Up"; then
        info_msg "MySQL을 먼저 시작합니다..."
        docker-compose up -d mysql
        sleep 20
    fi
    
    # 초기화 스크립트가 실행되었는지 확인
    info_msg "데이터베이스 초기화 상태를 확인합니다..."
    if ! docker-compose exec -T mysql mysql -u euroameri -pstrong_password_123 euroamericar -e "SELECT COUNT(*) FROM admin;" > /dev/null 2>&1; then
        warn_msg "초기화 스크립트가 실행되지 않았을 수 있습니다. MySQL을 재시작합니다..."
        docker-compose restart mysql
        sleep 25
    fi
    
    docker-compose up --build -d
    
    # 초기 데이터 확인
    sleep 10
    info_msg "초기 데이터 로드를 확인합니다..."
    if docker-compose exec -T mysql mysql -u euroameri -pstrong_password_123 euroamericar -e "SELECT COUNT(*) as admin_count FROM admin; SELECT COUNT(*) as post_count FROM post;" 2>/dev/null; then
        success_msg "초기 데이터가 정상적으로 로드되었습니다."
    fi
    
    show_status
}

# 완전 초기화 후 시작
fresh_start() {
    title_msg "완전 초기화 후 시작합니다..."
    check_docker
    
    warn_msg "모든 데이터가 삭제됩니다. 계속하시겠습니까? (y/N)"
    read -p "답변: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info_msg "취소되었습니다."
        return
    fi
    
    info_msg "모든 컨테이너와 볼륨을 정리합니다..."
    docker-compose down -v --remove-orphans 2>/dev/null || true
    
    info_msg "MySQL부터 단계별로 시작합니다..."
    docker-compose up -d mysql
    
    info_msg "MySQL 초기화를 기다립니다..."
    sleep 30
    
    info_msg "데이터베이스 초기화 스크립트 실행을 확인합니다..."
    # MySQL 초기화 확인
    if docker-compose exec -T mysql mysql -u euroameri -pstrong_password_123 euroamericar -e "SELECT COUNT(*) FROM admin;" > /dev/null 2>&1; then
        success_msg "데이터베이스 초기화 스크립트가 성공적으로 실행되었습니다."
    else
        warn_msg "초기화 스크립트 실행 중... 조금 더 기다립니다."
        sleep 15
    fi
    
    info_msg "백엔드를 시작합니다..."
    docker-compose up -d backend
    sleep 20
    
    info_msg "전체 서비스를 시작합니다..."
    docker-compose up -d
    sleep 10
    
    # 초기 데이터 확인
    info_msg "초기 데이터를 확인합니다..."
    if docker-compose exec -T mysql mysql -u euroameri -pstrong_password_123 euroamericar -e "SELECT title FROM post LIMIT 1;" > /dev/null 2>&1; then
        success_msg "초기 데이터가 정상적으로 로드되었습니다."
    else
        warn_msg "초기 데이터 로드에 문제가 있을 수 있습니다."
    fi
    
    show_status
}

# 정지
stop() {
    title_msg "서비스를 정지합니다..."
    docker-compose down
    success_msg "서비스 정지 완료!"
}

# 상태 확인
status() {
    title_msg "서비스 상태를 확인합니다..."
    
    if ! docker ps >/dev/null 2>&1; then
        warn_msg "Docker가 실행되지 않고 있습니다."
        return
    fi
    
    echo "📊 컨테이너 상태:"
    docker-compose ps
    echo ""
    
    # 연결 테스트
    echo "🌐 서비스 연결 테스트:"
    
    if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200\|404"; then
        success_msg "웹사이트 (Nginx): http://localhost ✓"
    else
        warn_msg "웹사이트 (Nginx): http://localhost ✗"
    fi
    
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|404"; then
        success_msg "프론트엔드: http://localhost:3000 ✓"
    else
        warn_msg "프론트엔드: http://localhost:3000 ✗"
    fi
    
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:4000 | grep -q "200\|404\|401"; then
        success_msg "백엔드 API: http://localhost:4000 ✓"
    else
        warn_msg "백엔드 API: http://localhost:4000 ✗"
    fi
}

# 상태 표시 (내부 함수)
show_status() {
    echo ""
    status
    echo ""
    echo "🔍 문제가 있다면:"
    echo "   ./euroameri.sh logs     # 로그 확인"
    echo "   ./euroameri.sh restart  # 재시작"
    echo "   ./euroameri.sh fresh    # 완전 초기화"
}

# 로그 확인
logs() {
    title_msg "로그를 확인합니다..."
    
    if [ -z "$2" ]; then
        echo "전체 로그 (Ctrl+C로 종료):"
        docker-compose logs -f
    else
        case "$2" in
            backend|back|be)
                echo "백엔드 로그 (Ctrl+C로 종료):"
                docker-compose logs -f backend
                ;;
            frontend|front|fe)
                echo "프론트엔드 로그 (Ctrl+C로 종료):"
                docker-compose logs -f frontend
                ;;
            mysql|db)
                echo "MySQL 로그 (Ctrl+C로 종료):"
                docker-compose logs -f mysql
                ;;
            nginx)
                echo "Nginx 로그 (Ctrl+C로 종료):"
                docker-compose logs -f nginx
                ;;
            *)
                echo "사용법: ./euroameri.sh logs [backend|frontend|mysql|nginx]"
                ;;
        esac
    fi
}

# 재시작
restart() {
    title_msg "서비스를 재시작합니다..."
    docker-compose restart
    show_status
}

# 업데이트
update() {
    title_msg "소스 코드를 업데이트합니다..."
    
    if [ -d "euroameri-car-back" ]; then
        info_msg "백엔드 업데이트 중..."
        cd euroameri-car-back && git pull && cd ..
    fi
    
    if [ -d "euroameri-car-front" ]; then
        info_msg "프론트엔드 업데이트 중..."
        cd euroameri-car-front && git pull && cd ..
    fi
    
    # Dockerfile 재복사
    [ -f "dockerfiles/Dockerfile.backend" ] && cp dockerfiles/Dockerfile.backend euroameri-car-back/Dockerfile
    [ -f "dockerfiles/Dockerfile.frontend" ] && cp dockerfiles/Dockerfile.frontend euroameri-car-front/Dockerfile
    
    success_msg "업데이트 완료! 재시작이 필요할 수 있습니다."
}

# 데이터베이스 초기화 스크립트 확인
db_check() {
    title_msg "데이터베이스 초기화 상태를 확인합니다..."
    
    if ! docker ps | grep -q "euroameri-mysql"; then
        warn_msg "MySQL 컨테이너가 실행되지 않고 있습니다."
        return 1
    fi
    
    echo "📊 데이터베이스 정보:"
    docker-compose exec -T mysql mysql -u euroameri -pstrong_password_123 euroamericar -e "
        SELECT 'Admin 계정' as 테이블, COUNT(*) as 개수 FROM admin
        UNION ALL
        SELECT 'Post 게시물', COUNT(*) FROM post
        UNION ALL  
        SELECT 'Comment 댓글', COUNT(*) FROM comment
        UNION ALL
        SELECT 'Image 이미지', COUNT(*) FROM image;
    " 2>/dev/null || warn_msg "데이터베이스 연결에 실패했습니다."
    
    echo ""
    echo "🔍 초기화 스크립트 위치: mysql/init/01-init.sql"
    echo "📝 초기화 스크립트 내용:"
    echo "   - 데이터베이스 생성: euroamericar"
    echo "   - 사용자 생성: euroameri"
    echo "   - 테이블 생성: admin, post, comment, image, users"
    echo "   - 초기 데이터: admin 계정, 샘플 게시물"
}

# 도움말
help() {
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}🚀 Euroameri Car 통합 관리 스크립트${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
    echo "사용법: ./euroameri.sh [명령어]"
    echo ""
    echo "📋 주요 명령어:"
    echo "  setup       초기 설정 (레포지토리 클론, 환경 설정)"
    echo "  start       서비스 시작 (DB 초기화 스크립트 자동 확인)"
    echo "  stop        서비스 정지"
    echo "  restart     서비스 재시작"
    echo "  fresh       완전 초기화 후 시작 (모든 데이터 삭제)"
    echo "  status      서비스 상태 확인"
    echo "  update      소스 코드 업데이트"
    echo "  db-check    데이터베이스 초기화 스크립트 실행 상태 확인"
    echo ""
    echo "🔍 디버깅 명령어:"
    echo "  logs        전체 로그 확인"
    echo "  logs backend    백엔드 로그만 확인"
    echo "  logs frontend   프론트엔드 로그만 확인"
    echo "  logs mysql      MySQL 로그만 확인"
    echo "  logs nginx      Nginx 로그만 확인"
    echo ""
    echo "🌐 접속 정보:"
    echo "  웹사이트: http://localhost (포트 번호 없이!)"
    echo "  프론트엔드: http://localhost:3000"
    echo "  백엔드 API: http://localhost:4000"
    echo "  MySQL: localhost:3306"
    echo ""
    echo "💡 빠른 시작:"
    echo "  ./euroameri.sh setup && ./euroameri.sh start"
}

# 메인 로직
case "${1:-help}" in
    setup|init)
        setup
        ;;
    start|up)
        start
        ;;
    fresh|clean)
        fresh_start
        ;;
    stop|down)
        stop
        ;;
    restart)
        restart
        ;;
    status|ps)
        status
        ;;
    logs|log)
        logs "$@"
        ;;
    update)
        update
        ;;
    db-check|dbcheck|db)
        db_check
        ;;
    help|--help|-h)
        help
        ;;
    *)
        error_msg "알 수 없는 명령어: $1"
        echo ""
        help
        exit 1
        ;;
esac
