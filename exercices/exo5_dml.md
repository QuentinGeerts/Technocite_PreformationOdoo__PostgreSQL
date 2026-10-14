# SQL Exercises — Gaming Platform

## DML — INSERT, UPDATE, DELETE

## How to work

Every exercise must be written **inside a transaction** and **cancelled at the end**, so the data stays identical for the next exercise:

```sql
BEGIN;

-- your INSERT / UPDATE / DELETE

-- a SELECT to check the result

ROLLBACK;
```

Rules:

* Always check your modification with a `SELECT` **before** the `ROLLBACK`.
* If a statement fails, the transaction is aborted: every following statement is refused until you run `ROLLBACK`.
* No hard-coded `id`: find the ids with a subquery (`(SELECT id FROM users WHERE username = 'Davit')`).
* `RETURNING` displays the rows affected by an `INSERT`, `UPDATE` or `DELETE`:

```sql
UPDATE games
SET price = 0
WHERE title = 'Minecraft'
RETURNING title, price;
```

The "Expected" line gives the number of rows affected.

---

## Level 1 — INSERT

### 1. New user

Add the user `Zelda` (`zelda@test.com`, Belgium).

Check that she exists, then cancel. Check again after the `ROLLBACK`.

Expected: 1 row inserted, 0 rows after the `ROLLBACK`.

---

### 2. Several users at once

Add these 3 users **in a single statement**, and display their generated `id`, `username` and `created_at`:

| username | email           | country |
| -------- | --------------- | ------- |
| Link     | link@test.com   | Japan   |
| Samus    | samus@test.com  | USA     |
| Kratos   | kratos@test.com | Greece  |

Question: run the exercise twice. Are the generated `id` values the same? Why?

Expected: 3 rows inserted.

---

### 3. New publisher and its first game

In the same transaction:

1. add the publisher `Supergiant Games` (USA)
2. add its game `Hades II` (29.99€, released on `2025-09-25`)

Display the game with the name and country of its publisher.

Expected: 1 + 1 rows inserted.

---

### 4. A profile for Tom

Tom has no profile. Create one with the bio `Counter Strike addict` and the birth date `1999-12-24`.

Constraint: use `INSERT ... SELECT` (no `VALUES`).

Expected: 1 row inserted.

---

### 5. Breaking the constraints

Each insertion below **must fail**. For each one, run it in its own transaction and explain which constraint blocks it.

a) A user named `Al`
b) A user with the email `albert.test.com`
c) A second user named `Davit`
d) A game that costs -10€
e) A review with a rating of 6
f) A purchase for the user with `id` 999
g) A user inserted with the `id` 100
h) Davit buys Elden Ring (again)
i) A review with the comment `Wow`

Question: why one transaction per insertion?

---

## Level 2 — UPDATE

### 6. Mike moves

Mike now lives in Ireland.

Expected: 1 row updated.

---

### 7. FromSoftware sale

All FromSoftware games are 20% off. Round the new prices to 2 decimals and display the titles and new prices.

Expected: 4 rows updated.

---

### 8. Inflation

Games released since 2022 that cost more than 50€ get 10% more expensive (rounded to 2 decimals).

Expected: 3 rows updated.

---

### 9. Davit's gaming weekend

Davit played 50 more hours on **each** of his games.

Display Davit's total hours before and after the update, in the same transaction.

Expected: 8 rows updated, total from 1540 to 1940.

---

### 10. Fill the empty profiles

In a **single** `UPDATE`:

* profiles without bio get `No bio yet`
* profiles without avatar get `default.png`

The existing values must not change.

Expected: 2 rows updated.

---

### 11. New pricing policy

For all paid games:

* under 30€: +5€
* between 30€ and 60€: -10% (rounded to 2 decimals)
* above 60€: 59.99€

Free games stay free.

Constraint: a single `UPDATE`.

Expected: 14 rows updated.

---

### 12. Verified owners

