-- SQL Exercises
-- JOINs and Advanced SELECT
-- Level 1 — Fundamentals

-- 1. Games and publishers
-- Display every game with its publisher.
-- Columns : game_title, publisher_name

SELECT
  g.title game_title,
  p.name publisher_name
FROM games g
  JOIN publishers p ON g.publisher_id = p.id;

-- 2. Owned games
-- Display every game owned by a user.
-- Columns : username, game_title, hours_played

SELECT
  u.username,
  g.title game_title,
  ug.hours_played
FROM games g
  JOIN user_games ug ON ug.game_id = g.id
  JOIN users u ON ug.user_id = u.id;

-- 3. Users and profiles
-- Display all users with their profile information. 
-- Users without a profile must still appear.
-- Columns: username, bio, avatar_url

SELECT
  u.username,
  p.bio,
  p.avatar_url
FROM users u
  LEFT JOIN profiles p ON p.user_id = u.id;

SELECT
  u.username,
  p.bio,
  p.avatar_url
FROM profiles p
  RIGHT JOIN users u ON p.user_id = u.id;

-- 4. Reviews
-- Display every review with the user and game information.
-- Columns: username, game_title, rating, comment

SELECT 
  u.username,
  g.title game_title,
  r.rating,
  r.comment
FROM reviews r
  JOIN users u ON u.id = r.user_id
  JOIN games g ON g.id = r.game_id;

-- 5. Publishers and games
-- Display all publishers with their games. 
-- Publishers without games must still appear.
-- Columns: publisher_name, game_title

SELECT 
  p.name publisher_name,
  g.title game_title
FROM publishers p
  LEFT JOIN games g ON g.publisher_id = p.id;

-- 6. Users without games
-- Display all users who have never bought a game.
-- Columns: username

-- Version 1
SELECT username FROM users
EXCEPT
SELECT username FROM users u, user_games ug WHERE u.id = ug.user_id;

-- Version 2

SELECT 
  u.username
FROM users u
  LEFT JOIN user_games ug ON ug.user_id = u.id
WHERE ug.user_id IS NULL;

-- 7. Game purchases
-- Display all users with the games they own and the corresponding purchase date.
-- Columns: username, game_title, purchase_date

SELECT
  u.username,
  g.title game_title,
  ug.purchase_date
FROM users u
  JOIN user_games ug ON u.id = ug.user_id
  JOIN games g ON g.id = ug.game_id;

-- 8. Games without purchases
-- Display all games that have never been purchased.
-- Columns: game_title

SELECT title game_title FROM games
EXCEPT
SELECT title FROM games, user_games WHERE games.id = user_games.game_id;

-- 9. Number of players per game
-- Display every game with its total number of players. 
-- Games without players must still appear.
-- Columns: game_title, total_players

SELECT
  g.title game_title,
  COUNT(ug.user_id) total_players
FROM games g
  LEFT JOIN user_games ug ON ug.game_id = g.id
GROUP BY g.title;

-- 10. Average rating per game
-- Display every reviewed game with its average rating.
-- Columns: game_title, average_rating

SELECT 
  g.title game_title,
  ROUND(AVG(r.rating), 2) average_rating
FROM games g
  JOIN reviews r ON g.id = r.game_id
GROUP BY g.title;

-- 11. User activity summary
-- Display all users with the number of games they own and their total number of hours played. 
-- Users without games must still appear.
-- Columns: username, games_owned, total_hours_played

SELECT
  u.username,
  COUNT(ug.game_id) games_owned,
  COALESCE(SUM(ug.hours_played), 0) total_hours_played
FROM users u
  LEFT JOIN user_games ug ON ug.user_id = u.id
GROUP BY u.id;

-- 12. Publishers with several games
-- Display publishers that have published more than one game.
-- Columns: publisher_name, total_games

SELECT 
  publishers.name publisher_name,
  COUNT(games.id) total_games
FROM publishers 
  JOIN games ON games.publisher_id = publishers.id
GROUP BY publishers.id
HAVING COUNT(games.id) > 1;

