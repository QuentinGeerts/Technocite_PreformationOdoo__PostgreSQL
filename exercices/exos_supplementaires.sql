-- SQL Exercises — Gaming Platform
-- BONUS — Mix everything (hard mode)


--
-- Level 1 — Filter, then group
--

-- B1. European communities
-- For each country except the USA and the UK: label "Country (n users)",
-- number of usernames containing "a", number of usernames of 4 characters or less.
-- Keep only the countries with at least 2 users.
-- Columns: country_label, names_with_a, short_names

-- COUNT ignore les NULL → un CASE sans ELSE renvoie NULL quand la condition est fausse

SELECT
  country || ' (' || COUNT(id) || ' users)' country_label,
  COUNT(CASE WHEN username ILIKE '%a%' THEN 1 END) names_with_a,
  COUNT(CASE WHEN LENGTH(username) <= 4 THEN 1 END) short_names
FROM users
WHERE country NOT IN ('USA', 'UK')
GROUP BY country
HAVING COUNT(id) >= 2
ORDER BY COUNT(id) DESC, country;

-- Version 2 : FILTER (spécifique PostgreSQL)

SELECT
  country || ' (' || COUNT(id) || ' users)' country_label,
  COUNT(id) FILTER (WHERE username ILIKE '%a%') names_with_a,
  COUNT(id) FILTER (WHERE LENGTH(username) <= 4) short_names
FROM users
WHERE country NOT IN ('USA', 'UK')
GROUP BY country
HAVING COUNT(id) >= 2
ORDER BY COUNT(id) DESC, country;

-- B2. Title length matters
-- Classify the games by number of words in their title: 1 word, 2 words, 3+ words.
-- Columns: title_type, total_games, avg_title_length, avg_price, cheapest_price, most_expensive_price

-- Nombre de mots = nombre d'espaces + 1
-- Nombre d'espaces = longueur du titre - longueur du titre sans les espaces

SELECT
  title,
  LENGTH(title) - LENGTH(REPLACE(title, ' ', '')) + 1 words
FROM games;

-- Assemblage

SELECT
  CASE LENGTH(title) - LENGTH(REPLACE(title, ' ', '')) + 1
    WHEN 1 THEN '1 word'
    WHEN 2 THEN '2 words'
    ELSE '3+ words'
  END title_type,
  COUNT(id) total_games,
  ROUND(AVG(LENGTH(title)), 1) avg_title_length,
  ROUND(AVG(price), 2) avg_price,
  MIN(price) cheapest_price,
  MAX(price) most_expensive_price
FROM games
GROUP BY title_type
ORDER BY title_type;

-- B3. Free-to-play publishers
-- For each publisher_id with at least one free game: total games, free games,
-- average price, average price of the paid games ("Only free games" if none). No CASE allowed.
-- Columns: publisher_id, total_games, free_games, avg_price, avg_paid_price

-- NULLIF(price, 0) → NULL pour les jeux gratuits
-- → COUNT(NULLIF(price, 0)) compte les jeux payants
-- → AVG(NULLIF(price, 0)) calcule la moyenne des jeux payants (les NULL sont ignorés)
-- → AVG d'une colonne uniquement NULL = NULL → COALESCE
-- COALESCE exige des valeurs du même type : la moyenne est convertie en texte (::TEXT)

SELECT
  publisher_id,
  COUNT(id) total_games,
  COUNT(id) - COUNT(NULLIF(price, 0)) free_games,
  ROUND(AVG(price), 2) avg_price,
  COALESCE(ROUND(AVG(NULLIF(price, 0)), 2)::TEXT, 'Only free games') avg_paid_price
FROM games
GROUP BY publisher_id
HAVING COUNT(NULLIF(price, 0)) < COUNT(id)
ORDER BY publisher_id;

-- B4. The 2022–2023 period
-- Purchases made in 2022 and 2023 only. For each user with at least 2 purchases:
-- summary "User #6 - 1050h", number of purchases, hours converted into days.
-- Columns: player_summary, total_purchases, days_played

-- Division entière : INT / INT = INT → 870 / 24 = 36
-- → il faut au moins un décimal : 24.0 ou un cast (::NUMERIC)

SELECT 870 / 24, 870 / 24.0, 870::NUMERIC / 24;

SELECT
  'User #' || user_id || ' - ' || SUM(hours_played) || 'h' player_summary,
  COUNT(*) total_purchases,
  ROUND(SUM(hours_played) / 24.0, 1) days_played
FROM user_games
WHERE purchase_date BETWEEN '2022-01-01' AND '2023-12-31'
GROUP BY user_id
HAVING COUNT(*) >= 2
ORDER BY SUM(hours_played) DESC;

--
-- Level 2 — Advanced CASE
--

