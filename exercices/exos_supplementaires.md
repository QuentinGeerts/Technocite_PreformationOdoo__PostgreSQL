# SQL Exercises — Gaming Platform

## BONUS — Mix everything (hard mode)

These exercises mix **everything** seen so far:

* `SELECT`, aliases, calculations, casts (`::`), integer vs decimal division
* concatenation (`||`, `CONCAT`, `CONCAT_WS`), `DISTINCT`
* `WHERE`, `BETWEEN`, `IN`, `LIKE` / `ILIKE`, `IS NULL`, `NOT`, `AND` / `OR`
* functions (`UPPER`, `LENGTH`, `EXTRACT`, `ROUND`, `COALESCE`, `NULLIF`), `CASE`
* aggregates, `GROUP BY`, `ROLLUP`, `HAVING`, `ORDER BY`
* joins (`INNER`, `LEFT`, `FULL`, self join, non-equi join)
* set operations (`UNION`, `EXCEPT`, `INTERSECT`)
* subqueries (in `WHERE`, `HAVING`, `SELECT` and `FROM`, correlated, `IN`, `EXISTS`, `ALL`)

Levels 1 to 4 use a single table. Joins and subqueries start at level 5.

The "Expected rows" line lets you check your result.

---

## Level 1 — Filter, then group

### B1. European communities

For each country **except the USA and the UK**, display:

* `country_label`: the country followed by its number of users, e.g. `Belgium (4 users)`
* `names_with_a`: number of usernames containing the letter "a" (uppercase or lowercase)
* `short_names`: number of usernames of 4 characters or less

Keep only the countries with at least 2 users.

Order by number of users (highest first), then by country.

Expected rows: 2

---

### B2. Title length matters

Classify the games by the number of words in their title:

* `1 word` (e.g. `Minecraft`)
* `2 words` (e.g. `Elden Ring`)
* `3+ words` (e.g. `Call of Duty MW3`)

For each type, display:

* `title_type`
* `total_games`
* `avg_title_length` (rounded to 1 decimal)
* `avg_price` (rounded to 2 decimals)
* `cheapest_price`
* `most_expensive_price`

Order by `title_type`.

Hint: what separates two words?

Expected rows: 3

---

### B3. Free-to-play publishers

For each `publisher_id` that has **at least one free game**, display:

* `publisher_id`
* `total_games`
* `free_games`
* `avg_price` (all games, rounded to 2 decimals)
* `avg_paid_price` (paid games only, rounded to 2 decimals)
  → if the publisher only has free games, display `Only free games`

Order by `publisher_id`.

Constraint: no `CASE` allowed in this exercise.

Expected rows: 4

---

### B4. The 2022–2023 period

Only consider the purchases made in 2022 and 2023.

For each user who made at least 2 purchases during this period, display:

* `player_summary`, e.g. `User #6 - 1050h`
* `total_purchases`
* `days_played`: total hours converted into days (rounded to 1 decimal)

Order by total hours played (highest first).

Watch out: `870 / 24` does not give `36.25`…

Expected rows: 6

---

## Level 2 — Advanced CASE

### B5. Review sentiment

Classify each review comment (case-insensitive):

* `Mixed` if the comment contains the word "but" (surrounded by spaces)
* `Negative` if the comment starts with "not " or "too "
* `Enthusiastic` if the comment contains "best", "masterpiece" or "perfect"
* `Neutral` otherwise

For each sentiment, display:

* `sentiment`
* `total_reviews`
* `avg_rating` (rounded to 2 decimals)
* `lowest_rating`
* `highest_rating`

Order by average rating (highest first).

Question: `Still toxic but addictive` — which category? Does the order of the `WHEN` matter?

Expected rows: 4

---

### B6. Profile completeness

A profile has 3 optional fields: `bio`, `avatar_url` and `birth_date`.

Group the profiles by completeness score, displayed as `3/3`, `2/3`, `1/3`…

For each score, display:

* `completeness`
* `total_profiles`
* `oldest_birth_date`
* `youngest_birth_date`

Order from the most complete to the least complete.

Expected rows: 3

---

### B7. Playtime distribution per year

Only consider the purchases made between 2020 and 2024 (included).

For each purchase year, display the number of purchases per playtime tier **as columns**, and the total hours:

| purchase_year | light (< 100h) | regular (100–499h) | heavy (≥ 500h) | total_hours |
| ------------- | -------------- | ------------------ | -------------- | ----------- |

Keep only the years with at least 5 purchases.

Order by year.

Expected rows: 5

---

### B8. Reviewer profiles

Ignore the reviews whose comment mentions "fun" (case-insensitive): they were part of a sponsored campaign.

For each user who still has at least 2 reviews, display:

* `user_id`
* `total_reviews`
* `positive_reviews` (rating of 4 or more)
* `short_comments` (comments of less than 15 characters)
* `avg_comment_length` (rounded to 1 decimal)
* `reviewer_profile`:
  * `Harsh` if they gave at least one rating of 2 or less
  * `Fan` if all their ratings are 5
  * `Balanced` otherwise

