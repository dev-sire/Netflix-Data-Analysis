CREATE TABLE `netflix` (
    `show_id` VARCHAR(10) PRIMARY KEY,
    `type` VARCHAR(10) NULL,
    `title` TEXT NULL, 
    `director` TEXT NULL,
    `cast` TEXT NULL,
    `country` VARCHAR(150) NULL,
    `date_added` VARCHAR(20) NULL,
    `release_year` INT NULL,
    `rating` VARCHAR(10) NULL,
    `duration` VARCHAR(10) NULL,
    `listed_in` VARCHAR(100) NULL,
    `description` TEXT NULL
);