-- SQL Exercises
-- Subqueries
-- Level 1 — Subqueries in WHERE (single value)

-- 1. Above-average games
-- Display all games that cost more than the average game price.
-- Columns: title, price

-- Récupérer la moyenne des prix des jeux

SELECT AVG(price)
FROM games;

-- Assemblage

SELECT
  g.title,
  g.price
FROM games g
WHERE g.price > (
  SELECT AVG(price)
  FROM games
)
ORDER BY g.price DESC;

-- 2. Most expensive game
-- Display the most expensive game(s).
-- Columns: title, price

SELECT
  g.title,
  g.price
FROM games g
WHERE g.price = (
  SELECT MAX(price)
  FROM games
);

-- 3. Same publisher as Elden Ring
-- Display all games published by the same publisher as "Elden Ring", except Elden Ring itself.
-- Columns: title, release_date

SELECT publisher_id
FROM games
WHERE title = 'Elden Ring';

SELECT
  g.title,
  g.release_date
FROM games g
WHERE g.publisher_id = 1
  AND title <> 'Elden Ring';

SELECT
  g.title,
  g.release_date
FROM games g
WHERE g.publisher_id = (
  SELECT publisher_id
  FROM games
  WHERE title = 'Elden Ring'
)
  AND title <> 'Elden Ring';

-- 4. Lucas's compatriots
-- Display all users who come from the same country as Lucas, except Lucas himself.
-- Columns: username, country

SELECT
  u.country
FROM users u
WHERE username = 'Lucas';

SELECT 
  u.username,
  u.country
FROM users u
WHERE u.country = 'Belgium' AND u.username <> 'Lucas';

SELECT 
  u.username,
  u.country
FROM users u
WHERE u.country = (
  SELECT
    u.country
  FROM users u
  WHERE username = 'Lucas'
) AND u.username <> 'Lucas';

-- 5. Long gaming sessions
-- Display every owned game whose hours played exceed the average hours played (all purchases).
-- Columns: username, game_title, hours_played

SELECT AVG(hours_played)
FROM user_games;

SELECT
  u.username,
  g.title game_title,
  ug.hours_played
FROM users u
  JOIN user_games ug ON u.id = ug.user_id
  JOIN games g ON g.id = ug.game_id
WHERE ug.hours_played > (
  SELECT AVG(hours_played)
  FROM user_games
)
ORDER BY ug.hours_played DESC;

-- Level 1 — Subqueries with IN / NOT IN

-- 6. Reviewers
-- Display all users who have written at least one review. No JOIN allowed.
-- Columns: username

SELECT user_id FROM reviews;

SELECT 
  u.username
FROM users u
WHERE u.id IN (
  SELECT DISTINCT user_id FROM reviews
);

-- 7. Games without reviews
-- Display all games that have never been reviewed. No JOIN allowed.
-- Columns: title

SELECT 
  g.title
FROM games g
WHERE g.id NOT IN (
  SELECT DISTINCT game_id FROM reviews
);

-- 8. FromSoftware players
-- Display all users who own at least one game published by FromSoftware. No JOIN allowed.
-- Columns: username

SELECT id FROM publishers WHERE name = 'FromSoftware';

SELECT id FROM games WHERE publisher_id = 1;

SELECT user_id FROM user_games WHERE game_id IN (1, 2, 12, 13);

SELECT username FROM users WHERE id IN (1, 3, 5, 9, 13);

-- Assemblage 
SELECT username 
FROM users 
WHERE id IN (
  SELECT user_id 
  FROM user_games 
  WHERE game_id IN (
    SELECT DISTINCT id 
    FROM games 
    WHERE publisher_id = (
      SELECT id FROM publishers WHERE name = 'FromSoftware'
    )
  )
);

-- 9. Users without a profile
-- Display all users who don't have a profile. No JOIN allowed.
-- Columns: username

-- Liste des utilisateurs qui ont un profil
SELECT user_id FROM profiles;

SELECT username
FROM users
WHERE id NOT IN (SELECT DISTINCT user_id FROM profiles);

-- 10. Publishers with local users
-- Display all publishers based in a country where at least one user lives.
-- Columns: publisher_name, country

SELECT DISTINCT country FROM users;

SELECT
  p.name publisher_name,
  p.country
FROM publishers p
WHERE p.country IN (
  SELECT DISTINCT country FROM users
);

-- Level 2 — Subqueries in HAVING, SELECT and FROM

-- 11. Premium publishers
-- Display publishers whose average game price is higher than the average price of all games.
-- Columns: publisher_name, average_price

