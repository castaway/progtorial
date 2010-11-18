-- Convert schema './ProgTorial-Database-2.0-MySQL.sql' to 'ProgTorial::Database v3.0':;

BEGIN;

SET foreign_key_checks=0;

CREATE TABLE `settings` (
  id integer NOT NULL,
  name varchar(50) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE `user_settings` (
  user_id integer NOT NULL,
  setting_id integer NOT NULL,
  value enum('0','1') NOT NULL,
  INDEX user_settings_idx_setting_id (setting_id),
  INDEX user_settings_idx_user_id (user_id),
  PRIMARY KEY (user_id, setting_id),
  CONSTRAINT user_settings_fk_setting_id FOREIGN KEY (setting_id) REFERENCES `settings` (id),
  CONSTRAINT user_settings_fk_user_id FOREIGN KEY (user_id) REFERENCES `users` (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET foreign_key_checks=1;

ALTER TABLE solutions CHANGE COLUMN results results text NOT NULL;


COMMIT;


