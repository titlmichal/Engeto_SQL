USE data_academy_2024_04_17;

/*
LEKCE 2_24.4.2024:
- dnes to bude o LIKE, IN, WHERE a SELECT klauzulích
- btw u WHERE ne/dávám uvozovky dle datového typu, ale některé DBs si to umí přelouskat
- fce TRIM se podívá na začátek a konec řetězce a ořízne mezery/volná místa
	- podobně pak LTRIM a RTRIM, které trimmují jen z jedné strany
- fce OFFSET (bez závorek, jen s číselm) přeskočí daný počet řádků
- u CASE WHEN podmínek je třeba dávat pozor na pořadí, protože když splní první podmínku, tak další netestuje
- samozřejmě je taky dobrý specifikovat všechny možnosti, jinak se ty data zašpiní
*/

-- úkol 1: Vypište od všech poskytovatelů zdravotních služeb jméno a typ. Záznamy seřaďte podle jména vzestupně.
SELECT
	TRIM(name),
	provider_type
FROM healthcare_provider
ORDER BY 1 ASC;		-- ASC je default, tak nemusí být, ale když admin změní default nastavení, tak je to good

-- Úkol 2: Vypište od všech poskytovatelů zdravotních služeb ID, jméno a typ. 
-- Záznamy seřaďte primárně podle kódu kraje a sekundárně podle kódu okresu.

SELECT
	provider_id,
	name,
	provider_type
FROM healthcare_provider
ORDER BY region_code, district_code;

-- Úkol 3: Seřaďte na výpisu data z tabulky czechia_district sestupně podle kódu okresu.

-- ...

-- Úkol 4: Vypište abacedně pět posledních krajů v ČR.

SELECT *
FROM czechia_region
ORDER BY 1 DESC
LIMIT 5 OFFSET 5;

/* ##### CASE Expression ##### */
-- Úkol 1: Přidejte na výpisu k tabulce healthcare_provider nový sloupec is_from_Prague, 
-- který bude obsahovat 1 pro poskytovate z Prahy a 0 pro ty mimo pražské.
SELECT
	name,
	region_code,
	CASE 
		WHEN region_code = 'CZ010' THEN 1
		ELSE 0
	END AS is_from_Prague
FROM healthcare_provider
ORDER BY region_code;

-- Úkol 2: Upravte dotaz z předchozího příkladu tak, aby obsahoval záznamy, které spadají jenom do Prahy.
SELECT
	name,
	region_code,
	CASE 
		WHEN region_code = 'CZ010' THEN 1
		ELSE 0
	END AS is_from_Prague
FROM healthcare_provider
WHERE region_code = 'CZ010'
ORDER BY region_code;

-- Úkol 3: Sestavte dotaz, který na výstupu ukáže název poskytovatele, město poskytování služeb, zeměpisnou délku 
-- a v dynamicky vypočítaném sloupci slovní informaci, 
-- jak moc na západě se poskytovatel nachází – určete takto čtyři kategorie rozdělení.

-- MIN hodnota = 12.167
-- MAX hodnota = 18.805
-- AVG = 15.5472
-- AVG menší 1/2 = 14.232
-- AVG větší 1/2 = 17.034
SELECT
	name,
	municipality,
	longitude,
	CASE
		WHEN longitude < 14.233 THEN 1
		WHEN longitude < 15.548 THEN 2
		WHEN longitude < 17.035 THEN 3
		WHEN longitude >= 17.035 THEN 4
		ELSE '#N/A'
	END AS longitude_group
FROM healthcare_provider
-- WHERE longitude IS NOT NULL
;

-- Úkol 4: Vypište název a typ poskytovatele a v novém sloupci odlište, 
-- zda jeho typ je Lékárna nebo Výdejna zdravotnických prostředků.
SELECT
	name,
	provider_type,
	CASE
		WHEN provider_type = 'Lékárna' OR provider_type = 'Výdejna zdravotnických prostředků' THEN 1
		ELSE 0
	END AS lekarna_nebo_vydejna
FROM healthcare_provider;

