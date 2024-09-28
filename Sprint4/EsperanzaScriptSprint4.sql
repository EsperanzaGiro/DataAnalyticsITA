# En primer lugar analizo los csv, creo la base de datos:

DROP DATABASE IF EXISTS sprint4;
CREATE DATABASE IF NOT EXISTS sprint4;

# A continuación, creo las 7 tablas:
DROP TABLE IF EXISTS companies;
CREATE TABLE companies (
    company_id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(150),
    country VARCHAR(100),
    website VARCHAR(200)
);

DROP TABLE IF EXISTS product;
CREATE TABLE product (
	id INT PRIMARY KEY,
	product_name VARCHAR(200),
	price DECIMAL(10,2),
	colour CHAR(7),
	weight INT,
	warehouse_id VARCHAR(10)
);

DROP TABLE IF EXISTS credit_cards;
CREATE TABLE credit_cards (
    id VARCHAR(20) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(34),
    pan VARCHAR(16),
    pin INT,
    cvv INT,
    track1 VARCHAR(200),
    track2 VARCHAR(200),
    expiring_date DATE
);

DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
    id CHAR(36) PRIMARY KEY,
    card_id VARCHAR(20),
    business_id VARCHAR(20),
    timestamp DATETIME,
    amount DECIMAL(10, 2),
    declined BOOLEAN,
    product_ids VARCHAR(200),
    user_id INT,
    lat VARCHAR(15),
    longitude VARCHAR(15)
);

DROP TABLE IF EXISTS users_uk;
CREATE TABLE users_uk (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    address VARCHAR(200)
);

DROP TABLE IF EXISTS users_usa;
CREATE TABLE users_usa (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    address VARCHAR(200)
);

DROP TABLE IF EXISTS users_ca;
CREATE TABLE users_ca (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    address VARCHAR(200)
);

# Tras intentar cargar los datos con el comando LOAD DATA, aparece el error 1260 y realizo
# una serie de cambios para que permita la carga:

	SET GLOBAL local_infile = 1;
	SHOW GLOBAL VARIABLES LIKE 'local_infile';  # verifica que realmente aparece activado 'ON'
	SHOW GLOBAL VARIABLES LIKE 'secure_file_priv'; # muestra si existe una carpeta por defecto para la carga y la ruta.
	SHOW GLOBAL VARIABLES LIKE 'datadir';

		/* al margen de estas actuaciones locales de arriba, he accedido al fichero my.ini de mi equipo
		para modificarlo de forma que permita cargar de forma local y no exija un a ubicación concreto. 
		Este último punto no me acaba de gustar por temas de seguridad en accesos y posibles manipulaciones
		de tercerosa los ficheros. Estos son los cambios que he realizado en 'my.ini'(copio fragmento del fichero):

			[mysqld]

			# Añadido local_infile para permitir LOAD DATA LOCAL INFILE.
			# Fecha de cambio: 2024-09-25 por Espe
			local_infile=1

			# Cambiado secure_file_priv a '' para permitir LOAD DATA INFILE desde cualquier ubicación. 
			# Fecha de cambio: YYYY-MM-DD
			# Motivo: Para permitir la carga de archivos CSV sin restricciones de directorio.
			secure_file_priv=''
			
            También me he asegurado de que configurar en propiedades, los permisos de lectura y escritura en la carpeta Mysql 
            y de reiniciar el servicio del servidor mysql
            */
# Carga de datos desde el fichero:
TRUNCATE TABLE companies;
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
SELECT * FROM companies;

TRUNCATE TABLE product;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product.csv'
INTO TABLE product
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'           
LINES TERMINATED BY '\n'  
IGNORE 1 LINES;
SELECT * FROM product;

TRUNCATE TABLE credit_cards;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'           
LINES TERMINATED BY '\n'  
IGNORE 1 LINES;
SELECT * FROM credit_cards;

