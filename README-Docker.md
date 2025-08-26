# Euroameri Car - Docker & Nginx 프록시 설정

## 🚀 빠른 시작

### 1. 환경 설정

```bash
# 환경 변수 파일 복사
cp env.example .env

# 필요한 경우 .env 파일을 수정하세요
```

### 2. Docker Compose로 실행

```bash
# 모든 서비스 빌드 및 실행
docker-compose up --build

# 백그라운드에서 실행
docker-compose up -d --build

# 로그 확인
docker-compose logs -f
```

### 3. 서비스 접속

- **웹사이트**: http://localhost
- **API**: http://localhost/api/
- **MySQL**: localhost:3306

## 📁 프로젝트 구조

```
euroameri-car/
├── docker-compose.yml          # Docker Compose 설정
├── nginx/                      # Nginx 설정
│   ├── nginx.conf             # 메인 Nginx 설정
│   └── conf.d/
│       └── default.conf       # 프록시 서버 설정
├── euroameri-car-back/        # 백엔드 (Node.js/Express)
│   ├── Dockerfile
│   └── .dockerignore
├── euroameri-car-front/       # 프론트엔드 (Next.js)
│   ├── Dockerfile
│   └── .dockerignore
└── env.example                # 환경 변수 예시
```

## 🔧 서비스 구성

### Nginx 프록시 서버

- **포트**: 80, 443
- **역할**:
  - 프론트엔드(`/`)와 백엔드(`/api/`) 요청 라우팅
  - 정적 파일 캐싱
  - 로드 밸런싱
  - 보안 헤더 추가

### 백엔드 서버 (Node.js)

- **포트**: 4000 (내부)
- **기술**: Express.js + TypeScript
- **경로**: `/api/*` 요청 처리

### 프론트엔드 서버 (Next.js)

- **포트**: 3000 (내부)
- **기술**: Next.js + React + TypeScript
- **경로**: `/` 루트 요청 처리

### 데이터베이스 (MySQL)

- **포트**: 3306
- **버전**: MySQL 8.0
- **데이터**: `mysql_data` 볼륨에 영구 저장

## 🛠️ 개발 명령어

```bash
# 특정 서비스만 재시작
docker-compose restart nginx
docker-compose restart backend
docker-compose restart frontend

# 특정 서비스 로그 확인
docker-compose logs nginx
docker-compose logs backend
docker-compose logs frontend

# 컨테이너 내부 접속
docker-compose exec backend sh
docker-compose exec frontend sh
docker-compose exec nginx sh

# 서비스 중지
docker-compose down

# 볼륨까지 모두 삭제
docker-compose down -v

# 이미지 재빌드
docker-compose build --no-cache
```

## 🔧 프로덕션 설정

### 1. 환경 변수 수정

```bash
# .env 파일에서 프로덕션 설정으로 변경
NODE_ENV=production
DOMAIN=yourdomain.com
CLIENT_URL=https://yourdomain.com
```

### 2. HTTPS 설정 (선택사항)

SSL 인증서가 있는 경우, `nginx/conf.d/` 디렉토리에 HTTPS 설정을 추가할 수 있습니다.

### 3. Dockerfile 수정

프로덕션 환경에서는 각 Dockerfile의 `CMD` 부분을 다음과 같이 수정:

**백엔드**:

```dockerfile
CMD ["yarn", "start"]
```

**프론트엔드**:

```dockerfile
RUN yarn build
CMD ["yarn", "start"]
```

## 🐛 트러블슈팅

### 포트 충돌

- 80 포트가 이미 사용 중인 경우: `docker-compose.yml`에서 nginx 포트를 `8080:80`으로 변경

### 데이터베이스 연결 실패

- MySQL 컨테이너가 완전히 시작될 때까지 기다리세요
- `docker-compose logs mysql`로 데이터베이스 로그 확인

### 빌드 실패

- Docker 이미지와 컨테이너 정리: `docker system prune -a`
- 의존성 재설치: `docker-compose build --no-cache`

## 📊 모니터링

### 헬스 체크

- **Nginx**: http://localhost/health
- **백엔드**: 컨테이너 자체 헬스체크 내장
- **프론트엔드**: 컨테이너 자체 헬스체크 내장

### 로그 모니터링

```bash
# 실시간 로그 모니터링
docker-compose logs -f --tail=100

# 특정 시간대 로그
docker-compose logs --since="2024-01-01T00:00:00" --until="2024-01-01T23:59:59"
```
