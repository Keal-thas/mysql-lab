CREATE DATABASE IF NOT EXISTS nk_lab;
USE nk_lab;

DROP TABLE IF EXISTS points;
CREATE TABLE points (
    id INT PRIMARY KEY,
    val INT NOT NULL,
    INDEX idx_val (val)
) ENGINE = InnoDB;

INSERT INTO points VALUES (1, 10), (2, 20), (3, 30);
