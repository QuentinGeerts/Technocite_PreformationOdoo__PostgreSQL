--
-- SQL Exercises — Gaming Platform
--

--
-- 1. Display all users.
--

SELECT *
FROM users;

--
-- 2. Display only the usernames and countries of all users.
--

SELECT username, country
FROM users;

--
-- 3. Display all games.
--

SELECT *
FROM games;

--
-- 4. Display only the title and price of all games.
--

SELECT title, price
FROM games;

--
-- 5. Display all games that cost more than 40€.
--

SELECT *
FROM games
WHERE price > 40;

--
-- 6. Display all games that cost less than 50€.
--

SELECT *
FROM games
WHERE price < 50;

--
-- 7. Display all free games.
--

SELECT *
FROM games
WHERE price = 0;

--
-- 8. Display all users coming from Belgium.
--

SELECT *
FROM users
WHERE country = 'Belgium';

--
-- 9. Display all users who are not from Belgium.
--

SELECT *
FROM users
WHERE country <> 'Belgium';

SELECT *
FROM users
WHERE country != 'Belgium';

--
-- 10. Display all publishers from the USA.
--

SELECT *
FROM publishers
WHERE country = 'USA';

--
-- 11. Display all games released after 2020.
--

SELECT *
FROM games
WHERE release_date >= '2020-01-01';

--
-- 12. Display all games released before 2020.
--

SELECT *
FROM games
WHERE release_date < '2020-01-01';

--
-- 13. Display all games ordered by price in descending order.
--

SELECT *
FROM games
ORDER BY price DESC;

--
-- 14. Display all games ordered by release date from newest to oldest.
--

SELECT *
FROM games
ORDER BY release_date DESC;

--
-- 15. Display all usernames ordered alphabetically.
--

SELECT username
FROM users
ORDER BY username;

--
-- 16. Display all games whose title contains "Dark".
--

SELECT *
FROM games
WHERE title ILIKE '%DARK%';

--
-- 17. Display all games whose title starts with "C".
--

SELECT *
FROM games
WHERE title ILIKE 'C%';

--
-- 18. Display all users whose username contains the letter "a".
--

SELECT *
FROM users
WHERE username ILIKE '%a%';

--
-- 19. Display all reviews with a rating of 5.
--

SELECT *
FROM reviews
WHERE rating = 5;

--
-- 20. Display all reviews created after `2024-01-01`.
--

SELECT *
FROM reviews
WHERE created_at > '2024-01-01';

--
-- 21. Display all games with a price between 20€ and 60€.
--

SELECT *
FROM games
WHERE price BETWEEN 20 AND 60;

--
-- 22. Display all users coming from Belgium or France.
--

SELECT * 
FROM users
WHERE country IN ('Belgium', 'France');

SELECT * 
FROM users
WHERE country = 'Belgium' OR country = 'France';

--
-- 23. Display all games that are not free.
--

SELECT *
FROM games
WHERE price > 0;

--
-- 24. Display all games ordered alphabetically by title.
--

SELECT *
FROM games
ORDER BY title;

--
-- 25. Display all publishers ordered alphabetically.
--

SELECT *
FROM publishers
ORDER BY name;

--
-- 26. Display all games where the title ends with "2".
--

SELECT *
FROM games
WHERE title LIKE '%2';

--
-- 27. Display all users created after a specific date.
--

SELECT *
FROM users
WHERE created_at = '2026-10-09 10:13:14.560646';

--
-- 28. Display all games released between 2015 and 2022.
--

SELECT *
FROM games
WHERE release_date BETWEEN '2015-01-01' AND '2022-12-31';

--
-- 29. Display all reviews where the comment contains the word "best".
--

SELECT *
FROM reviews
WHERE comment ILIKE '%best%';

--
-- 30. Display all games whose price is exactly 59.99€
--

SELECT *
FROM games
WHERE price = 59.99;