-- 13. Highly played games
-- Display games for which the total number of hours played exceeds 500.
-- Columns: game_title, total_hours_played

SELECT 
  games.title game_title,
  SUM(user_games.hours_played) total_hours_played
FROM games 
  JOIN user_games ON user_games.game_id = games.id
GROUP BY games.title
HAVING SUM(user_games.hours_played) > 500;

-- 14. Active reviewers
-- Display users who have written more than one review.
-- Columns: username, reviews_written

SELECT 
  users.username,
  COUNT(reviews.id) reviews_written
FROM users 
  JOIN reviews ON reviews.user_id = users.id
GROUP BY users.id
HAVING COUNT(reviews.id) > 1;

-- 15. Most-played games
-- Display the five games with the highest total number of hours played.
-- The most-played game must appear first.
-- Columns: game_title, total_hours_played

SELECT 
  g.title game_title,
  SUM(ug.hours_played) total_hours_played
FROM games g
  JOIN user_games ug ON ug.game_id = g.id
GROUP BY g.id
ORDER BY total_hours_played DESC
LIMIT 5;

-- 16. Detailed game review statistics
-- Display all games with their publisher and review statistics. 
-- Games without reviews must still appear.
-- Order the result by average rating from highest to lowest.
-- Columns: game_title, publisher_name, total_reviews, average_rating

SELECT 
  g.title game_title,
  p.name publisher_name,
  COUNT(r.id) total_reviews,
  ROUND(AVG(r.rating), 2) average_rating
FROM games g
  JOIN publishers p ON g.publisher_id = p.id
  LEFT JOIN reviews r ON r.game_id = g.id
GROUP BY g.title, p.name
ORDER BY average_rating DESC NULLS LAST; -- Tips NULLS LAST ;)

-- 17. Complete user activity
-- Display all users with the number of games they own and the number of reviews they have written. 
-- Users without games or reviews must still appear.
-- Be careful not to count the same game or review several times.
-- Columns: username, games_owned, reviews_written

SELECT 
  u.username,
  COUNT(DISTINCT ug.game_id) games_owned,
  COUNT(DISTINCT r.id) reviews_written
FROM users u
  LEFT JOIN user_games ug ON ug.user_id = u.id
  LEFT JOIN reviews r ON r.user_id = u.id
GROUP BY u.username;

-- 18. Users loyal to a publisher
-- Display every user who owns at least two games from the same publisher.
-- Columns: username, publisher_name, games_owned_from_publisher

SELECT 
  u.username,
  p.name publisher_name,
  COUNT(p.id) games_owned_from_publisher
FROM users u
  JOIN user_games ug ON u.id = ug.user_id
  JOIN games g ON g.id = ug.game_id
  JOIN publishers p ON g.publisher_id = p.id
GROUP BY u.id, p.name
HAVING COUNT(p.id) >= 2;

-- 19. Local publisher audiences
-- For each publisher, display the number of distinct players who come from the same country as the publisher. 
-- Publishers without matching players must still appear.
-- Columns: publisher_name, publisher_country, local_players

SELECT
  p.name publisher_name,
  p.country publisher_country,
  COUNT(DISTINCT u.id)
FROM publishers p
  LEFT JOIN games g ON p.id = g.publisher_id
  LEFT JOIN user_games ug ON g.id = ug.game_id
  LEFT JOIN users u ON u.id = ug.user_id AND u.country = p.country
GROUP BY p.name, p.country;

-- 20. Publishers ranked by playtime
-- Display all publishers with the total number of hours played across all their games.
-- Publishers whose games have never been played must still appear.
-- Order the result from the highest total playtime to the lowest.
-- Columns: publisher_name, total_hours_played

SELECT 
  p.name publisher_name,
  SUM(COALESCE(ug.hours_played, 0)) total_hours_played
FROM publishers p
  LEFT JOIN games g ON p.id = g.publisher_id
  LEFT JOIN user_games ug ON ug.game_id = g.id
GROUP BY p.name
ORDER BY total_hours_played DESC;
