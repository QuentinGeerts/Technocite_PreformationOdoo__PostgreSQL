# SQL Exercises — Gaming Platform

## Subqueries

A **subquery** is a `SELECT` written inside another query, between parentheses.
It can be used in the `WHERE`, `HAVING`, `SELECT` and `FROM` clauses.

* **Single value** subquery (one row, one column) → compare with `=`, `<`, `>`, …
* **List** subquery (one column, several rows) → use `IN`, `NOT IN`, `ANY`, `ALL`
* **Table** subquery (in the `FROM`) → must have an alias, or be written with `WITH` (CTE)
* **Correlated** subquery → references the outer query and is evaluated for each row
* `EXISTS` / `NOT EXISTS` → checks whether the subquery returns at least one row

The "Expected rows" line lets you check your result.

---

## Level 1 — Subqueries in `WHERE` (single value)

### 1. Above-average games

Display all games that cost more than the average game price.

Expected columns:

* `title`
* `price`

Expected rows: 8

---

### 2. Most expensive game

Display the most expensive game(s).

Expected columns:

* `title`
* `price`

Do not use `ORDER BY` + `LIMIT`: your query must still work if several games share the highest price.

Expected rows: 1

---

### 3. Same publisher as Elden Ring

Display all games published by the same publisher as "Elden Ring", except Elden Ring itself.

You only know the title of the game, not the publisher's id or name.

Expected columns:

* `title`
* `release_date`

Expected rows: 3

---

### 4. Lucas's compatriots

Display all users who come from the same country as Lucas, except Lucas himself.

Expected columns:

* `username`
* `country`

Expected rows: 3

---

### 5. Long gaming sessions

Display every owned game whose number of hours played is higher than the average number of hours played (across all purchases).

Expected columns:

* `username`
* `game_title`
* `hours_played`

Order the result from the highest number of hours played to the lowest.

Expected rows: 19

---

## Level 1 — Subqueries with `IN` / `NOT IN`

### 6. Reviewers

Display all users who have written at least one review.

**No JOIN allowed.**

Expected columns:

* `username`

Expected rows: 14

---

### 7. Games without reviews

Display all games that have never been reviewed.

**No JOIN allowed.**

Expected columns:

* `title`

Expected rows: 3

---

### 8. FromSoftware players

Display all users who own at least one game published by FromSoftware.

**No JOIN allowed:** you will need to nest several subqueries.

Expected columns:

* `username`

Expected rows: 5

---

### 9. Users without a profile

Display all users who don't have a profile.

**No JOIN allowed.**

Expected columns:

* `username`

Expected rows: 7

---

### 10. Publishers with local users

Display all publishers based in a country where at least one user lives.

Expected columns:

* `publisher_name`
* `country`

Expected rows: 8

---

## Level 2 — Subqueries in `HAVING`, `SELECT` and `FROM`

### 11. Premium publishers

Display publishers whose average game price is higher than the average price of all games.

Expected columns:

* `publisher_name`
* `average_price` (rounded to 2 decimals)

Expected rows: 5

---

### 12. Bigger communities than France

Display the countries that have more users than France.

Expected columns:

* `country`
* `total_users`

Expected rows: 2

---

### 13. Price compared to the average

Display every game with its price, the average price of all games and the difference between both.

Expected columns:

* `title`
* `price`
* `average_price` (rounded to 2 decimals)
* `price_difference` (rounded to 2 decimals, negative if the game is cheaper than the average)

Order the result from the highest difference to the lowest.

Expected rows: 19

---

### 14. Library size without JOIN

Display every user with the number of games they own.

Users without games must still appear with `0`.

**No JOIN allowed:** use a subquery in the `SELECT`.

Expected columns:

* `username`
* `games_owned`

Expected rows: 15

---

### 15. Average library size

Display the average number of games owned per user.

Only users who own at least one game are taken into account.

Expected columns:

* `average_games_per_user` (rounded to 2 decimals)

Write it twice: once with a subquery in the `FROM`, once with a CTE (`WITH`).

Expected rows: 1

---

### 16. Heavy players

Display users whose total number of hours played is higher than the **average total** number of hours played per user.

Careful: this is not the same as the average of `hours_played`!

Expected columns:

* `username`
* `total_hours_played`

Order the result from the highest total to the lowest.

Expected rows: 7

---

## Level 3 — Correlated subqueries, `EXISTS`, `ANY` / `ALL`

### 17. Flagship game of each publisher

Display the most expensive game(s) of each publisher.

If several games of the same publisher share the highest price, all of them must appear.

Expected columns:

* `publisher_name`
* `game_title`
* `price`

Expected rows: 11

---

### 18. Favorite game of each user

Display, for each user, the game(s) they played the most.

Expected columns:

* `username`
* `game_title`
* `hours_played`

Expected rows: 14

---

### 19. Better than the average player

Display every owned game where the user played more than the average number of hours played **on that same game**.

Expected columns:

* `username`
* `game_title`
* `hours_played`
* `game_average_hours` (rounded to 2 decimals)

Expected rows: 24

---

### 20. Publishers with recent games

Display publishers that have released at least one game after `2020-01-01`.

Use `EXISTS`.

Expected columns:

* `publisher_name`

Expected rows: 6

---

### 21. Inactive users

Display users who have never bought a game.

Use `NOT EXISTS`.

Expected columns:

* `username`
* `country`

Expected rows: 1

---

### 22. More expensive than every Valve game

Display games that cost more than **every** game published by Valve.

Use `ALL`.

Expected columns:

* `title`
* `price`

Expected rows: 10

---

### 23. Cheaper than a FromSoftware game

Display games, **not** published by FromSoftware, that are cheaper than **at least one** FromSoftware game.

Use `ANY`.

Expected columns:

* `title`
* `price`

Expected rows: 12

---

### 24. Completionists

Display users who own at least one game **and** have reviewed **every** game they own.

Hint: "every game they own is reviewed" means "there is no owned game without a review".

Expected columns:

* `username`

Expected rows: 2

---

### 25. Publishers above the average playtime

Using a CTE (`WITH`), display publishers whose total number of hours played (across all their games) is higher than the average total number of hours played per publisher.

Publishers whose games have never been played count as `0` in the average.

Expected columns:

* `publisher_name`
* `total_hours_played`

Order the result from the highest total playtime to the lowest.

Expected rows: 4