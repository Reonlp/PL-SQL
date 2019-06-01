DECLARE
  --Declare constants
  cMinSalary CONSTANT NUMBER(6) := 15000;
  cMaxSalary CONSTANT NUMBER(6) := 99000;
  
  --Declare variables
  nSalary NUMBER(6) DEFAULT 25000;
  cSSN CHAR(11) := '111-22-3333';
  vLName VARCHAR2(15) NOT NULL := 'Smith';
  vFName VARCHAR2(15) NOT NULL := 'John';
  
BEGIN
  --SHOW THE RESULT
  dbms_output.put_line('Name:    ' || vFName || ' ' || vLName );
  dbms_output.put_line('SSN:    '  || cSSN );
  dbms_output.put_line('Salary:  $' || nSalary);
  dbms_output.put_line('Minimum: $' || cMinSalary);
  dbms_output.put_line('Maximum: $' || cMaxSalary);

END;


--%TYPE
DECLARE
  --DEFINE VARIABLES (%type will hold whatever the type is)
  x_last     employee.lname%TYPE;
  x_salary   employee.salary%TYPE;
BEGIN
  SELECT salary, lname
  into x_salary, x_last
  from employee
  WHERE SSN = '999887777';
  
  dbms_output.put_line(x_last || ' salary is $' || x_salary);
END;
  
--%ROWTYPE
DECLARE
  --DECLARE VARIABLE
  x_emp employee%ROWTYPE;
BEGIN
  --fill the fields
  SELECT fname, lname, sex, salary
  into x_emp.fname, x_emp.lname, x_emp.sex, x_emp.salary
  from employee
  where ssn = '999887777';
  
  dbms_output.put_line(x_emp.fname || ' ' || x_emp.lname || ' salary is $' || x_emp.salary);
END;


--Handling string literals
DECLARE 
  nValue NUMBER(10) := &enter_value;
  vMessage VARCHAR(30);

BEGIN
  IF nValue > 60000 THEN
    vMessage := '!The value isn''t valid.!';
    dbms_output.put_line(vMessage);
  END IF;
END;

--IF THEN ELSE structure
DECLARE
  birth_month  CHAR(3) := '&enter_birth_month';
  message      VARCHAR(25);
BEGIN 
  IF birth_month = 'JAN' THEN
    message:= 'Start of the year';
  ELSIF birth_month = 'FEB' THEN
    message:= 'Short month';
  ELSE
    message:= 'No comment';
  END IF;

  DBMS_OUTPUT.PUT_LINE(message);
END;

--USING THE CASE STATEMENT
DECLARE
  birth_month  CHAR(3) := '&enter_birth_month';
  message      VARCHAR(25);
BEGIN 
  CASE birth_month
    WHEN 'JAN' THEN message := 'Start of the year';
    WHEN 'FEB' THEN message := 'Short month';
    WHEN 'MAR' THEN message := 'Spring has sprung';
    WHEN 'APR' THEN message := 'Watch for showers';
    ELSE message := 'No comment';
  END CASE;
  DBMS_OUTPUT.PUT_LINE(message);
END;

--FOR LOOPS
BEGIN
  FOR I IN 1..100 LOOP
    INSERT INTO employee (ssn, fname, lname, dno, salary)
    VALUES(90000 + I, 'John', 'Doe', 1, 3000 + I);
  END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
    dbms_output.put_line('ERROR. REVISA EL BLOQUE');
END;

BEGIN
  FOR I IN 1..10 LOOP
    dbms_output.put_line('Contador = ' || I);
  END LOOP;
END;

BEGIN 
  FOR I IN 1..23 LOOP
    dbms_output.put_line('Contador = ' || I);
  END LOOP;
END;

--REVERSE LOOP
BEGIN
  FOR I IN REVERSE 1..10 LOOP
    dbms_output.put_line('Contador = ' || I);
  END LOOP;
END;


