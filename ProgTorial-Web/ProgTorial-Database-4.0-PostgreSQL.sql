-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Mon Jan  3 11:33:32 2011
-- 
--
-- Table: dummy
--
DROP TABLE "dummy" CASCADE;
CREATE TABLE "dummy" (
  "user_id" integer NOT NULL,
  "occurred_on" timestamp NOT NULL,
  "status" character varying(2048) NOT NULL,
  PRIMARY KEY ("user_id", "occurred_on", "status")
);
CREATE INDEX "dummy_idx_user_id" on "dummy" ("user_id");

--
-- Table: settings
--
DROP TABLE "settings" CASCADE;
CREATE TABLE "settings" (
  "id" integer NOT NULL,
  "name" character varying(50) NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: openids
--
DROP TABLE "openids" CASCADE;
CREATE TABLE "openids" (
  "user_id" integer,
  "url" character varying(1024) NOT NULL,
  PRIMARY KEY ("url")
);

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
  "password" character varying(50),
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
-- Table: user_settings
--
DROP TABLE "user_settings" CASCADE;
CREATE TABLE "user_settings" (
  "user_id" integer NOT NULL,
  "setting_id" integer NOT NULL,
  "value" boolean NOT NULL,
  PRIMARY KEY ("user_id", "setting_id")
);
CREATE INDEX "user_settings_idx_setting_id" on "user_settings" ("setting_id");
CREATE INDEX "user_settings_idx_user_id" on "user_settings" ("user_id");

--
-- Table: bookmarks
--
DROP TABLE "bookmarks" CASCADE;
CREATE TABLE "bookmarks" (
  "user_id" integer NOT NULL,
  "occurred_on" datetuime NOT NULL,
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
  "occurred_on" timestamp NOT NULL,
  "tutorial" character varying(50) NOT NULL,
  "exercise" character varying(50) NOT NULL,
  "attempt" integer NOT NULL,
  "results" character varying(2048) NOT NULL,
  "status" character varying(15) NOT NULL,
  PRIMARY KEY ("user_id", "tutorial", "exercise", "attempt")
);
CREATE INDEX "solutions_idx_exercise_exercise" on "solutions" ("exercise");
CREATE INDEX "solutions_idx_tutorial" on "solutions" ("tutorial");
CREATE INDEX "solutions_idx_user_id" on "solutions" ("user_id");

--
-- Foreign Key Definitions
--

ALTER TABLE "dummy" ADD FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") DEFERRABLE;

ALTER TABLE "exercises" ADD FOREIGN KEY ("tutorial")
  REFERENCES "tutorials" ("tutorial") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "user_settings" ADD FOREIGN KEY ("setting_id")
  REFERENCES "settings" ("id") DEFERRABLE;

ALTER TABLE "user_settings" ADD FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

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