-- B5. Review sentiment
-- Classify each comment: Mixed (" but "), Negative (starts with "not " or "too "),
-- Enthusiastic ("best", "masterpiece" or "perfect"), Neutral otherwise.
-- Columns: sentiment, total_reviews, avg_rating, lowest_rating, highest_rating

-- Le CASE s'arrête au premier WHEN vrai → l'ordre des WHEN est important
-- 'Still toxic but addictive' → Mixed (premier WHEN vérifié)
-- 'Best competitive FPS' → Enthusiastic
-- Si Enthusiastic était testé en premier, 'Good but buggy' resterait Mixed
-- mais un commentaire 'Best game but too short' deviendrait Enthusiastic

SELECT
  CASE
    WHEN comment ILIKE '% but %' THEN 'Mixed'
    WHEN comment ILIKE 'not %' OR comment ILIKE 'too %' THEN 'Negative'
    WHEN comment ILIKE '%best%'
      OR comment ILIKE '%masterpiece%'
      OR comment ILIKE '%perfect%' THEN 'Enthusiastic'
    ELSE 'Neutral'
  END sentiment,
  COUNT(id) total_reviews,
  ROUND(AVG(rating), 2) avg_rating,
  MIN(rating) lowest_rating,
  MAX(rating) highest_rating
FROM reviews
GROUP BY sentiment
ORDER BY avg_rating DESC;

-- B6. Profile completeness
-- Group the profiles by completeness score (bio, avatar_url, birth_date filled): 3/3, 2/3, 1/3...
-- Columns: completeness, total_profiles, oldest_birth_date, youngest_birth_date

-- Version 1 : CASE

SELECT
  CASE WHEN bio IS NOT NULL THEN 1 ELSE 0 END
    + CASE WHEN avatar_url IS NOT NULL THEN 1 ELSE 0 END
    + CASE WHEN birth_date IS NOT NULL THEN 1 ELSE 0 END
    || '/3' completeness,
  COUNT(id) total_profiles,
  MIN(birth_date) oldest_birth_date,
  MAX(birth_date) youngest_birth_date
FROM profiles
GROUP BY completeness
ORDER BY completeness DESC;

-- Version 2 : cast d'un booléen en entier (true → 1, false → 0)

SELECT
  (bio IS NOT NULL)::INT
    + (avatar_url IS NOT NULL)::INT
    + (birth_date IS NOT NULL)::INT
    || '/3' completeness,
  COUNT(id) total_profiles,
  MIN(birth_date) oldest_birth_date,
  MAX(birth_date) youngest_birth_date
FROM profiles
GROUP BY completeness
ORDER BY completeness DESC;

-- B7. Playtime distribution per year
-- Purchases made between 2020 and 2024. For each year: number of purchases per playtime tier
-- as columns, and total hours. Keep only the years with at least 5 purchases.
-- Columns: purchase_year, light (< 100h), regular (100–499h), heavy (≥ 500h), total_hours

-- Tableau croisé : un COUNT conditionnel par colonne

SELECT
  EXTRACT(YEAR FROM purchase_date) purchase_year,
  COUNT(CASE WHEN hours_played < 100 THEN 1 END) "light (< 100h)",
  COUNT(CASE WHEN hours_played BETWEEN 100 AND 499 THEN 1 END) "regular (100–499h)",
  COUNT(CASE WHEN hours_played >= 500 THEN 1 END) "heavy (≥ 500h)",
  SUM(hours_played) total_hours
FROM user_games
WHERE purchase_date BETWEEN '2020-01-01' AND '2024-12-31'
GROUP BY purchase_year
HAVING COUNT(*) >= 5
ORDER BY purchase_year;

-- B8. Reviewer profiles
-- Ignore the reviews mentioning "fun". For each user with at least 2 remaining reviews:
-- total, positive reviews (>= 4), short comments (< 15 characters), average comment length,
-- profile: Harsh (a rating <= 2), Fan (only 5), Balanced otherwise.
-- Columns: user_id, total_reviews, positive_reviews, short_comments, avg_comment_length, reviewer_profile

-- "Au moins une note <= 2" → la note minimale est <= 2
-- "Toutes les notes valent 5" → la note minimale vaut 5

SELECT
  user_id,
  COUNT(id) total_reviews,
  COUNT(CASE WHEN rating >= 4 THEN 1 END) positive_reviews,
  COUNT(CASE WHEN LENGTH(comment) < 15 THEN 1 END) short_comments,
  ROUND(AVG(LENGTH(comment)), 1) avg_comment_length,
  CASE
    WHEN MIN(rating) <= 2 THEN 'Harsh'
    WHEN MIN(rating) = 5 THEN 'Fan'
    ELSE 'Balanced'
  END reviewer_profile
FROM reviews
WHERE comment NOT ILIKE '%fun%'
GROUP BY user_id
HAVING COUNT(id) >= 2
ORDER BY AVG(rating), user_id;

