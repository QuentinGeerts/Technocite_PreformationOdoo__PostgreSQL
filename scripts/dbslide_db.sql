-- Rend le script rejouable
DROP TABLE IF EXISTS course, professor, student, grade, section CASCADE;

CREATE TABLE section (
  section_id int NOT NULL,
  section_name varchar(50),
  delegate_id int,
  CONSTRAINT PK_section PRIMARY KEY (section_id)
);

CREATE TABLE professor (
  professor_id int NOT NULL,
  professor_name varchar(30) NOT NULL,
  professor_surname varchar(30) NOT NULL,
  section_id int NOT NULL,
  professor_office int NOT NULL,
  professor_email varchar(30) NOT NULL,
  professor_hire_date timestamp NOT NULL,
  professor_wage int NOT NULL,
  CONSTRAINT PK_professor PRIMARY KEY (professor_id),
  CONSTRAINT FK_professor_section FOREIGN KEY (section_id) REFERENCES section (section_id)
);

CREATE TABLE course (
  course_id varchar(8) NOT NULL,
  course_name varchar(200) NOT NULL,
  course_ects decimal(3,1) NOT NULL,
  professor_id int NOT NULL,
  CONSTRAINT PK_course PRIMARY KEY (course_id),
  CONSTRAINT FK_course_professor FOREIGN KEY (professor_id) REFERENCES professor (professor_id)
);

CREATE TABLE student (
  student_id int NOT NULL,
  first_name varchar(50),
  last_name varchar(50),
  birth_date timestamp,
  login varchar(50),
  section_id int,
  year_result int,
  course_id varchar(8),  -- NULL = aucun cours (remplace l'ancien '0')
  CONSTRAINT PK_student PRIMARY KEY (student_id),
  CONSTRAINT FK_student_section FOREIGN KEY (section_id) REFERENCES section (section_id),
  CONSTRAINT FK_student_course FOREIGN KEY (course_id) REFERENCES course (course_id)
);

CREATE TABLE grade (
  grade char(2) NOT NULL,
  lower_bound int NOT NULL,
  upper_bound int NOT NULL,
  CONSTRAINT PK_grade PRIMARY KEY (grade)
);

-- Référence circulaire section <-> student : la FK est ajoutée après coup
-- et vérifiée seulement au COMMIT (DEFERRABLE INITIALLY DEFERRED)
ALTER TABLE section
  ADD CONSTRAINT FK_section_delegate FOREIGN KEY (delegate_id) REFERENCES student (student_id)
  DEFERRABLE INITIALLY DEFERRED;