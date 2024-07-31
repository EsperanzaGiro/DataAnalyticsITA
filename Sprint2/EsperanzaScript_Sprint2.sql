USE transactions;
SELECT * FROM company;
SELECT * FROM transaction;
--------------------------------------------------------------------------------
-- NIVEL 1
--------------------------------------------------------------------------------
-- 2: Consultas con JOIN 

	-- 2.1: Listado de los países que están haciendo compras:
			
		SELECT DISTINCT c.country AS ListadoPaisesComprando
		FROM company c
		INNER JOIN transaction t ON c.id = t.company_id;
        -- WHERE t.declined = 0;

	-- 2.2 Desde cuántos países se realizan las compras:
		
        SELECT count(DISTINCT c.country) AS NumeroDePaisesComprando
		FROM company c
		INNER JOIN transaction t ON c.id = t.company_id;
        -- WHERE t.declined = 0;

	-- 2.3 Identificar la compañía con la media más grande de ventas: 
    
		SELECT c.company_name AS Empresa, AVG(t.amount) AS VentasMedias
		FROM company c
		JOIN transaction t ON c.id = t.company_id
        -- WHERE t.declined = 0
		GROUP BY c.company_name
		ORDER BY VentasMedias DESC
		LIMIT 1;

	-- Exercici 3: Utilitzant només subconsultes (sense utilitzar JOIN):

		-- 3.1 Mostra totes les transaccions realitzades per empreses d'Alemanya.
        
			SELECT *
			FROM transaction t
			WHERE t.company_id IN	(
									SELECT c.id
									FROM company c
									WHERE c.country = 'Germany'
									);


		-- 3.2 Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
        
			SELECT c.company_name
			FROM company c
			WHERE c.id IN	(
							SELECT t.company_id 
							FROM transaction t
							WHERE amount > (
											SELECT AVG(t1.amount) AS MediaPorEmpresa
											FROM transaction t1
											)
							);
						
		-- 3.3 Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
		            
			SELECT *	
			FROM company c           
			WHERE c.id NOT IN (
							SELECT DISTINCT t.company_id
							FROM transaction t
							); -- todas las empresas tienen transacciones registradas. No hay empresas a eliminar
							
			-- Ahora podríamos "delete" los registros:
			DELETE FROM company
			WHERE id NOT IN (
							SELECT t.company_id
							FROM transaction t
							);

		
---------------------------------------------------------------------------------------
-- NIVEL 2
---------------------------------------------------------------------------------------
-- 3.1 Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.
	    
		SELECT date(t.timestamp) AS DiaMayorVenta, SUM(t.amount) AS VentasDelDia
		FROM transaction t
		WHERE t.declined = 0 
		GROUP BY DATE(t.timestamp)
		ORDER BY VentasDelDia DESC
		LIMIT 5;

-- 3.2 Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

	SELECT c.country, AVG(t.amount) MediaVentasPais
	FROM transaction t
	INNER JOIN company c ON t.company_id = c.id
    WHERE t.declined = 0
	GROUP BY c.country
	ORDER BY MediaVentasPais DESC;


/* 3.3 En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer 
competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions 
realitzades per empreses que estan situades en el mateix país que aquesta companyia.*/

	-- 3.3.1. Mostra el llistat aplicant JOIN i subconsultes.
    
		SELECT t.*, c.country AS País, c.company_name AS Empresa
		FROM transaction t
		JOIN company c ON t.company_id = c.id
		WHERE c.country = (
							SELECT c1.country
							FROM company c1
							WHERE c1.company_name = 'Non Institute'
						  ); 
	
    -- 3.3.2. Mostra el llistat aplicant solament subconsultes.
        
			SELECT t.*, 
						(
						SELECT c.country 
						FROM company c 
						WHERE c.id = t.company_id
						) AS País, 
						(
						SELECT c.company_name 
						FROM company c 
						WHERE c.id = t.company_id
						) AS Empresa
			FROM transaction t
			WHERE t.company_id IN 	(
									SELECT c.id FROM company c
									WHERE c.country = 	(
														SELECT c2.country
														FROM company c2
														WHERE c2.company_name = 'Non Institute'
														)
									);                                    
-------------------------------------------------------------------------------------------------------------
-- Nivell 3
------------------------------------------------------------------------------------------------------------

-- 1. Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions 
-- amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 
-- 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.

	SELECT DISTINCT company_name AS Empresa, phone AS Teléfono, country AS País, timestamp AS Fecha, amount AS Importe
	FROM company c
	INNER JOIN transaction t ON c.id = t.company_id
	WHERE amount BETWEEN 100 AND 200
	AND DATE(t.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
	ORDER BY amount DESC;

-- 2. Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis 
-- si tenen més de 4 transaccions o menys.

	SELECT c.id, c.company_name AS Empresa, CASE
											WHEN COUNT(t.id) > 4 THEN 'Mas de 4 ventas'
											ELSE 'Pocas ventas'
											END AS NivelVentas -- , COUNT(t.id) AS NumTransacciones (info adicional)
	FROM company c
	INNER JOIN transaction t ON t.company_id = c.id
	GROUP BY c.id, c.company_name
	ORDER BY COUNT(t.id) DESC;



