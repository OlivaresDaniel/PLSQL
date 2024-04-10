/
SET SERVEROUTPUT ON;
/
/*
TIPO: PROCEDURE
NOMBRE: proc_update_dep_location
P. ENTRADA: p_dept_id NUMBER, p_loc_id NUMBER, p_update_emps BOOLEAN

DESC: El procedimiento actualizar� el location_id del departamento
con el nuevo location_id que recibimos por par�metros.
Si el par�metro p_update_emps vale TRUE, tambi�n se actualizar� el
location id y ciudad(si no existe la columna, cr�ala) de cada empleado (tabla copy_employees).
Se mostrar� un mensaje por cada cambio en la tabla departments y
copy_employees.

CONTROL DE ERRORES:
- Si p_dept_id no existe o es NULL, se muestra error.
- Si p_loc_id no existe o es NULL, se muestra error.
- Si p_update_emps es NULL, se trata como si fuera FALSE.
- SI hay cualquier otro error de ejecuci�n, mostrar tipo de error y
deshacer cambios.
*/

CREATE OR REPLACE PROCEDURE proc_update_dep_location(p_dept_id NUMBER, p_loc_id NUMBER, p_update_emps BOOLEAN)
IS
    CURSOR c_cur IS
        SELECT emp.employee_id
         FROM copy_employees emp
          JOIN departments dep ON (dep.department_id = emp.department_id)
        WHERE dep.department_id = p_dep_id;
    
    v_exist NUMBER;
    v_city VARCHAR2(500);
    no_dep EXCEPTION;
    no_loc EXCEPTION;

BEGIN
    --Control de errores
    SELECT COUNT(*) INTO v_exist FROM departments
        WHERE department_id = p_dep_id;

    IF (v_exist = 0) THEN RAISE no_dep END IF;
    
    SELECT COUNT(*) INTO v_exist FROM locations
        WHERE location_id = p_loc_id;
    
    IF (v_exist = 0) THEN RAISE no_loc END IF;
    --Actualizo departamento
    UPDATE departments SET location_id = p_loc_id
        WHERE department_id = p_dep_id;
    --Si p_update es TRUE
    IF (p_update_emps) THEN
        --Buscar la ciudad del p_loc_id
        SELECT city INTO v_city
            FROM locations WHERE location_id = p_loc_id;
    
    
    
    
        FOR i IN c_cur LOOP
            UPDATE copy_employees
             SET location_id = p_loc_id, city = v_city
             WHERE employee_id = i.employee_id;
         
            DBMS_OUTPUT.PUT_LINE('Empleado '||i.employee_id||' actualizado.');
        END LOOP;
    END IF;
    --COMMIT;
EXCEPTION

    WHEN no_dep THEN
        DBMS_OUTPUT.PUT_LINE('Error - no existe el departamento');
    WHEN no_loc THEN
        DBMS_OUTPUT.PUT_LINE('Error - no existe el location');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        ROLLBACK;
END;
/

/*
TIPUS: PROCEDIMMENT
NOM: PROC_FIND_EMPLOYEES
P. ENTRADA: min_salary, max_salary, dep_id, loc_id
DESCRIPCI�:
El procediment mostrar� els empleats (employee_id, first_name, last_name) que
compleixin amb les dades que ens passen per par�metres. El filtratge d'empleats
ser� acumulatiu, en funci� dels par�metres informats. Si un par�metre rep valor
NULL, no es filtrar� per ell.
Detalls de par�metres informats:
- Si MIN_SALARY est� informat, es mostren tots els empleats amb un salari que no estigui per sota.
- Si MAX_SALARY est� informat, es mostren tots els empleats que no superin aquest salari.
- Si DEPT_ID est� informat, es mostren tots els empleats d'aquell location.
- Si no s'informa de cap par�metre (tots a NULL), es mostren tots els empleats.

CONTROLS i ERRORS:
- Si no es troben coincid�ncies (cap empleat). Es mostrara el missatge "no s'han trobat empleats"
- Si el DEP_ID �s un department que no existeix, es mostra el missatge "error - departament no existex."
- Si el LOC_ID �s una localitzaci� que existeix, es mostra el missatge "error - location no existeix."
*/

CREATE OR REPLACE PROCEDURE proc_find_employees()
IS


BEGIN




EXCEPTION



END;
/










