-- 
-- Created by SQL::Translator::Producer::SQLServer
-- Created on Sat Dec 18 16:18:13 2010
-- 

--
-- Drop tables
--

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'solutions' AND type = 'U') DROP TABLE solutions;

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'bookmarks' AND type = 'U') DROP TABLE bookmarks;

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'user_settings' AND type = 'U') DROP TABLE user_settings;

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'exercises' AND type = 'U') DROP TABLE exercises;

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'dummy' AND type = 'U') DROP TABLE dummy;

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'users' AND type = 'U') DROP TABLE users;

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'tutorials' AND type = 'U') DROP TABLE tutorials;

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'settings' AND type = 'U') DROP TABLE settings;



--
-- Table: settings
--

CREATE TABLE settings (
  id integer NOT NULL,
  name varchar(50) NOT NULL,
  CONSTRAINT settings_pk PRIMARY KEY (id)
);

--
-- Table: tutorials
--

CREATE TABLE tutorials (
  tutorial varchar(50) NOT NULL,
  CONSTRAINT tutorials_pk PRIMARY KEY (tutorial)
);

--
-- Table: users
--

CREATE TABLE users (
  id integer IDENTITY NOT NULL,
  username varchar(50) NOT NULL,
  password varchar(50) NOT NULL,
  displayname varchar(25) NOT NULL,
  email varchar(50) NULL,
  CONSTRAINT users_pk PRIMARY KEY (id)
);

--
-- Table: dummy
--

CREATE TABLE dummy (
  user_id integer NOT NULL,
  occurred_on datetime NOT NULL,
  status varchar(2048) NOT NULL,
  CONSTRAINT dummy_pk PRIMARY KEY (user_id, occurred_on, status)
);

CREATE INDEX dummy_idx_user_id ON dummy (user_id);

--
-- Table: exercises
--

CREATE TABLE exercises (
  exercise varchar(50) NOT NULL,
  tutorial varchar(50) NOT NULL,
  CONSTRAINT exercises_pk PRIMARY KEY (exercise, tutorial)
);

CREATE INDEX exercises_idx_tutorial ON exercises (tutorial);

--
-- Table: user_settings
--

CREATE TABLE user_settings (
  user_id integer NOT NULL,
  setting_id integer NOT NULL,
  value boolean NOT NULL,
  CONSTRAINT user_settings_pk PRIMARY KEY (user_id, setting_id)
);

CREATE INDEX user_settings_idx_setting_id ON user_settings (setting_id);

CREATE INDEX user_settings_idx_user_id ON user_settings (user_id);

--
-- Table: bookmarks
--

CREATE TABLE bookmarks (
  user_id integer NOT NULL,
  occurred_on datetuime NOT NULL,
  tutorial varchar(50) NOT NULL,
  chapter varchar(50) NOT NULL,
  exercise varchar(50) NOT NULL,
  CONSTRAINT bookmarks_pk PRIMARY KEY (user_id, tutorial, exercise)
);

CREATE INDEX bookmarks_idx_exercise_exercise ON bookmarks (exercise);

CREATE INDEX bookmarks_idx_tutorial ON bookmarks (tutorial);

CREATE INDEX bookmarks_idx_user_id ON bookmarks (user_id);

--
-- Table: solutions
--

CREATE TABLE solutions (
  user_id integer NOT NULL,
  occurred_on datetime NOT NULL,
  tutorial varchar(50) NOT NULL,
  exercise varchar(50) NOT NULL,
  attempt integer NOT NULL,
  results varchar(2048) NOT NULL,
  status varchar(15) NOT NULL,
  CONSTRAINT solutions_pk PRIMARY KEY (user_id, tutorial, exercise, attempt)
);

CREATE INDEX solutions_idx_exercise_exercise ON solutions (exercise);

CREATE INDEX solutions_idx_tutorial ON solutions (tutorial);

CREATE INDEX solutions_idx_user_id ON solutions (user_id);
ALTER TABLE dummy ADD CONSTRAINT dummy_fk_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE exercises ADD CONSTRAINT exercises_fk_tutorial FOREIGN KEY (tutorial) REFERENCES tutorials (tutorial) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE user_settings ADD CONSTRAINT user_settings_fk_setting_id FOREIGN KEY (setting_id) REFERENCES settings (id);
ALTER TABLE user_settings ADD CONSTRAINT user_settings_fk_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE bookmarks ADD CONSTRAINT bookmarks_fk_exercise_exercise FOREIGN KEY (exercise) REFERENCES exercises (exercise, tutorial);
ALTER TABLE bookmarks ADD CONSTRAINT bookmarks_fk_tutorial FOREIGN KEY (tutorial) REFERENCES tutorials (tutorial);
ALTER TABLE bookmarks ADD CONSTRAINT bookmarks_fk_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE solutions ADD CONSTRAINT solutions_fk_exercise_exercise FOREIGN KEY (exercise) REFERENCES exercises (exercise, tutorial);
ALTER TABLE solutions ADD CONSTRAINT solutions_fk_tutorial FOREIGN KEY (tutorial) REFERENCES tutorials (tutorial);
ALTER TABLE solutions ADD CONSTRAINT solutions_fk_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE;