--
-- Level 3 — Everything at once
--

-- B9. Yearly activity
-- For each purchase year: purchases, distinct buyers, distinct games, purchases per buyer.
-- Keep only the years with at least 3 distinct buyers.
-- Columns: purchase_year, total_purchases, distinct_buyers, distinct_games, purchases_per_buyer

-- COUNT(*) / COUNT(DISTINCT ...) → division entière → cast en NUMERIC

SELECT
  EXTRACT(YEAR FROM purchase_date) purchase_year,
  COUNT(*) total_purchases,
  COUNT(DISTINCT user_id) distinct_buyers,
  COUNT(DISTINCT game_id) distinct_games,
  ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT user_id), 2) purchases_per_buyer
FROM user_games
GROUP BY purchase_year
HAVING COUNT(DISTINCT user_id) >= 3
ORDER BY purchase_year;

-- B10. Premium publishers
-- Paid games released between 2010 and 2022, titles containing "of" excluded.
-- For each publisher with at least 2 matching games: price statistics and tier.
-- Columns: publisher, total_games, cheapest_price, most_expensive_price, price_spread, avg_price, tier

SELECT
  'Publisher #' || publisher_id publisher,
  COUNT(id) total_games,
  MIN(price) cheapest_price,
  MAX(price) most_expensive_price,
  MAX(price) - MIN(price) price_spread,
  ROUND(AVG(price), 2) avg_price,
  CASE
    WHEN AVG(price) > 45 THEN 'Premium'
    WHEN AVG(price) >= 25 THEN 'Mid-range'
    ELSE 'Budget'
  END tier
FROM games
WHERE price > 0
  AND release_date BETWEEN '2010-01-01' AND '2022-12-31'
  AND title NOT ILIKE '%of%'
GROUP BY publisher_id
HAVING COUNT(id) >= 2
ORDER BY AVG(price) DESC;

--
-- Level 4 — ROLLUP
--

-- B11. Catalogue by era
-- Number of games and average price per era (Retro, Modern, Recent) and business model (Free, Paid),
-- with a subtotal per era and a grand total.
-- Columns: era, business_model, total_games, avg_price

-- ROLLUP (a, b) → regroupements (a, b), puis (a), puis () (total général)
-- Les colonnes "regroupées" d'une ligne de sous-total valent NULL → COALESCE
-- Tri : l'alias "era" contient le texte remplacé ('All eras')
-- → on trie sur l'expression d'origine, qui vaut NULL sur les lignes de total
-- → en PostgreSQL, ASC place les NULL en dernier (NULLS LAST par défaut)

SELECT
  COALESCE(
    CASE
      WHEN release_date < '2015-01-01' THEN 'Retro'
      WHEN release_date < '2020-01-01' THEN 'Modern'
      ELSE 'Recent'
    END,
    'All eras'
  ) era,
  COALESCE(
    CASE WHEN price = 0 THEN 'Free' ELSE 'Paid' END,
    'All models'
  ) business_model,
  COUNT(id) total_games,
  ROUND(AVG(price), 2) avg_price
FROM games
GROUP BY ROLLUP (
  CASE
    WHEN release_date < '2015-01-01' THEN 'Retro'
    WHEN release_date < '2020-01-01' THEN 'Modern'
    ELSE 'Recent'
  END,
  CASE WHEN price = 0 THEN 'Free' ELSE 'Paid' END
)
ORDER BY
  CASE
    CASE
      WHEN release_date < '2015-01-01' THEN 'Retro'
      WHEN release_date < '2020-01-01' THEN 'Modern'
      ELSE 'Recent'
    END
    WHEN 'Retro' THEN 1
    WHEN 'Modern' THEN 2
    WHEN 'Recent' THEN 3
  END,
  CASE WHEN price = 0 THEN 'Free' ELSE 'Paid' END;

-- Version 2 : classement d'abord dans une sous-requête du FROM → plus lisible, aucune répétition

SELECT
  COALESCE(era, 'All eras') era,
  COALESCE(business_model, 'All models') business_model,
  COUNT(*) total_games,
  ROUND(AVG(price), 2) avg_price
FROM (
  SELECT
    price,
    CASE
      WHEN release_date < '2015-01-01' THEN 'Retro'
      WHEN release_date < '2020-01-01' THEN 'Modern'
      ELSE 'Recent'
    END era,
    CASE WHEN price = 0 THEN 'Free' ELSE 'Paid' END business_model
  FROM games
) classified
GROUP BY ROLLUP (classified.era, classified.business_model)
ORDER BY
  CASE classified.era
    WHEN 'Retro' THEN 1
    WHEN 'Modern' THEN 2
    WHEN 'Recent' THEN 3
  END,
  classified.business_model;