--FOR LOOP CURSOR (NO NEED OF FETCH)
BEGIN
  FOR Employees IN
    (SELECT *
     FROM employee) LOOP
     dbms_output.put_line('Employee: ' || Employees.Lname || ' earns $' || Employees.salary);
  END LOOP;
END;

--NESTED LOOP
CREATE TABLE "TRANSACTIONS" 
  ("STOCK_ID"             NUMBER(*,0),
   "TIME_ID"              NUMBER(*,0),
   "BROKERAGE_ID"         NUMBER(*,0),
   "BUY_SELL_INDICATOR"   CHAR(1 BYTE),
   "NUMBER_SHARES"        NUMBER(*, 0),
   "PRICE"                FLOAT(4) DEFAULT(0)
  )

DECLARE
  --Declare variables
  brokerage_id_limit  transactions.brokerage_id%TYPE := 10;
  stock_id_limit      TRANSACTIONS.STOCK_ID%TYPE := 10;
  time_id             TRANSACTIONS.TIME_ID%TYPE := 45;

BEGIN

  --We begin the outer loop and create a similar transaction for every broker
    FOR x IN 1..brokerage_id_limit LOOP
  
      --We begin the nested loop. Every brokerage will either buy or sell every stock.
      FOR i IN 1..stock_id_limit LOOP
      
        --Test for every even value of 1
        IF mod(i, 2) = 0 THEN
        INSERT INTO transactions (STOCK_ID, TIME_ID, BROKERAGE_ID, BUY_SELL_INDICATOR, NUMBER_SHARES, PRICE)
          VALUES (i, time_id, x, 'S', 100 + x + i, 10 + x + 1);
        
        ELSE
          INSERT INTO transactions (STOCK_ID, TIME_ID, BROKERAGE_ID, BUY_SELL_INDICATOR, NUMBER_SHARES, PRICE)
            VALUES(i, time_id, x, 'B', 200 + x + i, 20 + x + 1);
        END IF;
        
        --Ending the nested loop
      END LOOP;

  --Ending the nested loop
  END LOOP;

END;

SELECT * FROM TRANSACTIONS;
  
  

--CURSORS

DECLARE
  --WE DECLARE THE CURSOR
  CURSOR Employees IS
    SELECT *
    FROM employee;

    EmpRecord employee%ROWTYPE;
  BEGIN
    OPEN Employees;
    
    LOOP
      FETCH Employees INTO EmpRecord;
      EXIT WHEN Employees%NOTFOUND;
      
      --Display the record detail
      
      dbms_output.put_line('Employees ' || EmpRecord.LName || ' earns ' || EmpRecord.Salary);
      
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('ROWS: ' || Employees%ROWCOUNT);
    CLOSE Employees;
END;


DECLARE

  CURSOR Employees is
    SELECT * 
    FROM employee
    ORDER BY salary DESC;
    
    EmpRecords employee%ROWTYPE;
    
BEGIN
  IF NOT (Employees%ISOPEN) THEN
    OPEN Employees;
  END IF;
  
  LOOP
    FETCH Employees INTO EmpRecords;
    EXIT WHEN Employees%NOTFOUND;
  
  dbms_output.put_line('Employees number ' || Employees%ROWCOUNT || ' ' || EmpRecords.LName || ' earns ' || EmpRecords.Salary);
  
  END LOOP;
  
  IF Employees%ISOPEN THEN
    CLOSE Employees;
  END IF;
END;

--UPDATE CURSOR
DECLARE
  CURSOR Employees IS
    SELECT * 
    FROM employee
  FOR UPDATE OF salary;
  
  EmpRecord         employee%ROWTYPE;
  PayCut            employee.salary%TYPE := 0;
  ReductionTotal    PayCut%TYPE := 0;
  
  DependentCount    NUMBER(10);
  HasDependents     BOOLEAN := FALSE;
  
  HoursSum          works_on.hours%TYPE;
  WorksHard         BOOLEAN := FALSE;
  
  DayOfMonth        INTEGER;
  TooLateInMonth    EXCEPTION;

