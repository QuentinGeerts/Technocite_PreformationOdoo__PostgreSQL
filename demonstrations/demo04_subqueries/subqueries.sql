--
-- Subqueries
--


-- 1. Au niveau d'un WHERE / HAVING

-- Récupération de la liste des élèves de la classe de Bruce Willis

SELECT
  last_name,
  first_name,
  section_id
FROM student
WHERE section_id = 1010;


-- Sélectionner la section_id de Bruce Willis

SELECT section_id 
FROM student 
WHERE last_name = 'Willis' AND first_name = 'Bruce';

-- Assemblage des deux requêtes

SELECT
  last_name,
  first_name,
  section_id
FROM student
WHERE section_id = (
  SELECT section_id 
  FROM student 
  WHERE last_name = 'Willis' AND first_name = 'Bruce'
) AND last_name <> 'Willis' AND first_name <> 'Bruce';


SELECT 
  last_name,
  first_name,
  section_id
FROM student
WHERE section_id IN (
  SELECT DISTINCT section_id
  FROM student
  WHERE first_name IN ('Bruce', 'Natalie', 'Tom', 'Georges')
);

-- Au niveau du HAVING

-- Récupérer les sections qui ont une moyenne supérieure à la moyenne de l'ensemble des étudiants

SELECT AVG(year_result) moyenne
FROM student;

SELECT 
  section_id,
  AVG(year_result)
FROM student
GROUP BY section_id
HAVING AVG(year_result) >= 8.76;

-- Assemblage 

SELECT 
  section_id,
  AVG(year_result)
FROM student
GROUP BY section_id
HAVING AVG(year_result) >= (
  SELECT AVG(year_result) moyenne
  FROM student
);

-- Au niveau du FROM

SELECT 
  last_name,
  first_name,
  s.section_id,
  section_name,
  c.course_id,
  course_name
FROM student st
  JOIN section s ON st.section_id = s.section_id
  JOIN course c ON  st.course_id = c.course_id


SELECT 
  last_name,
  first_name,
  section_name,
  course_name
FROM (
  SELECT 
    last_name,
    first_name,
    s.section_id,
    section_name,
    c.course_id,
    course_name
  FROM student st
    JOIN section s ON st.section_id = s.section_id
    JOIN course c ON  st.course_id = c.course_id
);


WITH student_section_course 
AS (
  SELECT 
    last_name,
    first_name,
    s.section_id,
    section_name,
    c.course_id,
    course_name
  FROM student st
    JOIN section s ON st.section_id = s.section_id
    JOIN course c ON  st.course_id = c.course_id
)

SELECT * 
FROM student_section_course;