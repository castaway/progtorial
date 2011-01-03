-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Mon Jan  3 11:33:20 2011
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `openids`;

--
-- Table: `openids`
--
CREATE TABLE `openids` (
  `user_id` integer,
  `url` text NOT NULL,
  PRIMARY KEY (`url`)
);

DROP TABLE IF EXISTS `settings`;

--
-- Table: `settings`
--
CREATE TABLE `settings` (
  `id` integer NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `tutorials`;

--
-- Table: `tutorials`
--
CREATE TABLE `tutorials` (
  `tutorial` varchar(50) NOT NULL,
  PRIMARY KEY (`tutorial`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `users`;

--
-- Table: `users`
--
CREATE TABLE `users` (
  `id` integer NOT NULL auto_increment,
  `username` varchar(50) NOT NULL,
  `password` varchar(50),
  `displayname` varchar(25) NOT NULL,
  `email` varchar(50),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `dummy`;

--
-- Table: `dummy`
--
CREATE TABLE `dummy` (
  `user_id` integer NOT NULL,
  `occurred_on` datetime NOT NULL,
  `status` text NOT NULL,
  INDEX `dummy_idx_user_id` (`user_id`),
  PRIMARY KEY (`user_id`, `occurred_on`, `status`),
  CONSTRAINT `dummy_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `exercises`;

--
-- Table: `exercises`
--
CREATE TABLE `exercises` (
  `exercise` varchar(50) NOT NULL,
  `tutorial` varchar(50) NOT NULL,
  INDEX `exercises_idx_tutorial` (`tutorial`),
  PRIMARY KEY (`exercise`, `tutorial`),
  CONSTRAINT `exercises_fk_tutorial` FOREIGN KEY (`tutorial`) REFERENCES `tutorials` (`tutorial`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `user_settings`;

--
-- Table: `user_settings`
--
CREATE TABLE `user_settings` (
  `user_id` integer NOT NULL,
  `setting_id` integer NOT NULL,
  `value` enum('0','1') NOT NULL,
  INDEX `user_settings_idx_setting_id` (`setting_id`),
  INDEX `user_settings_idx_user_id` (`user_id`),
  PRIMARY KEY (`user_id`, `setting_id`),
  CONSTRAINT `user_settings_fk_setting_id` FOREIGN KEY (`setting_id`) REFERENCES `settings` (`id`),
  CONSTRAINT `user_settings_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `bookmarks`;

--
-- Table: `bookmarks`
--
CREATE TABLE `bookmarks` (
  `user_id` integer NOT NULL,
  `occurred_on` datetuime NOT NULL,
  `tutorial` varchar(50) NOT NULL,
  `chapter` varchar(50) NOT NULL,
  `exercise` varchar(50) NOT NULL,
  INDEX `bookmarks_idx_exercise_exercise` (`exercise`),
  INDEX `bookmarks_idx_tutorial` (`tutorial`),
  INDEX `bookmarks_idx_user_id` (`user_id`),
  PRIMARY KEY (`user_id`, `tutorial`, `exercise`),
  CONSTRAINT `bookmarks_fk_exercise_exercise` FOREIGN KEY (`exercise`) REFERENCES `exercises` (`exercise`, `tutorial`),
  CONSTRAINT `bookmarks_fk_tutorial` FOREIGN KEY (`tutorial`) REFERENCES `tutorials` (`tutorial`),
  CONSTRAINT `bookmarks_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `solutions`;

--
-- Table: `solutions`
--
CREATE TABLE `solutions` (
  `user_id` integer NOT NULL,
  `occurred_on` datetime NOT NULL,
  `tutorial` varchar(50) NOT NULL,
  `exercise` varchar(50) NOT NULL,
  `attempt` integer NOT NULL,
  `results` text NOT NULL,
  `status` varchar(15) NOT NULL,
  INDEX `solutions_idx_exercise_exercise` (`exercise`),
  INDEX `solutions_idx_tutorial` (`tutorial`),
  INDEX `solutions_idx_user_id` (`user_id`),
  PRIMARY KEY (`user_id`, `tutorial`, `exercise`, `attempt`),
  CONSTRAINT `solutions_fk_exercise_exercise` FOREIGN KEY (`exercise`) REFERENCES `exercises` (`exercise`, `tutorial`),
  CONSTRAINT `solutions_fk_tutorial` FOREIGN KEY (`tutorial`) REFERENCES `tutorials` (`tutorial`),
  CONSTRAINT `solutions_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET foreign_key_checks=1;