/*
##### Relační databáze - teorie #####
- není to na biflování, ale určitě good to know
- sofistokovanější než třeba texťák
- můžeme mít i NoSQL - SQL by tam fungovalo, ale je to trochu specifičtější prý
- ta síla je právě v těch relacích - viz ty vzahy v diagramu

Relační DB systémy (RDBMS)
- "program", kde běží DBs
- mnoho variant: PostgreSQL, MySQL, ...
- každý jsou trochu specifický, ale základ je stjený

SQL
- jazyk ke komunikaci s DBs, základ pro různé RDBMS
- dělí na několik podskupin
--> druhy SQL
	- DDL - data definition language
		- definice struktury tabulky
		- nepracujeme přímo s daty, ale řešíme strukturu a omezení, default fungování apod.
	- DML - data manipulation langugage
		- manipulace s daty, pracujeme s nimi
		- podskupina: DQL - Data Query Language (SELECT)
	- DCL - data control language
		- přidělování oprávnění, to dělají třeba DBs admini
	- DTL - Data Transaction language
		- správa transakcí
		- vlastně jeden SELECT ... statement je 1 transakce
		- když třeba udělám v sérii SELECTů chybu, tak můžu udělat nějaký transaction rollback --> vrácení změn
- je dobré si tyhle věci nastudovat

Integritní omezení
- hlavně u návrhu skladů
- omezení, co nám pomáhají mít data konzistentní
- takové prvotní omezení jsou už třeba datový typy ve sloupcích (do int nedám string)
- nebo třeba primární klíč (v ER diagramu má symbol klíče) --> vždy UNIKÁTNÍ, může být v každé tabulce jednou
- může se skládat z více sloupců --> jejich kombinace MUSÍ být unikátní
- pak je cizí klíč, který omezuje, jaké hodnoty tam lze vložit

Datové typy
- ve své podstatě taky integritní omezení
- jiný typ nelze vkládat než je definovaný
- např. do varchar můžu dát cokoliv, protože i číslo si převede na string
- ale třeba do integeru nezapíšu text
- podobně u booleanů, timestampů (počet sekund od nějakého začátku, typicky 1.1.1970)
- při stavění tabulek není dobrý dávat vysoké/zbytečně malé množství znaků pro jednotlivé columns
- např rozdíl varchar X char: u charu musí být přesně tolik znaků, na kolik je definovaný X u varcharu je to maximum
- btw prý není dobrý používat datový typ money, dělá to bordel při transformacích
		
... prezentace je na gitu btw
 */

/* ##### WHERE, IN a LIKE ##### */
-- Úkol 1: Vyberte z tabulky healthcare_provider záznamy o poskytovatelích, kteří mají ve jméně slovo nemocnice.
SELECT
	name
FROM healthcare_provider
WHERE name LIKE '%nemocnice%';		-- POZOR, je to výpočetně náročná operace (!) --> pokud je možný, je dobrý se vyhnout

-- Úkol 2: Vyberte z tabulky healthcare_provider jméno poskytovatelů, kteří v něm mají slovo lékárna. 
-- Vytvořte další dynamicky vypsaný sloupec, který bude obsahovat 1, pokud slovem lékárna název začíná. 
-- V opačném případě bude ve sloupci 0.
SELECT
	name,
--	LOWER(name),		-- u MariaDB to není třeba řešit, ale třeba SnowFlake JE CASE SENSITIVE (!), takže by to bylo potřeba řešit
--	UPPER(name),
	CASE
		WHEN TRIM(name) LIKE 'lékárna%' THEN 1
		ELSE 0
	END AS zacina_lekarnou
FROM healthcare_provider
WHERE name LIKE '%lékárna%';

-- Úkol 3: Vypište jméno a město poskytovatelů, jejichž název města poskytování má délku čtyři písmena (znaky).
SELECT
	name,
	municipality
FROM healthcare_provider
WHERE municipality LIKE '____'  -- každé podtržítko za LIKE je 1 random znak
ORDER BY 1;

-- výhodnější by bylo použít fci char_length
SELECT
	name,
	municipality,
	char_length(municipality),
	length(municipality)		-- POZOR, u length je diakritika za víc znaků (viz třeba ten Zlín), protože bere počet bitů, ne znaků
