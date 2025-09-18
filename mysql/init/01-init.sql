-- Euroameri Car 데이터베이스 초기화
-- TypeORM 실제 구조에 맞춘 테이블 생성

-- Health Check 테이블
CREATE TABLE IF NOT EXISTS health_check (
    id INT AUTO_INCREMENT PRIMARY KEY,
    status VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admin 테이블 (TypeORM 실제 구조)
CREATE TABLE IF NOT EXISTS admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    uid VARCHAR(255) NOT NULL
);

-- Post 테이블 (TypeORM 실제 구조)
CREATE TABLE IF NOT EXISTS post (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255),
    secret TINYINT NOT NULL DEFAULT 0,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    name VARCHAR(30) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    deleted_at DATETIME(6) NULL
);

-- Comment 테이블 (TypeORM 실제 구조)
CREATE TABLE IF NOT EXISTS comment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    content TEXT NOT NULL,
    deleted_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    INDEX FK_comment_post_id (post_id),
    FOREIGN KEY (post_id) REFERENCES post(id) ON DELETE CASCADE
);

-- Image 테이블 (TypeORM 실제 구조)
CREATE TABLE IF NOT EXISTS image (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    src VARCHAR(255) NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    INDEX FK_image_post_id (post_id),
    FOREIGN KEY (post_id) REFERENCES post(id) ON DELETE CASCADE
);

-- Users 테이블 (TypeORM 실제 구조)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 초기 데이터 삽입
INSERT INTO health_check (status) VALUES ('Database initialized successfully');

-- 초기 Admin 사용자 생성 (TypeORM 컬럼 순서에 맞춤)
DELETE FROM admin;
INSERT INTO admin (uid, password) VALUES ('euroadmin', 'euroadmin');

-- 실제 게시판 데이터 삽입 (TypeORM 컬럼 순서에 맞춤)
INSERT INTO post (id, title, content, name, email, phone, password, secret, created_at, deleted_at) VALUES 
(1, '유로아메리카 게시판', '유로아메리카 게시판이 오픈 되었습니다.  많이 사용해 주세요.', 'STEEL HORSE', 'sales@euroamericar.com', '01087270663', '$2b$12$XFgcGYI5AkzpPt4VHYgkQuf9jhVMyznKgixHopJJui/QOC1XX0x2S', 0, '2022-08-30 08:37:57.461127', NULL),
(2, '해외부품 문의', '안녕하세요 해외부품 문의좀 드리려 합니다 \n제 차량이 2022 더 뉴K3 2세대 차량 인데 \n리어 하단커버를 2022 Forte GT 4DOOR\n디퓨저로 변경하려고 합니다 \n부품번호\nLower Cover - kia (86650-M7GA0)', '전성희', 'totopis2020@naver.com', '01091243956', '$2b$12$DqOoZiUDnDOtLnKGMDNXxOiZJlfqbTPtUyoMSXB7k.XCMvFEVJFb2', 1, '2024-03-05 18:16:02.139578', NULL);