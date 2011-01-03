-- Convert schema './ProgTorial-Database-3.0-SQLite.sql' to './ProgTorial-Database-4.0-SQLite.sql':;

BEGIN;

CREATE TABLE openids (
  user_id integer,
  url varchar(1024) NOT NULL,
  PRIMARY KEY (url)
);

CREATE TEMPORARY TABLE users_temp_alter (
  id INTEGER PRIMARY KEY NOT NULL,
  username varchar(50) NOT NULL,
  password varchar(50),
  displayname varchar(25) NOT NULL,
  email varchar(50)
);

INSERT INTO users_temp_alter SELECT id, username, password, displayname, email FROM users;

DROP TABLE users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  username varchar(50) NOT NULL,
  password varchar(50),
  displayname varchar(25) NOT NULL,
  email varchar(50)
);

INSERT INTO users SELECT id, username, password, displayname, email FROM users_temp_alter;

DROP TABLE users_temp_alter;


COMMIT;