FROM healthcare_provider
WHERE char_length(municipality) = 4
ORDER BY 4 DESC;

-- Úkol 4: Vypište jméno, město a okres místa poskytování u těch poskytovatelů, 
-- kteří jsou z Brna, Prahy nebo Ostravy nebo z okresů Most nebo Děčín.
SELECT
	name,
	municipality,
	district_code
FROM healthcare_provider
WHERE municipality IN ('Brno', 'Praha', 'Ostrava') OR district_code IN ('CZ0421', 'CZ0425');

-- Úkol 5: Pomocí vnořeného SELECT vypište kódy krajů pro Jihomoravský a Středočeský kraj z tabulky czechia_region. 
-- Ty použijte pro vypsání ID, jména a kraje jen těch vyhovujících poskytovatelů z tabulky healthcare_provider.
-- BTW tyhle vnořené (subselecty) SELECTY SE HODNE POUŽÍVAJÍ !
-- výhoda je, že ta tabulka není zapsaná v DB, takže nežera data, jen výkon, když si zavolá

SELECT
	provider_id,
	name,
	region_code 
FROM healthcare_provider
WHERE region_code IN (
						SELECT
							code
						FROM czechia_region
						WHERE name IN ('Středočeský kraj', 'Jihomoravský kraj')
						)
;

-- Úkol 6: Z tabulky czechia_district vypište jenom ty okresy, ve kterých se vyskytuje název města, které má délku čtyři písmena (znaky).
SELECT
	*
FROM czechia_district
WHERE code in (SELECT
					district_code 
				FROM healthcare_provider
				WHERE CHAR_LENGTH(municipality) = 4
				)
;

/* ##### Pohledy (VIEW) ##### 
- viewčka jsou docela důležitý
- = hodně podobný jako tabulka, dá se na to odkazovat při psaní querries, ALE není to zapsaný v DB
- takže pak při volání se spustí ten skript za tím
- --> záleží pak, když třeba ten skript by měl běžet dlouho, tak je lepší si udělat opravdovou tabulku
- ale na views se často napojují různé analysis services a tak
- dělá se to podobně jako tabulky
	- CREATE VIEW, případně CREATE OR REPLACE VIEW AS
	- a pak pod tím ten SELECT ...
- když to pustím, tak se neupdatne žádná row, protože žádná se nemění z definice
- pak když kouknu skrze View View na Source, tak uvidím ten skript, což je vlastně ten hlavní výsledek Viewčka
--> to je hlavní VÝHODA view, protože jsou díky tomu DYNAMICKÝ a mění se dle dat (jen skript, co se pustí na aktuálních datech)
- hodí se to dělat v situaci, kdy se na ty Views budu odkazovat víckrát
- takže v REPORTINGU JE TO SUPER, protože neukládá data, ale jen postup jak na ně sáhnout
*/
-- Úkol 1: Vytvořte pohled (VIEW) s ID, jménem, městem a okresem místa poskytování u těch poskytovatelů, 
-- kteří jsou z Brna, Prahy nebo Ostravy. Pohled pojmenujte v_healthcare_provider_subset

CREATE OR REPLACE VIEW v_healthcare_provider_subset_mich_ti AS
SELECT
	provider_id,
	name,
	municipality,
	district_code 
FROM healthcare_provider
WHERE municipality IN ('Brno', 'Praha', 'Ostrava');

SELECT * FROM v_healthcare_provider_subset_mich_ti;

-- Úkol 2: Vytvořte dva SELECT nad tímto pohledem. První vybere vše z něj, druhý vybere všechny poskytovatele 
-- z tabulky healthcare_provider, kteří se nenacházejí v pohledu v_healthcare_provider_subset.
SELECT * FROM v_healthcare_provider_subset_mich_ti;

SELECT
	provider_id,
	name
FROM healthcare_provider 
WHERE provider_id NOT IN (
							SELECT
								provider_id 
							FROM v_healthcare_provider_subset_mich_ti
							)
;

-- Úkol 3: Smažte pohled z databáze.
DROP VIEW IF EXISTS v_healthcare_provider_subset_mich_ti;
SELECT * FROM v_healthcare_provider_subset_mich_ti;