TRUNCATE TABLE transactions;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'           
LINES TERMINATED BY '\n'  
IGNORE 1 LINES;
SELECT * FROM transactions;

TRUNCATE TABLE users_uk;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
INTO TABLE users_uk
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'           
LINES TERMINATED BY '\n'  
IGNORE 1 LINES;
SELECT * FROM users_uk;

TRUNCATE TABLE users_usa;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'
INTO TABLE users_usa
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'           
LINES TERMINATED BY '\n'  
IGNORE 1 LINES;
SELECT * FROM users_usa;

TRUNCATE TABLE users_ca;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv'
INTO TABLE users_ca
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'           
LINES TERMINATED BY '\n'  
IGNORE 1 LINES;
SELECT * FROM users_ca;

/* ANÁLISIS DE LAS TABLAS Y ESQUEMA E-R

	Tabla de hechos: transactions:
		Contiene las FK que apuntarán a cada una de la PK de la tabla de dimension a la que pertenezca.
			1. credit_cards (FK card_id). Reación 1-N
			2. company (FK business_id). Relación 1-N
			3. product (FK product_ids). Relación N-N. Se creará tabla intermedia ProductTransaction
			4. users_uk, users_usa, users_ca (FK user_id) Normalización uniendo las 3 tablas en una sola .
			
	Tablas dimensiones:
		1.	credit_cards: tarjetas de crédito utilizadas en las transacciones. Cada transacción está asociada con una tarjeta.
        2.	company: empresas donde se hacen las transacciones.
		3.	product: productos incluidos en las transacciones.
        4.	users_xxx: usuarios de las transacciones. Hay 3 tablas, una tabla por cada zona (ca, uk, usa). 
			Estas tablas serían el resultado de aplicar filtros a una tabla general de 'users'. No obstante,
            dado que en el ejercicio no indica referirse a los sprints anteriores, la tabla 'users' la crearé anexando las 3 trablas
*/

# Unifico laS 3 tablas 'users_xxx' en 1 sólatabla 'users':            

# Primero creo la tabla 'users' para tener el contenedor:
	DROP TABLE IF EXISTS users;
	CREATE TABLE users 
	(
		id INT PRIMARY KEY,
		name VARCHAR(100),
		surname VARCHAR(100),
		phone VARCHAR(20),
		email VARCHAR(100),
		birth_date DATE,
		country VARCHAR(50),
		city VARCHAR(50),
		postal_code VARCHAR(10),
		address VARCHAR(200)
	);
    
DESCRIBRE user;

# Cargo los datos en 'users' desde cada una de las tablas de usuarios con INSERT INTO y UNION ALL:
	INSERT INTO users (id, name, surname, phone, email, birth_date, country, city, postal_code, address)
	SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address FROM users_uk
	UNION ALL
	SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address FROM users_usa
	UNION ALL
	SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address FROM users_ca;


# creo la tabla intermedia ProductTransaction:
	DROP TABLE IF EXISTS ProductTransaction
	CREATE TABLE ProductTransaction 
	(
		transaction_id CHAR(36), 
		product_id INT           
	);

# Defino las Foreigh Keys:
	# Foreign key entre transactions y credit_cards
	ALTER TABLE transactions ADD CONSTRAINT fk_transactions_credit_cards FOREIGN KEY (card_id) REFERENCES credit_cards(id);

	# Foreign key entre transactions y company
	ALTER TABLE transactions ADD CONSTRAINT fk_transactions_company FOREIGN KEY (business_id) REFERENCES company(company_id);

	# Foreign key entre transactions y users (unificada)
	ALTER TABLE transactions ADD CONSTRAINT fk_transactions_users FOREIGN KEY (user_id) REFERENCES users(id);	

	# Foreign key entre 'credit_cards' y 'users' (unificada)
	ALTER TABLE credit_cards ADD CONSTRAINT fk_credit_cards_users FOREIGN KEY (user_id) REFERENCES users(id);









