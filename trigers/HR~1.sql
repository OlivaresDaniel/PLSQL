--NUEVA TABLA
CREATE TABLE my_logs(
    log_id          NUMBER,
    log_desc        VARCHAR2(300),
    creation_date   DATE,
    CONSTRAINT pk_my_log PRIMARY KEY (log_id)
);

CREATE SEQUENCE seq_my_log
    START WITH 1 INCREMENT BY 1;
    
/*
CREA UN TRIGGER QUE AÑADA UN MENSAJE A LA tabla de logs ANTES de insertar un nuevo JOB
*/

CREATE OR REPLACE TRIGGER t_add_job_log
    BEFORE INSERT ON jobs
    FOR EACH ROW
BEGIN
    INSERT INTO my_logs
        VALUES(seq_my_log.NEXTVAL, 'Se ha insertado el nuevo JOB: '||:new.job_id, sysdate);
END;

/
--TESTEO

SELECT * FROM my_logs;
SELECT * FROM jobs;

INSERT INTO jobs
 VALUES('XXX_IT','Info Tech experimental',10,900000);

/*------------------------------------------------*/

--Creamos tabla copy_employees
CREATE TABLE copy_employees
    AS SELECT * FROM employees;

-- Añadimos PK a copy_employees
ALTER TABLE copy_employees
    ADD CONSTRAINT pk_copy_emps PRIMARY KEY (employee_id);

-- NUEVA TABLA
CREATE TABLE salary_history(
    employee_id     NUMBER,
    update_date     DATE,
    old_salary      NUMBER,
    new_salary      NUMBER,
    CONSTRAINT pk_salary_hist PRIMARY KEY (employee_id, update_date),
    CONSTRAINT fk_sh_employees FOREIGN KEY (employee_id)
        REFERENCES copy_employees(employee_id)
    --ickkck
);


/*
TIPO: PROCEDURE
NOMBRE: ADD_SALARY_HISTORY
P.ENTRADA: p_emp_id, p_date, p_old_salary, p-new_salary
DESC: Insertar un nuevo registro en la tabla salary_history
*/
CREATE OR REPLACE PROCEDURE add_salary_history(p_emp_id NUMBER,
                    p_date DATE, p_old_salary NUMBER, p_new-salary NUMBER)
IS
BEGIN
    INSERT INTO salary_history
        VALUES(p_emp_id, p_date, p_old_salary, p_new-salary);
END;
/



/*
TIPO: TRIGGER
DISPARADOR:Al actualizar SALARY de empleado de COPY_EMPLOYEES
DESC: Insertar un nuevo registro en SALARY_HISTORY con la referéncia del empleado,
    su antiguo salario, el nuevo salario y la fecha de actualización.
*/

CREATE OR REPLACE TRIGGER t_add_salary_history
ALTER UPDATE OF salary ON copy_employees
FOR EACH ROW
BEGIN
    add_salary_history(:old.employee_id, sysdate, :old.salary, :new.salary);
END;
/


/*-----------------------------------*/





/*----TODO ESTO FUNCIONA Y COMPLIA----*/
/
CREATE OR REPLACE PROCEDURE proc_update_sal (p_emp_id NUMBER, p_salary NUMBER)
IS
    v_exist NUMBER;
    e_no_emp    EXCEPTION;
BEGIN
    /*Control error empleado no existe*/
    SELECT COUNT(*) INTO v_exist FROM copy_employees
        WHERE employee_id = p_emp_id;
    
    IF v_exist = 0 THEN RAISE e_no_emp;
    END IF;
    /*Actualizar salario*/
    UPDATE copy_employees SET salary = p_salary
        WHERE employee_id = p_emp_id;

EXCEPTION
    WHEN e_no_emp THEN
        DBMS_OUTPUT.PUT_LINE('Error no emp.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SQLERRM');
    
END;
/  
CREATE OR REPLACE TRIGGER t_salary_limit
BEFORE UPDATE OF salary ON copy_employees
FOR EACH ROW
DECLARE
    v_min_sal   NUMBER;
    v_max_sal   NUMBER;
BEGIN
    SELECT min_salary, max_salary INTO v_min_sal, v_max_sal FROM jobs WHERE job_id = :new.job_id;
    
    IF (:new.salary > v_max_sal) THEN
        :new.salary := v_max_sal;
    ELSIF (:new.salary < v_min_sal) THEN
        :new.salary := v_min_sal;
    END IF;
END;
/

EXECUTE proc_update_sal(150,7000);

SELECT * FROM copy_employees;



/*-------------EXAMEN DEL AÑO PASADO--------------*/

/*
(3 punts) Defineix una FUNCIÓ anomenada F_MAX_DEP

    PARÀMETRES D'ENTRADA:
        p_department_id1    (és tipus NUMBER)
        p_department_id2    (és tipus NUMBER)
    PARÀMETRE DE SORTIDA:
        (tipus NUMBER)
    DESCRIPCIÓ:
        La funció rebrà l'id de dos departaments, i retornarà l'id del departament amb més
        empleats assignats a ell. En cas d'empat, es retorna el primer departament.
    CONTROL D'ERRORS:
        - Si qualsevol dels departaments no existeix, es retornà un -2.
        - Si qualsevol dels dos departamants és NULL, es retornarà un -1.
*/

