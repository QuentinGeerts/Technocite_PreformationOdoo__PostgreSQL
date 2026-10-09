--
-- Création de la base de données
-- On se connecte d'abord à la base système "postgres" :
-- → impossible de supprimer la base à laquelle on est connecté
-- WITH (FORCE) ferme les connexions encore ouvertes sur la base
-- \c est une commande psql (équivalent du USE de SQL Server)
--

\c postgres

DROP DATABASE IF EXISTS pfo_games WITH (FORCE);
CREATE DATABASE pfo_games;