SELECT AVG(g.price) FROM games g;

SELECT
  p.name publisher_name,
  ROUND(AVG(g.price), 2) average_price
FROM publishers p
  JOIN games g ON p.id = g.publisher_id
GROUP BY p.name
HAVING AVG(g.price) > (
  SELECT AVG(g.price) FROM games g
)
ORDER BY average_price DESC;

-- 12. Bigger communities than France
-- Display the countries that have more users than France.
-- Columns: country, total_users

SELECT COUNT(id) FROM users WHERE country = 'France';

SELECT 
  u.country,
  COUNT(u.id) total_users
FROM users u
GROUP BY u.country
HAVING COUNT(u.id) > (
  SELECT COUNT(id) 
  FROM users 
  WHERE country = 'France'
)
ORDER BY total_users DESC;

-- 13. Price compared to the average
-- Display every game with its price, the average price of all games and the difference between both.
-- Columns: title, price, average_price, price_difference

SELECT
  g.title,
  g.price,
  ROUND((SELECT AVG(price) FROM games), 2) average_price,
  ROUND(g.price - (SELECT AVG(price) FROM games), 2) price_difference
FROM games g
ORDER BY price_difference DESC;

-- 14. Library size without JOIN
-- Display every user with the number of games they own. No JOIN allowed. Users without games show 0.
-- Columns: username, games_owned

SELECT COUNT(user_id)
FROM user_games ug
WHERE ug.user_id = 1;

SELECT
  u.username,
  (
    SELECT COUNT(user_id)
    FROM user_games ug
    WHERE ug.user_id = u.id
  ) games_owned
FROM users u
ORDER BY games_owned DESC;

-- 15. Average library size
-- Display the average number of games owned per user (only users who own at least one game).
-- Columns: average_games_per_user

SELECT 
  user_id, 
  COUNT(*) games_owned 
FROM user_games 
GROUP BY user_id;

-- Version sous-requête
SELECT
  ROUND(AVG(games_owned), 2) average_games_per_user
FROM (
  SELECT user_id, COUNT(*) games_owned FROM user_games GROUP BY user_id
) games_per_user;


-- Version CTE
WITH games_per_user AS (
  SELECT 
    user_id, 
    COUNT(*) games_owned 
  FROM user_games 
  GROUP BY user_id
)
SELECT
  ROUND(AVG(games_owned), 2) average_games_per_user
FROM games_per_user


-- 16. Heavy players
-- Display users whose total hours played is higher than the average total hours played per user.
-- Columns: username, total_hours_played

-- Total heures jouées par utilisateur
SELECT
  SUM(hours_played) total_hours
FROM user_games
GROUP BY user_id;

-- Moyenne du total d'heures jouées par utilisateur
SELECT AVG(total_hours)
FROM (
  SELECT
    SUM(hours_played) total_hours
  FROM user_games
  GROUP BY user_id
) totals;

-- Liste des joueurs avec un total > moyenne
SELECT 
  u.username,
  SUM(ug.hours_played) total_hours_played
FROM users u
  JOIN user_games ug ON ug.user_id = u.id
GROUP BY u.id
HAVING SUM(ug.hours_played) > (
  SELECT AVG(total_hours)
  FROM (
    SELECT
      SUM(hours_played) total_hours
    FROM user_games
    GROUP BY user_id
  ) totals
)
ORDER BY total_hours_played DESC;

-- Level 3 — Correlated subqueries, EXISTS, ANY / ALL

-- 17. Flagship game of each publisher
-- Display the most expensive game(s) of each publisher.
-- Columns: publisher_name, game_title, price

-- Version 1
SELECT
  p.name publisher_name,
  g.title game_title,
  g.price
FROM games g
  JOIN publishers p ON p.id = g.publisher_id
WHERE g.price = (
  SELECT MAX(g2.price)
  FROM games g2
  WHERE g2.publisher_id = g.publisher_id
);

-- Version 2
SELECT
  p.name publisher_name,
  g.title game_title,
  g.price
FROM games g
  JOIN publishers p ON p.id = g.publisher_id
WHERE g.price >= ALL (
  SELECT g2.price
  FROM games g2
  WHERE g2.publisher_id = g.publisher_id
);

-- 18. Favorite game of each user
-- Display, for each user, the game(s) they played the most.
-- Columns: username, game_title, hours_played

-- Version 1 
SELECT 
  u.username,
  g.title game_title,
  ug.hours_played