/
CREATE OR REPLACE FUCTION p_max_dep(p_depid1 NUMBER, p_depid2 NUMBER)
RETURN NUMBER
IS
    v_num1  NUMBER;
    v_num2  NUMBER;
BEGIN
    /*errores*/
    SELECT COUNT(*) INTO v_num1
     FROM departments
     WHERE department_id IN (p_depid1, p_pedid2);
    
    IF (v_num1 < 2) THEN RETURN -2;
    END IF;
    
    IF (v_num1 IS NULL OR p_depid2 IS NULL) THEN RETURN -1;
    END IF;
    /*---*/
    SELECT COUNT(*) INTO v_num1
     FROM employees
     WHERE department_id = p_depid1;
    
    SELECT COUNT(*) INTO v_num2
     FROM employees
     WHERE department_id = p_depid2;
    
    IF (v_num1 >= v_num2) THEN RETURN p_depid1;
    ELSE RETURN p_depid2;
    END IF;
    
END;
/


/*
(3,5 punts) Defineix un PROCEDIMENT anomenat BULK_MIN_SALARY

    PARÀMETRES D'ENTRADA:
        p_job_title (tipus VARCHAR2)
    DESCRIPCIÓ:
        El procediment modificarà tots els empleats que treballen en el job (p_job_title), canviant el seu
        salari pel MIN_SALARY associat al job. Per cada empleat modificat es mostrarà un missatge amb
        el seu nom, cognom, antic salari i nou salari.
        
        Al final de les actualitzacions també es mostrarà un missatge amb el total d'empleats
        actualitzats.
    CONTROL D'ERRORS:
        - Si p_job_title és NULL es mostrarà l'error:
            "error - JOB NULL".
        - Si p_job_title no existeix, es mostrarà l'error:
            "error - JOB NOT EXIST".
        - En cas de qualsevol altre error, s'ha d'informar de codi i descripció de ´'error.
*/
/
CREATE OR REPLACE PROCEDURE bulc_min_salary(p_job_title VARCHAR2)
IS
    CURSOR c_cur IS
        SELECT first_name || last_name || salary AS cosa
         FROM employees emp
         JOIN jobs jo ON (emp.job_id = jo.job_id)
         WHERE job_title = p_job_title;
    e_pamm EXCEPTION;
    e_pumm EXCEPTION;
    v_exist NUMBER;
    v_min_sal NUMBER;
    v_job NUMBER;
    
BEGIN
    SELECT COUNT(*) INTO v_exist
     FROM jobs
     WHERE job_title = p_job_title;
    
    IF (v_exist = 0) THEN RAISE e_pumm;
    END IF;
    
    IF(p_job_title IS NULL) THEN RAISE e_pamm;
    
    /*--*/

    SELECT job_id, min_salary INTO v_job, v_min_sal
     FROM jobs
     WHERE job_title = p_job_title;

    UPDATE employees SET salary = v_min_sal
     WHERE job_id = v_job;
    
    v_exist := 0;

    FOR i IN c_cur loop
        DBMS_OUTPUT.PUT_LINE(i.cosa || v_min-sal);
        v_exist := v_exist + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(v_exit);


END;


/*ULTIMO EJERCICO PARA EXAMEN*/

/*
TIPO: PROCEDURE
NOMBRE: p_salary_debug
P. ENTRADA: p_update BOOLEAN
DESC:
El procedimiento recorrerà todos los empleados y mostrarà un
mensaje por cada empleado con un salario que exceda los limites de su job (tabla JOBS).

Si p_update está activado, se actualizará automaticamente el salario
con el limite excedido. Si está desactivado, solo se informa.

ERRORES:
    - Error por defecto indicado tipo de error y descripcion.
    - Si jobs no tiene min o max se muestra una linea de error
    (pero el programa no se detiene).
*/
/
CREATE OR REPLACE PROCEDURE p_salary_debug(p_update BOOLEAN)
IS
    CURSOR c_cur IS
        SELECT emp.first_name||' '||emp.last_name AS name,
            emp.employee_id AS emp_id,
            emp.salary,
            jo.job_title,
            jo.min_salary,
            jo.max_salary
         FROM employees emp
            JOIN jobs jo ON (jo.job_id = emp.job_id);
BEGIN
    FOR i IN c_cur LOOP
        IF i.min_salary IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Error en min_salary del job'||i.job_title);
        
        ELSIF i.max_salary IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Error en max salary del job'||i.job_title);
        
        ELSIF i.salary < i.min_salary THEN
            DBMS_OUTPUT.PUT_LINE(i.name||' - está por debajo del salario mínimo.');
        
            IF p_update THEN
                UPDATE copy_employees SET salary = i.min_salary
                    WHERE employee_id = i.emp_id;
                DBMS_OUTPUT.PUT_LINE(' -- Actializado al mínimo');
            END IF;
        ELSIF i.salary > i.max_salary THEN
            DBMS_OUTPUT.PUT_LINE(i.name||' - está por encima del salario máximo.');
            
            IF p_update THEN
                UPDATE copy_employees SET salary = i.max_salary
                    WHERE employee_id = i.emp_id;
                DBMS_OUTPUT.PUT_LINE(' -- Actualizado al máximo');
            END IF;
        END IF;
    END LOOP;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/




















