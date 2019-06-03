--Desarrolla un procedimiento que visualice el apellido y la fecha de alta de todoos los empleados ordenados por apellido.
CREATE OR REPLACE PROCEDURE visualizar_apellido
  IS
    CURSOR empleados IS SELECT APELLIDO, FECHA_ALTA
              FROM EMPLEADOS
              ORDER BY APELLIDO;
    
    
BEGIN
  FOR apeAlta IN empleados LOOP
    DBMS_OUTPUT.PUT_LINE('Apellido ' || apeAlta.APELLIDO || ' Fecha de alta ' || apeAlta.FECHA_ALTA);
  END LOOP;
END;

EXECUTE visualizar_apellido;


--Codifica un procedimiento que muestre el nombre de cada departamento y el número de empleados que tiene. 
CREATE OR REPLACE PROCEDURE numeroDeTrabajadoresDep
IS
  CURSOR trabajadoresDepart IS
    SELECT D.DNOMBRE, COUNT(*) as numero
    FROM  DEPARTAMENTOS D, EMPLEADOS E
    WHERE D.DEP_NO = E.DEP_NO
    GROUP BY DNOMBRE, D.DNOMBRE;
  
  DEPARTAMENTO_TEMP DEPARTAMENTOS.DNOMBRE%TYPE; 
  CONTADOR EMPLEADOS.EMP_NO%TYPE;
  
BEGIN
  FOR departamento IN trabajadoresDepart LOOP
    DBMS_OUTPUT.PUT_LINE('El departamento ' || departamento.DNOMBRE || ' tiene ' || departamento.numero || ' empleados');
  END LOOP;
END;

EXECUTE numeroDeTrabajadoresDep;


--Escribe un progama que visualice el apellido y el salario de los cinco empleados que tienen el salario más alto
CREATE OR REPLACE PROCEDURE salarioMasAlto
IS
  CURSOR trabajadoresSalario IS
    SELECT APELLIDO, SALARIO
    FROM EMPLEADOS
    ORDER BY SALARIO DESC;
    
  CONTADOR NUMBER(3) := 0;
BEGIN
  FOR apeSalario IN trabajadoresSalario LOOP
    DBMS_OUTPUT.PUT_LINE('APELLIDO: ' || apeSalario.APELLIDO || ' * SALARIO: ' || apeSalario.SALARIO);
    CONTADOR := CONTADOR + 1;
    EXIT WHEN CONTADOR >= 5;
  END LOOP;
END;

EXECUTE salarioMasAlto;


--Codifica un programa que visualice los dos empleados que ganan menos de cada oficio
CREATE OR REPLACE PROCEDURE menosPorOficio
IS
  CURSOR salarioMenor IS
    SELECT OFICIO, APELLIDO, SALARIO
    FROM EMPLE
    ORDER BY OFICIO, SALARIO ASC;
  
  oficio_temp VARCHAR2(30) := 'TEMPORAL';
  contador NUMBER(3) := 0;

BEGIN
  FOR porSalario IN salarioMenor LOOP
    IF oficio_temp <> porSalario.OFICIO THEN
     DBMS_OUTPUT.PUT_LINE('OFICIO: ' || porSalario.OFICIO || ' APELLIDO: ' || porSalario.APELLIDO || ' SALARIO: ' || porSalario.SALARIO);
     CONTADOR := 0;
    ELSIF oficio_temp = porSalario.OFICIO AND CONTADOR = 1 THEN
      DBMS_OUTPUT.PUT_LINE('OFICIO: ' || porSalario.OFICIO || ' APELLIDO: ' || porSalario.APELLIDO || ' SALARIO: ' || porSalario.SALARIO);

    END IF;
    CONTADOR := CONTADOR + 1;
    oficio_temp := porSalario.OFICIO;
  END LOOP;
END;
  
EXECUTE menosPorOficio;

--Desarrolla un procedimiento que permita insertar nuevos departamentos.
  --Se pasará como parámetro el nombre del departamento y la localidad
  --El procedimiento insertará la fila asignando como numero de departamento la decena siguiente al mayor de la tabla
  --Gestión de errores

CREATE OR REPLACE PROCEDURE insertDepart(nombreDep DEPART.DNOMBRE%TYPE, localidad DEPART.LOC%TYPE)
  IS
    CURSOR departamentosCursor IS
      SELECT * FROM DEPART;
    
    numeroDepartamento DEPART.DEPT_NO%TYPE := 0;
