CREATE DATABASE IF NOT EXISTS iso_lab;
USE iso_lab;

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
    id INT PRIMARY KEY,
    balance DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB;
INSERT INTO accounts (id, balance) VALUES (1, 100.00);

DROP TABLE IF EXISTS items;
CREATE TABLE items (
    id INT PRIMARY KEY,
    val INT NOT NULL
) ENGINE=InnoDB;
INSERT INTO items (id, val) VALUES (1, 10), (2, 20), (3, 30);