Order by average rating (lowest first), then by `user_id`.

Expected rows: 8

---

## Level 3 — Everything at once

### B9. Yearly activity

For each purchase year, display:

* `purchase_year`
* `total_purchases`
* `distinct_buyers` (a user who bought 3 games counts once)
* `distinct_games`
* `purchases_per_buyer` (rounded to 2 decimals)

Keep only the years with at least 3 distinct buyers.

Order by year.

Hint: `COUNT(DISTINCT column)`

Expected rows: 5

---

### B10. Premium publishers

The marketing team wants a report on the **paid** games released **between 2010 and 2022** (included).
Titles containing "of" (case-insensitive) are handled by another team: exclude them.

For each publisher with at least 2 games matching these criteria, display:

* `publisher`, e.g. `Publisher #1`
* `total_games`
* `cheapest_price`
* `most_expensive_price`
* `price_spread`
* `avg_price` (rounded to 2 decimals)
* `tier`:
  * `Premium` if the average price is greater than 45
  * `Mid-range` if the average price is 25 or more
  * `Budget` otherwise

Order by average price (highest first).

Expected rows: 3

---

## Level 4 — ROLLUP

### B11. Catalogue by era

Classify the games by era:

* `Retro`: released before 2015
* `Modern`: released between 2015 and 2019
* `Recent`: released from 2020

and by business model: `Free` or `Paid`.

Display the number of games and the average price (rounded to 2 decimals) per era and model, with a subtotal per era and a grand total.
The NULL values produced by `ROLLUP` must be replaced by `All eras` and `All models`.

Expected columns:

* `era`
* `business_model`
* `total_games`
* `avg_price`

Order the eras **chronologically** (`Retro`, `Modern`, `Recent`, then `All eras`), and inside each era: `Free`, `Paid`, then `All models`.

Expected rows: 10

---

### B12. Users by country and name length

Only consider the users from Belgium, France and the USA.

Display the number of users per country and username length (`Short`: 4 characters or less, `Long` otherwise), with a subtotal per country and a grand total.

Replace the NULL values with `All countries` and `All lengths`.

Order by country, with each subtotal after its details and the grand total last.

Expected rows: 8

---

## Level 5 — Joins

### B13. Publisher scorecard

Display **all** publishers (even those without games) with:

* `publisher_name`
* `publisher_country`
* `total_games`
* `distinct_players` (a player who owns 2 games of the publisher counts once)
* `total_hours` (0 instead of NULL)
* `status`:
  * `No game` if the publisher has no game
  * `No player` if nobody plays its games
  * `Blockbuster` if its games total at least 3000 hours
  * `Active` otherwise

Order by total hours (highest first), then by publisher name.

Expected rows: 10

---

### B14. Gaming duos

Two users form a "duo" when they own at least 3 games **in common**.

Display:

* `duo`, e.g. `Sarah & Lucas` (each pair only once: no `Lucas & Sarah`, no `Sarah & Sarah`)
* `origin`: `Same country` or `International`
* `common_games`
* `combined_hours` (hours played by both users on their common games)

Order by number of common games (highest first), then by combined hours (highest first).

Hint: `user_games` joined with… `user_games`.

Expected rows: 11

---

### B15. Trustworthy reviews

A review is only trustworthy if its author **owns** the game and played it for at least 50 hours.

**a)** Display the suspicious reviews (game not owned, or less than 50 hours played):

* `username`
* `game_title`
* `rating`
* `hours_played` (`Not owned` if the user does not own the game)
* `reason`: `Not owned` or `Too early`

Order by rating, then by username.

Expected rows: 5

**b)** For each game with at least 2 reviews, display:

* `game_title`
* `total_reviews`
* `trusted_reviews`
* `avg_rating` (all reviews, rounded to 2 decimals)
* `trusted_avg_rating` (trustworthy reviews only, rounded to 2 decimals)
  → `No trusted review` if there is none

Order by trusted average (highest first, games without trusted review last), then by title.

Expected rows: 9

---

### B16. Cheaper siblings

Only consider the publishers that have at least 3 games.

For each of their games, display the number of games **of the same publisher** that are strictly cheaper.

Expected columns:

* `publisher_name`
* `game_title`
* `price`
* `cheaper_siblings` (0 for the cheapest game)

Order by publisher name, then by number of cheaper siblings (highest first).

Expected rows: 10

---

## Level 6 — Subqueries

### B17. Overpriced for their publisher

Display the games that are more expensive than the average price **of their own publisher**.

Expected columns:

* `game_title`
* `publisher_name`
* `price`
* `publisher_avg_price` (rounded to 2 decimals)
* `difference`

Order by difference (highest first).

Expected rows: 6

---

### B18. Above-average players

Compute the total hours played by each user, then the average of these totals.

Display the users whose total is above this average:

* `username`
* `country`
* `total_hours`
* `above_average_by` (rounded to 1 decimal)

Order by total hours (highest first).

Hint: an average of sums = a subquery in the `FROM`.

Expected rows: 7

---

### B19. Favourite game

For each user, display their most-played game and the share it represents in their total playtime.