FROM user_games ug 
  JOIN users u ON u.id = ug.user_id
  JOIN games g ON g.id = ug.game_id
WHERE ug.hours_played >= ALL (
  SELECT ug2.hours_played
  FROM user_games ug2
  WHERE ug2.user_id = ug.user_id
);

-- Version 2
SELECT 
  u.username,
  g.title game_title,
  ug.hours_played
FROM user_games ug 
  JOIN users u ON u.id = ug.user_id
  JOIN games g ON g.id = ug.game_id
WHERE ug.hours_played = (
  SELECT MAX(ug2.hours_played)
  FROM user_games ug2
  WHERE ug2.user_id = ug.user_id
);

-- 19. Better than the average player
-- Display every owned game where the user played more than the average hours played on that same game.
-- Columns: username, game_title, hours_played, game_average_hours

SELECT 
  u.username,
  g.title game_title,
  ug.hours_played,
  (
    SELECT ROUND(AVG(ug2.hours_played), 2)
    FROM user_games ug2
    WHERE ug2.game_id = ug.game_id
  ) game_average_hours
FROM user_games ug 
  JOIN users u ON u.id = ug.user_id
  JOIN games g ON g.id = ug.game_id
WHERE ug.hours_played > (
  SELECT AVG(ug2.hours_played)
  FROM user_games ug2
  WHERE ug2.game_id = ug.game_id
);

-- 20. Publishers with recent games
-- Display publishers that have released at least one game after 2020-01-01. Use EXISTS.
-- Columns: publisher_name

SELECT
  p.name publisher_name
FROM publishers p
WHERE EXISTS (
  SELECT 1
  FROM games g
  WHERE g.publisher_id = p.id AND g.release_date > '2020-01-01'
);

-- 21. Inactive users
-- Display users who have never bought a game. Use NOT EXISTS.
-- Columns: username, country

SELECT
  u.username,
  u.country
FROM users u
WHERE NOT EXISTS (
  SELECT 1
  FROM user_games ug
  WHERE ug.user_id = u.id
);

-- 22. More expensive than every Valve game
-- Display games that cost more than every game published by Valve. Use ALL.
-- Columns: title, price

SELECT
  g.title,
  g.price
FROM games g
WHERE g.price > ALL (
  SELECT g2.price
  FROM games g2
  WHERE publisher_id = (
    SELECT id
    FROM publishers 
    WHERE name = 'Valve'
  )
);

-- 23. Cheaper than a FromSoftware game
-- Display games, not published by FromSoftware, that are cheaper than at least one FromSoftware game. Use ANY.
-- Columns: title, price

SELECT 
  g.title,
  g.price
FROM games g
WHERE publisher_id <> (SELECT id FROM publishers WHERE name = 'FromSoftware')
  AND price < ANY (
    SELECT price
    FROM games
    WHERE publisher_id = (SELECT id FROM publishers WHERE name = 'FromSoftware')
  )

-- 24. Completionists
-- Display users who own at least one game and have reviewed EVERY game they own.
-- Columns: username

-- Version 1
SELECT 
  u.username
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM user_games ug
  WHERE ug.user_id = u.id
)
  AND 
    (SELECT COUNT(ug.user_id) FROM user_games ug WHERE ug.user_id = u.id) = 
    (SELECT COUNT(r.id) FROM reviews r WHERE r.user_id = u.id)


-- Version plus sécurisée
SELECT 
  u.username
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM user_games ug
  WHERE ug.user_id = u.id
)
  AND NOT EXISTS (
    SELECT 1
    FROM user_games ug
    WHERE ug.user_id = u.id 
    AND NOT EXISTS (
      SELECT 1
      FROM reviews r
      WHERE r.user_id = u.id
      AND r.game_id = ug.game_id
    )
  )

-- 25. Publishers above the average playtime
-- Using a CTE (WITH), display publishers whose total hours played (all their games)
-- is higher than the average total hours played per publisher.
-- Publishers whose games have never been played count as 0 in the average.
-- Columns: publisher_name, total_hours_played

WITH publishers_hours AS (
  SELECT
    p.name publisher_name,
    COALESCE(SUM(ug.hours_played), 0) total_hours_played
  FROM publishers p
    JOIN games g ON g.publisher_id = p.id
    LEFT JOIN user_games ug ON ug.game_id = g.id
  GROUP BY p.name
)

SELECT
  publisher_name,
  total_hours_played
FROM publishers_hours
WHERE total_hours_played > (
  SELECT AVG(total_hours_played)
  FROM publishers_hours
)
ORDER BY total_hours_played DESC;