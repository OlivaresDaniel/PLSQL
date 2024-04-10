
CREATE TABLE salary_history(
      
      employee_id NUMBER,
      update_date DATE,
      old_salary NUMBER,
      new_salary NUMBER,
      
      CONSTRAINT pk_sal_his PRIMARY KEY (employee_id,update_date),
    
      CONSTRAINT fk_sh_employees FOREIGN KEY (employee_id)
      REFERENCES employees(employee_id),
     
      CONSTRAINT fk_sh_copy_employees FOREIGN KEY (employee_id)
      REFERENCES copy_employees(employee_id)
      
);
SELECT * FROM salary_history;


/*PROCESO PARA AÑADIR DATA EN salary_history*/
/
CREATE OR REPLACE PROCEDURE proc_add_salary_history(p_emp_id NUMBER, p_date DATE, p_old_salary NUMBER, p_new_salary NUMBER)
IS

BEGIN
      INSERT INTO salary_history VALUES(p_emp_id,p_date,p_old_salary,p_new_salary);
END;
/

EXEC proc_add_salary_history(100,sysdate,10,1000000);

SELECT * FROM EMPLOYEES;

SELECT * FROM salary_history;

/*Trigger que accione el proceso*/
/

CREATE OR REPLACE TRIGGER t_add_sal_his
      AFTER UPDATE OF salary ON copy_employees
      FOR EACH ROW 
      
BEGIN
      proc_add_salary_history(:old.employee_id,sysdate,:old.salary,:new.salary);
END;
/

UPDATE copy_employees SET salary=10 where employee_id=100;

SELECT * FROM salary_history;
/



/*
      emp-job max i min salary
      limites ad_press (No hay control)
      
      Necesito que cuando se axctualize un salario se controle si esta dentro del tramo de su job
      Si se pasa del salario ya sea por encima o por debajo, este sera actualizado a su valor mas cercano dentro del tramo
     
      OPCION 1:
      procedure
      Con employee_id y salario
      
      OPCION 2:
      Proc que actualize salario
      +
      trigger para controlar limites

*/
/
CREATE OR REPLACE PROCEDURE proc_versal(p_emp_id NUMBER, p_salary NUMBER)
IS
      v_max NUMBER;
      v_min NUMBER;
BEGIN
      SELECT min_salary, max_salary INTO v_min, v_max FROM employees emp 
      JOIN jobs jo ON (emp.job_id=jo.job_id) WHERE employee_id=p_emp_id;
      
      IF(p_salary>v_max)THEN
      UPDATE copy_employees set salary=v_max where employee_id=p_emp_id;
      
      ELSIF(p_salary<v_min)THEN
      UPDATE copy_employees set salary=v_min where employee_id=p_emp_id;
      
      else
      UPDATE copy_employees set salary=p_salary where employee_id=p_emp_id;
      END IF;
      
END;
/
select * from jobs;

select * from copy_employees;

EXEC proc_versal(100,23000);

/
CREATE OR REPLACE PROCEDURE proc_versal2(p_emp_id NUMBER, p_salary NUMBER)
IS

BEGIN
      UPDATE copy_employees set salary=p_salary where employee_id=p_emp_id;
END;
/
CREATE OR REPLACE TRIGGER t_salary_control BEFORE UPDATE OF salary ON copy_employees
      FOR EACH ROW
       declare
            v_max NUMBER;
            v_min NUMBER;
      begin  
      SELECT min_salary, max_salary INTO v_min, v_max FROM jobs WHERE job_id=:old.job_id;
      
      IF(:new.salary>v_max)THEN
      :new.salary:=v_max;
      ELSIF(:new.salary<v_min)THEN
      :new.salary:=v_min;
      END IF;
      end;
/
exec proc_versal2(100,23000);

select * from copy_employees;

/
/*
      TIPO: PROCEDURE 
      NOMBRE: P_SET_DEP_MAN
      P.ENTRADA: LOC_ID, EMP_ID
      DESC: MUESTRA TODOS LOS DEPS DEL LOC Y ENCHUFA EL MAN(EMP)
*/
CREATE OR REPLACE PROCEDURE p_set_dep_man(p_loc_id NUMBER, p_emp_id NUMBER)
IS
      CURSOR c_cur is
      SELECT department_id as dep_id , department_name as dep_name , manager_id as man_id FROM departments WHERE location_id=p_loc_id;
      e_no_emp EXCEPTION;
      e_no_loc EXCEPTION;
      v_count NUMBER;
BEGIN
      SELECT COUNT(*) INTO v_count FROM employees
      WHERE employee_id=p_emp_id;
      
      IF (v_count=0) THEN
      RAISE e_no_emp;
      END IF;
      
      SELECT COUNT(*) INTO v_count FROM locations
      WHERE location_id=p_loc_id;
      
      IF (v_count=0) THEN
      RAISE e_no_loc;
      END IF;
      
      
      FOR i IN c_cur 
      LOOP
            IF(i.man_id is not null) THEN
                  DBMS_OUTPUT.PUT_LINE(i.dep_id||' '||i.dep_name||' '||i.man_id);
            END IF;
            IF (i.man_id IS NULL) THEN
                  UPDATE departments set manager_id=p_emp_id WHERE department_id=i.dep_id;
                  DBMS_OUTPUT.PUT_LINE('Actualizado :'||i.dep_id||' '||i.dep_name);
            END IF;
      END LOOP;
EXCEPTION
      WHEN e_no_emp THEN
      dbms_output.put_line('Error - No empleado');
      WHEN e_no_loc THEN
      dbms_output.put_line('Error - No location');
      WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
END;
/

exec p_set_dep_man(1100,100);
ROLLBACK;










