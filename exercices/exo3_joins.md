# SQL Exercises — Gaming Platform

## JOINs and Advanced SELECT

## Level 1 — Fundamentals

### 1. Games and publishers

Display every game with its publisher.

Expected columns:

* `game_title`
* `publisher_name`

---

### 2. Owned games

Display every game owned by a user.

Expected columns:

* `username`
* `game_title`
* `hours_played`

---

### 3. Users and profiles

Display all users with their profile information.

Users without a profile must still appear.

Expected columns:

* `username`
* `bio`
* `avatar_url`

---

### 4. Reviews

Display every review with the user and game information.

Expected columns:

* `username`
* `game_title`
* `rating`
* `comment`

---

### 5. Publishers and games

Display all publishers with their games.

Publishers without games must still appear.

Expected columns:

* `publisher_name`
* `game_title`

---

### 6. Users without games

Display all users who have never bought a game.

Expected columns:

* `username`

---

### 7. Game purchases

Display all users with the games they own and the corresponding purchase date.

Expected columns:

* `username`
* `game_title`
* `purchase_date`

---

### 8. Games without purchases

Display all games that have never been purchased.

Expected columns:

* `game_title`

---

### 9. Number of players per game

Display every game with its total number of players.

Games without players must still appear.

Expected columns:

* `game_title`
* `total_players`

---

### 10. Average rating per game

Display every reviewed game with its average rating.

Expected columns:

* `game_title`
* `average_rating`

---

## Level 2 — Intermediate

### 11. User activity summary

Display all users with the number of games they own and their total number of hours played.

Users without games must still appear.

Expected columns:

* `username`
* `games_owned`
* `total_hours_played`

---

### 12. Publishers with several games

Display publishers that have published more than one game.

Expected columns:

* `publisher_name`
* `total_games`

---

### 13. Highly played games

Display games for which the total number of hours played exceeds 500.

Expected columns:

* `game_title`
* `total_hours_played`

---

### 14. Active reviewers

Display users who have written more than one review.

Expected columns:

* `username`
* `reviews_written`

---

### 15. Most-played games

Display the five games with the highest total number of hours played.

Expected columns:

* `game_title`
* `total_hours_played`

The most-played game must appear first.

---

## Level 3 — Advanced

### 16. Detailed game review statistics

Display all games with their publisher and review statistics.

Games without reviews must still appear.

Expected columns:

* `game_title`
* `publisher_name`
* `total_reviews`
* `average_rating`

Order the result by average rating from highest to lowest.

---

### 17. Complete user activity

Display all users with the number of games they own and the number of reviews they have written.

Users without games or reviews must still appear.

Expected columns:

* `username`
* `games_owned`
* `reviews_written`

Be careful not to count the same game or review several times.

---

### 18. Users loyal to a publisher

Display every user who owns at least two games from the same publisher.

Expected columns:

* `username`
* `publisher_name`
* `games_owned_from_publisher`

---

### 19. Local publisher audiences

For each publisher, display the number of distinct players who come from the same country as the publisher.

Publishers without matching players must still appear.

Expected columns:

* `publisher_name`
* `publisher_country`
* `local_players`

---

### 20. Publishers ranked by playtime

Display all publishers with the total number of hours played across all their games.

Publishers whose games have never been played must still appear.

Expected columns:

* `publisher_name`
* `total_hours_played`

Order the result from the highest total playtime to the lowest.
