SET SERVEROUTPUT ON;
/*
1. Defineix un bloc anònim que faci el següent:
El programa mostrarà una llista de tots els departaments amb:
department_id, department_name, nombre d'empleats del departament i suma de
salaris d’empleats del departament.
Construeix la cadena de sortida amb el text que tu vulguis.
Quan et trobis un departament amb un EMPLEAT sense MANAGER (un cap), afegeix davant el
missatge de sortida el següent text: "JEFE AQUÍ---->"
*/
DECLARE
    --Declaracion del cursor
    CURSOR c_emp IS
        SELECT dep.department_id, dep.department_name,
            COUNT(emp.employee_id) AS em,
            NVL(SUM(emp.salary),0) AS sal
        FROM employees emp
            RIGHT JOIN departments dep
             ON (dep.department_id = emp.department_id)
        GROUP BY dep.department_id, dep.department_name;
        
    v_jefes NUMBER;
BEGIN
    --Recorremos cursor con un LOOP(bucle).
    FOR sacar_datos IN c_emp
    LOOP
        --Busco si hay empleado jefe (sin manager)
        SELECT COUNT(*) INTO v_jefes
         FROM employees
         WHERE manager_id IS NULL
          AND department_id = sacar_datos.department_id;
        
        IF (v_jefes > 0) THEN
            DBMS_OUTPUT.PUT_LINE('JEFE AQUI!!!');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Departmento '||sacar_datos.department_name||': '||'num '||sacar_datos.department_id);
        DBMS_OUTPUT.PUT_LINE('Total departamento: '||sacar_datos.em);
        DBMS_OUTPUT.PUT_LINE('Total salario: '||sacar_datos.sal);
        DBMS_OUTPUT.PUT_LINE('-------------------------------');
    
    END LOOP;
END;
/


/*
2. Defineix un bloc anònim que faci el següent:
Mostrar una llista de missatges recorrent la taula de departaments. A cada departament es
mostrarà el missatge:
El departament <nom de departament> té el manager <nom del manager de
departament>.
Si un departament no té manager, es mostrarà el missatge:
El departament <nom de departament> no té manager.
*/



DECLARE
    CURSOR c_cur IS
        SELECT dep.department_name,
            man.first_name||' '||man.last_name AS manager_name,
            man.employee_id
        FROM departments dep
         LEFT JOIN employees man
          ON (dep.manager_id = man.employee_id);
BEGIN
    FOR sacar_datos IN c_cur
    LOOP
        IF (sacar_datos.employee_id IS NULL) THEN
            DBMS_OUTPUT.PUT_LINE('DEP: '||sacar_datos.department_name||' no tiene manager');
        ELSE
            DBMS_OUTPUT.PUT_LINE('DEP: '||sacar_datos.department_name||' - MAN: '||sacar_datos.manager_name);
        END IF;
    END LOOP;
END;
/
/*
3. Defineix un bloc anònim que faci les següents operacions:
Mostra un llistat de missatges amb tots els empleats, indicant quants empleats tenen a càrrec
seu. Han d’aparèixer tots els empleats i mostrar el següent text:
<nom de l’empleat> té a càrrec seu a <n> empleats.
Si un treballador no té ningú a càrreg es mostrarà:
<nom de l’empleat> no és manager.
*/
DECLARE
    CURSOR c_cur IS 
    SELECT man.first_name, man.last_name, COUNT(emp.employee_id) AS recuento 
     FROM employees emp
      RIGHT JOIN employees man
       ON (emp.manager_id = man.employee_id)
    GROUP BY man.first_name, man.last_name;
BEGIN
    FOR sacar_datos IN c_cur
    LOOP
        IF (sacar_datos.recuento = 0) THEN
            DBMS_OUTPUT.PUT_LINE(sacar_datos.first_name||' '||sacar_datos.last_name||' no tiene empleados a cargo.');
        ELSE
            DBMS_OUTPUT.PUT_LINE(sacar_datos.first_name||' '||sacar_datos.last_name||' tiene '||sacar_datos.recuento||' empleados ac argo');
        END IF;
    END LOOP;
END;
/









































