# Euroameri Car - 인프라 설정 레포지토리

이 레포지토리는 Euroameri Car 프로젝트의 Docker 및 Nginx 프록시 서버 설정을 관리합니다.

## 📁 레포지토리 구조

```
euroameri-car-infra/
├── docker-compose.yml          # Docker Compose 설정
├── nginx/                      # Nginx 설정
│   ├── nginx.conf             # 메인 Nginx 설정
│   └── conf.d/
│       └── default.conf       # 프록시 서버 설정
├── dockerfiles/               # Dockerfile 템플릿들
│   ├── Dockerfile.backend     # 백엔드용 Dockerfile
│   ├── Dockerfile.frontend    # 프론트엔드용 Dockerfile
│   ├── .dockerignore.backend  # 백엔드용 dockerignore
│   └── .dockerignore.frontend # 프론트엔드용 dockerignore
├── scripts/                   # 실행 스크립트들
│   ├── start.sh              # 서비스 시작
│   └── stop.sh               # 서비스 중지
├── setup.sh                  # 초기 설정 스크립트
├── update-repos.sh           # 레포지토리 업데이트
├── env.example              # 환경 변수 예시
└── README.md               # 이 파일
```

## 🚀 빠른 시작

### 1. 초기 설정

```bash
# 1. 이 레포지토리 클론
git clone <이-레포지토리-URL> euroameri-car-infra
cd euroameri-car-infra

# 2. 초기 설정 실행 (백엔드/프론트엔드 레포지토리 클론)
./setup.sh

# 3. 환경 변수 설정 (필요한 경우 .env 파일 수정)
cp env.example .env
```

### 2. 서비스 실행

```bash
# 전체 서비스 시작
./scripts/start.sh

# 또는 직접 실행
docker-compose up --build -d
```

### 3. 접속 정보

- **웹사이트**: http://localhost
- **API**: http://localhost/api/
- **MySQL**: localhost:3306

## 🔄 업데이트

### 코드 업데이트

```bash
# 백엔드/프론트엔드 레포지토리 업데이트
./update-repos.sh

# 서비스 재시작
docker-compose up --build -d
```

### 인프라 설정 업데이트

```bash
# 이 레포지토리 업데이트
git pull

# 서비스 재시작
docker-compose down
docker-compose up --build -d
```

## 🔧 개발 워크플로우

### 1. 로컬 개발

```bash
# 개발자 각자의 로컬 환경에서
./setup.sh          # 최초 한 번만
./update-repos.sh    # 코드 업데이트 시
./scripts/start.sh   # 서비스 시작
```

### 2. 프로덕션 배포

```bash
# 서버에서
git pull                    # 인프라 설정 업데이트
./update-repos.sh          # 애플리케이션 코드 업데이트
docker-compose down        # 기존 서비스 중지
docker-compose up --build -d  # 새 버전으로 시작
```

## 🏗️ 아키텍처

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   사용자 요청    │───▶│  Nginx (포트80) │───▶│ 백엔드/프론트엔드 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │ MySQL (포트3306) │
                       └─────────────────┘
```

### 라우팅 규칙

- `/` → 프론트엔드 (Next.js, 포트 3000)
- `/api/` → 백엔드 (Express.js, 포트 4000)
- 정적 파일은 캐싱 및 압축 적용

## 📋 관련 레포지토리

- **백엔드**: [euroameri-car-back 레포지토리 URL]
- **프론트엔드**: [euroameri-car-front 레포지토리 URL]
- **인프라**: [이 레포지토리]

## 🛠️ 유지보수

### 로그 확인

```bash
# 전체 로그
docker-compose logs -f

# 특정 서비스 로그
docker-compose logs nginx
docker-compose logs backend
docker-compose logs frontend
```

### 트러블슈팅

```bash
# 서비스 상태 확인
docker-compose ps

# 컨테이너 재시작
docker-compose restart nginx

# 전체 재빌드
docker-compose build --no-cache
```

## 🔐 보안 설정

- Nginx 보안 헤더 자동 적용
- 서버 정보 숨김 설정
- CORS 정책 설정
- 파일 업로드 크기 제한

## 📊 모니터링

- 헬스체크 엔드포인트: `/health`
- 각 컨테이너별 헬스체크 내장
- 로그 로테이션 설정
