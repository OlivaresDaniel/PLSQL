/
SET SERVEROUTPUT ON;
/
/*
EXERCICI 1
TIPUS: Bloc anónim
DESCRIPCIÓ:
El programa recorrerà tota la taula de departaments i mostrarà el següent missatge, per cada
departament:
"El departament XXXXXX té id XXXXXXX"
*/
/
DECLARE
    --Declaracion del cursor
    CURSOR c_emp IS
        SELECT department_id AS dep, department_name AS nom
         FROM departments;
BEGIN
    --Recorremos cursor con un LOOP(bucle).
    FOR sacar_datos IN c_emp
    LOOP
        DBMS_OUTPUT.PUT_LINE('El departament '||sacar_datos.nom||' té id '||sacar_datos.dep);
    END LOOP;
END;
/
/*
EXERCICI 2
TIPUS: Bloc anónim
DESCRIPCIÓ:
El programa recorrerà la taula d’empleats i mostrarà el següent missatge per als treballadors
amb id senar:
“L’empleat XXXXXX té id XXXXXXX
*/
/
DECLARE
    CURSOR c_emp IS
        SELECT first_name||' '||last_name AS nom, employee_id AS idemp
         FROM employees
         WHERE MOD(employee_id,2) = 1;
BEGIN
    FOR sacar_datos IN c_emp
    LOOP
        DBMS_OUTPUT.PUT_LINE('L`empleat '||sacar_datos.idemp||' és '||sacar_datos.nom);
    END LOOP;
END;
/
/*
EXERCICI 3
TIPUS: Bloc anónim
DESCRIPCIÓ:
El programa mostrarà una llista de missatges amb el següent text:
“L’empleat XXXXX cobra MÁS/MENOS que la mitja del seu departament”
Si l’empleat no té departament, canvia pel text:
"L’empleat XXXXX no el volen a cap departament..."
*/
/
DECLARE
    CURSOR c_emp IS 
        SELECT first_name||' '||last_name AS emp, salary, department_id
          FROM employees;
    v_avg NUMBER;
BEGIN
    FOR sacar_datos IN c_emp
    LOOP
        SELECT AVG(salary) INTO v_avg
          FROM employees
          WHERE department_id = sacar_datos.department_id;
    
        IF(sacar_datos.department_id IS NULL) THEN
            DBMS_OUTPUT.PUT_LINE('L`empleat '||sacar_datos.emp||' no el colen a cap department...');
        ELSIF(v_avg > sacar_datos.salary) THEN
            DBMS_OUTPUT.PUT_LINE('L`empleat '||sacar_datos.emp||' cobra MENOS que la mitja del seu department');
        ELSIF(v_avg < sacar_datos.salary) THEN
            DBMS_OUTPUT.PUT_LINE('L`empleat '||sacar_datos.emp||' cobra MÁS que la mitja del seu department');
        ELSIF(v_avg = sacar_datos.salary) THEN
            DBMS_OUTPUT.PUT_LINE('L`empleat '||sacar_datos.emp||' cobra IGUAL que la mitja del seu department');
        END IF;
    END LOOP;
END;
/
/*
EXERCICI 4
TIPUS: Bloc anónim
DESCRIPCIÓ:
El programa mostrarà una llista de missatges pera a cada departament amb el següent text:
“El departament <department_name> té el manager <first_name> <last_name>”.
Si el departament no té manager, el missatge serà:
"El departament <department_name> no té manager."
*/
/
DECLARE
    CURSOR c_cur IS
        SELECT dep.department_name,
            man.first_name||' '||man.last_name AS man,
            dep.manager_id
        FROM departments dep
         LEFT JOIN employees man ON (dep.manager_id = man.employee_id);
BEGIN
    FOR i IN c_cur
    LOOP
        IF(i.manager_id IS NULL) THEN
            DBMS_OUTPUT.PUT_LINE(i.department_name||' no tiene manager.');
        ELSE
            DBMS_OUTPUT.PUT_LINE(i.department_name||' tiene manager '||i.man);
        END IF;
    END LOOP;
END;

/
/*
EXERCICI 5
TIPUS: procedimiento
NOM: p_quien_cobra
PARÀMETRES D’ENTRADA: p_salary
DESCRIPCIÓ:
El procediment rebrà un import(salary) i mostrarà el llistat de tots els treballadors que
cobren aquesta quantitat (nom i cognom).
CONTROL D’ERRORS:
- Si ens passen un nombre negatiu – Genera error “salari negatiu”
- Si ens passen un 0 – Genera error “Ningú fa tanta llàstima”
- Si no hi ha cap empleat que cobra la quantitat – Genera error “Ningú cobra la quantitat”
*/
/
CREATE OR REPLACE PROCEDURE p_quien_cobra(p_salary NUMBER)
IS
    CURSOR c_cur IS
        SELECT first_name||' '||last_name AS emp
         FROM employees WHERE salary = p_salary;
         
    c_count NUMBER := 0;
BEGIN
    IF(p_salary = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Nadie cobra tan poco');
    ELSIF (p_salary < 0) THEN
        DBMS_OUTPUT.PUT_LINE('No puede ser negativo');
    ELSE
        FOR i IN c_cur LOOP
            DBMS_OUTPUT.PUT_LINE(i.emp);
            c_count := 1;
        END LOOP;
        
        IF c_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nadie cobra eso.');
        END IF;
    END IF;
END;
/