BEGIN
  FOR dep IN departamentosCursor LOOP
    IF numeroDepartamento < dep.DEPT_NO THEN
      numeroDepartamento := dep.DEPT_NO;
    END IF;
  END LOOP;
  numeroDepartamento := numeroDepartamento + 10;
  INSERT INTO DEPART (DEPT_NO, DNOMBRE, LOC) VALUES (numeroDepartamento, nombreDep, localidad);
  
END;
    
EXECUTE insertDepart('RR.HH.', 'SEVILLA');

EXECUTE insertDepart('&Departamento', '&Localidad');


--Codifica un procedimiento que reciba como parámetros un número de departamento, un importe y un porcentaje; y que suba el salario
--a todos los empleados del departamento indicado en la llamada. La subida será el porcentaje o el importe que se indica en la llamada
--(el que sea más beneficioso en cada caso)
CREATE OR REPLACE PROCEDURE subidaSueldo(numeroDep EMPLEADOS.DEP_NO%TYPE, porcentaje NUMBER, importe NUMBER)
IS
  CURSOR empleadosCursor IS
    SELECT * FROM EMPLEADOS
    WHERE DEP_NO = numeroDep
    FOR UPDATE OF SALARIO;
  
  aumentoPorcentaje  NUMBER(10) := 0;
  aumentoImporte    NUMBER(10) := 0;
BEGIN
  FOR empleTemp IN empleadosCursor LOOP

    
    aumentoPorcentaje := empleTemp.SALARIO * ((100 + porcentaje) /100);
    aumentoImporte := empleTemp.SALARIO + importe;
    
    IF(aumentoPorcentaje > aumentoImporte) THEN 
      UPDATE EMPLEADOS SET SALARIO = aumentoPorcentaje WHERE CURRENT OF empleadosCursor;
      DBMS_OUTPUT.PUT_LINE(empleTemp.APELLIDO || ' su salario ha sido aumentado por porcentaje');
    ELSIF (aumentoImporte > aumentoPorcentaje) THEN 
      UPDATE EMPLEADOS SET SALARIO = aumentoImporte WHERE CURRENT OF empleadosCursor;
      DBMS_OUTPUT.PUT_LINE(empleTemp.APELLIDO || ' su salario ha sido aumentado por importe');
    END IF;
      DBMS_OUTPUT.PUT_LINE(aumentoPorcentaje || '   '  || aumentoImporte);
      aumentoPorcentaje := 0;
      aumentoImporte := 0;
  END LOOP;
END;

UPDATE EMPLEADOS SET SALARIO = SALARIO - 3000 WHERE APELLIDO = 'REY';

EXECUTE subidaSueldo(10, 10, 200);

--Escribe un procedimiento que suba el sueldo de todos los empleados que ganen menos que el salario medio de su oficio.
--La subida será del 50 por 100 de la dferencia entre el salaro del empleado y la media de su oficio.
--Se deberá hacer que la transacción no se quede a medias y se gestionarán los posibles errores.

CREATE OR REPLACE PROCEDURE subidaSalarioPorOficio
  IS
    CURSOR salariosMedios IS
      SELECT OFICIO, TRUNC(AVG(SALARIO), 2) AS SALARIOMEDIO
      FROM EMPLE
      GROUP BY OFICIO;
      
    CURSOR empleados IS
      SELECT * FROM EMPLE
      FOR UPDATE OF SALARIO;
      
      temporalSalario EMPLE.SALARIO%TYPE := 0;
BEGIN
  FOR emp IN empleados LOOP
    FOR sal in salariosMedios LOOP
      IF(sal.OFICIO = emp.OFICIO AND emp.SALARIO < sal.SALARIOMEDIO) THEN
        temporalSalario := (sal.SALARIOMEDIO - emp.SALARIO) * 0.5;
        DBMS_OUTPUT.PUT_LINE('Se le ha subido el salario a ' || emp.APELLIDO);
         UPDATE EMPLE SET SALARIO = (SALARIO + temporalSalario) WHERE CURRENT OF empleados;
      END IF;
      temporalSalario := 0;
    END LOOP;
  END LOOP;
END;

EXECUTE subidaSalarioPorOficio;


