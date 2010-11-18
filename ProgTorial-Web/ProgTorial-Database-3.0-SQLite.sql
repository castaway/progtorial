-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Nov 18 22:16:07 2010
-- 

BEGIN TRANSACTION;

--
-- Table: settings
--
DROP TABLE settings;

CREATE TABLE settings (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL
);

--
-- Table: tutorials
--
DROP TABLE tutorials;

CREATE TABLE tutorials (
  tutorial varchar(50) NOT NULL,
  PRIMARY KEY (tutorial)
);

--
-- Table: users
--
DROP TABLE users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  username varchar(50) NOT NULL,
  password varchar(50) NOT NULL,
  displayname varchar(25) NOT NULL,
  email varchar(50)
);

--
-- Table: exercises
--
DROP TABLE exercises;

CREATE TABLE exercises (
  exercise varchar(50) NOT NULL,
  tutorial varchar(50) NOT NULL,
  PRIMARY KEY (exercise, tutorial)
);

CREATE INDEX exercises_idx_tutorial ON exercises (tutorial);

--
-- Table: user_settings
--
DROP TABLE user_settings;

CREATE TABLE user_settings (
  user_id integer NOT NULL,
  setting_id integer NOT NULL,
  value boolean NOT NULL,
  PRIMARY KEY (user_id, setting_id)
);

CREATE INDEX user_settings_idx_setting_id ON user_settings (setting_id);

CREATE INDEX user_settings_idx_user_id ON user_settings (user_id);

--
-- Table: bookmarks
--
DROP TABLE bookmarks;

CREATE TABLE bookmarks (
  user_id integer NOT NULL,
  occurred_on datetuime NOT NULL,
  tutorial varchar(50) NOT NULL,
  chapter varchar(50) NOT NULL,
  exercise varchar(50) NOT NULL,
  PRIMARY KEY (user_id, tutorial, exercise)
);

CREATE INDEX bookmarks_idx_exercise_exercise ON bookmarks (exercise);

CREATE INDEX bookmarks_idx_tutorial ON bookmarks (tutorial);

CREATE INDEX bookmarks_idx_user_id ON bookmarks (user_id);

--
-- Table: solutions
--
DROP TABLE solutions;

CREATE TABLE solutions (
  user_id integer NOT NULL,
  occurred_on datetime NOT NULL,
  tutorial varchar(50) NOT NULL,
  exercise varchar(50) NOT NULL,
  attempt integer NOT NULL,
  results varchar(2048) NOT NULL,
  status varchar(15) NOT NULL,
  PRIMARY KEY (user_id, tutorial, exercise, attempt)
);

CREATE INDEX solutions_idx_exercise_exercise ON solutions (exercise);

CREATE INDEX solutions_idx_tutorial ON solutions (tutorial);

CREATE INDEX solutions_idx_user_id ON solutions (user_id);

COMMIT;

