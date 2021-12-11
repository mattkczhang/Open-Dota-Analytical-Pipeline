-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema game_stat
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema game_stat
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `game_stat` DEFAULT CHARACTER SET utf8 ;
USE `game_stat` ;

-- -----------------------------------------------------
-- Table `game_stat`.`dim_result`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `game_stat`.`dim_result` (
  `result_id` INT NOT NULL,
  `description` VARCHAR(20) NULL,
  `result_dimcol` VARCHAR(45) NULL,
  PRIMARY KEY (`result_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `game_stat`.`dim_barrack_status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `game_stat`.`dim_barrack_status` (
  `bit_mask` INT NOT NULL,
  `description` VARCHAR(40) NULL,
  PRIMARY KEY (`bit_mask`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `game_stat`.`dim_tower_status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `game_stat`.`dim_tower_status` (
  `bit_mask` INT NOT NULL,
  `description` VARCHAR(40) NULL,
  PRIMARY KEY (`bit_mask`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `game_stat`.`dim_match_date`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `game_stat`.`dim_match_date` (
  `date_id` INT NOT NULL,
  `match_date` TIMESTAMP NULL,
  PRIMARY KEY (`date_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `game_stat`.`fact_matches`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `game_stat`.`fact_matches` (
  `match_id` INT NOT NULL,
  `match_result_id` INT NOT NULL,
  `start_time_id` INT NOT NULL,
  `tower_status_radiant` INT NULL,
  `tower_status_dire` INT NULL,
  `barrack_status_radiant` INT NULL,
  `barrack_status_dire` INT NULL,
  `fire_blood_time` INT NULL,
  PRIMARY KEY (`match_id`),
  INDEX `result_fk_idx` (`match_result_id` ASC) VISIBLE,
  INDEX `radiant_barrack_fk_idx` (`tower_status_radiant` ASC, `tower_status_dire` ASC) VISIBLE,
  INDEX `date_fk_idx` (`start_time_id` ASC) VISIBLE,
  CONSTRAINT `result_fk`
    FOREIGN KEY (`match_result_id`)
    REFERENCES `game_stat`.`dim_result` (`result_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `barrack_fk`
    FOREIGN KEY (`tower_status_radiant` , `tower_status_dire`)
    REFERENCES `game_stat`.`dim_barrack_status` (`bit_mask` , `bit_mask`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `tower_fk`
    FOREIGN KEY (`tower_status_radiant` , `tower_status_dire`)
    REFERENCES `game_stat`.`dim_tower_status` (`bit_mask` , `bit_mask`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `date_fk`
    FOREIGN KEY (`start_time_id`)
    REFERENCES `game_stat`.`dim_match_date` (`date_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `game_stat`.`dim_performance`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `game_stat`.`dim_performance` (
  `performance_id` INT NOT NULL,
  `description` VARCHAR(45) NULL,
  PRIMARY KEY (`performance_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `game_stat`.`dim_hero`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `game_stat`.`dim_hero` (
  `hero_id` INT NOT NULL,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`hero_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `game_stat`.`fact_hero_performance`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `game_stat`.`fact_hero_performance` (
  `hero_id` INT NOT NULL,
  `performance_id` INT NULL,
  PRIMARY KEY (`hero_id`),
  INDEX `performance_fk_idx` (`performance_id` ASC),
  CONSTRAINT `performance_fk`
    FOREIGN KEY (`performance_id`)
    REFERENCES `game_stat`.`dim_performance` (`performance_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `hero_fk`
    FOREIGN KEY (`hero_id`)
    REFERENCES `game_stat`.`dim_hero` (`hero_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `game_stat`.`fact_all_chat`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `game_stat`.`fact_all_chat` (
  `match_id` INT NOT NULL,
  `start_time_id` INT NULL,
  `ingame_time` INT NULL,
  `chat_message` VARCHAR(60) NULL,
  PRIMARY KEY (`match_id`),
  CONSTRAINT `date_fk`
    FOREIGN KEY (`start_time_id`)
    REFERENCES `game_stat`.`dim_match_date` (`date_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
