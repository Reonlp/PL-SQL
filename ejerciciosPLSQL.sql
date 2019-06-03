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



  