--EXAMPLE OF A FUNCTION
CREATE OR REPLACE FUNCTION enconrarEmpleado(v_apellido VARCHAR2)
  RETURN REAL
AS
  N_EMPLEADO emple.emp_no%TYPE;
BEGIN
  SELECT emp_no INTO N_EMPLEADO FROM EMPLE WHERE APELLIDO = v_apellido;
  RETURN N_EMPLEADO;
END;

DECLARE
  num EMPLE.EMP_NO%TYPE;
BEGIN
 num := enconrarEmpleado('SÁNCHEZ');
 DBMS_OUTPUT.PUT_LINE(num);
END;

--TRIGGERS
CREATE TABLE audit_entry (
  entry_date DATE,
  entry_user VARCHAR2(30),
  entry_text VARCHAR2(2000),
  old_value VARCHAR2(2000),
  new_value VARCHAR2(2000));
  
CREATE OR REPLACE TRIGGER employee_journal
  AFTER INSERT OR UPDATE OF salary ON employee
  FOR EACH ROW
  WHEN (new.salary > 70000)
BEGIN
  INSERT INTO audit_entry
    (entry_date, entry_user, entry_text, old_value, new_value)
  VALUES
    (SYSDATE, USER, 'Salary > 7000 for ' || :NEW.ssn, :OLD.salary, :new.salary);
END;

UPDATE employee SET salary = salary * 1.5 WHERE lname = 'Borg';


CREATE TABLE budget_request (
  account_no VARCHAR2(3),
  amount  NUMBER(6),
  description VARCHAR2(2000),
  date_entered DATE default SYSDATE);
  
CREATE OR REPLACE TRIGGER budget_event
  AFTER INSERT OR UPDATE OF salary ON employee
  FOR EACH ROW

BEGIN
  IF UPDATING
  AND :NEW.salary > :OLD.salary THEN
    INSERT INTO budget_request(account_no, amount, description)
      VALUES(101, :NEW.salary - :OLD.salary, 'Employee raise');
  ELSE
    INSERT INTO budget_request(account_no, amount, description)
      VALUES(101, :NEW.salary, 'New employee');
  END IF;
END;

/*Escribe un trigger que permita auditar las modificaciones en la tabla EMPLEADOS, 
insertando los siguientes datos en la tabla auditaremple: fecha y hora, número de empleado, apellido, 
la operación de actualización MODIFICACIÓN y el valor anterior y el valor nuevo de cada columna modificada (sólo en las columnas modificadas) */
CREATE TABLE auditarEmpleCasa (
  logInfo VARCHAR2(2000));

CREATE OR REPLACE TRIGGER modificacionesEmpleados
  AFTER INSERT OR DELETE OR UPDATE ON EMPLEADOS
  FOR EACH ROW

DECLARE
  operacionRealizada VARCHAR2(100) := 'Operacion';
  
BEGIN
  IF UPDATING ('EMP_NO') THEN
    operacionRealizada := 'Actualizacion ' || sysdate || ' * ' || :OLD.EMP_NO || ' * ' || ' * ' || :NEW.EMP_NO;
  ELSIF UPDATING ('SALARIO') THEN
    operacionRealizada := 'Actualizacion ' || sysdate || ' * ' || :OLD.SALARIO || ' * ' || :NEW.SALARIO;
  ELSIF DELETING THEN
    operacionRealizada := 'Borrado';
  END IF;
  
  INSERT INTO AUDITAREMPLECASA (logInfo) VALUES (operacionRealizada);
END;

UPDATE EMPLEADOS SET SALARIO = SALARIO + 3000 WHERE APELLIDO = 'GARRIDO';



/* Escribir un disparador de base de datos que haga fallar cualquier 
operación de modificación del apellido o del número de un empleado, o que suponga una subida de sueldo superior al 10%. */
CREATE OR REPLACE TRIGGER operacionesNoPermitidas
  AFTER UPDATE OF APELLIDO, SALARIO ON EMPLE
  FOR EACH ROW
  
BEGIN
  IF UPDATING ('APELLIDO') OR UPDATING ('SALARIO') AND :NEW.SALARIO < :OLD.SALARIO *1.1 THEN
    RAISE_APPLICATION_ERROR (-20001, ('Modificación no permitida'));
  END IF;
END;

UPDATE EMPLE SET SALARIO = SALARIO * 1.01 WHERE APELLIDO = 'GARRIDO';