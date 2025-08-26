-- Euroameri Car 데이터베이스 초기화 스크립트

-- 데이터베이스 설정
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 시간대 설정
SET time_zone = '+09:00';

-- 사용자 권한 설정 (보안 강화)
GRANT ALL PRIVILEGES ON `euroamericar`.* TO 'euroameri'@'%';
FLUSH PRIVILEGES;

-- 기본 설정 확인
SELECT 
    'Database initialization completed' as status,
    NOW() as timestamp,
    @@character_set_database as charset,
    @@collation_database as collation;
