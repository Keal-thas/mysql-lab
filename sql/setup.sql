CREATE DATABASE IF NOT EXISTS deadlock_lab;
USE deadlock_lab;

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    balance DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB;

INSERT INTO accounts (id, name, balance) VALUES
    (1, 'Alice', 1000.00),
    (2, 'Bob', 1000.00);
