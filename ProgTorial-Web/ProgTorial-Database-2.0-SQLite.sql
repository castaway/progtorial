-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Wed Nov 10 21:05:42 2010
-- 

BEGIN TRANSACTION;

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
-- Table: bookmarks
--
DROP TABLE bookmarks;

CREATE TABLE bookmarks (
  user_id integer NOT NULL,
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
  tutorial varchar(50) NOT NULL,
  exercise varchar(50) NOT NULL,
  attempt integer NOT NULL,
  results varchar(2048) NOT NULL,
  PRIMARY KEY (user_id, tutorial, exercise, attempt)
);

CREATE INDEX solutions_idx_exercise_exercise ON solutions (exercise);

CREATE INDEX solutions_idx_tutorial ON solutions (tutorial);

CREATE INDEX solutions_idx_user_id ON solutions (user_id);

COMMIT;

