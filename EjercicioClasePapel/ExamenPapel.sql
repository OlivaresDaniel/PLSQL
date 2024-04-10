/
SET SERVEROUTPUT ON;
/

            /* EJERCICIO DE EXAMEN DEL AÑO PASADO */

/*
El programa ha de recórrer tota la taula dèmpleats i actualitzar la nova
columna CITY amb el valor de ciutat on treballa lèmpleat (la trobaràs a la taula locations.)

Per cada actualització, s'ha de mostrar un missatge dient:
    Registre de l'empleat <NOM COGNOM> s'ha actualitzat amb la ciutat <NOM CIUTAT>.
    
Quan s'hagin actualitzat tots els registres, fes que el procediment guardi (confirmi) els canvis.

    -Control d'errors:
Fes un control d'errors genéric que inclogui el codi i descripció de l'error.
També desfés qualsevol modificació que s'hagi fet la taula employees.
*/

CREATE OR REPLACE PROCEDURE UPGRADE_EMP_CITY
IS
    CURSOR c_cur IS
        SELECT emp.employee_id, emp.first_name||' '||emp.last_name AS nom, loc.city
        FROM employees emp
         LEFT JOIN departments dep 
            ON (dep.department_id = emp.department_id)
        LEFT JOIN location loc
            ON (loc.location_id = dep.location_id);


BEGIN
    FOR i IN c_cur LOOP
        UPDATE copy_employees
         SET city = i.city
         WHERE employee_id = i.employee_id;
        
        DBMS_OUTPUT.PUT_LINE(' actualizado con ciudad'||i.city);

    END LOOP;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error de la copa grande: '||SQLERRM);
        ROLLBACK;

/

/*
(3,5 punts) Defineix un PROCEDIMENT anomenat CITY_LIST que faci les seguents operacions:

    -Descripció:
El programa mostrarà un missatge per cada localització de la base de dades, mostrant el nom de la CIUTAT.

Si es mostra el nom d'una ciutat que està repetida a localitzacions, s'haurà de mostrar el missatge addicional "Aquesta ciutat està repetida!!"

    -Control d'errors:
Fes un control d'errors genéric que inclogui el codi i descripció de l'error.
*/
CREATE OR REPLACE PROCEDURE CITY_LIST
IS
    CURSOR c_cur IS
        SELECT city FROM locations ORDER BY 1;
        
    v_count NUMBER;
    v_old_city VARCHAR2(200) := NULL;
BEGIN
    FOR i IN c_cur LOOP
        SELECT COUNT(*) INTO v_count FROM locations
         WHERE city=i.city;
    
        DBMS_OUTPUT.PUT_LINE('Ciutat: '||i.city);
        
        IF(v_count > 1 AND v_old_city = i.city) THEN
            DBMS_OUTPUT.PUT_LINE('Esta repetida!');
        END IF;
        
        v_old_city := i.city;
        
        
    END LOOP;
    
END;
/



/*
NOMBRE: proc_sube_sueldo
PARAMETROS: p_dept_name VARCHAR2, p_plus NUMBER
DESCRIPCION:
    El procedimiento actualizara los asalrios de todos
    los empleados de cp_employees que trabajen en el departmento
    p_dept_name. El nuevo salario será el mismo sumado a p_plus.
    Para cada empleado actualizado se tiene que mostrar una linea de mensaje con NOMBRE, APELLIDO, SALARIO ANTERIOR y NUVO SALARIO.

CONTROL DE ERRORES:
    -Si el departamento no existe, informar de error.
    -Si el p_plus es negativo, informar del error.
    -Si no hay ningun empleado en el departamento, informar de ello.
*/

CREATE OR REPLACE PROCEDURE proc_sube_sueldo(p_dep_name VARCHAR2, p_plus NUMBER)
IS
    CURSOR c_cur IS
    SELECT emp.employee_id, emp.first_name AS fn, emp.last_name AS ln, emp.salary, emp.salary+p_plus AS new_salary
    FROM employees emp
        JOIN departments dep ON (emp.department_id = dep.department_id)
    WHERE UPPER(dep.department_name) = UPPER(p_dep_name);

    e_nodep         EXCEPTION;
    e_plus_negativo EXCEPTION;
    e_noemps        EXCEPTION;
    v_count         NUMBER;
    v_nuevo         NUMBER;
BEGIN

    IF(p_plus < 0) THEN
        RAISE e_plus_negativo;
    END IF;
    
    -- Control no dep
    SELECT COUNT(*) INTO v_count
    FROM departments
    WHERE UPPER(department_name) = upper(p_dep_name);
    IF (v_count = 0) THEN
        RAISE e_nodep;
    END IF;
    
    -- Control no emp
    v_count := 0;
    
    -- Atualizar emp
    FOR i IN c_cur LOOP
        v_nuevo := i.salary+p_plus
        UPDATE copy_employees SET salary = v_nuevo
         WHERE employee_id = i.employee_id;
         
        DBMS_OUTPUT.PUT_LINE('Empleado '||i.fn||' '||i.ln||' actualizar.');
        DBMS_OUTPUT.PUT_LINE('  --Antiguo salario: '||i.salary);
        DBMS_OUTPUT.PUT_LINE('  --Nuevo salario: '||v_nuevo);
        v_count := 1;
    END LOOP;
    
    -- Control no emp
    IF(v_count = 0) THEN
        RAISE e_noemps;
    END IF;

EXCEPTION
    WHEN e_plus_negativo THEN
        DBMS_OUTPUT.PUT_LINE('Error - plus negativo.');
    WHEN e_nodep THEN
        DBMS_OUTPUT.PUT_LINE('Error - no existe el departmento.');
    WHEN e_noemps THEN
        DBMS_OUTPUT.PUT_LINE('Error - no hay empleados a actualizar.');
END;
/
EXEC proc_sube_sueldo();
/
