##### BONUSOVÁ CVIČENÍ ##### 
##### Countries: další cvičení #####
-- Úkol 1: Najděte národní pokrm pro všechny státy východní Evropy.
SELECT
	country,
	region_in_world,
	national_dish 
FROM countries
WHERE region_in_world = 'Eastern Europe';

-- Úkol 2: Najděte všechny státy a území, jejichž měna má v názvu 'dolar'. 
-- Najděte také všechny státy a území, kde se platí americkým dolarem.

SELECT
	country,
	currency_name,
	currency_code
FROM countries c 
WHERE LOWER(currency_name) LIKE '%dollar%';

SELECT
	country,
	currency_name,
	currency_code
FROM countries c 
WHERE LOWER(currency_code) = 'usd';

-- Úkol 3: Ověřte, jestli je mezinárodní zkratka území (abbreviation) vždy shodná s koncovkou internetové domény (domain_tld).
SELECT
	country,
	abbreviation,
	domain_tld,
	CASE
		WHEN abbreviation = RIGHT(domain_tld, 2) THEN 1
		ELSE 0
	END as ending_check	
FROM countries c;

-- Úkol 4: Najděte všechna území, jejichž hlavní město má víceslovný název.
SELECT
	country,
	capital_city 
FROM countries
WHERE LENGTH(capital_city) > LENGTH(REPLACE(capital_city, ' ', '')) ;

-- Úkol 5: Seřaďte všechny křesťanské země podle roku, kdy získaly nezávislost (independence_date). 
-- Seřaďte je od nejstarších po nejmladší.

SELECT
	country,
	religion,
	independence_date 
FROM countries c 
WHERE LOWER(religion) = 'Christianity' AND independence_date IS NOT NULL
ORDER BY independence_date ASC;

/*
Úkol 6: Vyberte země, které splňují alespoň jednu z následujících podmínek:
	- jejich průměrná nadmořská výška (elevation) je větší než 2000 metrů nad mořem.
	- průměrná roční teplota (yearly_average_temperature) je nižší než 5 stupňů nebo vyšší než 25 stupňů.
	- jejich populace je větší než 10 milionů obyvatel a zároveň je hustota zalidnění větší než 1000 obyvatel na kilometr čtvereční
 */

SELECT
	country,
	elevation,
	yearly_average_temperature,
	population
FROM countries
	WHERE elevation > 2000
	OR (yearly_average_temperature < 5 OR yearly_average_temperature > 25)
	OR (population > 10000000 AND population_density > 1000)
;

/*
Úkol 7: Rozšiřte tabulku s vybranými zeměmi z minulého úkolu. 
Pro každou podmínku zadanou v minulém úkolu vytvořte nový sloupec s binární hodnou 1/0. 
Hodnota bude 1, pokud daná země splňuje danou podmínku výběru a 0 jinak. 
Výslednou tabulku uložte jako pohled s názvem v_{jméno}_{příjmení}_hostile_countries.
 */
CREATE OR REPLACE VIEW v_Michal_Titl_hostile_countries AS
SELECT
	country,
	elevation,
	yearly_average_temperature,
	population,
	population_density,
	CASE
		WHEN elevation > 2000 THEN 1
		ELSE 0
	END AS elevation_over_2k,
	CASE
		WHEN yearly_average_temperature < 5 OR yearly_average_temperature > 25 THEN 1
		ELSE 0
	END AS terrible_temperature,
	CASE
		WHEN population > 10000000 AND population_density > 1000 THEN 1
		ELSE 0
	END AS overcrowded	
FROM countries
	WHERE elevation > 2000
	OR (yearly_average_temperature < 5 OR yearly_average_temperature > 25)
	OR (population > 10000000 AND population_density > 1000)
;

SELECT * FROM v_Michal_Titl_hostile_countries;

-- Úkol 8: Načtěte pohled z minulého úkolu. Vyberte všechny země, které splňují více než jednu podmínku.
SELECT
	*
FROM v_Michal_Titl_hostile_countries
	WHERE (elevation_over_2k + terrible_temperature + overcrowded) > 1;

