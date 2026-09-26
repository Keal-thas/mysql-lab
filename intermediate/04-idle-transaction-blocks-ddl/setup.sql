CREATE DATABASE IF NOT EXISTS mdl_lab;
USE mdl_lab;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id INT PRIMARY KEY,
    status VARCHAR(10) NOT NULL
) ENGINE = InnoDB;

INSERT INTO orders VALUES (1, 'paid'), (2, 'pending');
