--
-- SELECT ... FROM ...
-- Extraire des données depuis une table
--

SELECT student_id,
       last_name,
       first_name,
       birth_date,
       login
FROM student;


SELECT last_name -- , first_name
FROM student;


SELECT *
FROM student;


SELECT last_name AS "Nom de famille",
       first_name,
       section_id Section,
                  section_id "Section"
FROM student;


SELECT last_name,
       first_name,
       year_result,
       year_result * 5 "percentage"
FROM student;


SELECT 10 / 3.0;


SELECT 10.0 / 3;


SELECT last_name,
       first_name,
       (year_result::NUMERIC / 20) * 100 "percentage"
FROM student;


SELECT last_name || ' ' || first_name "fullname"
FROM student;


SELECT concat(last_name, ' ', first_name) "fullname",
       concat(last_name, ' ', first_name, ' ', birth_date, ' ', login) "informations",
       concat_ws(' ', last_name, first_name, birth_date) "informations"
FROM student;


SELECT DISTINCT first_name,
                last_name
FROM student;


SELECT 'Hello la préfo',
       12 * 4;


SELECT last_name,
       first_name,
       'élève' "role"
FROM student;


SELECT *
FROM student
WHERE year_result >= 10;


SELECT *
FROM student
WHERE NOT(year_result >= 10);


SELECT *
FROM student
WHERE year_result BETWEEN 7 AND 14;


SELECT *
FROM student
WHERE birth_date BETWEEN '1940-01-01' AND '1955-12-31';


SELECT *
FROM student
WHERE date_part('year', birth_date) BETWEEN 1940 AND 1955;


SELECT *
FROM student
WHERE first_name IN ('tom',
                     'Georges',
                     'Natalie');


SELECT *
FROM student
WHERE first_name LIKE 'A%';


SELECT *
FROM student
WHERE first_name LIKE '%a';


SELECT *
FROM student
WHERE first_name ILIKE '%A';


SELECT *
FROM student
WHERE first_name ILIKE '%A%';


SELECT *
FROM student
WHERE first_name ILIKE '__E%';


SELECT *
FROM student
WHERE last_name ILIKE '%OO%';


SELECT *
FROM student
WHERE year_result NOT BETWEEN 5 AND 15;

SELECT *
FROM student
WHERE first_name NOT ILIKE '%E%';

SELECT *
FROM student
WHERE section_id NOT IN (1010, 1020, 1310, 1320);


SELECT *
FROM student
WHERE year_result IS NULL;

SELECT *
FROM student
WHERE year_result IS NOT NULL;

SELECT student_id, first_name, last_name, year_result
FROM student
WHERE first_name LIKE 'J%' AND year_result >= 10;

SELECT student_id, first_name, last_name, year_result
FROM student
WHERE first_name LIKE 'J%' OR year_result >= 10;


SELECT year_result, first_name, last_name
FROM student
ORDER BY year_result DESC, first_name, last_name ASC;