-- B12. Users by country and name length
-- Users from Belgium, France and the USA. Number of users per country and username length
-- (Short: 4 characters or less, Long otherwise), with a subtotal per country and a grand total.
-- Columns: country, name_length, total_users

-- u.country (qualifié) → colonne de la table, pas l'alias du SELECT

SELECT
  COALESCE(u.country, 'All countries') country,
  COALESCE(
    CASE WHEN LENGTH(u.username) <= 4 THEN 'Short' ELSE 'Long' END,
    'All lengths'
  ) name_length,
  COUNT(u.id) total_users
FROM users u
WHERE u.country IN ('Belgium', 'France', 'USA')
GROUP BY ROLLUP (
  u.country,
  CASE WHEN LENGTH(u.username) <= 4 THEN 'Short' ELSE 'Long' END
)
ORDER BY
  u.country,
  CASE WHEN LENGTH(u.username) <= 4 THEN 'Short' ELSE 'Long' END;

-- Version 2 : GROUPING(colonne) → 1 si la colonne est "regroupée" sur la ligne (ligne de total), 0 sinon

SELECT
  COALESCE(u.country, 'All countries') country,
  COALESCE(
    CASE WHEN LENGTH(u.username) <= 4 THEN 'Short' ELSE 'Long' END,
    'All lengths'
  ) name_length,
  COUNT(u.id) total_users
FROM users u
WHERE u.country IN ('Belgium', 'France', 'USA')
GROUP BY ROLLUP (
  u.country,
  CASE WHEN LENGTH(u.username) <= 4 THEN 'Short' ELSE 'Long' END
)
ORDER BY
  GROUPING(u.country),
  u.country,
  GROUPING(CASE WHEN LENGTH(u.username) <= 4 THEN 'Short' ELSE 'Long' END),
  name_length;

--
-- Level 5 — Joins
--

-- B13. Publisher scorecard
-- All publishers with their number of games, distinct players, total hours and status
-- (No game, No player, Blockbuster >= 3000h, Active).
-- Columns: publisher_name, publisher_country, total_games, distinct_players, total_hours, status

-- Une ligne par achat après les jointures → un jeu acheté 3 fois apparaît 3 fois
-- → COUNT(DISTINCT g.id) pour ne compter chaque jeu qu'une fois

SELECT
  p.name publisher_name,
  p.country publisher_country,
  COUNT(DISTINCT g.id) total_games,
  COUNT(DISTINCT ug.user_id) distinct_players,
  COALESCE(SUM(ug.hours_played), 0) total_hours,
  CASE
    WHEN COUNT(g.id) = 0 THEN 'No game'
    WHEN COUNT(ug.user_id) = 0 THEN 'No player'
    WHEN SUM(ug.hours_played) >= 3000 THEN 'Blockbuster'
    ELSE 'Active'
  END status
FROM publishers p
  LEFT JOIN games g ON g.publisher_id = p.id
  LEFT JOIN user_games ug ON ug.game_id = g.id
GROUP BY p.id
ORDER BY total_hours DESC, publisher_name;

-- B14. Gaming duos
-- Two users form a duo when they own at least 3 games in common.
-- Columns: duo, origin, common_games, combined_hours

-- Auto-jointure : user_games avec elle-même sur le même jeu
-- ug1.user_id < ug2.user_id → chaque paire une seule fois, pas de paire avec soi-même

SELECT
  u1.username || ' & ' || u2.username duo,
  CASE
    WHEN u1.country = u2.country THEN 'Same country'
    ELSE 'International'
  END origin,
  COUNT(*) common_games,
  SUM(ug1.hours_played + ug2.hours_played) combined_hours
FROM user_games ug1
  JOIN user_games ug2 ON ug2.game_id = ug1.game_id AND ug1.user_id < ug2.user_id
  JOIN users u1 ON u1.id = ug1.user_id
  JOIN users u2 ON u2.id = ug2.user_id
GROUP BY u1.id, u2.id
HAVING COUNT(*) >= 3
ORDER BY common_games DESC, combined_hours DESC;

-- B15. Trustworthy reviews
-- A review is trustworthy if its author owns the game and played it for at least 50 hours.

-- a) Suspicious reviews (game not owned, or less than 50 hours played)
-- Columns: username, game_title, rating, hours_played, reason

-- LEFT JOIN sur user_games : un avis sans achat correspondant → colonnes ug à NULL

SELECT
  u.username,
  g.title game_title,
  r.rating,
  COALESCE(ug.hours_played::TEXT, 'Not owned') hours_played,
  CASE
    WHEN ug.user_id IS NULL THEN 'Not owned'
    ELSE 'Too early'
  END reason
FROM reviews r
  JOIN users u ON u.id = r.user_id
  JOIN games g ON g.id = r.game_id
  LEFT JOIN user_games ug ON ug.user_id = r.user_id AND ug.game_id = r.game_id
