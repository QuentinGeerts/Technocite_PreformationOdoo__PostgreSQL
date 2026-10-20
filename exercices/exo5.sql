-- SQL Exercises — Gaming Platform
-- DML : INSERT, UPDATE, DELETE + transactions
--
-- Chaque exercice est encadré par BEGIN ... ROLLBACK
-- → les modifications sont annulées : la base reste identique pour l'exercice suivant
-- → en cas d'erreur, la transaction est "abortée" : seul ROLLBACK est encore accepté


--
-- Level 1 — INSERT
--

-- 1. New user
BEGIN;

INSERT INTO users (username, email, country)
VALUES ('Zelda', 'zelda@test.com', 'Belgium')
RETURNING *;

ROLLBACK;

SELECT * FROM users WHERE username = 'Zelda';

-- 2. Several users at once

BEGIN;

INSERT INTO users (username, email, country)
VALUES
  ('Link', 'link@test.com', 'Japan'),
  ('Samus', 'samus@test.com', 'USA'),
  ('Kratos', 'kratos@test.com', 'Greece')
RETURNING *;

ROLLBACK;


-- 3. New publisher and its first game

BEGIN;

INSERT INTO publishers (name, country)
VALUES ('Supergiant Games', 'USA');

INSERT INTO games (title, price, release_date, publisher_id)
VALUES (
  'Hades II', 
  29.99, 
  '2025-09-25', 
  (SELECT id FROM publishers WHERE name = 'Supergiant Games')
);

SELECT
  g.title,
  g.price,
  p.name,
  p.country
FROM games g
  JOIN publishers p ON g.publisher_id = p.id
WHERE g.title = 'Hades II';

ROLLBACK;

-- 4. A profile for Tom

BEGIN;

INSERT INTO profiles (user_id, bio, birth_date)
SELECT 
  id, 'Counter-Strike Addict', '1999-12-24'
FROM users 
WHERE username = 'Tom';

SELECT
  u.username,
  p.bio,
  p.avatar_url,
  p.birth_date
FROM users u
  JOIN profiles p ON u.id = p.user_id
WHERE u.username = 'Tom';

ROLLBACK;

-- 5. Constraints

-- a) A user named `Al`

BEGIN;
INSERT INTO users (username, email, country)
VALUES ('Al', 'al@test.com', 'Belgium'); -- Contrainte username longueur >= 3
ROLLBACK;

-- b) A user with the email `albert.test.com`

BEGIN;
INSERT INTO users (username, email, country)
VALUES ('Albert', 'albert.test.com', 'Belgium'); -- Format email
ROLLBACK;

-- c) A second user named `Davit`

BEGIN;
INSERT INTO users (username, email, country)
VALUES ('Davit', 'davit@test.com', 'Belgium'); -- Unique constraint
ROLLBACK;

-- d) A game that costs -10€

BEGIN;
INSERT INTO games (title, price, publisher_id)
VALUES ('Severed steel', -10, 1); -- check price
ROLLBACK;

-- e) A review with a rating of 6

BEGIN;
INSERT INTO reviews (user_id, game_id, rating, comment)
VALUES (1, 3, 6, 'Super'); -- ck_reviews_rating_range
ROLLBACK;

-- f) A purchase for the user with `id` 999

BEGIN;
INSERT INTO user_games (user_id, game_id, purchase_date)
VALUES (999, 1, CURRENT_DATE); -- fk_user_games_users
ROLLBACK;

-- g) A user inserted with the `id` 100

BEGIN;
INSERT INTO users (id, username, email, country)
VALUES (100, 'Quentin', 'quentin@test.com', 'Belgium'); -- DETAIL: Column "id" is an identity column defined as GENERATED ALWAYS.
ROLLBACK;

-- h) Davit buys Elden Ring (again)

BEGIN;
INSERT INTO user_games (user_id, game_id, purchase_date)
VALUES (1, 1, CURRENT_DATE);
ROLLBACK;

-- i) A review with the comment `Wow`

BEGIN;
INSERT INTO reviews(user_id, game_id, rating, comment)
VALUES (1, 1, 5, 'Wow'); -- ck_reviews_comment_length
ROLLBACK;

--
-- Level 2 — UPDATE
--

-- 6. Mike moves

BEGIN;

UPDATE users
SET country = 'Ireland'
WHERE username = 'Mike'
RETURNING old.*, new.*;

ROLLBACK;

-- 7. FromSoftware sale (-20%)

BEGIN;

UPDATE games
SET price = ROUND(price * 0.8, 2)
WHERE publisher_id = (SELECT id FROM publishers WHERE name = 'FromSoftware')
RETURNING title, price;

ROLLBACK;

-- 8. Inflation (+10% on recent expensive games)

BEGIN;

UPDATE games
SET price = ROUND(price * 1.1, 2)
WHERE release_date >= '2022-01-01' AND price > 50
RETURNING title, release_date, price "new_price", old.price "old_price";

ROLLBACK;

-- 9. Davit's gaming weekend (+50h on each of his games)

BEGIN;

SELECT
  SUM(hours_played) before_update
FROM user_games
WHERE user_id = (SELECT id from users WHERE username = 'Davit');

UPDATE user_games
SET hours_played = hours_played + 50
WHERE user_id = (SELECT id from users WHERE username = 'Davit');

SELECT
  SUM(hours_played) after_update
FROM user_games
WHERE user_id = (SELECT id from users WHERE username = 'Davit');

ROLLBACK;

-- 10. Fill the empty profiles

BEGIN;

UPDATE profiles
SET
  bio = COALESCE(bio, 'No bio yet'),
  avatar_url = COALESCE(avatar_url, 'default.png')
WHERE
  bio IS NULL OR avatar_url IS NULL
