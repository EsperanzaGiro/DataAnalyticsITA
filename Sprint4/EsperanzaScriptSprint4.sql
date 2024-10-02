# En primer lugar analizo los csv, creo la base de datos:

DROP DATABASE IF EXISTS sprint4;
CREATE DATABASE IF NOT EXISTS sprint4;

# A continuación, creo las 6 de las 7 tablas. Transactions necesita que se creen antes users, credit_cards, companies
# para que no de error
DROP TABLE IF EXISTS companies;
CREATE TABLE companies 
(
    company_id VARCHAR(15) NOT NULL PRIMARY KEY,
    company_name VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(150),
    country VARCHAR(100),
    website VARCHAR(200)
);
DESCRIBE companies;

DROP TABLE IF EXISTS product;
CREATE TABLE product 
(
	id INT NOT NULL PRIMARY KEY,
	product_name VARCHAR(200),
	price DECIMAL(10, 2), #  Haré CAST en el UPLOAD. En el CSV es un VARCHAR por el símbolo $
	colour CHAR(7),
	weight INT,
	warehouse_id VARCHAR(10)
);
DESCRIBE product;

DROP TABLE IF EXISTS users_uk;
CREATE TABLE users_uk 
(
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    address VARCHAR(200)
);
DESCRIBE users_uk;

DROP TABLE IF EXISTS users_usa;
CREATE TABLE users_usa 
(
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    address VARCHAR(200)
);
DESCRIBE users_usa;

DROP TABLE IF EXISTS users_ca;
CREATE TABLE users_ca 
(
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    address VARCHAR(200)
);
DESCRIBE users_ca;

# Tras intentar cargar los datos con el comando LOAD DATA, aparece el error 1260 y realizo
# una serie de cambios para que permita la carga:

	SET GLOBAL local_infile = 1;
	SHOW GLOBAL VARIABLES LIKE 'local_infile';  # verifica que realmente aparece activado 'ON'
	SHOW GLOBAL VARIABLES LIKE 'secure_file_priv'; # muestra si existe una carpeta por defecto para la carga y la ruta.
	
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
			
            También me he asegurado de que configurar en propiedades, los permisos de lectura y escritura tanto de la carpeta Mysql, 
            # como de la carpeta 'Uploads' (donde están los ficheros csv con los datos de cada tabla) y de reiniciar el servicio del servidor mysql */
            
# Cargo datos csv haciendo los CAST necesarios de los campos con posibles problemas de formato (fechas, decimales...) 
# SELECTs para mostrar los datos:
	TRUNCATE TABLE companies;
	LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv"
	INTO TABLE companies
	FIELDS TERMINATED BY ','
	OPTIONALLY ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES;
	SELECT * FROM companies;

	TRUNCATE TABLE product;
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
	INTO TABLE product
	FIELDS TERMINATED BY ','
	OPTIONALLY ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES
		(@id, @product_name, @price, @colour, @weight, @warehouse_id)
	SET 
		id = @id,
		product_name = @product_name,
		price = CAST(REPLACE(@price, '$', '') AS DECIMAL(10, 2)),  # elimino con REPLACE el $ por '' y transformo a decimal
		colour = @colour,
		weight = @weight,
		warehouse_id = @warehouse_id;
	SELECT * FROM product;

	TRUNCATE TABLE users_uk;
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
	INTO TABLE users_uk
	FIELDS TERMINATED BY ','  
	OPTIONALLY ENCLOSED BY '"'           
	LINES TERMINATED BY '\r\n'  
	IGNORE 1 LINES;
	SELECT * FROM users_uk;

	TRUNCATE TABLE users_usa;
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'
	INTO TABLE users_usa
	FIELDS TERMINATED BY ','  
	OPTIONALLY ENCLOSED BY '"'           
	LINES TERMINATED BY '\r\n'  
	IGNORE 1 LINES;
	SELECT * FROM users_usa;

	TRUNCATE TABLE users_ca;
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv'
	INTO TABLE users_ca
	FIELDS TERMINATED BY ','  
	OPTIONALLY ENCLOSED BY '"'           
	LINES TERMINATED BY '\r\n'  
	IGNORE 1 LINES;
	SELECT * FROM users_ca;
    
# Unifico la 3 tablas 'users_xxx' en 1 sóla tabla 'users' para cumplir con la tercera forma normal:          