Expected columns:

* `username`
* `favourite_game`
* `hours_played`
* `share_pct` (rounded to 1 decimal)

Order by share (highest first), then by username.

Expected rows: 14

---

### B20. Hidden gems

Display the games that have **never been reviewed** but that are owned by at least 2 players.

Expected columns:

* `game_title`
* `publisher_name`
* `total_players`
* `total_hours`

Order by number of players (highest first).

Bonus: write it twice, once with `NOT IN` and once with `NOT EXISTS`.

Expected rows: 2

---

### B21. World map

Display every country that appears in `users` **or** in `publishers`, with:

* `country`
* `total_users` (0 instead of NULL)
* `total_publishers` (0 instead of NULL)
* `status`: `Both`, `Users only` or `Publishers only`

Order by status, then by country.

Hint: aggregate each table in its own subquery first, then join the two results. Which join keeps the rows of both sides?

Expected rows: 10

---

## Level 7 — Set operations

### B22. Played but never reviewed

For each user, count the games they own but never reviewed, and the hours played on these games.

Keep only the users with at least 3 unreviewed games.

Expected columns:

* `username`
* `unreviewed_games`
* `unreviewed_hours`

Order by number of unreviewed games (highest first), then by hours (highest first).

Constraint: use `EXCEPT`.

Expected rows: 6

---

### B23. Ghost accounts

Display the users who never bought **nor** reviewed anything.

Expected columns:

* `username`
* `country`
* `bio` (`No bio` if NULL)
* `profile_status`: `Has profile` or `No profile`

Constraint: use `UNION` in a subquery.

Expected rows: 1

---

## Level 8 — Final bosses

### B24. Most-played game per country

For each country (of the **players**), display the game with the highest total hours played by the players of this country.

Expected columns:

* `country`
* `game_title`
* `total_hours`

Order by total hours (highest first).

Hint: a total is the highest if it is greater than or equal to **all** the totals of the same country.

Expected rows: 8

---

### B25. FromSoftware completionists

Display the users who own **every** game published by FromSoftware.

Expected columns:

* `username`
* `country`

The query must still work if FromSoftware releases a new game tomorrow: no hard-coded number of games, no hard-coded `id`.

Hint: two possible approaches — compare counts, or "there is no FromSoftware game that the user does not own".

Expected rows: 1

---

## Level 9 — Find the bug

Each query below is wrong. For each one:

1. explain **why** (error or wrong result)
2. write the corrected query

### B26.a — Profiles without bio (returns nothing)

```sql
SELECT *
FROM profiles
WHERE bio = NULL;
```

### B26.b — Dark Souls (returns nothing)

```sql
SELECT title
FROM games
WHERE title LIKE 'dark%';
```

### B26.c — Belgian or French users with a username longer than 4 characters

`Lina` and `Nina` appear in the result. Why?

```sql
SELECT username, country
FROM users
WHERE country = 'Belgium' OR country = 'France' AND LENGTH(username) > 4;
```

### B26.d — Days played per user

User 1 played 1540 hours, which is 64.2 days. The query displays `64.0`. Why?

```sql
SELECT user_id, ROUND(SUM(hours_played) / 24, 1) AS days_played
FROM user_games
GROUP BY user_id;
```

### B26.e — Countries with more than 1 user

```sql
SELECT country, COUNT(*)
FROM users
WHERE COUNT(*) > 1
GROUP BY country;
```

### B26.f — Games with an average rating of 4.5 or more

```sql
SELECT game_id, AVG(rating) AS avg_rating
FROM reviews
GROUP BY game_id
HAVING avg_rating >= 4.5;
```

### B26.g — Profiles without bio (returns 0)

```sql
SELECT COUNT(bio) AS profiles_without_bio
FROM profiles
WHERE bio IS NULL;
```

### B26.h — Publishers and their recent games

All publishers should appear, even those without a game released since 2020. Only 8 rows are returned. Why?

```sql
SELECT p.name, g.title
FROM publishers p
  LEFT JOIN games g ON g.publisher_id = p.id
WHERE g.release_date >= '2020-01-01';
```

### B26.i — Number of games per publisher

Ubisoft has no game, but the query displays `1`. Why?

```sql
SELECT p.name, COUNT(*) AS total_games
FROM publishers p
  LEFT JOIN games g ON g.publisher_id = p.id
GROUP BY p.id, p.name;
```

### B26.j — Total hours per publisher

Riot Games displays 12660 hours instead of 4950. Why?

```sql
SELECT p.name, SUM(ug.hours_played) AS total_hours
FROM publishers p
  JOIN games g ON g.publisher_id = p.id
  JOIN user_games ug ON ug.game_id = g.id
  JOIN reviews r ON r.game_id = g.id
GROUP BY p.id, p.name;
```

### B26.k — Games from American publishers

```sql
SELECT title
FROM games
WHERE publisher_id = (SELECT id FROM publishers WHERE country = 'USA');
```

### B26.l — Games with their publisher

```sql
SELECT id, title, name
FROM games
  JOIN publishers ON publisher_id = id;
```