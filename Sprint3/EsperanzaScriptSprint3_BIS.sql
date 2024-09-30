USE transactions;
DESCRIBE company;
DESCRIBE user;
DESCRIBE transaction;
SELECT * FROM transaction;
SELECT * FROM company;
DESCRIBE credit_card;
# =============================================================================================
-- Nivell 1
# =============================================================================================
-- Exercici 1
/* La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules 
("transaction" i "company").*/ 

    DROP TABLE IF EXISTS credit_card;
	CREATE TABLE IF NOT EXISTS credit_card
    (
		id VARCHAR(8) NOT NULL PRIMARY KEY,
		iban VARCHAR(50), 
		pan VARCHAR (50), 
		pin INT,
		cvv INT,
		expiring_date VARCHAR(10)
	);
    
    -- para verificar la estrucutra de tabla y campos
		DESCRIBE credit_card; 
    
    -- Describir la tabla: 
		-- se trata de una tabla de dimendiones que apunta a la tabla de hechos 'transaction'
		-- PK = campo id (único campo 'NOT NULL')
        -- formato fecha = VARCHAR por usar '/' en lugar de '-'). NO OBLIGATORIO
        -- Resto campos = VARCHAR, observando el formato en el scropt insert into. NO OBLIGATORIOS
    
	-- Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit":
		-- Ejecuto el script 'datos_introducir_credit con 'INSERT INTO' facilitado en el ejercicio.
			
		-- Muestro tabla resultante con un SELECT:
			SELECT * FROM credit_card;  
			
	-- Añado CONSTRAINT con ALTER TABLE para definir FK en 'transaction', que apunta a la PK de credit_card 'id':
		ALTER TABLE transaction ADD CONSTRAINT fk_transaction_credit_card FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);	
			-- Ahora la PK de Credit_card 'id' está relacionada fon la tabla transaction a través de su FK 'fk_transaction_credit_card'.
			-- Tipo de relación: 1:N - 1 credit card puede tener N transacciones, pero cada transacción apunta a 1 única credit_card
	            
    -- Tras los scripts, muestro la estructura de las tablas credit_card y transaction con el formato de sus campos:        
			DESCRIBE credit_card;
			DESCRIBE transaction;
        
	-- Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.-- crear el diagrama Database\Reverse engine (recorte) + explicación */ 
	
    
-------------------------------------------------------------------------------------------------------------------	
-- Exercici 2
	/* El departament de Recursos Humans ha identificat un error en el número de compte de 
	l'usuari amb ID CcU-2938; La informació que ha de mostrar-se per a aquest registre 
	és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar */

	-- Vemos los datos que tenemos de ese usuario:
		SELECT * FROM credit_card
		WHERE id = 'CcU-2938';

	-- Modifico el dato con UPDATE:
		UPDATE credit_card
		SET iban = 'R323456312213576817699999'
		WHERE id = 'CcU-2938';
		
	-- Verifico los datos modificados con SELECT:
		SELECT * FROM credit_card
		WHERE id = 'CcU-2938';
        
        
