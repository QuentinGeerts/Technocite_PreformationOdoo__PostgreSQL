--
-- Functions, GROUP BY and HAVING
--


-- 1. Functions


SELECT COUNT(student_id), first_name
FROM student;


-- L'instruction CASE
-- → similaire à if elif else

SELECT 
  last_name,
  first_name,
  CASE
    WHEN year_result >= 19 THEN 'Excellent'
    WHEN year_result >= 10 THEN 'Réussi'
    ELSE 'Raté'
  END
FROM student;

-- L'expression CASE
-- → match ... case

SELECT 
  last_name,
  first_name,
  section_id,
  CASE section_id
    WHEN 1010 THEN 'Informatique de gestion'
    WHEN 1020 THEN 'Comptabilité'
    ELSE 'Sans section'
  END 
FROM student;


SELECT section_id, course_id, AVG(year_result)
FROM student
GROUP BY section_id, course_id
ORDER BY section_id;


SELECT section_id, AVG(year_result)
FROM student
GROUP BY section_id;


SELECT section_id, course_id, AVG(year_result)
FROM student
GROUP BY ROLLUP(section_id, course_id)$
ORDER BY section_id, course_id;