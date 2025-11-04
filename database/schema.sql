-- ============================================================================ --
--                                                                              --
--                                 FILE HEADER                                  --
-- ---------------------------------------------------------------------------- --
--  File:       schema.sql                                                      --
--  Author:     dlesieur                                                        --
--  Email:      dlesieur@student.42.fr                                          --
--  Created:    2025/11/03 20:28:45                                             --
--  Updated:    2025/11/03 20:28:45                                             --
--                                                                              --
-- ============================================================================ --

-- [https://dev.mysql.com/doc/refman/8.4/en/blob.html] 
-- [https://www.digitalocean.com/community/tutorials/how-to-use-the-mysql-blob-data-type-to-store-images-with-php-on-ubuntu-18-04-fr]

DROP TABLE IF EXISTS has_param, participates, uses, manages, owns, submits;
DROP TABLE IF EXISTS review, carpool, car, brand, configuration, parameter;
DROP TABLE IF EXISTS role, user;

CREATE TABLE user
(
	user_id		INT AUTO_INCREMENT PRIMARY KEY,
	last_name	VARCHAR(50),
	first_name	VARCHAR(50),
	email		VARCHAR(50),
	password	VARCHAR(50),
	phone		VARCHAR(50),
	address		VARCHAR(100),
	birth_date	VARCHAR(50),
	photo		BLOB,
	username	VARCHAR(50)
);

CREATE TABLE role
(
	role_id	INT AUTO_INCREMENT PRIMARY KEY,
	label	VARCHAR(50)
);

CREATE TABLE owns
(
	user_id		INT,
	role_id		INT,
	PRIMARY KEY	(user_id, role_id),
	FOREIGN KEY	(user_id) REFERENCES user(user_id) ON DELETE CASCADE,
	FOREIGN KEY	(role_id) REFERENCES role(role_id) ON DELETE CASCADE
);

CREATE TABLE review
(
	review_id	INT AUTO_INCREMENT PRIMARY KEY,
	comment		VARCHAR(255),
	rating		VARCHAR(50),
	status		VARCHAR(50)
);

CREATE TABLE submits
(
	user_id		INT,
	review_id	INT,
	PRIMARY KEY	(user_id, review_id),
	FOREIGN KEY	(user_id) REFERENCES user(user_id) ON DELETE CASCADE,
	FOREIGN KEY	(review_id) REFERENCES review(review_id) ON DELETE CASCADE
);

CREATE TABLE brand
(
	brand_id	INT AUTO_INCREMENT PRIMARY KEY,
	label		VARCHAR(50)
);

CREATE TABLE car
(
	car_id					INT AUTO_INCREMENT PRIMARY KEY,
	model					VARCHAR(50),
	license_plate			VARCHAR(50),
	energy					VARCHAR(50),
	color					VARCHAR(50),
	first_registration_date	VARCHAR(50),
	brand_id				INT,
	FOREIGN KEY (brand_id) REFERENCES brand(brand_id) ON DELETE SET NULL
);

CREATE TABLE carpool
(
	carpool_id			INT AUTO_INCREMENT PRIMARY KEY,
	departure_date		DATE,
	departure_time		TIME,
	departure_place		VARCHAR(100),
	arrival_date		DATE,
	arrival_time		TIME,
	arrival_place		VARCHAR(100),
	status				VARCHAR(50),
	seats_available		INT,
	price_per_person	FLOAT
);

CREATE TABLE manages
(
	user_id		INT,
	car_id		INT,
	PRIMARY KEY	(user_id, car_id),
	FOREIGN KEY	(user_id) REFERENCES user(user_id) ON DELETE CASCADE,
	FOREIGN KEY	(car_id) REFERENCES car(car_id) ON DELETE CASCADE
);

CREATE TABLE uses
(
	carpool_id	INT,
	car_id		INT,
	PRIMARY KEY	(carpool_id, car_id),
	FOREIGN KEY	(carpool_id) REFERENCES carpool(carpool_id) ON DELETE CASCADE,
	FOREIGN KEY	(car_id) REFERENCES car(car_id) ON DELETE CASCADE
);

CREATE TABLE participates
(
	user_id		INT,
	carpool_id	INT,
	PRIMARY KEY	(user_id, carpool_id),
	FOREIGN KEY	(user_id) REFERENCES user(user_id) ON DELETE CASCADE,
	FOREIGN KEY	(carpool_id) REFERENCES carpool(carpool_id) ON DELETE CASCADE
);

CREATE TABLE configuration
(
	config_id INT	AUTO_INCREMENT PRIMARY KEY
);

CREATE TABLE parameter
(
	parameter_id	INT AUTO_INCREMENT PRIMARY KEY,
	property		VARCHAR(50),
	value			VARCHAR(50)
);

CREATE TABLE has_param
(
	config_id		INT,
	parameter_id	INT,
	PRIMARY KEY		(config_id, parameter_id),
	FOREIGN KEY		(config_id) REFERENCES configuration(config_id) ON DELETE CASCADE,
	FOREIGN KEY		(parameter_id) REFERENCES parameter(parameter_id) ON DELETE CASCADE
);