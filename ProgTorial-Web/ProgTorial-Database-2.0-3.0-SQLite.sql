-- Convert schema './ProgTorial-Database-2.0-SQLite.sql' to './ProgTorial-Database-3.0-SQLite.sql':;

BEGIN;

CREATE TABLE settings (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL
);

CREATE TABLE user_settings (
  user_id integer NOT NULL,
  setting_id integer NOT NULL,
  value boolean NOT NULL,
  PRIMARY KEY (user_id, setting_id)
);

CREATE INDEX user_settings_idx_setting_id ON user_settings (setting_id);

CREATE INDEX user_settings_idx_user_id ON user_settings (user_id);


COMMIT;