WHERE ug.user_id IS NULL OR ug.hours_played < 50
ORDER BY r.rating, u.username;

-- b) For each game with at least 2 reviews: total and trusted reviews, average and trusted average
-- Columns: game_title, total_reviews, trusted_reviews, avg_rating, trusted_avg_rating

-- AVG(CASE WHEN ... THEN rating END) → moyenne des seuls avis de confiance (les NULL sont ignorés)
-- Tri : sur l'expression numérique (l'alias contient du texte)

SELECT
  g.title game_title,
  COUNT(r.id) total_reviews,
  COUNT(CASE WHEN ug.hours_played >= 50 THEN 1 END) trusted_reviews,
  ROUND(AVG(r.rating), 2) avg_rating,
  COALESCE(
    ROUND(AVG(CASE WHEN ug.hours_played >= 50 THEN r.rating END), 2)::TEXT,
    'No trusted review'
  ) trusted_avg_rating
FROM reviews r
  JOIN games g ON g.id = r.game_id
  LEFT JOIN user_games ug ON ug.user_id = r.user_id AND ug.game_id = r.game_id
GROUP BY g.id
HAVING COUNT(r.id) >= 2
ORDER BY AVG(CASE WHEN ug.hours_played >= 50 THEN r.rating END) DESC NULLS LAST, g.title;

-- B16. Cheaper siblings
-- Publishers with at least 3 games: for each game, the number of games of the same publisher
-- that are strictly cheaper.
-- Columns: publisher_name, game_title, price, cheaper_siblings

-- Jointure non-équi : la condition de jointure n'est pas une égalité (g2.price < g.price)
-- LEFT JOIN → le jeu le moins cher n'a aucun "frère" moins cher mais doit apparaître (0)

SELECT
  p.name publisher_name,
  g.title game_title,
  g.price,
  COUNT(g2.id) cheaper_siblings
FROM games g
  JOIN publishers p ON p.id = g.publisher_id
  LEFT JOIN games g2 ON g2.publisher_id = g.publisher_id AND g2.price < g.price
WHERE g.publisher_id IN (
  SELECT publisher_id
  FROM games
  GROUP BY publisher_id
  HAVING COUNT(id) >= 3
)
GROUP BY p.name, g.id
ORDER BY publisher_name, cheaper_siblings DESC;

--
-- Level 6 — Subqueries
--

-- B17. Overpriced for their publisher
-- Display the games more expensive than the average price of their own publisher.
-- Columns: game_title, publisher_name, price, publisher_avg_price, difference

-- Version 1 : sous-requêtes corrélées

SELECT
  g.title game_title,
  p.name publisher_name,
  g.price,
  (
    SELECT ROUND(AVG(g2.price), 2)
    FROM games g2
    WHERE g2.publisher_id = g.publisher_id
  ) publisher_avg_price,
  ROUND(g.price - (
    SELECT AVG(g2.price)
    FROM games g2
    WHERE g2.publisher_id = g.publisher_id
  ), 2) difference
FROM games g
  JOIN publishers p ON p.id = g.publisher_id
WHERE g.price > (
  SELECT AVG(g2.price)
  FROM games g2
  WHERE g2.publisher_id = g.publisher_id
)
ORDER BY difference DESC;

-- Version 2 : sous-requête dans le FROM (moyenne calculée une seule fois par éditeur)

SELECT
  g.title game_title,
  p.name publisher_name,
  g.price,
  ROUND(pa.avg_price, 2) publisher_avg_price,
  ROUND(g.price - pa.avg_price, 2) difference
FROM games g
  JOIN publishers p ON p.id = g.publisher_id
  JOIN (
    SELECT publisher_id, AVG(price) avg_price
    FROM games
    GROUP BY publisher_id
  ) pa ON pa.publisher_id = g.publisher_id
WHERE g.price > pa.avg_price
ORDER BY difference DESC;

-- B18. Above-average players
-- Users whose total hours played is above the average of the totals.
-- Columns: username, country, total_hours, above_average_by

-- Total par utilisateur

SELECT user_id, SUM(hours_played) total_hours
FROM user_games
GROUP BY user_id;

-- Moyenne des totaux

SELECT AVG(total_hours)
FROM (
  SELECT user_id, SUM(hours_played) total_hours
  FROM user_games
  GROUP BY user_id
) totals;

-- Assemblage

SELECT
  u.username,
  u.country,
  t.total_hours,
  ROUND(t.total_hours - (
    SELECT AVG(total_hours)
    FROM (
      SELECT user_id, SUM(hours_played) total_hours
      FROM user_games
      GROUP BY user_id
    ) totals
  ), 1) above_average_by
FROM users u
  JOIN (
    SELECT user_id, SUM(hours_played) total_hours
    FROM user_games
    GROUP BY user_id
  ) t ON t.user_id = u.id
