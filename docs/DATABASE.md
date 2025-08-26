# 📊 데이터베이스 설정 가이드

## 🔧 MySQL 설정 개요

Euroameri Car 프로젝트는 MySQL 8.0을 데이터베이스로 사용하며, Docker를 통해 관리됩니다.

## 📁 데이터베이스 관련 파일 구조

```
mysql/
├── init/
│   └── 01-init.sql          # 데이터베이스 초기화 스크립트
└── my.cnf                   # MySQL 설정 파일
```

## ⚙️ 환경 변수 설정

### `.env` 파일에서 설정 가능한 변수들:

```bash
# 데이터베이스 연결 설정
DB_HOST=mysql                    # Docker 컨테이너명
DB_PORT=3306                     # MySQL 포트
DB_USERNAME=euroameri            # 애플리케이션 사용자
DB_PASSWORD=strong_password_123  # 애플리케이션 패스워드
DB_NAME=euroamericar             # 데이터베이스명

# MySQL 루트 계정
MYSQL_ROOT_PASSWORD=root_password_456
```

## 🚀 데이터베이스 초기화

### 자동 초기화

컨테이너 최초 실행 시 `mysql/init/` 폴더의 SQL 스크립트들이 자동으로 실행됩니다.

#### `01-init.sql`에서 수행하는 작업:

- UTF8MB4 문자셋 설정
- 한국 시간대(+09:00) 설정
- 사용자 권한 부여
- 초기화 상태 확인

### 수동 초기화

```bash
# MySQL 컨테이너 접속
docker-compose exec mysql mysql -u root -p

# 데이터베이스 생성 확인
SHOW DATABASES;
USE euroamericar;
SHOW TABLES;
```

## 🔒 보안 설정

### 1. 패스워드 정책

- 기본 패스워드는 반드시 변경
- 프로덕션에서는 복잡한 패스워드 사용
- 정기적인 패스워드 변경

### 2. 네트워크 보안

- 내부 Docker 네트워크에서만 접근 가능
- 외부 접근이 필요한 경우에만 포트 노출

### 3. 권한 관리

```sql
-- 애플리케이션 사용자는 특정 데이터베이스에만 접근
GRANT SELECT, INSERT, UPDATE, DELETE ON euroamericar.* TO 'euroameri'@'%';

-- 불필요한 권한 제거
REVOKE ALL PRIVILEGES ON *.* FROM 'euroameri'@'%';
```

## 📈 성능 최적화

### MySQL 설정 (`my.cnf`)

```ini
# 버퍼 풀 크기 (사용 가능한 메모리의 70-80%)
innodb_buffer_pool_size=256M

# 로그 파일 크기
innodb_log_file_size=64M

# 연결 수 제한
max_connections=200

# 쿼리 캐시
query_cache_size=32M
```

### 모니터링 쿼리

```sql
-- 성능 상태 확인
SHOW STATUS LIKE 'Innodb_buffer_pool%';
SHOW STATUS LIKE 'Connections';
SHOW STATUS LIKE 'Threads_connected';

-- 느린 쿼리 확인
SHOW VARIABLES LIKE 'slow_query_log';
```

## 🔄 백업 및 복구

### 자동 백업 스크립트

```bash
#!/bin/bash
# backup-db.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"

# 백업 실행
docker-compose exec mysql mysqldump \
  -u root -p${MYSQL_ROOT_PASSWORD} \
  --single-transaction \
  --routines \
  --triggers \
  euroamericar > ${BACKUP_DIR}/euroamericar_${DATE}.sql

echo "백업 완료: euroamericar_${DATE}.sql"
```

### 복구

```bash
# 백업 파일을 컨테이너로 복사
docker cp backup.sql euroameri-mysql:/tmp/

# 복구 실행
docker-compose exec mysql mysql -u root -p euroamericar < /tmp/backup.sql
```

## 🐛 트러블슈팅

### 일반적인 문제들

#### 1. 연결 실패

```bash
# MySQL 컨테이너 상태 확인
docker-compose ps mysql

# 로그 확인
docker-compose logs mysql

# 네트워크 확인
docker network ls
```

#### 2. 문자 인코딩 문제

```sql
-- 현재 문자셋 확인
SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';

-- 테이블 문자셋 변경
ALTER TABLE table_name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 3. 성능 문제

```sql
-- 프로세스 리스트 확인
SHOW PROCESSLIST;

-- 느린 쿼리 확인
SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 10;
```

### 헬스체크 실패

```bash
# MySQL 서비스 재시작
docker-compose restart mysql

# 헬스체크 로그 확인
docker inspect euroameri-mysql | grep -A 10 Health
```

## 📚 유용한 명령어

### 개발용 명령어

```bash
# MySQL 쉘 접속
docker-compose exec mysql mysql -u euroameri -p euroamericar

# 데이터베이스 초기화 (주의: 데이터 삭제됨)
docker-compose down -v
docker-compose up -d mysql

# 실시간 쿼리 모니터링
docker-compose exec mysql mysql -u root -p -e "SHOW PROCESSLIST;"
```

### 운영용 명령어

```bash
# 안전한 재시작 (데이터 보존)
docker-compose stop mysql
docker-compose start mysql

# 메모리 사용량 확인
docker stats euroameri-mysql

# 볼륨 크기 확인
docker system df -v
```