# Primero creo la tabla 'users' para tener el contenedor:
	DROP TABLE IF EXISTS users;
	CREATE TABLE users 
	(
		id INT NOT NULL PRIMARY KEY,
		name VARCHAR(100),
		surname VARCHAR(100),
		phone VARCHAR(20),
		email VARCHAR(100),
		birth_date VARCHAR(20),
		country VARCHAR(50),
		city VARCHAR(50),
		postal_code VARCHAR(10),
		address VARCHAR(200)
	);
    DESCRIBE users;
    
# Cargo los datos en 'users' desde cada una de las tablas de usuarios con INSERT INTO y UNION ALL:
	TRUNCATE TABLE users;
    INSERT INTO users 
		(id, name, surname, phone, email, birth_date, country, city, postal_code, address)
	SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address 
    FROM users_uk
	UNION ALL
	SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address 
    FROM users_usa
	UNION ALL
	SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address 
    FROM users_ca;
    SELECT * FROM users; 

#Elimino las 3 tablas parciales de users para que no molesten en el esquema E-R
	DROP TABLE users_ca;
    DROP TABLE users_uk;
    DROP TABLE users_usa;
    
# Ejecuto script para crear credit_cards con la FK correspondiente
DROP TABLE IF EXISTS credit_cards;
CREATE TABLE credit_cards 
(
    id VARCHAR(20) NOT NULL PRIMARY KEY,
    user_id INT,
    iban VARCHAR(34),
    pan VARCHAR(25),
    pin INT,
    cvv INT,
    track1 VARCHAR(200),
    track2 VARCHAR(200),
    expiring_date DATE, #  Haré CAST en el UPLOAD. El formato es  MM/DD/YY y lo pasaré a DATE
    CONSTRAINT fk_credit_cards_users FOREIGN KEY (user_id) REFERENCES users(id) # FK hacia users
);
DESCRIBE credit_cards;   

# Cargo los datos de la tabla crecit_cards
TRUNCATE TABLE credit_cards;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'           
LINES TERMINATED BY '\n'  
IGNORE 1 LINES
	(@id, @user_id, @iban, @pan, @pin, @cvv, @track1, @track2, @expiring_date)
	SET 
		id = @id,
		user_id = @user_id,
		iban = @iban,
		pan = @pan,
		pin = @pin,
		cvv = @cvv,
		track1 = @track1,
		track2 = @track2,
		expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');  # Aquí convertimos el formato MM/DD/YY a YYYY-MM-DD;
SELECT * FROM credit_cards;
  
  
# Ejecuto script para crear Transactions con las FK correspondientes
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions 
(
    id VARCHAR(100) NOT NULL PRIMARY KEY,
    card_id VARCHAR(20),
    business_id VARCHAR(20),
    timestamp DATETIME,
    amount DECIMAL(10, 2),
    declined TINYINT,
    product_ids VARCHAR(255),
    user_id INT,
    lat VARCHAR(50), 
    longitude VARCHAR(50),
    CONSTRAINT fk_transactions_credit_cards FOREIGN KEY (card_id) REFERENCES credit_cards(id), # FK hacia credit_cards
	CONSTRAINT fk_transactions_companies FOREIGN KEY (business_id) REFERENCES companies(company_id), # FK hacia cimpanies
    CONSTRAINT fk_transactions_users FOREIGN KEY (user_id) REFERENCES users(id) # FK hacia users 
 );
 DESCRIBE transactions;
    
# Cargo los datos de la tabla Transactions:
	TRUNCATE TABLE transactions; 
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
	INTO TABLE transactions
	FIELDS TERMINATED BY ';'  
	OPTIONALLY ENCLOSED BY '"'           
	LINES TERMINATED BY '\n'  
	IGNORE 1 LINES;
	SELECT * FROM transactions;


/* ANÁLISIS DE LAS TABLAS Y ESQUEMA E-R

	Tabla de hechos: transactions:
		Contiene las FK que apuntarán a cada una de la PK de la tabla de dimension a la que pertenezca.
			1. credit_cards (FK card_id). Reación 1-N
			2. company (FK business_id). Relación 1-N
			3. product (FK product_ids). Relación N-N. Como el campo product_ids refleja varios ids en un solo campo,
				hay que crear una tabla intermedia ProductTransaction
			4. users_uk, users_usa, users_ca (FK user_id) Normalización: unir las 3 tablas en una sola ('users')
			
	Tablas dimensiones:
		1.	credit_cards: tarjetas de crédito utilizadas en las transacciones. Cada transacción está asociada con una tarjeta.
        2.	company: empresas donde se hacen las transacciones.
		3.	product: productos incluidos en las transacciones.
        4.	users_xxx: usuarios de las transacciones. Hay 3 tablas, una tabla por cada zona (ca, uk, usa). 
			Estas tablas serían el resultado de aplicar filtros a una tabla general de 'users'. No obstante,
            dado que en el ejercicio no indica referirse a los sprints anteriores, la tabla 'users' la crearé anexando las 3 trablas
*/

