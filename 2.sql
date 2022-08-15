-- Write a query to transpose the data for each employee from below table -
--    Employee (EmployeeFirstName, EmployeeLastName, ContactType, ContactNumber).
--    ContactType can be "Mobile", "Home", "Office" or "Emergency". 
-- Result should have GKID (system generated surrogate key), EmployeeFirstName, EmployeeLastName followed by one columns for each contact type.



WITH E AS (
    SELECT 
        EmpFirstName
        , EmpLastName
        , ContactType
        , ContactNumber
        RANK() (OVER ORDER BY EmpFirstName, EmpLastName) AS GCID
    FROM Employee
) E
SELECT 
    ROW_NUMBER() OVER (PARTITION BY EmpFirstName, EmpLastName ORDER BY EmpFirstName, EmpLastName) AS GKID
    , EmpFirstName
    , EmpLastName
    COALESCE(MAX(CASE WHEN GCID = 1 THEN ContactNumber ELSE '' END), NULL) AS ContactNumber_Emergency
    COALESCE(MAX(CASE WHEN GCID = 2 THEN ContactNumber ELSE '' END), NULL) AS ContactNumber_Home
    COALESCE(MAX(CASE WHEN GCID = 3 THEN ContactNumber ELSE '' END), NULL) AS ContactNumber_Mobile
    COALESCE(MAX(CASE WHEN GCID = 4 THEN ContactNumber ELSE '' END), NULL) AS ContactNumber_Office
FROM E
GROUP BY EmpFirstName, EmpLastName;
