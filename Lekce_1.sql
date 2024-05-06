USE data_academy_2024_04_17;

/*
LEKCE 1_17.4.2024:
- https://mariadb.com/kb/en/reserved-words/
	- tyhle slova jsou rezerovaný pro klíčový slova --> píšeme VELKÝMA
    - takže bychom je neměli používat pro nové sloupce, tabulky apod
-     
*/
/* ##### SELECT, ORDER BY a LIMIT ##### */
-- úkol 1
SELECT *
FROM healthcare_provider AS hp;

-- úkol 2
SELECT
	hp.name,
    hp.provider_type,
    CONCAT(hp.name, " - " ,hp.provider_type)
FROM healthcare_provider AS hp;

-- úkol 3
SELECT
	hp.name,
    hp.provider_type
FROM healthcare_provider AS hp
LIMIT 20;								-- btw třeba MSSQL nebo Snowflake používá TOP 20 místo LIMIT 20, jinak SQL má prý ISO standard

-- úkol 4
SELECT
	hp.name,
    hp.provider_type,
    hp.region_code
FROM healthcare_provider AS hp
ORDER BY 3 ASC;							-- btw ASC je default

-- úkol 5
SELECT
	hp.name AS jméno,
    hp.region_code AS kod_kraje,
    hp.district_code AS kod_okresu
FROM healthcare_provider AS hp
ORDER BY hp.district_code DESC
LIMIT 500;


/* ##### WHERE ##### */
-- úkol 1
SELECT 	
	hp.name AS jméno,
    hp.region_code AS kod_kraje,
    hp.district_code AS kod_okresu
FROM healthcare_provider AS hp
WHERE hp.region_code = 'CZ010';

-- úkol 2
SELECT
	hp.name,
    hp.street_name,
    hp.street_number,
    hp.phone,
    hp.fax,
    hp.email
FROM healthcare_provider AS hp
WHERE hp.region_code != 'CZ010';		-- btw MariaDB není case sensitive, ale třeba snowflake je

-- úkol 3
SELECT
	hp.name,
    hp.region_code,
    hp.residence_region_code
FROM healthcare_provider AS hp
WHERE hp.region_code = hp.residence_region_code;

-- úkol 4
SELECT
	hp.name,
    hp.phone
FROM healthcare_provider AS hp
WHERE hp.phone IS NOT NULL;				-- '' != NULL

-- úkol 5
SELECT
	hp.name,
--    hp.municipality,
    hp.district_code
FROM healthcare_provider AS hp
WHERE hp.district_code IN ('CZ0201', 'CZ0202')
ORDER BY hp.district_code ASC;

/* ##### TVOBRA TABULEK ##### */
-- úkol 1: vytvoř tabulku
CREATE TABLE IF NOT EXISTS t_Michal_Titl_providers_south_moravia AS
	SELECT *
	FROM healthcare_provider AS hp
	WHERE hp.region_code = 'CZ064';			-- znovu neprojde, protože už tabulka existuje, příp. lze řešit pomocí doplnění IF NOT EXISTS
/*
skrze temporary table mě to nepustí, takže skrze syntax CREATE TABLE nazev_tabulky AS
	odsazený_obsah_tabulky_klasicky_SELECT_...
*/
SELECT *
FROM t_Michal_Titl_providers_south_moravia;

-- úkol 2: vytvoř novou (prázdnou) tabulku
CREATE TABLE t_Michal_Titl_resume(
	date_start date,
	date_end date,
	job varchar(255),
	education varchar(255)
)
;
SELECT *
FROM t_Michal_Titl_resume AS tmtr;	-- btw ten weird alias vyrábí DBeaver sám --> je lepší si ho pak změnit 
/*
	vytvářím novou tabulku prázdnou, takže nedávám to AS, ale dám závorku definuju prvně název sloupce,
	pak datový typ a případně počet znaků a čárku, pokud není poslední + nakonec konec závorky
*/

/* ##### VKLÁDÁNÍ DAT DO TABULKY ##### */
-- úkol 1: vložit data do tabulky
INSERT INTO t_Michal_Titl_resume VALUES(
'2024-01-01', NULL, 'Analyst', NULL
	);
SELECT * FROM t_Michal_Titl_resume;		-- btw tady mám dva řádky, protože jsem to spustil 2krát
/*
	začínám INSERT INTO název_tabulky VALUES()
	když nespecifikuji, kam dávám, tak to jde dle pořadí
	NULL dávám, protože stále pracuji
*/

-- úkol 2: vložit hodnoty do tabulky
INSERT INTO t_Michal_Titl_resume (date_start, date_end, education)
VALUES ('2020-01-01', '2023-01-01', 'MUNI');

SELECT * FROM t_Michal_Titl_resume tmtr ;
/*
 	tady insertuju hodnoty dle sloupců, takže ještě před VALUES specifikuju sloupce,
 	kam budu chtít VALUES sypat
*/