WHERE t.total_hours > (
  SELECT AVG(total_hours)
  FROM (
    SELECT user_id, SUM(hours_played) total_hours
    FROM user_games
    GROUP BY user_id
  ) totals
)
ORDER BY t.total_hours DESC;

-- Version CTE : la sous-requête des totaux n'est écrite qu'une fois

WITH totals AS (
  SELECT user_id, SUM(hours_played) total_hours
  FROM user_games
  GROUP BY user_id
)
SELECT
  u.username,
  u.country,
  t.total_hours,
  ROUND(t.total_hours - (SELECT AVG(total_hours) FROM totals), 1) above_average_by
FROM users u
  JOIN totals t ON t.user_id = u.id
WHERE t.total_hours > (SELECT AVG(total_hours) FROM totals)
ORDER BY t.total_hours DESC;

-- B19. Favourite game
-- For each user: most-played game and the share it represents in their total playtime.
-- Columns: username, favourite_game, hours_played, share_pct

SELECT
  u.username,
  g.title favourite_game,
  ug.hours_played,
  ROUND(ug.hours_played * 100.0 / (
    SELECT SUM(ug2.hours_played)
    FROM user_games ug2
    WHERE ug2.user_id = ug.user_id
  ), 1) share_pct
FROM user_games ug
  JOIN users u ON u.id = ug.user_id
  JOIN games g ON g.id = ug.game_id
WHERE ug.hours_played = (
  SELECT MAX(ug2.hours_played)
  FROM user_games ug2
  WHERE ug2.user_id = ug.user_id
)
ORDER BY share_pct DESC, u.username;

-- B20. Hidden gems
-- Games never reviewed but owned by at least 2 players.
-- Columns: game_title, publisher_name, total_players, total_hours

-- Version 1 : NOT IN

SELECT
  g.title game_title,
  p.name publisher_name,
  COUNT(ug.user_id) total_players,
  SUM(ug.hours_played) total_hours
FROM games g
  JOIN publishers p ON p.id = g.publisher_id
  JOIN user_games ug ON ug.game_id = g.id
WHERE g.id NOT IN (SELECT game_id FROM reviews)
GROUP BY g.id, p.name
HAVING COUNT(ug.user_id) >= 2
ORDER BY total_players DESC;

-- Version 2 : NOT EXISTS
-- → plus sûr : NOT IN renvoie 0 ligne si la sous-requête contient un NULL

SELECT
  g.title game_title,
  p.name publisher_name,
  COUNT(ug.user_id) total_players,
  SUM(ug.hours_played) total_hours
FROM games g
  JOIN publishers p ON p.id = g.publisher_id
  JOIN user_games ug ON ug.game_id = g.id
WHERE NOT EXISTS (
  SELECT 1
  FROM reviews r
  WHERE r.game_id = g.id
)
GROUP BY g.id, p.name
HAVING COUNT(ug.user_id) >= 2
ORDER BY total_players DESC;

-- B21. World map
-- Every country appearing in users or publishers, with the number of users and publishers.
-- Columns: country, total_users, total_publishers, status

-- FULL JOIN → garde les lignes des deux côtés, même sans correspondance
-- Agrégation AVANT la jointure : sinon chaque utilisateur serait multiplié par le nombre d'éditeurs du pays

SELECT
  COALESCE(uc.country, pc.country) country,
  COALESCE(uc.total_users, 0) total_users,
  COALESCE(pc.total_publishers, 0) total_publishers,
  CASE
    WHEN uc.country IS NULL THEN 'Publishers only'
    WHEN pc.country IS NULL THEN 'Users only'
    ELSE 'Both'
  END status
FROM (
  SELECT country, COUNT(id) total_users
  FROM users
  GROUP BY country
) uc
  FULL JOIN (
    SELECT country, COUNT(id) total_publishers
    FROM publishers
    GROUP BY country
  ) pc ON pc.country = uc.country
ORDER BY status, country;

--
-- Level 7 — Set operations
--

-- B22. Played but never reviewed
-- For each user: number of owned games never reviewed and hours played on these games.
-- Keep only the users with at least 3 unreviewed games. Use EXCEPT.
-- Columns: username, unreviewed_games, unreviewed_hours

-- Couples (utilisateur, jeu) possédés - couples (utilisateur, jeu) avec avis

SELECT user_id, game_id FROM user_games
EXCEPT
SELECT user_id, game_id FROM reviews;

-- Assemblage : on rejoint user_games pour récupérer les heures

SELECT
  u.username,
  COUNT(*) unreviewed_games,
  SUM(ug.hours_played) unreviewed_hours
FROM (
  SELECT user_id, game_id FROM user_games
  EXCEPT
  SELECT user_id, game_id FROM reviews
) nr
  JOIN users u ON u.id = nr.user_id
  JOIN user_games ug ON ug.user_id = nr.user_id AND ug.game_id = nr.game_id