-- ---------------------------------------------------------------------------------------------------------------------------
# Nivell 1
-- ---------------------------------------------------------------------------------------------------------------------------

# Exercici 1
# Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
    SELECT u.id, u.name, u.surname, (SELECT COUNT(t.id) 
									FROM transactions t 
									WHERE t.user_id = u.id) AS NumTransactions
	FROM users u
	WHERE u.id IN (SELECT t.user_id 
				   FROM transactions t 
				   GROUP BY t.user_id 
				   HAVING COUNT(t.id) > 30)
	ORDER BY NumTransactions DESC;
    

# Exercici 2
# Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
       
    #También podría hacerse con una subquery anidada en el join de transactions, pero sería un script más largo
    SELECT cc.IBAN, ROUND(AVG(t.amount), 2) AS AverageAamount
	FROM credit_cards cc
	JOIN  (
			SELECT * FROM transactions
			WHERE business_id IN  (
									SELECT company_id FROM companies 
                                    WHERE company_name = 'Donec Ltd'
								  )
		  ) AS t ON cc.id = t.card_id
	GROUP BY cc.IBAN;
    
    # Esta sería más compacta y sencilla con JOIN (no lo pide el ejercicio)
    SELECT cc.IBAN, ROUND(AVG(t.amount), 2) AS AverageAamount #ROUND 2 DECIMALES. sALEN 5 POR DEFECTO
	FROM transactions t
	JOIN credit_cards cc ON t.card_id = cc.id
	JOIN companies c ON t.business_id = c.company_id
	WHERE c.company_name = 'Donec Ltd'
	GROUP BY cc.IBAN;

-- ========================================================================================================================
-- Nivell 2
-- ========================================================================================================================

#Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:
	DROP TABLE IF EXISTS cc_active;
    CREATE TABLE cc_active
	(
		credit_card_id VARCHAR(15) PRIMARY KEY,
		active BOOLEAN
	);
    DESCRIBE cc_active;
        
    # USANDO ROW_NUMBER:
    # debemos contar si las ultimas 3 transacciones son True o False según si el campo 'declined de la tabla transactions es True o False.
    # No todas, sólo las 3 últimas (FECHA DESCENCIENTE) Con condicional anidado (CASE) en el SELECT o con if/then iremos contando suando lleguemos a 3 y si
    # El valos que debe mostrar en la columna 'active' es: False/True. En tabla transactions, campo declined, contamos si son >= 3.
    # Con subquery en el FROM utilizamos función row_number para enumerar las transacciones de cada tarjeta de crédito (parámetro de partition), 
    # ordenadas por fecha descendiente. 
    
    # SCRIPT con ROW NUMBER
		INSERT INTO cc_active (credit_card_id, active)
		SELECT TransNumeradas.card_id,
							   CASE 
								   WHEN SUM(CASE 
												WHEN TransNumeradas.declined = 1 THEN 1 
                                                ELSE 0 END
											) = 3 THEN FALSE   # tarjeca inactiva
								   ELSE TRUE  # Tarjeta activa
							   END AS active    # Nombre de esta columna
		FROM (	SELECT t.card_id, t.declined, ROW_NUMBER() OVER (PARTITION BY t.card_id ORDER BY t.timestamp DESC) AS RowNumber 
				FROM transactions t
			 )	TransNumeradas  # ordena por fecha descenciente y enumera las transacciones de cada tarjeta
		WHERE TransNumeradas.RowNumber <= 3  
		GROUP BY TransNumeradas.card_id;
        # HAVING COUNT(*) >= 3;	# sólo tiene en cuenta tarjetas con 3 o más transacciones	
        SELECT * FROM cc_active;

# OPCION 1 SIN ROW_NUMBER:
		INSERT INTO cc_active (credit_card_id, active)
		SELECT t.card_id,
						CASE 
							WHEN SUM(CASE WHEN t.declined = 1 THEN 1 ELSE 0 END) = 3 THEN FALSE  -- Si hay 3 declinadas, es inactiva
							ELSE TRUE  -- Si no, es activa
						END AS active
		FROM transactions t 
		# la conjerá SI NO está ya incluida en la tabla cc_active
		WHERE NOT EXISTS ( 						
							SELECT 1    # comprueba si el id de la tarjeta de transactions aparece en la tabla cc_active==> ES CIERTO QUE NO EXISTE, POR LO QUE 
							FROM cc_active ca 
							WHERE ca.credit_card_id = t.card_id
						  )
		GROUP BY t.card_id
		HAVING COUNT(t.id) >= 3;  # Para asegurarme de que solo tiene en cuenta inicialmente las tarjetas que tengan mínimo 3 transacciones
		SELECT * FROM cc_active;

