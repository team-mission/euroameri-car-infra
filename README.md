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

### 간단한 통합 스크립트 사용

```bash
# 1. 이 레포지토리 클론
git clone <이-레포지토리-URL> euroameri-car-infra
cd euroameri-car-infra

# 2. 모든 것을 한 번에!
./euroameri.sh setup && ./euroameri.sh start

# 또는 단계별로:
./euroameri.sh setup    # 초기 설정
./euroameri.sh start    # 서비스 시작
```

### 주요 명령어

```bash
./euroameri.sh start     # 서비스 시작
./euroameri.sh stop      # 서비스 정지
./euroameri.sh fresh     # 완전 초기화 후 시작
./euroameri.sh status    # 상태 확인
./euroameri.sh logs      # 로그 확인
./euroameri.sh update    # 코드 업데이트
```

### 3. 접속 정보

- **웹사이트**: http://localhost (포트 번호 없이 접속!)
- **API**: http://localhost:4000
- **MySQL**: localhost:3306

> 🚨 **중요**: 프론트엔드는 `http://localhost`로, 백엔드 API는 `http://localhost:4000`으로 접속하세요!

## 🔄 사용 예시

### 일반적인 개발 흐름

```bash
# 매일 작업 시작
./euroameri.sh update     # 최신 코드 가져오기
./euroameri.sh start      # 서비스 시작

# 문제가 생겼을 때
./euroameri.sh status     # 상태 확인
./euroameri.sh logs backend  # 백엔드 로그 확인
./euroameri.sh restart    # 재시작

# 완전히 초기화가 필요할 때
./euroameri.sh fresh      # 모든 데이터 초기화 후 재시작

# 작업 종료
./euroameri.sh stop       # 서비스 정지
```

### 문제 해결

```bash
# 단계별 로그 확인
./euroameri.sh logs           # 전체 로그
./euroameri.sh logs backend   # 백엔드만
./euroameri.sh logs frontend  # 프론트엔드만
./euroameri.sh logs mysql     # MySQL만

# 상태 및 연결 테스트
./euroameri.sh status

# 완전 초기화 (DB 포함)
./euroameri.sh fresh
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

- `http://localhost` → 프론트엔드 (Next.js, Nginx 프록시)
- `http://localhost:4000` → 백엔드 (Express.js, 직접 접속)
- 정적 파일은 캐싱 및 압축 적용

## 📋 관련 레포지토리

- **백엔드**: https://github.com/team-mission/euroameri-car-back.git
- **프론트엔드**: https://github.com/team-mission/euroameri-car-front.git
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