GROUP BY u.id
HAVING COUNT(*) >= 3
ORDER BY unreviewed_games DESC, unreviewed_hours DESC;

-- B23. Ghost accounts
-- Users who never bought nor reviewed anything. Use UNION in a subquery.
-- Columns: username, country, bio, profile_status

-- UNION → liste (sans doublons) des utilisateurs actifs

SELECT
  u.username,
  u.country,
  COALESCE(p.bio, 'No bio') bio,
  CASE
    WHEN p.id IS NULL THEN 'No profile'
    ELSE 'Has profile'
  END profile_status
FROM users u
  LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.id NOT IN (
  SELECT user_id FROM user_games
  UNION
  SELECT user_id FROM reviews
);

--
-- Level 8 — Final bosses
--

-- B24. Most-played game per country
-- For each country of the players: the game with the highest total hours played by the players of this country.
-- Columns: country, game_title, total_hours

-- Total d'heures par pays et par jeu

SELECT
  u.country,
  ug.game_id,
  SUM(ug.hours_played) total_hours
FROM users u
  JOIN user_games ug ON ug.user_id = u.id
GROUP BY u.country, ug.game_id;

-- Assemblage (CTE) : un total est le plus élevé s'il est >= à TOUS les totaux du même pays

WITH country_games AS (
  SELECT
    u.country,
    ug.game_id,
    SUM(ug.hours_played) total_hours
  FROM users u
    JOIN user_games ug ON ug.user_id = u.id
  GROUP BY u.country, ug.game_id
)
SELECT
  cg.country,
  g.title game_title,
  cg.total_hours
FROM country_games cg
  JOIN games g ON g.id = cg.game_id
WHERE cg.total_hours >= ALL (
  SELECT cg2.total_hours
  FROM country_games cg2
  WHERE cg2.country = cg.country
)
ORDER BY cg.total_hours DESC;

-- B25. FromSoftware completionists
-- Users who own every game published by FromSoftware. No hard-coded number of games, no hard-coded id.
-- Columns: username, country

-- Version 1 : comparer les comptages
-- Nombre de jeux FromSoftware possédés = nombre total de jeux FromSoftware

SELECT
  u.username,
  u.country
FROM users u
  JOIN user_games ug ON ug.user_id = u.id
  JOIN games g ON g.id = ug.game_id
  JOIN publishers p ON p.id = g.publisher_id
WHERE p.name = 'FromSoftware'
GROUP BY u.id
HAVING COUNT(*) = (
  SELECT COUNT(g2.id)
  FROM games g2
    JOIN publishers p2 ON p2.id = g2.publisher_id
  WHERE p2.name = 'FromSoftware'
);

-- Version 2 : double NOT EXISTS
-- "Possède tous les jeux FromSoftware" = "il n'existe aucun jeu FromSoftware qu'il ne possède pas"

SELECT
  u.username,
  u.country
FROM users u
WHERE NOT EXISTS (
  SELECT 1
  FROM games g
    JOIN publishers p ON p.id = g.publisher_id
  WHERE p.name = 'FromSoftware'
    AND NOT EXISTS (
      SELECT 1
      FROM user_games ug
      WHERE ug.user_id = u.id
        AND ug.game_id = g.id
    )
);

--
-- Level 9 — Find the bug
--

-- B26.a — Profiles without bio (returns nothing)

-- Toute comparaison avec NULL (=, <>, <, ...) donne NULL (inconnu), jamais vrai
-- → aucune ligne ne passe le WHERE → il faut IS NULL

SELECT *
FROM profiles
WHERE bio = NULL;

SELECT *
FROM profiles
WHERE bio IS NULL;

-- B26.b — Dark Souls (returns nothing)

-- LIKE est sensible à la casse : 'dark%' ne correspond pas à 'Dark Souls 3'
-- → ILIKE (insensible à la casse, spécifique PostgreSQL) ou respecter la casse

SELECT title
FROM games
WHERE title LIKE 'dark%';

SELECT title
FROM games
WHERE title ILIKE 'dark%';

-- B26.c — Belgian or French users with a username longer than 4 characters

-- AND est prioritaire sur OR
-- → la requête lit : country = 'Belgium' OR (country = 'France' AND LENGTH(username) > 4)
-- → tous les Belges passent, même Lina et Nina → parenthèses (ou IN)

SELECT username, country
FROM users
WHERE country = 'Belgium' OR country = 'France' AND LENGTH(username) > 4;

SELECT username, country
FROM users
WHERE (country = 'Belgium' OR country = 'France') AND LENGTH(username) > 4;

SELECT username, country
FROM users
WHERE country IN ('Belgium', 'France') AND LENGTH(username) > 4;

-- B26.d — Days played per user

-- SUM d'entiers / 24 → division entière : 1540 / 24 = 64 (et non 64.17)
-- → le ROUND arrive trop tard : la partie décimale est déjà perdue → 24.0 ou cast

