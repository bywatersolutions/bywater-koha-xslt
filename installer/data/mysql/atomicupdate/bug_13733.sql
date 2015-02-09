CREATE TABLE IF NOT EXISTS `item_messages` (
            `item_message_id` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY,
            `itemnumber` INT( 11 ) NOT NULL,
            `type` VARCHAR( 80 ) NULL, -- ITEM_MESSAGE authorised value
            `message` TEXT NOT NULL,
            `created_on` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX (  `itemnumber` )
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