RETURNING user_id, bio, avatar_url;

ROLLBACK;

-- 11. New pricing policy

BEGIN;

UPDATE games
SET price =
  CASE
    WHEN price < 30 THEN price + 5
    WHEN price <= 60 THEN ROUND(price * 0.9, 2)
    ELSE 59.99
  END
WHERE price > 0
RETURNING title, price new_price, old.price old_price;

ROLLBACK;

-- 12. Verified owners

BEGIN;

UPDATE reviews r
SET comment = r.comment || ' (verified owner)'
WHERE EXISTS (
  SELECT 1
  FROM user_games ug
  WHERE ug.user_id = r.user_id
    AND ug.game_id = r.game_id
    AND ug.hours_played >= 100
)
RETURNING r.user_id, r.game_id, r.comment;

ROLLBACK;

-- 13. The forgotten WHERE

BEGIN;

UPDATE users
SET country = 'Belgium';

SELECT country, COUNT(id) FROM users GROUP BY country;

ROLLBACK;

SELECT country, COUNT(id) FROM users GROUP BY country;

--
-- Level 3 — DELETE
--

-- 14. Chris's review on League of Legends

BEGIN;

DELETE FROM reviews
WHERE user_id = (SELECT id FROM users WHERE username = 'Chris')
  AND game_id = (SELECT id FROM games WHERE title = 'League of Legends')
RETURNING *;

ROLLBACK;

-- 15. Reviews from non-owners (generic version)

BEGIN;

DELETE FROM reviews r
WHERE NOT EXISTS (
  SELECT 1
  FROM user_games ug
  WHERE ug.user_id = r.user_id
    AND ug.game_id = r.game_id
)
RETURNING *;

ROLLBACK;

-- 16. Lina deletes her account

BEGIN;

SELECT
  (SELECT COUNT(*) FROM users) users,
  (SELECT COUNT(*) FROM user_games) user_games,
  (SELECT COUNT(*) FROM reviews) reviews;

DELETE FROM users
WHERE username = 'Lina';

SELECT
  (SELECT COUNT(*) FROM users) users,
  (SELECT COUNT(*) FROM user_games) user_games,
  (SELECT COUNT(*) FROM reviews) reviews;

ROLLBACK;

-- 17. Deleting publishers

BEGIN;
DELETE FROM publishers WHERE name = 'Valve';
ROLLBACK;

BEGIN;
DELETE FROM publishers WHERE name = 'Ubisoft' RETURNING *;
ROLLBACK;

-- 18. Ghost accounts

-- Version 1
BEGIN;

DELETE FROM users u
WHERE NOT EXISTS (SELECT 1 FROM user_games ug WHERE ug.user_id = u.id)
  AND NOT EXISTS (SELECT 1 FROM reviews r WHERE r.user_id = u.id)
RETURNING *;

ROLLBACK;

-- Version 2
BEGIN;

DELETE FROM users u
WHERE id NOT IN (
  SELECT user_id FROM user_games
  UNION
  SELECT user_id FROM reviews
)
RETURNING *;

ROLLBACK;

-- 19. Games nobody bought

BEGIN;

DELETE FROM games g
WHERE NOT EXISTS (SELECT 1 FROM user_games ug WHERE ug.game_id = g.id)
RETURNING *;

ROLLBACK;

-- 20. DELETE vs TRUNCATE

BEGIN;

TRUNCATE TABLE reviews;
SELECT COUNT(*) FROM reviews; -- 0

ROLLBACK;

SELECT COUNT(*) FROM reviews; -- 27

--
-- Level 4 — INSERT ... SELECT
--

-- 21. A profile for everyone

BEGIN;

INSERT INTO profiles (user_id, bio)
SELECT id, 'Hello, I am ' || username
FROM users
WHERE id NOT IN (SELECT user_id FROM profiles)
RETURNING user_id, bio;

SELECT COUNT(*)
FROM users u
  LEFT JOIN profiles p ON p.user_id = u.id
WHERE p.id IS NULL;

ROLLBACK;

-- 22. Belgian gift: Portal 2

BEGIN;
INSERT INTO user_games (user_id, game_id, hours_played, purchase_date)
SELECT
  u.id,
  (SELECT id FROM games WHERE title = 'Portal 2'),
  0,
  CURRENT_DATE
FROM users u
WHERE u.country = 'Belgium'
  AND NOT EXISTS (
    SELECT 1 
    FROM user_games ug
      JOIN games g ON g.id = ug.game_id
    WHERE ug.user_id = u.id
      AND g.title = 'Portal 2'
  )
RETURNING *;
ROLLBACK;

-- 23. Statistics table

BEGIN;

-- Création de la table
CREATE TABLE game_stats (
  game_id INT,
  title VARCHAR(100),
  total_players INT,
  total_hours INT,
  avg_rating NUMERIC(3,2),
  CONSTRAINT pk_game_stats PRIMARY KEY (game_id)
);

-- Insertion des statistiques
INSERT INTO game_stats
SELECT
  g.id,
  g.title,
  (SELECT COUNT(*) FROM user_games ug WHERE ug.game_id = g.id),
  (SELECT COALESCE(SUM(ug.hours_played), 0) FROM user_games ug WHERE ug.game_id = g.id),
  (SELECT ROUND(AVG(r.rating), 2) FROM reviews r WHERE r.game_id = g.id)
FROM games g;

-- Affichage des statistiques par total_hours décroissant
SELECT * FROM game_stats ORDER BY total_hours DESC;

ROLLBACK;

SELECT * FROM game_stats; -- Erreur

--
-- Level 5 — Transactions
--

-- 24. Nina's first purchase (SAVEPOINT)



-- 25. Davit gives Elden Ring to Nina



-- 26. Account merge: Julie → Sarah


