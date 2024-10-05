1.什么是触发器
触发器是在数据库中定义的一种特殊的存储过程，它会在特定的数据库事件发生时自动执行。触发器可以帮助你实现以下功能：
2.触发器的基本原理
CREATE [OR REPLACE] TRIGGER trigger_name
{BEFORE | AFTER | INSTEAD OF} 
{INSERT | UPDATE [OF column_name] | DELETE}
ON table_name
[FOR EACH ROW]
[WHEN (condition)]
BEGIN
    -- 触发器主体 PL/SQL 代码
END trigger_name;
/
3.触发器示例
示例 1：记录插入操作
创建一个触发器，在向 employees 表插入新员工时，自动在 employees_audit 表中记录插入操作的详细信息。
-- 创建审计表
CREATE TABLE employees_audit (
    audit_id NUMBER PRIMARY KEY,
    emp_id NUMBER,
    action VARCHAR2(10),
    action_date DATE,
    username VARCHAR2(30)
);

-- 创建触发器
CREATE OR REPLACE TRIGGER trg_after_insert_emp
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employees_audit (audit_id, emp_id, action, action_date, username)
    VALUES (employees_audit_seq.NEXTVAL, :NEW.id, 'INSERT', SYSDATE, USER);
END;
/

示例 2：防止删除操作
创建一个触发器，防止从 departments 表中删除任何部门
CREATE OR REPLACE TRIGGER trg_before_delete_dept
BEFORE DELETE ON departments
BEGIN
    RAISE_APPLICATION_ERROR(-20001, '删除部门操作被禁止！');
END;
/

示例 3：自动更新时间戳
创建一个触发器，当 employees 表中的记录被更新时，自动更新 last_update 字段为当前日期和时间。
CREATE OR REPLACE TRIGGER trg_before_update_emp
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    :NEW.last_update := SYSDATE;
END;
/

示例 4：复合触发器
复合触发器允许在同一个触发器中定义多个触发事件，
如 BEFORE STATEMENT、BEFORE EACH ROW、AFTER EACH ROW 和 AFTER STATEMENT。
这对于需要在不同触发点执行不同逻辑的情况非常有用。
CREATE OR REPLACE TRIGGER trg_composite_emp
FOR INSERT OR UPDATE OR DELETE ON employees
COMPOUND TRIGGER

    -- 定义一个变量在整个触发器生命周期中共享
    total_changes NUMBER := 0;

    BEFORE STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('开始对 employees 表进行操作。');
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        total_changes := total_changes + 1;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        NULL; -- 可以在这里添加其他逻辑
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('操作结束，共进行了 ' || total_changes || ' 次更改。');
    END AFTER STATEMENT;

END trg_composite_emp;
/

