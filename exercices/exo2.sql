-- SQL Exercises — Gaming Platform
-- Functions, Aggregations, GROUP BY / HAVING


-- 1. Display all usernames in uppercase.

SELECT UPPER(username)
FROM users;

-- 2. Display each username with its length.

SELECT username, LENGTH(username)
FROM users;

-- 3. Display each game with its release year.

SELECT title, EXTRACT(YEAR FROM release_date)
FROM games;

SELECT title, DATE_PART('YEAR', release_date)
FROM games;

-- 4. Display profiles and replace NULL bio with 'No bio yet'.

SELECT 
  id, 
  user_id, 
  CASE
    WHEN bio IS NULL THEN 'No bio yet'
    ELSE bio
  END "Bio"
FROM profiles;

SELECT 
  id,
  user_id,
  COALESCE(bio, 'No bio yet') "Bio"
FROM profiles;

-- 5. Display each game with a price label: Free or Paid.

SELECT
  title,
  release_date,
  price,
  CASE price
    WHEN 0 THEN 'Free'
    ELSE 'Paid'
  END 
FROM games;

-- 6. Display the total number of users.

SELECT
  count(id) "count"
FROM users;

-- 7. Display the total number of games.

SELECT
  count(id) "count"
FROM games;

-- 8. Display the average game price.

SELECT
  ROUND(AVG(price), 2) "average_price"
FROM games;

-- 9. Display the total number of hours played.

SELECT
  SUM(hours_played) "total_hours_played"
FROM user_games;

-- 10. Display the highest and lowest rating.

SELECT
  MIN(rating) "lowest_rating",
  MAX(rating) "highest_rating"
FROM reviews;

-- 11. Display the number of users per country.

SELECT
  country, COUNT(id) "number_users_country"
FROM users
GROUP BY country;

-- 12. Display the number of games per publisher_id.

SELECT
  publisher_id, COUNT(id) "number_game_publisher"
FROM games
GROUP BY publisher_id;

-- 13. Display the average game price per publisher_id.

SELECT
  publisher_id, ROUND(AVG(price), 2) "average_game_price"
FROM games
GROUP BY publisher_id;

-- 14. Display the total hours played per user_id.

SELECT
  user_id, SUM(hours_played) "total_hours_played"
FROM user_games
GROUP BY user_id
ORDER BY "total_hours_played" DESC;

-- 15. Display the average hours played per user_id.

SELECT
  user_id, ROUND(AVG(hours_played), 2) "average_hours_played"
FROM user_games
GROUP BY user_id
ORDER BY "average_hours_played" DESC;

-- 16. Display the total hours played per game_id.

SELECT
  game_id, SUM(hours_played) "total_hours_played"
FROM user_games
GROUP BY game_id
ORDER BY "total_hours_played" DESC;

-- 17. Display the average rating per game_id.

SELECT
  game_id, ROUND(AVG(rating), 2) "average_rating"
FROM reviews
GROUP BY game_id
ORDER BY "average_rating" DESC;

-- 18. Display the number of purchases per year.

SELECT
  EXTRACT(YEAR from purchase_date),
  COUNT(*) "count"
FROM user_games
GROUP BY EXTRACT(YEAR from purchase_date);


SELECT 
  DATE_PART('YEAR', purchase_date) AS "year_purchase", COUNT(user_id)
FROM user_games
GROUP BY "year_purchase"; -- Possible qu'en PgSQL

-- 19. Display the number of games released per year.

SELECT
  EXTRACT(YEAR FROM release_date) "year",
  COUNT(id) "count_games_released"
FROM games
GROUP BY EXTRACT(YEAR FROM release_date)
ORDER BY "year" DESC;

-- 20. Display the number of games per price category:
-- - Free if price = 0
-- - Cheap if price < 30
-- - Standard if price between 30 and 60
-- - Expensive if price > 60

SELECT
  CASE 
    WHEN price = 0 THEN 'Free'
    WHEN price < 30 THEN 'Cheap'
    WHEN price <= 60 THEN 'Standard' 
    ELSE 'Expensive'
  END "price_category",
  COUNT(price) "count"
FROM games
GROUP BY "price_category"; -- merci pgsql

SELECT
  CASE 
    WHEN price = 0 THEN 'Free'
    WHEN price < 30 THEN 'Cheap'
    WHEN price <= 60 THEN 'Standard' 
    ELSE 'Expensive'
  END "price_category",
  COUNT(price) "count"
FROM games
GROUP BY CASE 
    WHEN price = 0 THEN 'Free'
    WHEN price < 30 THEN 'Cheap'
    WHEN price <= 60 THEN 'Standard' 
    ELSE 'Expensive'
  END; -- version utilisable pour plusieurs SGBD

-- 21. Display the number of paid games per publisher_id.

SELECT
  publisher_id,
  SUM(
    CASE
      WHEN price = 0 THEN 0
      ELSE 1
    END
  ) "count_paid_games"
FROM games
GROUP BY publisher_id;


SELECT
  publisher_id,
  COUNT(NULLIF(price, 0)) "count_paid_games"
FROM games
GROUP BY publisher_id;


-- 22. Display the average price per publisher_id for games released after '2015-01-01'.

SELECT
  publisher_id,
  ROUND(AVG(price), 2) "average_price"
FROM games
WHERE release_date > '2015-01-01'
GROUP BY publisher_id;

-- 23. Display only countries that have more than 1 user.

SELECT
  country, COUNT(id) "count"
FROM users
GROUP BY country
HAVING COUNT(id) > 1;

-- 24. Display only user_id values with more than 300 total hours played.

SELECT
  user_id, SUM(hours_played) "total_hours_played"
FROM user_games
GROUP BY user_id
HAVING SUM(hours_played) > 300;

-- 25. Display only game_id values with an average rating >= 4.5.

SELECT
  game_id, ROUND(AVG(rating), 2) "average_rating"
FROM reviews
GROUP BY game_id
HAVING AVG(rating) >= 4.5;
