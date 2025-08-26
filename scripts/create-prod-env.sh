#!/bin/bash

# 프로덕션환경 .env 파일 생성 스크립트

echo "🚀 프로덕션환경 .env 파일을 생성합니다..."

cat > .env << 'EOF'
# =======================================================
# 프로덕션환경 설정
# =======================================================

# 데이터베이스 설정
DB_HOST=mysql
DB_PORT=3306
DB_USERNAME=euroameri
DB_PASSWORD=production_strong_password_456
DB_NAME=euroamericar

# MySQL 루트 패스워드
MYSQL_ROOT_PASSWORD=production_root_password_789

# 애플리케이션 설정
NODE_ENV=production
BACKEND_PORT=4000
FRONTEND_PORT=3000

# 도메인 설정 (프로덕션)
DOMAIN=euroamericar.com
CLIENT_URL=https://euroamericar.com

# 프론트엔드에서 사용할 API URL (프로덕션)
NEXT_PUBLIC_API_URL=https://euroamericar.com

# 세션 시크릿 (프로덕션용 - 실제 배포시 반드시 변경)
SESSION_SECRET=euroameri_production_secret_key_change_this_in_real_deployment
EOF

echo "✅ 프로덕션환경 .env 파일이 생성되었습니다!"
echo "📁 파일 위치: $(pwd)/.env"
echo ""
echo "⚠️  중요: 실제 배포시에는 다음 값들을 반드시 변경하세요:"
echo "   - DB_PASSWORD"
echo "   - MYSQL_ROOT_PASSWORD" 
echo "   - SESSION_SECRET"