/* ##### ÚPRAVA TABULEK ##### */
-- úkol 1: přidat sloupce k vytvořené tabulce
ALTER TABLE t_Michal_Titl_resume 
	ADD COLUMN institution varchar(255), 
	ADD COLUMN actual_role varchar(255)
;
SELECT * FROM t_Michal_Titl_resume tmtr ;

-- alternativní řešení
CREATE TABLE t_Michal_Titl_resume_alt AS
	SELECT tmtr.*, 'MUNI' institution_alt
	FROM t_Michal_Titl_resume AS tmtr;

SELECT * FROM t_Michal_Titl_resume_alt;

/*
	začnu syntaxem ALTER TABLE název_tabulky,
	dám ADD COLUMN nazev_sloupce datovy_typ,
	pak čárka a případně další columns
	...
	alternativně můžu použít CREATE TABLE nazev_nove_tabulky AS
		odsazený SELECT nazev_nebo_alias_puvodni_tabulky.*, 'default_hodnota' nazev_sloupce
		FROM puvodni_tabulka AS alias_puvodni_tabulky
	nevýhoda je, že datový typ (a jeho délku) to vezme z dodané hodnoty (zde varchar(4))
*/

-- úkol 2: aktualizuj hodnoty tabulky
UPDATE t_Michal_Titl_resume_alt
SET actual_role = 'Analyst';		-- na tohle POZOR, tímhle přepíšu VŠECHNY HODNOTY --> nezapomínat na podmínku WHERE

UPDATE t_Michal_Titl_resume_alt
SET actual_role = 'Data Analyst'
WHERE education = 'MUNI' AND job = 'Analyst'
;

/*
	tady začnu keywordem UPDATE nazev_tabulky
	pak SET nazev_sloupce = 'hodnota' ... a tady bych mohl skončit, ale aktualizovat bych tím všechny řádky,
	takže si pak dám ještě pod to WHERE nazev_sloupce = 'hodnota'
	...
	rozdíl ALTER x UPDATE: ALTER je na strukturu (sloupce samotné), UPDATE na hodnoty
*/
-- jak smazat řádek
DELETE
FROM t_Michal_Titl_resume_alt
WHERE education IS NULL;

-- jinak bacha, průběžně jsem to měnil a spouštěl back and forth, takže výsledky nesedí tolik na pořadí querries (!)
/* syntax DELETE FROM nazev_tabulky WHERE nazev_sloupce logicky_operator hodnota */

/* ##### BONUSOVÁ CVIČENÍ ##### */
/* ##### COVID-19: SELECT, ORDER BY a LIMIT ##### */
-- úkol 1: 

SELECT *
FROM covid19_basic cb ;

-- úkol 2:

SELECT *
FROM covid19_basic cb 
LIMIT 20;

-- úkol 3:

SELECT *
FROm covid19_basic cb 
ORDER BY date ASC;

-- úkol 4:

SELECT *
FROm covid19_basic cb 
ORDER BY date DESC;

-- úkol 5:

SELECT
	country
FROm covid19_basic cb;

-- úkol 6:

SELECT
	country,
	date
FROm covid19_basic cb;

/* ##### COVID-19: WHERE ##### */
-- úkol 1:

SELECT *
FROM covid19_basic
WHERE country = 'Austria';

-- úkol 2:

SELECT
	country,
	date,
	confirmed
FROM covid19_basic
WHERE country = 'Austria';

-- úkol 3:

SELECT *
FROM covid19_basic
WHERE date = '2020-08-30';

-- úkol 4:

SELECT *
FROM covid19_basic
WHERE date = '2020-08-30' AND country = 'Czechia';

-- úkol 5:

SELECT *
FROM covid19_basic
WHERE country IN ('Czechia', 'Austria');

-- úkol 6:

SELECT *
FROM covid19_basic
WHERE confirmed IN (1000, 100000);

-- úkol 7:

SELECT *
FROM covid19_basic
WHERE confirmed > 10 AND confirmed  < 20 AND date = '2020-08-30';

-- úkol 8:
SELECT *
FROM covid19_basic
WHERE confirmed > 1000000 AND date = '2020-08-15';

-- úkol 9:

SELECT
	date,
	country,
	confirmed
FROM covid19_basic
WHERE country IN ('United Kingdom', 'France')
ORDER BY date DESC;

-- úkol 10:

SELECT *
FROM covid19_basic_differences
WHERE country = 'Czechia' AND date LIKE '2020-09%';

-- úkol 11:

SELECT
	country,
	population
FROM lookup_table
WHERE country = 'Austria';

-- úkol 12:

SELECT
	country,
	population
FROM lookup_table
WHERE population > 500000000;

-- úkol 13:

SELECT
	date,
	country,
	confirmed 
FROM covid19_basic
WHERE country = 'India' AND date = '2020-08-30';

-- úkol 14:

SELECT
	province,
	SUM(confirmed)
FROM covid19_detail_us
WHERE province = 'Florida' AND date = '2020-08-30'
GROUP BY 1;
