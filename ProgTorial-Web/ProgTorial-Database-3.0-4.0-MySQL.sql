-- Convert schema './ProgTorial-Database-3.0-MySQL.sql' to 'ProgTorial::Database v4.0':;

BEGIN;

SET foreign_key_checks=0;

CREATE TABLE `dummy` (
  user_id integer NOT NULL,
  occurred_on datetime NOT NULL,
  status text NOT NULL,
  INDEX dummy_idx_user_id (user_id),
  PRIMARY KEY (user_id, occurred_on, status),
  CONSTRAINT dummy_fk_user_id FOREIGN KEY (user_id) REFERENCES `users` (id)
) ENGINE=InnoDB;

CREATE TABLE `openids` (
  user_id integer,
  url text NOT NULL,
  PRIMARY KEY (url)
);

SET foreign_key_checks=1;

ALTER TABLE solutions CHANGE COLUMN results results text NOT NULL;

ALTER TABLE user_settings CHANGE COLUMN value value enum('0','1') NOT NULL;

ALTER TABLE users CHANGE COLUMN password password varchar(50);


COMMIT;


