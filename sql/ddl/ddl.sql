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
  `password` VARCHAR(255),
  `email` CHAR(20),
  `type` CHAR(10),
  `created` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `points` INT DEFAULT 0,
  `deleted` DATETIME
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;;


CREATE TABLE posts (
    id INT AUTO_INCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    user_id INT NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted BIT DEFAULT 0,

    FOREIGN KEY (user_id) REFERENCES users(id),
    PRIMARY KEY (id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;;

CREATE TABLE tags (
    tagname VARCHAR(32) NOT NULL,
    description VARCHAR(256) NOT NULL,
    image VARCHAR(30),

    PRIMARY KEY (tagname)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE post2tag (
    post_id INT,
    tag_name VARCHAR(32),

    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (tag_name) REFERENCES tags(tagname),
    INDEX post_id_index (post_id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE post_votes (
    id INT AUTO_INCREMENT,
    score INT NOT NULL,
    post_id INT NOT NULL,
    user_id INT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id),

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
    answer BOOLEAN  default 1,
    accepted TINYINT(1) default 0,
    deleted TINYINT(1) default 0,
    PRIMARY KEY (id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE comment_votes (
    id INT AUTO_INCREMENT,
    score INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    comment_id INT NOT NULL,
    FOREIGN KEY (comment_id) REFERENCES comments(id),

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

-- Insert into tags
--
DELETE FROM tags;
LOAD DATA LOCAL INFILE 'tags.csv'
INTO TABLE tags
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
;

-- Insert into posts
--
DELETE FROM posts;
LOAD DATA LOCAL INFILE 'posts.csv'
INTO TABLE posts
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
SET created = CURRENT_TIMESTAMP
;

-- Insert into post2tag
--
DELETE FROM post2tag;
LOAD DATA LOCAL INFILE 'post2tag.csv'
INTO TABLE post2tag
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
;


-- Insert into comments
--
DELETE FROM comments;
LOAD DATA LOCAL INFILE 'comments.csv'
INTO TABLE comments
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
SET answer = b'1',
    created = CURRENT_TIMESTAMP
;

--
-- -- Insert into post_votes
-- --
-- DELETE FROM post_votes;
-- LOAD DATA LOCAL INFILE 'post_votes.csv'
-- INTO TABLE post_votes
-- CHARSET utf8
-- FIELDS
--     TERMINATED BY ','
--     ENCLOSED BY '"'
-- LINES
--     TERMINATED BY '\n'
-- IGNORE 1 LINES
-- ;

DROP view if exists v_posts_comments_tags;
CREATE VIEW v_posts_comments_tags
AS
SELECT
    p.id as postid, p.title, p.content, p.created as postcreated, p.deleted as postdeleted, c.*, group_concat(pt.tag_name) as tags
FROM posts AS p
    JOIN comments AS c
        ON p.id = c.post_id
    JOIN post2tag AS pt
        ON c.post_id = pt.post_id
group by id
;
DELIMITER ;

--
-- Create a temporary view for all posts and then join with post2tag
--
DROP view if exists v_posts_comments;
CREATE VIEW v_posts_comments
AS
SELECT
    p.*, sum(c.answer) as answer
FROM posts AS p
    LEFT JOIN comments AS c
        ON p.id = c.post_id
group by id;
DELIMITER ;

--
-- Create a temporary view for all posts and then join with post2tag
--
DROP view if exists v_posts_comments_pv;
CREATE VIEW v_posts_comments_pv
AS
SELECT
    vpc.*, sum(pv.score) as votes
FROM v_posts_comments AS vpc
    LEFT JOIN post_votes AS pv
        ON vpc.id = pv.post_id
group by id;
DELIMITER ;
--
-- Create a view for all posts
--
DROP view if exists v_all;
CREATE VIEW v_all
AS
SELECT
    v.*, group_concat(tag_name) as tags
FROM v_posts_comments_pv AS v
    JOIN post2tag AS pt
        ON v.id = pt.post_id
group by id;
DELIMITER ;

--
-- Create a view for all posts
--
DROP view if exists v_all_user;
CREATE VIEW v_all_user
AS
SELECT
    v.*, u.username
FROM v_all AS v
    JOIN users AS u
        ON u.id = v.user_id;
DELIMITER ;

--
-- Create a view for comments for one question
--
DROP view if exists v_comments_user;
CREATE VIEW v_comments_user
AS
SELECT
    p.user_id as post_userid, c.*, u.username
FROM posts AS p
    RIGHT JOIN comments AS c
        ON p.id = c.post_id
    JOIN users AS u
        ON u.id = c.user_id;
DELIMITER ;

--
-- Create a view for post votes
--
DROP view if exists v_post_votes;
CREATE VIEW v_post_votes
AS
SELECT post_id, sum(score) as postscore from post_votes group by post_id;
DELIMITER ;

--
-- Create a view for comment votes
--
DROP view if exists v_comment_votes;
CREATE VIEW v_comment_votes
AS
SELECT comment_id, sum(score) as commentscore from comment_votes group by comment_id;
DELIMITER ;
