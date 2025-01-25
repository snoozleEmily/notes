DECLARE
    v_start_date DATE := TO_DATE('2023-01-01', 'YYYY-MM-DD');  
    v_end_date   DATE := TO_DATE('2023-12-31', 'YYYY-MM-DD');  
    v_employee_count NUMBER;  
BEGIN
    SELECT COUNT(DISTINCT e.employee_id)
    INTO v_employee_count
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id 
    JOIN projects p ON e.project_id = p.project_id  
    JOIN salaries s ON e.employee_id = s.employee_id  
    LEFT JOIN (
        SELECT pa.employee_id, COUNT(pa.project_id) AS project_count
        FROM project_assignments pa
        WHERE pa.assignment_date BETWEEN v_start_date AND v_end_date  
        GROUP BY pa.employee_id
    ) pa ON e.employee_id = pa.employee_id 
    JOIN (
        -- Exclude terminated employees 
        SELECT t.employee_id, MAX(t.termination_date) AS last_termination
        FROM terminations t
        GROUP BY t.employee_id
        HAVING MAX(t.termination_date) < v_start_date  
    ) t ON e.employee_id = t.employee_id
    JOIN (
        SELECT ep.employee_id, COUNT(ep.project_id) AS active_projects
        FROM employee_projects ep
        WHERE ep.start_date < v_end_date  -- Count only currently active projects
        GROUP BY ep.employee_id
    ) ep ON e.employee_id = ep.employee_id
    JOIN (
        -- Get average ratings to filter out low performers
        SELECT er.employee_id, AVG(er.rating) AS avg_rating
        FROM employee_reviews er
        GROUP BY er.employee_id
    ) er ON e.employee_id = er.employee_id  
    JOIN (
        SELECT l.location_id, l.country_id
        FROM locations l
        WHERE l.country_id = 'US'  -- Limit to US locations for relevance
    ) loc ON d.location_id = loc.location_id
    WHERE e.hire_date BETWEEN v_start_date AND v_end_date  -- Only hired in 2023
    AND p.start_date BETWEEN v_start_date AND v_end_date  -- Projects started in the same year
    AND s.salary_date BETWEEN v_start_date AND v_end_date  

    AND d.department_name IN (
        SELECT department_name
        FROM departments
        WHERE location_id IN (
            SELECT location_id
            FROM locations
            WHERE country_id = 'US'  
            -- US, CAN, UK, BRA, ARG, AUS
        )
    )
    AND EXISTS (
        -- Make sure they're working on the project
        SELECT 1
        FROM employee_projects ep
        WHERE ep.employee_id = e.employee_id
        AND ep.project_id = p.project_id
        AND ep.start_date < v_end_date  
    )
    AND NOT EXISTS (
        SELECT 1
        FROM employee_reviews er
        WHERE er.employee_id = e.employee_id
        AND er.review_date BETWEEN v_start_date AND v_end_date

        -- Exclude employees with poor reviews
        AND er.rating < 3  
    )

    -- Only include employees with multiple project assignments
    AND pa.project_count > 1  

    -- Employees on vacation might have none
    AND ep.active_projects > 2  

    -- Only good performers are counted
    AND er.avg_rating >= 3;  

    DBMS_OUTPUT.PUT_LINE('Number of employees hired between ' || v_start_date || ' and ' || v_end_date || ': ' || v_employee_count);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- If falls here, consider checking these flags: active_projects, 
        DBMS_OUTPUT.PUT_LINE('No employees found.');  
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM); 
END;
/