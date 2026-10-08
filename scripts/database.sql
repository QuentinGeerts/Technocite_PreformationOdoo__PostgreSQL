
-- Suppression des tables (<!> à l'ordre inversé de création)
DROP TABLE IF EXISTS subscriptions, sessions, users;

-- Création des tables (<!> ordre des dépendances)

CREATE TABLE subscriptions (
  subscription_id SERIAL,
  name VARCHAR(50) NOT NULL,
  price MONEY NOT NULL,

  CONSTRAINT pk_subscriptions PRIMARY KEY (subscription_id),
  CONSTRAINT ck_price_positive CHECK (price >= 0::MONEY)
);

CREATE TABLE sessions (
  session_id INT GENERATED ALWAYS AS IDENTITY,
  title VARCHAR(50) NOT NULL,
  description TEXT,
  session_date TIMESTAMP NOT NULL,

  CONSTRAINT pk_sessions PRIMARY KEY (session_id)
);

CREATE TABLE users (
  user_id UUID DEFAULT uuidv4(),
  username VARCHAR(50) NOT NULL,
  email VARCHAR(320) NOT NULL,
  password VARCHAR(256) NOT NULL,
  is_valid BOOLEAN NOT NULL DEFAULT false,
  duration SMALLINT,
  subscribed_at DATE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  subscription_id INT,

  CONSTRAINT pk_users PRIMARY KEY (user_id),
  CONSTRAINT uk_username UNIQUE (username),
  CONSTRAINT uk_email UNIQUE (email),
  CONSTRAINT ck_duration_enum CHECK (duration IN (1, 3, 6, 12)),
  CONSTRAINT fk_users_subscriptions FOREIGN KEY (subscription_id)
    REFERENCES subscriptions (subscription_id)
      ON DELETE SET NULL ON UPDATE CASCADE
);

-- Peupler la DB

INSERT INTO subscriptions (name, price)
VALUES 
  ('Basic', '29.99'),
  ('Gold', '49.99'),
  ('Ultimate', '99.99');
