SET SERVEROUTPUT ON;
/*
1. Defineix un bloc an�nim que faci el seg�ent:
El programa mostrar� una llista de tots els departaments amb:
department_id, department_name, nombre d'empleats del departament i suma de
salaris d�empleats del departament.
Construeix la cadena de sortida amb el text que tu vulguis.
Quan et trobis un departament amb un EMPLEAT sense MANAGER (un cap), afegeix davant el
missatge de sortida el seg�ent text: "JEFE AQU�---->"
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
2. Defineix un bloc an�nim que faci el seg�ent:
Mostrar una llista de missatges recorrent la taula de departaments. A cada departament es
mostrar� el missatge:
El departament <nom de departament> t� el manager <nom del manager de
departament>.
Si un departament no t� manager, es mostrar� el missatge:
El departament <nom de departament> no t� manager.
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
3. Defineix un bloc an�nim que faci les seg�ents operacions:
Mostra un llistat de missatges amb tots els empleats, indicant quants empleats tenen a c�rrec
seu. Han d�apar�ixer tots els empleats i mostrar el seg�ent text:
<nom de l�empleat> t� a c�rrec seu a <n> empleats.
Si un treballador no t� ning� a c�rreg es mostrar�:
<nom de l�empleat> no �s manager.
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









