--------------------------------------------------------------------------------------------------------------------    
-- Exercici 3
-- En la taula "transaction" ingressa un nou usuari amb la següent informació:
	
    -- Indico los campos con info a introducir y en el orden que especifica el ejercico.
	INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
	VALUES
		('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);
        
    	-- Error 1452: no encuentra la empresa b-9999. Por lo tanto:
        
			-- 1. compruebo que efectivamente no exista la empresa en la tabla Company:
				SELECT * FROM company WHERE id = 'b-9999'; 
			
			-- 2. Creo la empresa y vuelvo a ejecutar la query inicial para insertar el nuevo usuario en transaction
				INSERT INTO company (id) -- sólo es 'not null' (obligatorio) el id:
				VALUES ('b-9999');
                
			-- 3. Muestro que existe la nueva empresa:
				SELECT * FROM company
                WHERE id = 'b-9999';
                
			-- 4. Ya puedo ejecutar la querie inical para introducir los datos solicitados en el enunciado:
				INSERT INTO transaction(id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
				VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);
                
			-- 5. SELECT para mostrar que existe el nuevo usuario en la tabla transaction:
				SELECT * FROM transaction
				WHERE id = 'b-9999';
                
        
-------------------------------------------------------------------------------------------------------------------------
-- Exercici 4
	/*Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. 
	Recorda mostrar el canvi realitzat*/
    
		-- Reviso lo campos existentes de la tabla:
			DESCRIBE credit_card; 
    
		-- Modifico la tabla credit_card para eliminar la columna:
			ALTER TABLE credit_card 
			DROP COLUMN pan;
        
        -- verifico columna eliminada:los campos existentes de la tabla:
			DESCRIBE credit_card; 
               
        -- Muestro los datos de la tabla con las columnas actualizadas:
			SELECT * FROM credit_card;
            
            
==============================================================================================================
-- Nivell 2
==============================================================================================================
-- Exercici 1
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la BD.
	-- 1. Compruebo si existe esta transacción:
		SELECT * FROM transaction
		WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02'; 
        
	--  2. NO existe, por lo que la creamos en la tabla transaction:
		INSERT INTO transaction (id) 
		VALUES ('02C6201E-D90A-1859-B4EE-88D2986D3B02');
        
	-- 3. para poder eliminarla:
		DELETE FROM transaction
		WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02'; 
        
	-- 4. comprobamos que la hemos eliminado (NO devuelve filas):    
		SELECT * FROM transaction
		WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';  
        
        
-----------------------------------------------------------------------------------------------------------------------
-- Exercici 2
	/* La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
	S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
	Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
	Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
	Presenta la vista creada, ordenant les dades de major a menor mitjana de compra */
	
		DROP VIEW IF EXISTS VistaMarketing;
	
		CREATE VIEW VistaMarketing
		AS
		SELECT c.company_name AS Empresa, c.phone AS Teléfono, c.country AS País, AVG(t.amount) AS MediaCompra
		FROM company c
		LEFT JOIN transaction t ON c.id = t.company_id
		GROUP BY c.company_name, c.phone, c.country
		ORDER BY MediaCompra DESC;

		-- Muestro los campos de la vista
			SHOW CREATE VIEW VistaMarketing;
        
        -- Muestro los datos de la vista con las columnas del enunciado
			SELECT * FROM VistaMarketing;
            
    
---------------------------------------------------------------------------------------------------------------    
-- Exercici 3
	/* Filtra la vista VistaMarketing per a mostrar només les companyies 
	que tenen el seu país de residència en "Germany" */
	
    SELECT * FROM VistaMarketing
	WHERE Empresa = 'Germany';


=========================================================================================================
-- Nivell 3
==========================================================================================================
-- Exercici 1
	/* La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. 
	Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. 
	Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama: */

	-- TABLA company:
		-- Reviso campos de la tabla company. 
			DESCRIBE company;
		
		-- No necesitan la columna 'website':
				ALTER TABLE company
				DROP COLUMN website;
				
		-- Reviso campos resultantes de la tabla company. 
			DESCRIBE company;
		
	-- TABLA user:
		-- Reviso campos de la tabla:
			DESCRIBE user; 
            -- Observaciones:
				-- PK = id. Es el único campo NOT NUL (obligatorio)
                -- FK = FOREIGN KEY(id) REFERENCES transaction(user_id)        
                        /* esta línea del script es incorrecta. Está al revés. En transaction tenemos
                        el 'user_id' como FK que apunta al campo 'id' (PK) de la tabla user.
                        !!!! VER FINAL DEL SCRIPT: tras revisar todas las FK de las tablas, las elimino todas
						para definirlas de nuevo fuera de las tablas con ALTER TABLE '' ADD CONSTRAINT.*/
				-- Resto de campos son VARCHAR y pueden ser NULL (no obligatorios)
		
		-- cambio el nombre de la tabla 'user' a 'data_user':
			RENAME TABLE user TO data_user;
		
		-- Reviso campos de la tabla con el nuevo nombre
			DESCRIBE data_user; 
		
		-- Muestro los datos de la tabla:
			SELECT * FROM data_user;

	-- TABLA Credit Card
		-- Verifico los campos de la tabla:
			DESCRIBE credit_card;    
		
		-- añado campo 'fecha_actual' y mofifico formato de los campos
			ALTER TABLE credit_card
			ADD COLUMN fecha_actual DATE,
				MODIFY id VARCHAR(20), 
				MODIFY iban VARCHAR(50),
				MODIFY pin VARCHAR(4);            
		
        -- Verifico los campos de la tabla:
        DESCRIBE credit_card; -- verifico cambios

	-- TABLA transaction:
		-- Verifico los campos de la tabla:
			DESCRIBE transaction;    

------------------------------------------------------------------------------------------------------------	
-- Exercici 2
/* L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" 
que contingui la següent informació:

		ID de la transacció
		Nom de l'usuari/ària
		Cognom de l'usuari/ària
		IBAN de la targeta de crèdit usada.
		Nom de la companyia de la transacció realitzada.
        
Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies 
per a canviar de nom columnes segons sigui necessari.
Mostra els resultats de la vista, ordena els resultats de manera descendent 
en funció de la variable ID de transaction.*/
	-- Creo la vista con los campos del enunciado
		DROP VIEW IF EXISTS InformeTecnico;
        
		CREATE VIEW InformeTecnico
		AS
		SELECT t.id AS TransaccionId, u.name AS Nombre, u.surname AS Apellido, cc.iban AS IBAN, c.company_name AS Empresa
		FROM transaction t
		JOIN company c ON t.company_id = c.id
		JOIN data_user u ON t.user_id = u.id
		JOIN credit_card cc ON t.credit_card_id = cc.id
		ORDER BY TransaccionId DESC;
	
    -- Verifico estructura y campos de la vista:
		SHOW CREATE VIEW InformeTecnico;
	
    -- Muestro datos de la vista:
		SELECT * FROM InformeTecnico;
        
================================================================================
    -- ACTUACIÓN SOBRE LAS FOREIGN KEYS    
================================================================================
	
    -- OBSERVACIÓN: es más coherente tener las FK generadas al final del script fuera de las tablas y con ALTER TABLE, para garantizar
    -- que en caso de eliminación de datos, coluntas io tablas, lo primero es eliminar las restricciones para poder actuar al nivel de tabla.
    -- Se realizaría en 2 pasos: primero eliminar todas las FK para volver a definirlas en un segundo paso:
    
		-- PRIMERO: elimino las FK de Transaction y user:
			ALTER TABLE transaction DROP FOREIGN KEY fk_transaction_user;
			ALTER TABLE transaction DROP FOREIGN KEY fk_transaction_company;
			ALTER TABLE transaction DROP FOREIGN KEY fk_transaction_credit_card;
			ALTER TABLE user DROP FOREIGN KEY fk_user_transaction;
			
		-- SEGUNDO: creo todas las FK fuera de las tablas con ALTER TABLE ADD CONSTRAINT
			ALTER TABLE transaction ADD CONSTRAINT fk_transaction_user FOREIGN KEY (user_id) REFERENCES user(id);
			ALTER TABLE transaction ADD CONSTRAINT fk_transaction_credit_card FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);	
			ALTER TABLE transaction ADD CONSTRAINT fk_transaction_company FOREIGN KEY (company_id) REFERENCES company(id);
            
		-- Mostramos la estrucutra final de las 4 tablas:
			DESCRIBE transaction;
            DESCRIBE user;
            DESCRIBE company;
            DESCRIBE credit_card;
            
		-- Esquema E-R:
        
        
        



