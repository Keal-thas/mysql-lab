-- Run in session B, after session A's first SELECT COUNT(*)
USE iso_lab;

START TRANSACTION;
INSERT INTO items (id, val) VALUES (4, 25);
COMMIT;
