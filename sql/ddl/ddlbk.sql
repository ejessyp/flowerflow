--
-- Creating a small table.
-- Create a database and a user having access to this database,
-- this must be done by hand, se commented rows on how to do it.
--


drop database IF EXISTS ramverk;
CREATE DATABASE IF NOT EXISTS ramverk;

-- Välj vilken databas du vill använda
USE ramverk;
set NAMES utf8;
SET GLOBAL log_bin_trust_function_creators = 1;
SET GLOBAL local_infile = 1;
-- Skapa en användare user med lösenorder pass och ge tillgång oavsett
-- hostnamn.
CREATE USER IF NOT EXISTS 'user'@'%'
    IDENTIFIED BY 'pass'
;

-- Ge användaren alla rättigheter på en specifk databas.
GRANT ALL PRIVILEGES
    ON ramverk.*
    TO 'user'@'%'
;

DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS post2tag;
DROP TABLE IF EXISTS post_votes;
DROP TABLE IF EXISTS comment_votes;
DROP TABLE IF EXISTS comments;



--
-- Table User
--

CREATE TABLE users (
  `id` INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  `username` CHAR(40) UNIQUE,
  `firstname` CHAR(20),
  `lastname` CHAR(20),
  `password` CHAR(10),
  `email` CHAR(20),
  `type` CHAR(10),
  `created` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `points` INT DEFAULT 0,
  `deleted` DATETIME

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_swedish_ci;


CREATE TABLE posts (
    id INT AUTO_INCREMENT,
    title TEXT NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    content TEXT NOT NULL,
    user_id INT NOT NULL,
    deleted BIT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES user(id),
    PRIMARY KEY (id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE tags (
    id INT AUTO_INCREMENT,
    tagname TEXT NOT NULL,

    PRIMARY KEY (id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE post2tag (
    post_id INT,
    tagname INT,

    FOREIGN KEY (post_id) REFERENCES post(id),
    FOREIGN KEY (tagname) REFERENCES tags(tagname),
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE post_votes (
    id INT AUTO_INCREMENT,
    score INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),

    post_id INT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id),

    UNIQUE INDEX `user_id:post_id` (user_id, post_id),

    PRIMARY KEY (id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE comments (
    id INT AUTO_INCREMENT,
    comment TEXT,
    post_id INT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    comment_reply_id INT,
    FOREIGN KEY (comment_reply_id) REFERENCES comments(id),
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    answer BIT DEFAULT 0,
    deleted BIT DEFAULT 0,
    PRIMARY KEY (id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE comment_votes (
    id INT AUTO_INCREMENT,
    score INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    comment_id INT NOT NULL,
    FOREIGN KEY (comment_id) REFERENCES comments(id),

    UNIQUE INDEX `user_id:comment_id` (user_id, comment_id),
    PRIMARY KEY (id, user_id, comment_id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Insert into users
--
DELETE FROM users;

LOAD DATA LOCAL INFILE 'user.csv'
INTO TABLE users
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
SET created = CURRENT_TIMESTAMP
;

CREATE TABLE bbs_article (
art_id int(11) NOT NULL,
art_user_id int(11) DEFAULT NULL,
art_title varchar(255) DEFAULT NULL COMMENT '标题',
art_type_id int(11) DEFAULT NULL COMMENT '类型id',
art_content text COMMENT '正文',
art_comment_id int(11) DEFAULT NULL COMMENT '评论id',
art_cre_time datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
art_view int(11) DEFAULT NULL COMMENT '浏览量',
art_com_num int(11) DEFAULT NULL COMMENT '评论数',
art_hot_num int(11) DEFAULT NULL COMMENT '当日浏览量/热度',
art_like_num int(11) DEFAULT NULL COMMENT '点赞数',
PRIMARY KEY (art_id),
KEY type_index (art_type_id),
KEY com_index (art_comment_id),
KEY art_index (art_user_id),
CONSTRAINT art_index FOREIGN KEY (art_user_id) REFERENCES bbs_user (user_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
CONSTRAINT type_index FOREIGN KEY (art_type_id) REFERENCES bbs_article_type (type_id) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='文章表';
