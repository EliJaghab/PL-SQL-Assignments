DROP TABLE MyEmployees;

CREATE TABLE MyEmployees AS SELECT * FROM HR.Employees;

--Management is still investigating the issue of raises. 
-- They’re considering a new approach to raises where employees 
-- who make more than average salary get a 3% raise and employees 
-- who make an average or less than average salary get a 5% raise.

 -- Create a PL/SQL function called RaiseCalculator that will implement 
 -- the above rule. The function will take a current salary as an argument 
 -- and return the new raised salary (not the amount of the raise). Note that 
 -- the function should continue to work correctly even after the employees and 
 -- salaries you currently find in the table change in the future, so don’t 
 -- hard-code any literal values in your function.


CREATE OR REPLACE FUNCTION RaiseCalculator (
    salaryBefore MYEMPLOYEES.SALARY%TYPE) 
    RETURN MYEMPLOYEES.SALARY%TYPE
IS
    avgSalary MYEMPLOYEES.SALARY%TYPE;
BEGIN 
    SELECT AVG(SALARY) INTO avgSalary FROM MyEmployees;
    IF salaryBefore > avgSalary THEN
        RETURN salaryBefore + salaryBefore*.03;
    ELSE
        RETURN salaryBefore + salaryBefore*.05;
    END IF;
END;
/

SELECT employee_id, salary, RaiseCalculator(salary) AS raised_salary
FROM myemployees 
ORDER BY salary;







-- Problem 2
DROP TABLE HW2Log;
CREATE TABLE HW2Log
(
	Message VARCHAR2(200),
	TStamp TIMESTAMP DEFAULT SYSTIMESTAMP
);

DROP TABLE MyEmployees;
CREATE TABLE MyEmployees AS SELECT * FROM HR.Employees;



-- Management has now decided that no employee salary should ever be 
-- increased by more than $400 at a time, regardless of the percentage 
-- raise or the amount of money available. You have offered to change your 
-- RaiseSalary procedure and AssignRaises procedures (from Homework 1) to 
-- accommodate this limitation, but they are concerned about the possibility 
-- of rogue applications in the company bypassing your code and updating the 
-- tables with direct SQL. They want you to make sure that no single update can 
-- raise the salary by more than $400, regardless of which application it is 
-- requesting the change.




-- Implement a trigger called RaiseGuard which fires on any UPDATE to the 
-- Salary column of MyEmployees and which assures that raises of more than 
-- $400 are converted to exactly $400. 

CREATE OR REPLACE TRIGGER RaiseGuard
  BEFORE UPDATE OF SALARY ON MyEmployees
  FOR EACH ROW
DECLARE 
    correctedSalary INTEGER;
BEGIN
	IF :new.Salary - :old.Salary > 400 THEN
        correctedSalary := :old.Salary + 400;
        INSERT INTO HW2Log (Message) VALUES ('Salary update for employee ' || :new.Employee_Id 
            || ' modified from ' || :new.Salary || ' to limit of ' || correctedSalary);
        :new.Salary := correctedSalary;
    END IF;
END RaiseGuard;
/


-- Test code
--UPDATE MyEmployees 
--SET Salary = '99999'
--WHERE Employee_ID = 100;




-- Every time your trigger modifies a salary value, it should write a message 
-- to the HW2Log table in the following form:

-- Salary update for employee <employee id> modified from <what salary would 
-- have been without trigger> to limit of <what salary is now after effects of 
-- trigger>.

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
        IF remaining_budget > raise_amt THEN
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

-- Run the AssignRaises procedure with a raise percentage of 5 and a raise budget of 25000.
EXEC AssignRates('5','25000');

-- Show all Data and order by ascending time stamp value
SELECT * FROM HW2Log
ORDER BY TStamp ASC;

SELECT employee_id, salary FROM MyEmployees
ORDER BY employee_id ASC;











    