# OPCION 2 sin ROW NUMBER
	INSERT INTO cc_active (credit_card_id, active)
	SELECT c.id AS credit_card_id,
									CASE 
										WHEN COUNT(t.id) = 3 AND SUM(CASE WHEN t.declined = 1 THEN 1 ELSE 0 END) = 3 THEN FALSE
										ELSE TRUE
									END AS active
	FROM credit_cards c
	LEFT JOIN transactions t ON c.id = t.card_id # para tenga en cuenta inicialmente el listado de todas las tarjetas de cc
	GROUP BY c.id
	HAVING COUNT(t.id) >= 3 # Para asegurarme de que solo tiene en cuenta las tarjetas que tengan mínimo 3 transacciones
	ON DUPLICATE KEY UPDATE active = VALUES(active);	# sin esta linea el script daba eeror por ser  credit_card_id PK y no permite introducir 
														# otra tarjeta con = num. Esta linea deja 'actualizar' el valor de la columna 'active'. 
	SELECT * FROM cc_active;


# Exercici 1
# Quantes targetes estan actives?
	# cuenta el número de tarjetas activas (campo active = TRUE)
	SELECT COUNT(*) AS NumTarjetasActivas
	FROM cc_active
	WHERE active = TRUE;
    
-- =======================================================================================================================
-- Nivell 3
-- =======================================================================================================================
# Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte 
# que des de transaction tens product_ids. Genera la següent consulta:
	DROP TABLE IF EXISTS producttransaction;
    CREATE TABLE ProductTransaction 
    (
    transaction_id CHAR(36), 
    product_id INT,
    PRIMARY KEY (transaction_id, product_id),  # Clave combinada
    FOREIGN KEY (transaction_id) REFERENCES transactions(id), # FK apunta a tranzactions
    FOREIGN KEY (product_id) REFERENCES product(id) # FK apunta a product
	);
    DESCRIBE producttransaction;
    
# Exercici 1
# Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

# planteamiento de la query: hay que conseguir identificar la posición de cada id dentro de la columna products id
# No todos tendrán el mismo número de posiciones
# la coma me permite saber cuántos números hay en cada registro: 12, 3, 7 
# Tendré que colocar cada id en UNA linea distinta, de forma que la misma transaction se repetira aparecerá en 3 lineas si tiene 3 product_id
# NumColumnas: posición del id en el cmapo product_ids. 
# SUBSTRING_INDEX interno: consige la cadena de ids definida por NumColumnas y el externo
# SUBSTRING_INDEX externo, coge la cadena anterior y con el -1 obtiene el último numero despues de la coma, empezando por el final. Así hasta que acbe con todos los ids de ese registro
# CAST finalmente lo toma como un número (era cadena de texto)
		
		INSERT INTO producttransaction (product_id, transaction_id)
		SELECT 
			CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', ListaNum.NumColumnas), ',', -1) AS UNSIGNED) AS product_id,  
			t.id AS transaction_id  
		FROM transactions t
		JOIN (
				SELECT 1 AS NumColumnas UNION ALL 
				SELECT 2 UNION ALL 
				SELECT 3 UNION ALL 
				SELECT 4 UNION ALL 
				SELECT 5 UNION ALL 
				SELECT 6   # he visto que el csv tienen max 4 ids. Escojo 6 por seguridad
			) ListaNum 
		ON CHAR_LENGTH(t.product_ids) - CHAR_LENGTH(REPLACE(t.product_ids, ',', '')) >= ListaNum.NumColumnas - 1;
     
        # muestro la tabla completa con todos los articulos de todas las transacciones
			SELECT * FROM producttransaction
			ORDER BY transaction_id;
        
		#Consulta para presentar los resultados con el número de ventas de cada producto
			SELECT p.id AS Reference, p.product_name AS Description, COUNT(pt.product_id) AS NumVentas
			FROM product p
			JOIN producttransaction pt ON p.id = pt.product_id
			GROUP BY p.id, p.product_name
			ORDER BY NumVentas DESC;
