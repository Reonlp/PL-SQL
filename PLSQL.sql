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