-- Úkol 9: Seřaďte tabulku countries podle očekávané délky života (life_expectancy) vzestupně.
SELECT
	country,
	life_expectancy 
FROM countries c 
WHERE life_expectancy IS NOT NULL
ORDER BY 2 ASC
;

-- Úkol 10:
SELECT
	country,
	life_expectancy_2019,
	life_expectancy_1950,
	life_expectancy_2019 - life_expectancy_1950 AS life_expectancy_diff
FROM v_life_expectancy_comparison
ORDER BY 4 DESC;

-- Úkol 11: Vyberte všechny země, kde je hlavním náboženstvím buddhismus.
SELECT
	country,
	religion 
FROM countries c 
	WHERE LOWER(religion) = 'buddhism';

-- Úkol 12: Vyberte země, které získaly samostatnost před rokem 1500.
SELECT
	country,
	independence_date 
FROM countries c
	WHERE independence_date < 1500;

-- Úkol 13: Vyberte země s průměrnou nadmořskou výškou přes 2000 metrů nad mořem.
SELECT
	country ,
	elevation 
FROM countries c 
WHERE elevation > 2000;

-- Úkol 14: Vyberte země, jejichž národním symbolem není zvíře.
SELECT
	country ,
	national_symbol 
FROM countries c 
	WHERE LOWER(national_symbol) != 'animal';

-- Úkol 15: Vyberte země, jejichž hlavním náboženstvím není ani křesťanství ani islám.
SELECT
	country,
	religion
FROM countries c
	WHERE LOWER(religion) NOT IN ('christianity', 'islam')
	
-- Úkol 16: Vyberte země platící Eurem, jejichž hlavním náboženstvím není křesťanství.
SELECT
	country,
	religion,
	currency_name 
FROM countries c
	WHERE LOWER(religion) NOT IN ('christianity')
	AND LOWER(currency_name) = 'euro'
;

-- Úkol 17: Vyberte země, jejichž průměrná roční teplota je menší než 0 stupňů nebo větší než 30 stupňů.
SELECT 
	country,
	yearly_average_temperature 
FROM countries c 
	WHERE yearly_average_temperature  <= 0 OR yearly_average_temperature >= 30;

-- Úkol 18: Vyberte země, které získaly nezávislost v devatenáctém století.
SELECT
	country,
	independence_date 
FROM countries c 
	WHERE independence_date >= 1800 AND independence_date < 1900;
	
-- Úkol 19: Spočítejte hustotu zalidnění pomocí sloupců population a surface_area. 
-- Porovnejte jej se sloupcem population_density.

SELECT 
	country,
	population,
	surface_area,
	population/surface_area AS density,
	population_density,
	(population/surface_area) - population_density AS calc_diff
FROM countries c 
	WHERE surface_area IS NOT NULL AND population_density IS NOT NULL;
	
-- Úkol 20: Zjistěte průměrnou roční teplotu ve Fahrenheitech (9/5 * Celsius + 32).
SELECT 
	country,
	yearly_average_temperature,
	yearly_average_temperature * (9/5) + 32 AS temperature_in_F
FROM countries c;

/* Úkol 21: Vytvořte novou proměnnou climate podle průměrné roční teploty. Kategorie budou následující:
méně než 0 : freezing
0-10 : chilly
11-20 : mild
21-30 : warm
30 a víc : scorching
*/

SELECT 
	country ,
	yearly_average_temperature,
	CASE
		WHEN yearly_average_temperature < 0 THEN 'freezing'
		WHEN yearly_average_temperature <= 10 THEN 'chilly'
		WHEN yearly_average_temperature <= 20 THEN 'mild'
		WHEN yearly_average_temperature <= 30 THEN 'warm'
		WHEN yearly_average_temperature > 30 THEN 'scorching'
		ELSE 'ERROR'
	END AS climate	
FROM countries c
ORDER BY 2;

/*
Úkol 22: Tj. vytvořte sloupec N_S_hemisphere, který bude mít hodnotu north, 
pokud se země nachází na severní polokouli, south, 
pokud se země nachází na jižní polokouli a equator, pokud zemí prochází rovník.
 */

