
-- Suppression des tables (<!> à l'ordre inversé de création)
-- DROP TABLE IF EXISTS registers;
-- DROP TABLE IF EXISTS users;
-- DROP TABLE IF EXISTS sessions;
-- DROP TABLE IF EXISTS subscriptions;

DROP TABLE IF EXISTS subscriptions, sessions, users, registers, profiles;

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

CREATE TABLE registers (
  note NUMERIC(2,1),

  user_id UUID NOT NULL,
  session_id INT NOT NULL,

  CONSTRAINT pk_registers PRIMARY KEY (user_id, session_id),
  CONSTRAINT fk_registers_users FOREIGN KEY (user_id)
    REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_registers_sessions FOREIGN KEY (session_id)
    REFERENCES sessions (session_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_note_between_0_and_5 CHECK (note BETWEEN 0 AND 5)
);

CREATE TABLE profiles (
  profile_id SERIAL,
  lastname VARCHAR(50) NOT NULL,
  firstname VARCHAR(50) NOT NULL,
  birthdate DATE NOT NULL,
  size SMALLINT,
  weight NUMERIC(5,2),

  user_id UUID NOT NULL,

  CONSTRAINT pk_profiles PRIMARY KEY (profile_id),
  CONSTRAINT ck_birthdate_before_today CHECK (EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) >= 14),
  CONSTRAINT ck_size_positive CHECK (size >= 0),
  CONSTRAINT ck_weight_positive CHECK (weight >= 0)
);

-- Ajouter la contrainte de clef étrangère sur "profiles" vers "users"

ALTER TABLE profiles
ADD CONSTRAINT fk_profiles_users FOREIGN KEY (user_id) 
  REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE;

-- ALTER TABLE profiles
-- DROP COLUMN user_id;

-- Peupler la DB

INSERT INTO subscriptions (name, price)
VALUES 
  ('Basic', '29.99'),
  ('Gold', '49.99'),
  ('Ultimate', '99.99');


INSERT INTO users (username, email, password)
VALUES 
  ('QuentinGeerts', 'quentin.geerts@bstorm.be', 'Test1234=');


INSERT INTO profiles (lastname, firstname, birthdate, size, weight, user_id)
VALUES
  (
    'Geerts',
    'Quentin',
    '1996-04-03',
    180,
    95.6,
    (SELECT user_id FROM users WHERE username = 'QuentinGeerts')
  );

SELECT * FROM profiles;