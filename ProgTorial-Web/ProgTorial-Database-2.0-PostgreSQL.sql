-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Wed Nov 10 21:05:42 2010
-- 
--
-- Table: tutorials
--
DROP TABLE "tutorials" CASCADE;
CREATE TABLE "tutorials" (
  "tutorial" character varying(50) NOT NULL,
  PRIMARY KEY ("tutorial")
);

--
-- Table: users
--
DROP TABLE "users" CASCADE;
CREATE TABLE "users" (
  "id" serial NOT NULL,
  "username" character varying(50) NOT NULL,
  "password" character varying(50) NOT NULL,
  "displayname" character varying(25) NOT NULL,
  "email" character varying(50),
  PRIMARY KEY ("id")
);

--
-- Table: exercises
--
DROP TABLE "exercises" CASCADE;
CREATE TABLE "exercises" (
  "exercise" character varying(50) NOT NULL,
  "tutorial" character varying(50) NOT NULL,
  PRIMARY KEY ("exercise", "tutorial")
);
CREATE INDEX "exercises_idx_tutorial" on "exercises" ("tutorial");

--
-- Table: bookmarks
--
DROP TABLE "bookmarks" CASCADE;
CREATE TABLE "bookmarks" (
  "user_id" integer NOT NULL,
  "tutorial" character varying(50) NOT NULL,
  "chapter" character varying(50) NOT NULL,
  "exercise" character varying(50) NOT NULL,
  PRIMARY KEY ("user_id", "tutorial", "exercise")
);
CREATE INDEX "bookmarks_idx_exercise_exercise" on "bookmarks" ("exercise");
CREATE INDEX "bookmarks_idx_tutorial" on "bookmarks" ("tutorial");
CREATE INDEX "bookmarks_idx_user_id" on "bookmarks" ("user_id");

--
-- Table: solutions
--
DROP TABLE "solutions" CASCADE;
CREATE TABLE "solutions" (
  "user_id" integer NOT NULL,
  "tutorial" character varying(50) NOT NULL,
  "exercise" character varying(50) NOT NULL,
  "attempt" integer NOT NULL,
  "results" character varying(2048) NOT NULL,
  PRIMARY KEY ("user_id", "tutorial", "exercise", "attempt")
);
CREATE INDEX "solutions_idx_exercise_exercise" on "solutions" ("exercise");
CREATE INDEX "solutions_idx_tutorial" on "solutions" ("tutorial");
CREATE INDEX "solutions_idx_user_id" on "solutions" ("user_id");

--
-- Foreign Key Definitions
--

ALTER TABLE "exercises" ADD FOREIGN KEY ("tutorial")
  REFERENCES "tutorials" ("tutorial") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "bookmarks" ADD FOREIGN KEY ("exercise")
  REFERENCES "exercises" ("exercise", "tutorial") DEFERRABLE;

ALTER TABLE "bookmarks" ADD FOREIGN KEY ("tutorial")
  REFERENCES "tutorials" ("tutorial") DEFERRABLE;

ALTER TABLE "bookmarks" ADD FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "solutions" ADD FOREIGN KEY ("exercise")
  REFERENCES "exercises" ("exercise", "tutorial") DEFERRABLE;

ALTER TABLE "solutions" ADD FOREIGN KEY ("tutorial")
  REFERENCES "tutorials" ("tutorial") DEFERRABLE;

ALTER TABLE "solutions" ADD FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;


