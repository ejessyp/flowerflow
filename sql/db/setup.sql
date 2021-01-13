-- Skapa databas
-- CREATE DATABASE lab;
drop database IF EXISTS lab;
CREATE DATABASE IF NOT EXISTS lab;

-- Välj vilken databas du vill använda
USE lab;
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
    ON lab.*
    TO 'user'@'%'
;

-- Visa vad en användare kan göra mot vilken databas.
SHOW GRANTS FOR 'user'@'%';

-- -- Visa för nuvarande användare
SHOW GRANTS FOR CURRENT_USER;
