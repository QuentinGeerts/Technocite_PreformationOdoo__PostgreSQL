--
-- DML
-- Data Manipulation Language : Langage de manipulation de données
-- INSERT, UPDATE, DELETE et transactions
--

-- Par défaut, PostgreSQL est en mode AUTOCOMMIT :
-- → Chaque instruction est validée immédiatement et définitivement 
-- → pour pouvoir annuler, on va travailler avec une transaction: BEGIN ... ROLLBACK


-- 1.  INSERT
-- Ajouter des lignes dans une table

-- 1.1. Sans liste de colonnes
-- → toutes les valeurs sont dans l'ordre exacte des colonnes de la table
-- → déconseillé

BEGIN;

INSERT INTO student
VALUES (26, 'Quentin', 'Geerts', '1996-04-03', 'qgeerts', 1010, 12, NULL);

SELECT * FROM student WHERE student_id = 26;

ROLLBACK;

-- 1.2. Avec liste de colonnes (recommandé)
-- → l'ordre des valeurs suit l'ordre des colonnes
-- → les colonnes omises reçoivent leur valeur par défaut (NULL si aucun DEFAULT)

BEGIN;

INSERT INTO student (student_id, last_name, first_name, section_id)
VALUES (26, 'Quentin', 'Geerts', 1010);

SELECT * FROM student WHERE student_id = 26;

ROLLBACK;

-- 1.3. Plusieurs lignes en une seule instruction

BEGIN;

INSERT INTO student (student_id, last_name, first_name, section_id)
VALUES 
  (26, 'Quentin', 'Geerts', 1010),
  (27, 'Mélanie', 'Geerts', 1010),
  (28, 'William', 'Geerts', 1010),
  (29, 'Antoine', 'Geerts', 1010),
  (30, 'Benjamin', 'Geerts', 1010);

SELECT * FROM student WHERE student_id >= 26;

ROLLBACK;

-- 1.4.  RETURNING (spécifique à PgSQL)
-- → renvoie les lignes réellement insérées (utile pour récupérer un id généré)

BEGIN;

INSERT INTO student (student_id, last_name, first_name, section_id)
VALUES 
  (26, 'Quentin', 'Geerts', 1010)
  -- RETURNING student_id, last_name, course_id;
  RETURNING *;

ROLLBACK;


-- 1.5. INSERT ... SELECT
-- → les lignes à insérer viennent d'une requête (pas de VALUES (...))
-- → le SELECT doit retourner le même nombre de colonne, dans le même ordre

BEGIN;

INSERT INTO section (section_id, section_name)
SELECT section_id + 1000, section_name || ' (soir)'
FROM section RETURNING *;

ROLLBACK;

-- 1.6. DEFAULT et IDENTITY
-- → la table student n'a ni IDENTITY ni DEFAULT: créer une petite table
-- → En PgSQL, le DDL est aussi annulable → supression de la table en rollback

BEGIN;

CREATE TABLE message (
  message_id INT GENERATED ALWAYS AS IDENTITY,
  content TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT pk_message PRIMARY KEY (message_id)
);

-- id, is_read et created_at sont remplis automatiquement
INSERT INTO message (content)
VALUES ('Hello la préfo Odoo !') RETURNING *;


-- le mot-clef "DEFAULT" force explicitement la valeur par défaut
INSERT INTO message (content, is_read)
VALUES 
  ('Déjà lu', true),
  ('Pas encore lu', DEFAULT) RETURNING *;

ROLLBACK;

-- 1.7. Contraintes
-- → toutes insertion qui viole une contrainte est refusée
-- → après une erreur, la transaction est bloquée : seul ROLLBACK est déclenché

-- PRIMARY KEY
BEGIN;
INSERT INTO student (student_id, last_name, first_name) VALUES (1, 'Doe', 'John');
ROLLBACK;

-- FOREIGN KEY
BEGIN;
INSERT INTO student (student_id, last_name, first_name, section_id) 
VALUES (26, 'Doe', 'John', 999);
ROLLBACK;

-- Pareil pour les autres...

-- 2.  UPDATE
-- Modifier des lignes existantes

-- UPDATE table
-- SET colonne = valeur [, colonne = valeur ...]
-- WHERE condition;

-- 2.1. Une colonne

BEGIN;

UPDATE student
SET last_name = 'Toto'
WHERE student_id = 1 RETURNING *;

ROLLBACK;

-- 2.2. Plusieurs colonnes

BEGIN;

UPDATE student
SET 
  last_name = 'Toto',
  first_name = 'Toto'
WHERE student_id = 1  -- ATTENTION AU WHERE
RETURNING *;

ROLLBACK;

-- 2.3. Valeur calculée à partir de l'ancienne valeur
-- LEAST renvoie la plus petite valeur (GREATEST: la plus grande)

BEGIN;

UPDATE student
SET year_result = LEAST(year_result + 5, 20)
-- SET year_result = year_result + 5 -- Attention ça peut dépasser 20
WHERE section_id = 1310
RETURNING *;

ROLLBACK;

-- 2.4.  CASE: une règle différente selon la ligne

BEGIN;

UPDATE professor
SET 
  professor_wage = 
  CASE 
    WHEN professor_hire_date < '2000-01-01' THEN professor_wage * 1.10
    ELSE professor_wage * 1.05
  END
RETURNING professor_name, professor_hire_date, professor_wage;

ROLLBACK;

-- 2.5. Sous-requêtes

BEGIN;

UPDATE student
SET
  course_id = (
    SELECT course_id FROM course WHERE course_name = 'Financial Management'
  )
WHERE section_id = (
  SELECT section_id
  FROM student
  WHERE last_name = 'Willis' AND first_name = 'Bruce'
)
RETURNING student_id, last_name, section_id, course_id;

ROLLBACK;

-- 2.6. UPDATE sans WHERE
-- → TOUTES les lignes sont modifiées : erreur classique à éviter

BEGIN;

UPDATE student
SET
  year_result = 0
RETURNING *;

ROLLBACK;

-- 3.  DELETE
-- Supprimer des lignes

-- DELETE FROM table
-- WHERE condition;

-- 3.1. Avec WHERE

BEGIN;

DELETE FROM student
WHERE student_id = 21
RETURNING *;

SELECT COUNT(*) FROM student; -- 24

ROLLBACK;

-- 3.2.  FOREIGN KEY : suppression refusée

BEGIN;
DELETE FROM professor WHERE professor_id = 1;
ROLLBACK;


-- 3.3.  DELETE sans WHERE vs TRUNCATE
-- DELETE FROM table → supprimer ligne par ligne, création d'une ligne par log
-- TRUNCATE → vider toute la table d'un coup (beaucoup plus optimisé)
-- → Les deux sont annulables par ROLLBACK

BEGIN;

DELETE FROM grade;
SELECT COUNT(*) FROM grade; -- 0

ROLLBACK;

BEGIN;

TRUNCATE TABLE grade;
SELECT COUNT(*) FROM grade; -- 0

ROLLBACK;

SELECT COUNT(*) FROM grade; -- 7
