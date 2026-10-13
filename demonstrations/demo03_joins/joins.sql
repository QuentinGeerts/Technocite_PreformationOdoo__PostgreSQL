--
-- Démonstration sur les jointures
--


-- 1.  Horizontales

-- 1.1.  [INNER] JOIN

SELECT
  student_id,
  last_name,
  first_name,
  section.section_id,
  section_name
FROM student
  JOIN section ON student.section_id = section.section_id;


SELECT
  student_id,
  last_name,
  first_name,
  s.section_id,
  section_name
FROM student st
  JOIN section s ON st.section_id = s.section_id;

SELECT
  student_id,
  last_name,
  first_name,
  s.section_id,
  section_name
FROM student st, section s 
WHERE st.section_id = s.section_id;


SELECT
  st.student_id,
  st.last_name,
  st.first_name,
  s.section_id,
  s.section_name,
  del.last_name "delegate_lastname",
  del.first_name "delegate_firstname",
  p.professor_name,
  p.professor_surname
FROM student st
  JOIN section s ON st.section_id = s.section_id
  JOIN student del ON s.delegate_id = del.student_id
  JOIN professor p ON p.section_id = s.section_id


-- Non equi join

SELECT
  st.student_id,
  st.last_name,
  st.first_name,
  st.year_result,
  g.grade
FROM student st
  JOIN grade g ON st.year_result BETWEEN g.lower_bound AND g.upper_bound
ORDER BY g.upper_bound DESC;

-- 1.2.  LEFT [OUTER] JOIN

SELECT
  s.section_name,
  p.professor_name,
  p.professor_surname
FROM section s 
  LEFT JOIN professor p ON s.section_id = p.section_id;

SELECT
  s.section_name,
  p.professor_name,
  p.professor_surname
FROM section s 
  RIGHT JOIN professor p ON s.section_id = p.section_id;


-- 1.3.  RIGHT [OUTER] JOIN
SELECT
  s.section_name,
  p.professor_name,
  p.professor_surname
FROM professor p 
  RIGHT JOIN section s ON s.section_id = p.section_id;


-- 1.4.  FULL [OUTER] JOIN
SELECT
  s.section_name,
  p.professor_name,
  p.professor_surname
FROM professor p 
  FULL JOIN section s ON s.section_id = p.section_id;

-- 2.  Verticales

-- 2.1.  UNION [ALL]


SELECT 
  last_name "lastname", 
  first_name "firstname", 
  'Élève' "role" 
FROM student
UNION
SELECT 
  professor_name, 
  professor_surname, 
  'Professeur' 
FROM professor
ORDER BY "lastname", "firstname";


-- 2.2.  EXCEPT

-- Liste des sections qui n'ont pas de professeur
SELECT section_id FROM section
EXCEPT
SELECT section_id FROM professor;

-- 2.3.  INTERSECT

-- Liste des sections qui ont un professeur
SELECT section_id FROM section
INTERSECT
SELECT section_id FROM professor;