BEGIN
  SELECT TO_CHAR(SYSDATE, 'DD')
  INTO DayOfMonth
  FROM DUAL;
  
  IF DayOfMonth > 28 THEN
    Raise TooLateInMonth;
  END IF;
  
  IF NOT (Employees%ISOPEN) THEN
    OPEN Employees;
  END IF;
  
  LOOP
    FETCH Employees INTO EmpRecord;
    EXIT WHEN Employees%NOTFOUND;
    
    PayCut := EmpRecord.salary * .10;
    
    SELECT COUNT(*)
    INTO DependentCount
    FROM dependent
    WHERE essn = EmpRecord.ssn;
    
    HasDependents := (DependentCount > 0);
    
    SELECT SUM(hours)
    INTO HoursSum
    FROM works_on
    WHERE essn = EmpRecord.ssn;
    
    WorksHard := (HoursSum > 40);
    
    CASE
      WHEN HasDependents THEN PayCut := PayCut - 100;
      WHEN WorksHard THEN PayCut := PayCut - 50;
      ELSE NULL;
    END CASE;
    
    UPDATE employee
    SET salary = salary - PayCut
    WHERE CURRENT OF Employees;
    
    dbms_output.put_line('Salary for ' || EmpRecord.LName || ' reduced by $ ' || PayCut);
    
    ReductionTotal := ReductionTotal + PayCut;
    HasDependents := False;
    WorksHard := False;
    
    END LOOP;
    
    COMMIT;
    
    IF Employees%ISOPEN THEN
    CLOSE Employees;
    END IF;
    
    dbms_output.put_line('Total salary reduction: $' || ReductionTotal);
    
    EXCEPTION
      WHEN TooLateInMonth  THEN
       dbms_output.put_line('No salary changes permitted after the 25th');
END;

BEGIN
  FOR Employees IN
    (SELECT *
    FROM employee) LOOP
    dbms_output.put_line('Employee: ' || Employees.Lname || ' earns $ ' || Employees.salary);
  END LOOP;
END;
  



--EXCEPTIONS


--PROCEDURES AND FUNCTIONS
CREATE OR REPLACE PROCEDURE raise_salary
(
  employee_ssn  IN CHAR,
  employee_pct  IN NUMBER DEFAULT 5,
  result_message OUT CHAR
)

AS

  old_salary      employee.salary%TYPE;
  increase_amount NUMBER;
  
  pct_too_high    EXCEPTION;
  update_error    EXCEPTION;

BEGIN
  IF employee_pct > 50 THEN
    RAISE pct_too_high;
  END IF;
  
  SELECT salary
  INTO old_salary
  FROM employee
  WHERE ssn = employee_ssn;
  
  IF(old_salary IS NOT NULL) AND (old_salary > 0) THEN
    increase_amount := employee_pct / 100;
    
  UPDATE employee
  SET salary = salary + (salary * increase_amount)
  WHERE ssn = employee_ssn;
  
  IF SQL%ROWCOUNT <> 1 THEN
    RAISE update_error;
  END IF;
  
  ELSE
  
    result_message := 'Current salary is either NULL or 0';
  END IF;
  
  WHEN pct_too_high THEN
    result_message := 'Raise percentage may not exceed 50%';
    
  WHEN NO_DATA_FOUND THEN
    result_message := 'Employee ' || employee_ssn || ' not found';
    
  WHEN update_error THEN
    result_message := 'Database error';
    
  WHEN OTHERS THEN
    result_message := 'Unknown error';
    
END raise_salary;



--FUNCTION
CREATE OR REPLACE FUNCTION salary_valid
(
 input_ssn  IN CHAR,
 input_salary IN NUMBER
)
RETURN BOOLEAN
IS
  count_mgmt    NUMBER,
  salary_limit  NUMBER
  
BEGIN
  IF input_salary > salary_limit THEN
    RETURN (FALSE);
  ELSE
    RETURN (TRUE);
  END IF;
END salary_valid;




