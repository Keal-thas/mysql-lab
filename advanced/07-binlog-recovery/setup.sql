CREATE DATABASE IF NOT EXISTS pit_lab;
USE pit_lab;

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    balance DECIMAL(10,2) NOT NULL
) ENGINE = InnoDB;

INSERT INTO accounts VALUES (1, 'Alice', 1000.00), (2, 'Bob', 500.00);