SELECT 
	country,
	north,
	south,
	CASE
		WHEN north > 0 THEN 'north'
		WHEN north < 0 THEN 'south'
		WHEN north = 0 THEN 'equator'
	END AS N_S_hemisphere
FROM countries c ;

##### COVID-19: ORDER BY ##### 
-- Úkol 1: Vyberte sloupec country, date a confirmed z tabulky covid19_basic pro Rakousko. Seřaďte sestupně podle sloupce date.
SELECT
	country,
	date,
	confirmed
FROM covid19_basic
	WHERE country = 'Austria'
ORDER BY 2;

-- Úkol 2: Vyberte pouze sloupec deaths v České republice.
SELECT
	deaths
FROM covid19_basic cb 
WHERE country LIKE '%Czech%';

-- Úkol 3: Vyberte pouze sloupec deaths v České republice. Seřaďte sestupně podle sloupce date.
SELECT
	deaths
FROM covid19_basic cb 
WHERE country LIKE '%Czech%'
ORDER BY date;

-- Úkol 4: Zjistěte, kolik nakažených bylo k poslednímu srpnu 2020 po celém světě.
SELECT
	SUM(confirmed)
FROM covid19_basic cb
WHERE date = '2020-08-31';

-- Úkol 5: Vyberte seznam provincií v US a seřadte jej podle názvu.
SELECT DISTINCT
	province 
FROM covid19_detail_us cdu 
ORDER BY 1 ASC;

-- Úkol 6: Vyberte pouze Českou republiku, seřaďte podle datumu a vytvořte nový sloupec udávající rozdíl mezi recovered a confirmed.
SELECT
	date,
	recovered,
	confirmed,
	ABS(recovered - confirmed) AS diff
FROM covid19_basic cb
WHERE country = 'Czechia'
ORDER BY 1;

-- Úkol 7: Vyberte 10 zemí s největším přírůstkem k 1.7.2020 a seřaďte je od největšího nárůstů k nejmenšímu.
SELECT 
	country,
	confirmed 
FROM covid19_basic cb 
WHERE date = '2020-07-01'
ORDER BY 2 DESC
LIMIT 10;

-- Úkol 8: Vytvořte sloupec, kde přiřadíte 1 těm zemím, které mají přírůstek nakažených vetši než 10000 k 30.8.2020. 
-- Seřaďte je sestupně podle velikosti přírůstku nakažených.
SELECT 
	country ,
	confirmed ,
	date,
	CASE 
		WHEN confirmed > 10000 THEN 1 ELSE 0
	END AS flag_more_than_10k
FROM covid19_basic cb
WHERE date = '2020-08-30'
ORDER BY 2 DESC;

-- Úkol 9: Zjistěte, kterým datumem začíná a končí tabulka covid19_detail_us.
SELECT 
	MIN(date),
	MAX(date)
FROM covid19_basic cb ;

-- Úkol 10: Seřaďte tabulku covid19_basic podle států od A po Z a podle data sestupně.
SELECT 
	*
FROM covid19_basic cb 
ORDER BY country, date DESC;

##### COVID-19: CASE Expression ##### 
/*
Úkol 1 Vytvořte nový sloupec flag_vic_nez_10000. 
Zemím, které měly dne 30. 8. 2020 denní přírůstek nakažených vyšší než 10000, přiřaďte hodnotu 1, ostatním hodnotu 0. 
Seřaďte země sestupně podle počtu nově potvrzených případů.
*/

SELECT
	*,
	CASE WHEN confirmed > 10000 THEN 1 ELSE 0 END AS flag_vic_nez_10000
FROM covid19_basic cb 
WHERE date = '2020-08-30'
ORDER BY confirmed;

/*
Úkol 2 Vytvořte nový sloupec flag_evropa a označte slovem Evropa země Německo, Francie, Španělsko. Zbytek zemí označte slovem Ostatni.
*/
SELECT
	country,
	CASE WHEN country IN ('Germany', 'France', 'Spain') THEN 'Evropa' ELSE 'Ostatni' END AS flag_evropa
FROM covid19_basic cb ;