SELECT user_id, ROUND(SUM(hours_played) / 24, 1) AS days_played
FROM user_games
GROUP BY user_id;

SELECT user_id, ROUND(SUM(hours_played) / 24.0, 1) AS days_played
FROM user_games
GROUP BY user_id;

-- B26.e — Countries with more than 1 user

-- Erreur : fonction d'agrégation interdite dans le WHERE
-- → le WHERE filtre les lignes AVANT le regroupement : COUNT n'existe pas encore → HAVING

SELECT country, COUNT(*)
FROM users
WHERE COUNT(*) > 1
GROUP BY country;

SELECT country, COUNT(*)
FROM users
GROUP BY country
HAVING COUNT(*) > 1;

-- B26.f — Games with an average rating of 4.5 or more

-- Erreur : la colonne "avg_rating" n'existe pas
-- → le HAVING est évalué AVANT le SELECT : l'alias n'est pas encore connu
-- → répéter l'expression (l'alias reste utilisable dans le GROUP BY et l'ORDER BY en PostgreSQL)

SELECT game_id, AVG(rating) AS avg_rating
FROM reviews
GROUP BY game_id
HAVING avg_rating >= 4.5;

SELECT game_id, AVG(rating) AS avg_rating
FROM reviews
GROUP BY game_id
HAVING AVG(rating) >= 4.5;

-- B26.g — Profiles without bio (returns 0)

-- COUNT(colonne) ne compte que les valeurs NON NULL
-- → après le WHERE, bio vaut toujours NULL → 0 → COUNT(*) compte les lignes

SELECT COUNT(bio) AS profiles_without_bio
FROM profiles
WHERE bio IS NULL;

SELECT COUNT(*) AS profiles_without_bio
FROM profiles
WHERE bio IS NULL;

-- B26.h — Publishers and their recent games

-- Le LEFT JOIN garde les éditeurs sans jeu récent avec g.release_date = NULL
-- → le WHERE élimine ensuite ces lignes (NULL >= '2020-01-01' n'est pas vrai)
-- → le LEFT JOIN se comporte comme un INNER JOIN → condition dans le ON

SELECT p.name, g.title
FROM publishers p
  LEFT JOIN games g ON g.publisher_id = p.id
WHERE g.release_date >= '2020-01-01';

SELECT p.name, g.title
FROM publishers p
  LEFT JOIN games g ON g.publisher_id = p.id AND g.release_date >= '2020-01-01';

-- B26.i — Number of games per publisher

-- COUNT(*) compte les lignes : Ubisoft a une ligne (avec g.* à NULL) grâce au LEFT JOIN
-- → COUNT(g.id) ignore les NULL → 0

SELECT p.name, COUNT(*) AS total_games
FROM publishers p
  LEFT JOIN games g ON g.publisher_id = p.id
GROUP BY p.id, p.name;

SELECT p.name, COUNT(g.id) AS total_games
FROM publishers p
  LEFT JOIN games g ON g.publisher_id = p.id
GROUP BY p.id, p.name;

-- B26.j — Total hours per publisher

-- La jointure avec reviews multiplie les lignes :
-- chaque achat d'un jeu est répété autant de fois que le jeu a d'avis
-- → League of Legends : 6 achats x 3 avis → les heures sont comptées 3 fois
-- → et Valorant (aucun avis) disparaît du total à cause du JOIN
-- → reviews n'est pas utile ici : on retire la jointure

SELECT p.name, SUM(ug.hours_played) AS total_hours
FROM publishers p
  JOIN games g ON g.publisher_id = p.id
  JOIN user_games ug ON ug.game_id = g.id
  JOIN reviews r ON r.game_id = g.id
GROUP BY p.id, p.name;

SELECT p.name, SUM(ug.hours_played) AS total_hours
FROM publishers p
  JOIN games g ON g.publisher_id = p.id
  JOIN user_games ug ON ug.game_id = g.id
GROUP BY p.id, p.name;

-- B26.k — Games from American publishers

-- Erreur : la sous-requête renvoie plusieurs lignes (plusieurs éditeurs américains)
-- → "=" attend une seule valeur → IN pour une liste

SELECT title
FROM games
WHERE publisher_id = (SELECT id FROM publishers WHERE country = 'USA');

SELECT title
FROM games
WHERE publisher_id IN (SELECT id FROM publishers WHERE country = 'USA');

-- B26.l — Games with their publisher

-- Erreur : la colonne "id" est ambiguë (elle existe dans games ET dans publishers)
-- → alias de table + colonnes qualifiées

SELECT id, title, name
FROM games
  JOIN publishers ON publisher_id = id;

SELECT g.id, g.title, p.name
FROM games g
  JOIN publishers p ON g.publisher_id = p.id;