Add ` (verified owner)` at the end of the comment of every review whose author owns the game **and** played it for at least 100 hours.

Expected: 17 rows updated.

---

### 13. The forgotten WHERE

Run this query, then display the number of users per country:

```sql
UPDATE users
SET country = 'Belgium';
```

What happened? Cancel, then check that the data is intact.

Expected: 15 rows updated.

---

## Level 3 — DELETE

### 14. Chris's review

Delete Chris's review on League of Legends.

Expected: 1 row deleted.

---

### 15. Reviews from non-owners

Delete every review written by a user who does not own the game.

Constraint: the query must work for any user and any game (no names, no ids).

Expected: 1 row deleted.

---

### 16. Lina deletes her account

Display the number of rows in `users`, `user_games` and `reviews`.
Delete Lina, then display the counts again.

What happened to her games and reviews? Which part of the table definitions explains it?

Expected: 1 user deleted — `users` 15 → 14, `user_games` 55 → 50, `reviews` 27 → 25.

---

### 17. Deleting publishers

a) Delete Valve. What happens? Why?
b) Delete Ubisoft. Why does it work?

Expected: a) error, b) 1 row deleted.

---

### 18. Ghost accounts

Delete the users who never bought **nor** reviewed anything.

Expected: 1 row deleted.

---

### 19. Games nobody bought

Delete the games that have never been purchased.

Expected: 1 row deleted.

---

### 20. DELETE vs TRUNCATE

Empty the `reviews` table with `TRUNCATE`, count its rows, then cancel.

Questions:

* What is the difference between `DELETE FROM reviews;` and `TRUNCATE TABLE reviews;`?
* Can a `TRUNCATE` be cancelled in PostgreSQL?

---

## Level 4 — INSERT ... SELECT

### 21. A profile for everyone

Create a profile for every user who doesn't have one yet, with the bio `Hello, I am <username>`.

Check that no user is left without a profile.

Expected: 7 rows inserted.

---

### 22. Belgian gift

Every Belgian user receives `Portal 2` today, with 0 hours played, unless they already own it.

Expected: 4 rows inserted.

---

### 23. Statistics table

In a transaction:

1. create a table `game_stats` (`game_id` as primary key, `title`, `total_players`, `total_hours`, `avg_rating`)
2. fill it with **one** `INSERT ... SELECT` covering all games (`total_hours` = 0 for games never played)
3. display it, sorted by total hours

After the `ROLLBACK`, try `SELECT * FROM game_stats;`. What happens?

Expected: 19 rows inserted.

---

## Level 5 — Transactions

### 24. Nina's first purchase

In a single transaction:

1. Nina buys `Hades` today
2. create a `SAVEPOINT`
3. Nina reviews it with a rating of 7 and the comment `Best roguelike ever` → error
4. go back to the `SAVEPOINT`
5. insert the review again with a rating of 5
6. check that Nina has 1 game and 1 review

Syntax:

```sql
SAVEPOINT savepoint_name;
ROLLBACK TO SAVEPOINT savepoint_name;
```

Question: without the `SAVEPOINT`, what would happen after the error?

---

### 25. A gift between friends

Davit gives his copy of Elden Ring to Nina:

* the game now belongs to Nina, with 0 hours played and today's purchase date
* Davit's review on Elden Ring is deleted

Display all the owners of Elden Ring with their hours and purchase date.

Constraint: no `INSERT`.

Expected: 1 row updated, 1 row deleted.

---

### 26. Account merge

Sarah and Julie are the same person. Merge Julie's account into Sarah's:

1. for the games they **both** own: add Julie's hours to Sarah's
2. Julie's other games are transferred to Sarah
3. Julie's reviews are transferred to Sarah (only for games Sarah has not reviewed yet)
4. Julie's account is deleted

Check at the end:

| sarah_games | sarah_reviews | cyberpunk_hours | julie |
| ----------- | ------------- | --------------- | ----- |
| 9           | 5             | 130             | 0     |

Question: why is the order of the steps important?
