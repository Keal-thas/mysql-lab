CREATE DATABASE IF NOT EXISTS gap_lock_lab;
USE gap_lock_lab;

DROP TABLE IF EXISTS points;
CREATE TABLE points (
    id INT PRIMARY KEY,
    val INT NOT NULL,
    INDEX idx_val (val)
) ENGINE = InnoDB;

INSERT INTO points VALUES (1, 10), (2, 20), (3, 30);
