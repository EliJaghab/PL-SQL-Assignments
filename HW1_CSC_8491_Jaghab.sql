DROP TABLE MyEmployees;
CREATE TABLE MyEmployees AS SELECT * FROM HR.Employees;
DROP TABLE HW1Log;
CREATE TABLE HW1Log
(
	Message VARCHAR2(200),
	TStamp TIMESTAMP DEFAULT SYSTIMESTAMP
);
INSERT INTO HW1Log (Message) VALUES ('This is a test');


CREATE OR REPLACE PROCEDURE RaiseSalary (
    emp_id MYEMPLOYEES.EMPLOYEE_ID%TYPE,
    raise_pct INTEGER
) AS
    invalid_id EXCEPTION;
BEGIN
    UPDATE MYEMPLOYEES SET SALARY = SALARY + (SALARY * (raise_pct/100)) WHERE EMPLOYEE_ID = emp_id;
    IF SQL%ROWCOUNT > 0 THEN
        INSERT INTO HW1Log (Message) VALUES ('Employee ' || emp_id || ' was raised by ' || raise_pct || '%');
        COMMIT;
    ELSE
        RAISE invalid_id;
    END IF;
EXCEPTION
    WHEN invalid_id THEN 
        DBMS_OUTPUT.PUT_LINE(SQLERRM || ': Error encountered while trying to give employee ' || emp_id || ' a raise.');
END;
/


-- Before Emp. 179 Initial Salary
DECLARE
    v_employee MYEMPLOYEES%ROWTYPE;
BEGIN
    SELECT * INTO v_employee
    FROM MYEMPLOYEES
    WHERE EMPLOYEE_ID = '179';
    DBMS_OUTPUT.PUT_LINE('Employee ' || v_employee.EMPLOYEE_ID || ' has a salary of ' || v_employee.SALARY);
END;
/
-- Call RaiseSalary
EXEC RaiseSalary('179','10');
/
-- After Emp. 179 Salary Raise
DECLARE
    v_employee MYEMPLOYEES%ROWTYPE;
BEGIN
    SELECT * INTO v_employee
    FROM MYEMPLOYEES
    WHERE EMPLOYEE_ID = '179';
    DBMS_OUTPUT.PUT_LINE('Employee ' || v_employee.EMPLOYEE_ID || ' has a salary of ' || v_employee.SALARY);
END;
/


-- Before Emp. 202 Initial Salary
DECLARE
    v_employee MYEMPLOYEES%ROWTYPE;
BEGIN
    SELECT * INTO v_employee
    FROM MYEMPLOYEES
    WHERE EMPLOYEE_ID = '202';
    DBMS_OUTPUT.PUT_LINE('Employee ' || v_employee.EMPLOYEE_ID || ' has a salary of ' || v_employee.SALARY);
END;
/
-- Call RaiseSalary
EXEC RaiseSalary('202','15');
/
-- After Emp. 202 Salary Raise
DECLARE
    v_employee MYEMPLOYEES%ROWTYPE;
BEGIN
    SELECT * INTO v_employee
    FROM MYEMPLOYEES
    WHERE EMPLOYEE_ID = '202';
    DBMS_OUTPUT.PUT_LINE('Employee ' || v_employee.EMPLOYEE_ID || ' has a salary of ' || v_employee.SALARY);
END;
/

-- Call RaiseSalary for Emp 500
EXEC RaiseSalary('500','20');
/
-- Show all Data and order by ascending time stamp value
SELECT * FROM HW1Log
ORDER BY TStamp ASC;





--Problem 2 
CREATE OR REPLACE PROCEDURE AssignRates (
    raise_pct INTEGER,
    budget INTEGER
) AS
    raise_amt NUMBER := 0;
    remaining_budget NUMBER := budget;
    raise_count NUMBER:= 0;
    skip_count NUMBER := 0;
    CURSOR current_employee IS
    SELECT * FROM MYEMPLOYEES
    ORDER BY Salary ASC, Hire_Date ASC;
BEGIN
    FOR v_employee IN current_employee
    LOOP
        raise_amt := v_employee.SALARY * raise_pct/100;
        --DBMS_OUTPUT.PUT_LINE('Raise Amount: ' || raise_amt || ' Remaining Budget: ' || remaining_budget);
        IF remaining_budget - raise_amt > 0 THEN
            RaiseSalary(v_employee.EMPLOYEE_ID, raise_pct);
            remaining_budget := remaining_budget - raise_amt;
            raise_count := raise_count + 1;
        ELSE
            INSERT INTO HW1Log (Message) VALUES ('Not enough money left to give a raise to employee ' || v_employee.EMPLOYEE_ID);
            skip_count := skip_count + 1;
        COMMIT;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Number of employees who received raises: ' || raise_count);
    DBMS_OUTPUT.PUT_LINE('Number of employees who did not receive raises: ' || skip_count); 
    DBMS_OUTPUT.PUT_LINE('Amount of money left unused in the raise budget: ' || remaining_budget);
END;
/

DROP TABLE MYEMPLOYEES;
CREATE TABLE MYEMPLOYEES AS SELECT * FROM HR.Employees;
TRUNCATE TABLE HW1Log;


-- Run the AssignRaises procedure with a raise percentage of 5 and a raise budget of 25000.
EXEC AssignRates('5','25000');

-- Show all Data and order by ascending time stamp value
SELECT * FROM HW1Log
ORDER BY TStamp ASC;

-- Show employee id and salary of all rows from the myemployee table
SELECT EMPLOYEE_ID, SALARY FROM MYEMPLOYEES
ORDER BY EMPLOYEE_ID ASC;

DROP TABLE MYEMPLOYEES;
CREATE TABLE MYEMPLOYEES AS SELECT * FROM HR.Employees;
TRUNCATE TABLE HW1Log;

-- Run the AssignRaises procedure with a raise percentage of 4 and a raise budget of 26000.
EXEC AssignRates('4','26000');

-- Show all Data and order by ascending time stamp value
SELECT * FROM HW1Log
ORDER BY TStamp ASC;

-- Show employee id and salary of all rows from the myemployee table
SELECT EMPLOYEE_ID, SALARY FROM MYEMPLOYEES
ORDER BY EMPLOYEE_ID ASC;




            
            
            



