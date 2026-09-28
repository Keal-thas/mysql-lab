-- Oracle 19c 典型语法样本，用于 Oracle -> PostgreSQL 兼容性 PoC。
-- 来源：手工整理的常见迁移痛点（ROWNUM / (+) 外连接 / CONNECT BY / 隐式类型转换 / PL/SQL 包），
-- 不是从某个具体系统抓的真实 SQL，只是覆盖面广的样本集。

-- 建表 + 序列 + 触发器模拟自增（Oracle 传统写法，12c 之前没有 IDENTITY）
CREATE TABLE departments (
    dept_id     NUMBER(10) NOT NULL PRIMARY KEY,
    dept_name   VARCHAR2(100) NOT NULL,
    manager_id  NUMBER(10)
);

CREATE SEQUENCE dept_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE employees (
    emp_id      NUMBER(10) NOT NULL PRIMARY KEY,
    emp_name    VARCHAR2(100),
    hire_date   DATE DEFAULT SYSDATE,
    salary      NUMBER(12,2),
    dept_id     NUMBER(10),
    mgr_id      NUMBER(10)
);

-- 1) ROWNUM 分页（PG 没有 ROWNUM，要改 LIMIT/OFFSET）
SELECT * FROM (
    SELECT e.*, ROWNUM rn FROM (
        SELECT * FROM employees ORDER BY salary DESC
    ) e WHERE ROWNUM <= 10
) WHERE rn > 0;

-- 2) 老式 (+) 外连接（PG 完全不支持，必须改成标准 LEFT/RIGHT JOIN）
SELECT e.emp_name, d.dept_name
FROM employees e, departments d
WHERE e.dept_id = d.dept_id (+);

-- 3) CONNECT BY 层次查询（PG 用 WITH RECURSIVE 改写）
SELECT emp_id, emp_name, LEVEL, SYS_CONNECT_BY_PATH(emp_name, '/') AS path
FROM employees
START WITH mgr_id IS NULL
CONNECT BY PRIOR emp_id = mgr_id;

-- 4) 字符串拼接 || 和 NVL/DECODE（PG 支持 ||，但 NVL/DECODE 需要 orafce 扩展或改写成 COALESCE/CASE）
SELECT emp_name || ' - ' || NVL(TO_CHAR(dept_id), 'N/A') AS label,
       DECODE(dept_id, 10, 'Sales', 20, 'Eng', 'Other') AS dept_label
FROM employees;

-- 5) 日期函数差异（SYSDATE、ADD_MONTHS、TO_CHAR 格式化模型不同）
SELECT emp_name,
       TO_CHAR(hire_date, 'YYYY-MM-DD HH24:MI:SS') AS hired,
       ADD_MONTHS(hire_date, 6) AS six_months_later
FROM employees
WHERE hire_date > SYSDATE - 365;

-- 6) 隐式类型转换（Oracle 很宽松，字符串和数字比较不报错；PG 严格，直接报错）
SELECT * FROM employees WHERE emp_id = '1001';

-- 7) 分析函数 / 窗口函数（19c 和 PG 都支持，语法基本一致，用来验证"没问题的部分"）
SELECT emp_name, salary,
       RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rnk
FROM employees;

-- 8) PL/SQL 存储过程 + 包（PG 要改写成 PL/pgSQL 函数，包在 PG 里没有直接对应物，
--    常见做法是拆成多个 schema 内的函数，或者用 PG 的 schema 模拟命名空间）
CREATE OR REPLACE PROCEDURE raise_salary(p_emp_id IN NUMBER, p_pct IN NUMBER) IS
BEGIN
    UPDATE employees
    SET salary = salary * (1 + p_pct / 100)
    WHERE emp_id = p_emp_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Employee not found: ' || p_emp_id);
    END IF;
    COMMIT;
END;
/

CREATE OR REPLACE PACKAGE emp_pkg AS
    FUNCTION get_headcount(p_dept_id NUMBER) RETURN NUMBER;
END emp_pkg;
/

CREATE OR REPLACE PACKAGE BODY emp_pkg AS
    FUNCTION get_headcount(p_dept_id NUMBER) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM employees WHERE dept_id = p_dept_id;
        RETURN v_count;
    END;
END emp_pkg;
/

-- 9) MERGE 语句（PG 15+ 才支持 MERGE，15 以前得用 INSERT ... ON CONFLICT）
MERGE INTO departments d
USING (SELECT 99 AS dept_id, 'Temp Dept' AS dept_name FROM dual) src
ON (d.dept_id = src.dept_id)
WHEN MATCHED THEN UPDATE SET d.dept_name = src.dept_name
WHEN NOT MATCHED THEN INSERT (dept_id, dept_name) VALUES (src.dept_id, src.dept_name);

-- 10) DUAL 表（PG 没有 dual，SELECT 1 就行，但大量遗留 SQL 会写 FROM dual）
SELECT SYSDATE FROM dual;
