#!/bin/bash

# 개발환경 .env 파일 생성 스크립트

echo "🔧 개발환경 .env 파일을 생성합니다..."

cat > .env << 'EOF'
# =======================================================
# 개발환경 설정
# =======================================================

# 데이터베이스 설정
DB_HOST=mysql
DB_PORT=3306
DB_USERNAME=euroameri
DB_PASSWORD=strong_password_123
DB_NAME=euroamericar

# MySQL 루트 패스워드
MYSQL_ROOT_PASSWORD=root_password_456

# 애플리케이션 설정
NODE_ENV=development
BACKEND_PORT=4000
FRONTEND_PORT=3000

# 도메인 설정 (개발환경)
DOMAIN=localhost
CLIENT_URL=http://localhost

# 프론트엔드에서 사용할 API URL (개발환경)
NEXT_PUBLIC_API_URL=http://localhost:4000

# 세션 시크릿 (개발용)
SESSION_SECRET=euroameri_development_secret_key
EOF

echo "✅ 개발환경 .env 파일이 생성되었습니다!"
echo "📁 파일 위치: $(pwd)/.env"