-- Úkol 3 Vytvořte nový sloupec s názvem flag_ge. 
-- Do něj uložte pro všechny země, začínající písmeny "Ge", heslo GE zeme, ostatní země označte slovem Ostatni.
SELECT 
	country,
	CASE WHEN country LIKE 'Ge%' THEN 'GE' ELSE 'Ostatni' END AS flag_ge
FROM covid19_basic cb ;

/*
Úkol 4 Využijte tabulku covid19_basic_differences a vytvořte nový sloupec category. 
Ten bude obsahovat tři kategorie podle počtu nově potvrzených případů: 0-1000, 1000-10000 a >10000. 
Výslednou tabulku seřaďte podle data sestupně. Vhodně také ošetřete možnost chybějících nebo chybně zadaných dat.
*/
SELECT *,
	CASE 
		WHEN confirmed < 1000 THEN 1
		WHEN confirmed < 10000 THEN 2
		WHEN confirmed >= 10000 THEN 3
		ELSE 'Error'
	END
FROM covid19_basic_differences cbd
WHERE confirmed IS NOT NULL AND deaths IS NOT NULL AND recovered IS NOT NULL
ORDER BY date DESC;

-- Úkol 5 Vytvořte nový sloupec do tabulky covid19_basic_differences a označte hodnotou 1 ty řádky, 
-- které popisují Čínu, USA nebo Indii a zároveň mají více než 10 tisíc nově nakažených v daném dni.
SELECT 
	*,
	CASE 
		WHEN country IN ('US', 'China', 'India') AND confirmed > 10000 THEN 1
		ELSE 0
	END
FROM covid19_basic_differences cbd
;

-- Úkol 6 Vytvořte nový sloupec flag_end_a, kde označíte heslem A zeme ty země, jejichž název končí písmenem A. 
-- Ostatní země označte jako ne A zeme.
SELECT 
	country,
	CASE 
		WHEN country LIKE '%a' THEN 'A'
		ELSE 'ne A'
	END AS flag_end_a
FROM covid19_basic cb; 

##### COVID-19: WHERE, IN a LIKE ##### 
-- Úkol 1 Vytvořte view obsahující kumulativní průběh jen ve Spojených státech, Číně a Indii. Použijte syntaxi s IN.
CREATE OR REPLACE VIEW v_Michal_Titl_covid_mega_countries_only AS
SELECT
	*
FROM covid19_basic cb 
WHERE country IN ('US', 'India', 'China');

SELECT * FROM v_Michal_Titl_covid_mega_countries_only;

-- Úkol 2 Vyfiltrujte z tabulky covid19_basic pouze země, které mají populaci větší než 100 milionů.
SELECT DISTINCT 
	cb.country,
	c.population 
FROM covid19_basic cb
LEFT JOIN countries c ON cb.country = c.country
WHERE c.population > 100000000 ;

-- Úkol 3 Vyfiltrujte z tabulky covid19_basic pouze země, které jsou zároveň obsaženy v tabulce covid19_detail_us.
SELECT 
	*
FROM covid19_basic cb 
WHERE country IN (SELECT country FROM covid19_detail_us cdu );

-- Úkol 4 Vyfiltrujte z tabulky covid19_basic seznam zemí, které měly alespoň jednou denní nárůst větší než 10 tisíc nově nakažených.
SELECT DISTINCT 
	country
FROM covid19_basic cb 
WHERE confirmed > 10000;

-- Úkol 5 Vyfiltrujte z tabulky covid19_basic seznam zemí, které nikdy neměly denní nárůst počtu nakažených větší než 1000.
SELECT
--	date,
	country,
--	confirmed,
	SUM(CASE
			WHEN confirmed > 1000 THEN 1
			ELSE 0
		END) AS below_1k_flag
FROM covid19_basic cb 
WHERE confirmed IS NOT NULL
GROUP BY 1
ORDER BY 2
LIMIT 14;

-- Úkol 6 Vyfiltrujte z tabulky covid19_basic seznam zemí, které nezačínají písmenem A.
SELECT DISTINCT 
	country
FROM covid19_basic cb
WHERE country NOT LIKE 'A%'