/*EJEMPLO 1 CURSORES:
Recorrer empleados del departamento 90 y mostrar
nombre, apellido, salario y antiguedad (en años)
*/

DECLARE
    --Declaracion del cursor
    CURSOR c_emp IS
        SELECT first_name, last_name, salary,
            ROUND((SYSDATE-hire_date)/365,1) AS antiguedad
         FROM employees WHERE department_id = 90;
    x NUMBER :=0;
BEGIN
    --Recorremos cursor con un LOOP(bucle). Tambien habra un FOR que cerraremos.
    FOR sacar_datos IN c_emp
    LOOP
    x := x+1;
        DBMS_OUTPUT.PUT_LINE('empleado '||x||': '||sacar_datos.first_name||' '||sacar_datos.last_name);
        DBMS_OUTPUT.PUT_LINE('- Salario '||x||': '||sacar_datos.salary);
        DBMS_OUTPUT.PUT_LINE('- Antiguedad '||x||': '||sacar_datos.antiguedad);
        DBMS_OUTPUT.PUT_LINE('---------------');
    
    END LOOP;
END;
/
SET SERVEROUTPUT ON;