/*
LEKCE 4_22.5.2024:
- JOIN a množinové operace
- hodí se to, protože data skládáme dočasně dohromady
- --> nevytváříme redundanci
- v kontextu NULL hodnotu máme více spojení
- základní koncept ve spojování tabulek: kartézský součin (každý s každým)
	- tzn. propojím vše se vším (1. s 1., s 2., s 3., ... s xtým, 2. s 1., s 2., ...)
	- ale je toho pak hodně --> děláme nějaké podmínky propojení
	- --> vnitřní spojení
- --> INNER JOIN: vnitřní spojení
	- spojení jen tam, kde to pasuje
	- kde ne, nespojí se a ztratí se
	- btw stačí jen JOIN, INNER není potřeba
- + vnější levé/pravé spojení
	- LEFT OUTER JOIN x RIGHT OUTER JOIN
	- v LEFT zůstane vše z levé tabulky nehledě na to, zda ne/mají NULL ve spojovacím sloupci
	- v RIGHT vše z pravé
	- ten RIGHT se hodí na větší velké joiny, ale na 95 % stačí LEFT
	- opět OUTER lze vypustit --> LEFT JOIN nebo RIGHT JOIN stačí
*/
-- Úkol 1: Spojte tabulky czechia_price a czechia_price_category. Vypište všechny dostupné sloupce.
select
	*
from czechia_price
left join czechia_price_category
	on czechia_price.category_code = czechia_price_category.code ;
	-- když bych tohle vykomentoval --> dostanu kartézský součin, tedy vše se vším spojím
-- jakou použít podmínku/join? kouknout na ERD (diagram vztahů tabulek)
-- nejčastěji za tím ON spojuji cizí klíče (spíš vlevo) s primárním klíči (spíše z tabulky vpravo)...např. data + popis dat

-- Úkol 2: Předchozí příklad upravte tak, že vhodně přejmenujete tabulky a vypíšete ID a jméno kategorie potravin a cenu.
select
	price.id,
	price.category_code,
	category.name,
	category.price_value 
from czechia_price as price
left join czechia_price_category as category
	on price.category_code = category.code
-- order by 4 desc
;

-- Úkol 3: Přidejte k tabulce cen potravin i informaci o krajích ČR a vypište informace o cenách společně s názvem kraje.
SELECT 
	cp.id,
	cp.value,
	cp.category_code,
	cp.region_code,
	cr.name 
FROM czechia_price cp
LEFT JOIN czechia_region cr 
	ON cp.region_code = cr.code;

-- Úkol 4: Využijte v příkladě z předchozího úkolu RIGHT JOIN s výměnou pořadí tabulek. Jak se změní výsledky?
SELECT 
	cp.id,
	cp.value,
	cp.category_code,
	cp.region_code,
	cr.name 
FROM czechia_region cr
RIGHT JOIN czechia_price cp 
	ON cr.code = cp.region_code;

-- Úkol 5: K tabulce czechia_payroll připojte všechny okolní tabulky. Využijte ERD model ke zjištění, které to jsou.
SELECT *
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_calculation cpc 
	ON cp.calculation_code  = cpc.code 
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cp.industry_branch_code  = cpib.code
LEFT JOIN czechia_payroll_unit cpu 
	ON cp.unit_code = cpu.code 
LEFT JOIN czechia_payroll_value_type cpvt 
	ON cp.value_type_code = cpvt.code
;

-- Úkol 6: Přepište dotaz z předchozí lekce do varianty, ve které použijete JOIN,
SELECT 
	cpib.*
FROM czechia_payroll_industry_branch cpib
LEFT JOIN czechia_payroll cp 
	ON cpib.code = cp.industry_branch_code 
WHERE cp.value_type_code = 5958
ORDER BY cp.value DESC 
LIMIT 1;

/*
Úkol 7: Spojte informace z tabulek cen a mezd (pouze informace o průměrných mzdách). 
Vypište z každé z nich základní informace, celé názvy odvětví a kategorií potravin a datumy měření, které vhodně naformátujete.
*/
SELECT
	cpib.name,
	cp.value,
	cpc.name,
	cpay.value,
	cpay.payroll_year,
	DATE_FORMAT(cp.date_from, '%d.%m.%Y') AS date_from,
	DATE_FORMAT(cp.date_to, '%d.%m.%Y') AS date_to
FROM czechia_price cp 
INNER JOIN czechia_payroll cpay
	ON cpay.payroll_year = YEAR(cp.date_from) -- matchuju přes INNER, protože matchuju přes rok a nečekám null
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = cpay.industry_branch_code 
LEFT JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
WHERE cpay.value IS NOT NULL ;

-- Úkol 8: K tabulce healthcare_provider připojte informace o regionech a vypište celé názvy krajů i okresů pro místa výkonu i sídla.
SELECT 
	hp.name provider_name,
	cd.name district_name,
	cr.name region_name,
	cr2.name residence_region_name,
	cd2.name residence_district_name
FROM healthcare_provider hp 
LEFT JOIN czechia_district cd 
	ON hp.district_code = cd.code
LEFT JOIN czechia_region cr 
	ON hp.region_code = cr.code 
LEFT JOIN czechia_region cr2 
	ON hp.residence_region_code = cr2.code
LEFT JOIN czechia_district cd2 
	ON hp.residence_district_code = cd2.code ;

-- Úkol 9: Upravte předchozí dotaz tak, aby byli na výpisu pouze takoví poskytovatelé, 
-- kteří mají sídlo v jiném kraji i jiném okrese než místo poskytování služeb.
SELECT 
	hp.name provider_name,
	cd.name district_name,
	cr.name region_name,
	cr2.name residence_region_name,
	cd2.name residence_district_name
FROM healthcare_provider hp 
LEFT JOIN czechia_district cd 
	ON hp.district_code = cd.code
LEFT JOIN czechia_region cr 
	ON hp.region_code = cr.code 
LEFT JOIN czechia_region cr2 
	ON hp.residence_region_code = cr2.code
LEFT JOIN czechia_district cd2 
	ON hp.residence_district_code = cd2.code 
WHERE cd.name != cd2.name AND cr.name != cr2.name;

/* ### Kartézský součin a CROSS JOIN ### */
-- ekvivalentní varianta pro INNER JOIN v MariaDB
-- ve standardním SQL ale NEJSOU ekvivalentní! (nebo nedovolí to striktní režim SQL)

-- Úkol 1: Spojte tabulky czechia_price a czechia_price_category pomocí kartézského součinu.
SELECT *
FROM czechia_price cp, czechia_price_category cpc ;
	-- takhle je to každý s každým a omezující podmínka se dává do WHERE podobně jako ON
SELECT *
FROM czechia_price cp, czechia_price_category cpc 
WHERE cp.category_code = cpc.code ;

-- Úkol 2: Převeďte předchozí příklad do syntaxe s CROSS JOIN. => ekvivalentní dotazy
SELECT *
FROM czechia_price cp
CROSS JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code ;

-- Úkol 3: Vytvořte všechny kombinace krajů kromě těch případů, kdy by se v obou sloupcích kraje shodovaly.
SELECT 
	cr.name first_region,
	cr2.name second_region
FROM czechia_region cr 
CROSS JOIN czechia_region cr2 
WHERE cr.code != cr2.code;

/* ### Množinové operace ### 
- sjednocení = UNION
- POZOR NA POŘADÍ A POČET SLOUPCŮ!
- ale samotné množiny/selecty neřeším
- průnik = INTERSECT
- rozdíl = EXCEPT (= co je v A a není v B)
*/
-- Úkol 1: Přepište následující dotaz na variantu spojení dvou separátních dotazů se selekcí pro každý kraj zvlášť.
SELECT category_code, value
FROM czechia_price cp 
WHERE region_code = 'CZ064'
UNION ALL						-- UNION ALL ... ALL zahrne i duplicitní hodnoty
SELECT category_code, value
FROM czechia_price cp 
WHERE region_code = 'CZ010';

-- Úkol 2: Upravte předchozí dotaz tak, aby byly odstraněny duplicitní záznamy.
SELECT category_code, value
FROM czechia_price cp 
WHERE region_code = 'CZ064'
UNION 						-- UNION  ... není tam ALL -->  nezahrne i duplicitní hodnoty
SELECT category_code, value
FROM czechia_price cp 
WHERE region_code = 'CZ010';

-- Úkol 3: Sjednoťe kraje a okresy do jedné množiny. Tu následně seřaďte dle kódu vzestupně.
SELECT code, name
FROM czechia_region
UNION
SELECT code, name
FROM czechia_district
ORDER BY 1;

-- Úkol 4: Vytvořte průnik cen z krajů Hl. město Praha a Jihomoravský kraj.
SELECT category_code, value
FROM czechia_price cp 
WHERE region_code = 'CZ064'
INTERSECT  						
SELECT category_code, value
FROM czechia_price cp 
WHERE region_code = 'CZ010';

/*
Úkol 5: Vypište kód a název odvětví, ID záznamu a hodnotu záznamu průměrných mezd a počtu zaměstnanců. 
Vyberte pouze takové záznamy, které se shodují v uvedené hodnotě a spadají do odvětví s označením A nebo B.
*/
SELECT 
	cpib.*,
	cp.id,
	cp.value 
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cp.industry_branch_code = cpib.code 
WHERE value IN (
		SELECT value 
		FROM czechia_payroll cp
		WHERE industry_branch_code = 'A'
		INTERSECT 
		SELECT value 
		FROM czechia_payroll cp
		WHERE industry_branch_code = 'B'
);

CREATE INDEX i_czechia_payroll__value ON czechia_payroll(value);
DROP INDEX i_czechia_payroll__value ON czechia_payroll;
	-- díky tomu se teď zrychlil ten předchozí dotaz
	-- ALE nemůžu je mít všude, protože ten index se musí vždy vytvářet znovu
	-- takže sice download je rychlejší, ale upload násobně delší
	-- občas je tak dobrý je před uploadem dropnout a pak znovu vytvořit

/* ### Common Table Expression ###  
- svým způsobem umožní vytvářet dočasné tabulky k použití v dotazech
- po použití v querry se jakoby ztratí
- hodí se to na přípravu dat, pro která si chci sáhnout v rámci querry
- těch tabulke pod WITH lze mít víc (jen dám za tu první čárku, název_druhé, AS a samotný select)

*/
-- Úkol 1: Pomocí operátoru WITH připravte tabulku s cenami nad 150 Kč. 
-- S její pomocí následně vypište jména takových kategorií potravin, které do této cenové hladiny spadají.
WITH high_prices AS (
	SELECT DISTINCT category_code 
	FROM czechia_price cp 
	WHERE value > 150
)
SELECT *
FROM high_prices hp
JOIN czechia_price_category cpc
	ON hp.category_code = cpc.code;
;

-- Úkol 2: Zjistěte, ve kterých okresech mají všichni praktičtí lékaři vyplněný telefon, fax, nebo e-mail. 
-- Pro tyto účely si připravte dočasnou tabulku s výčtem okresů, ve kterých tato podmínka naopak splněna není, 
-- pod názvem not_completed_provider_info_district.
WITH not_completed_provider_info_district AS (
	SELECT DISTINCT hp.district_code
	FROM healthcare_provider hp 
	WHERE hp.provider_type LIKE '%Samost. ordinace všeob. prakt. lékaře%' AND hp.phone IS NULL AND hp.fax IS NULL AND hp.email IS NULL
)
SELECT *
FROM czechia_district
WHERE code NOT IN (
	SELECT *
	FROM not_completed_provider_info_district
)
;

-- Úkol 3: Vypište z tabulky economies průměr světových daní, při HDP vyšším než 70 miliard.
WITH large_gdp_ares AS (
	SELECT *
	FROM economies e 
	WHERE gdp > 70000000000
)
SELECT
	country,
	ROUND(AVG(taxes), 2) AS taxes_avg
FROM large_gdp_ares
GROUP BY 1
ORDER BY 2 DESC 
;

WITH large_gdp_ares AS (
	SELECT *
	FROM economies e 
	WHERE gdp > 70000000000
),
larger_gdp_areas AS (
	SELECT *
	FROM economies e 
	WHERE gdp > 70000000000000
)
SELECT *
FROM large_gdp_ares
INTERSECT
SELECT *
FROM larger_gdp_areas;

/* ### BONUSOVÁ CVIČENÍ ### 
	### Countries: JOIN ### 
*/
-- Úkol 1: K tabulce countries připojte tabulku religions. Vybere název státu, hlavní město, celkovou populaci, název náboženství
--  a počet jeho příslušníků. Vyberte pouze rok 2020.
SELECT
	c.country,
	c.capital_city,
	c.population ,
	r.religion ,
	r.population 
FROM countries c
LEFT JOIN religions r 
	ON c.country = r.country AND r.YEAR = 2020;

-- Úkol 2: K tabulce countries připojte tabulku economies. Pro každý stát vyberte hodnoty HDP v milionech dolarů, gini koeficient a daně za období, 
-- kdy byla země samostatná (independence_date).
SELECT 
	c.country,
	c.independence_date,
	e.`year`,
	e.GDP,
	e.gini,
	e.taxes
FROM countries c
LEFT JOIN economies e 
	ON c.country = e.country
WHERE e.`year` <= c.independence_date 
;

SELECT
*
FROM economies e 
ORDER BY YEAR;

-- Úkol 3: Zjistěte, které země se nacházejí v tabulce countries, ale ne v tabulce economies. Seřaďte je sestupně podle počtu obyvatel.
WITH missing_countries AS (
	SELECT country
	FROM countries c
	EXCEPT
	SELECT country 
	FROM economies e 
	)
SELECT
	missing_countries.country,
	countries.population
FROM missing_countries
INNER JOIN countries
	ON countries.country = missing_countries.country 
ORDER BY 2 desc
;

-- Úkol 4: Joiny můžeme používat nejenom pro spojování dvou různých tabulek. Můžeme napojovat i jednu tabulku samu na sebe, 
-- abychom z ní zjistili nové informace. 
-- Použijte tabulku life_expectancy abyste pro každý stát zjistili podíl doby dožití v roce 2015 a v roce 1970.
SELECT 
	le.country,
	le.life_expectancy AS life_expectancy_1970,
	le2.life_expectancy AS life_expectancy_2015,
	round(le2.life_expectancy/le.life_expectancy, 2) AS result
FROM life_expectancy le 
LEFT JOIN life_expectancy le2 
	ON le.country = le2.country AND le2.YEAR = 2015
WHERE le.YEAR = 1970;

-- Úkol 5: Z tabulky economies spočítejte meziroční procentní nárůst populace a procentní nárůst HDP pro každou zemi.
SELECT 
	e.country,
	e.year,
--	e.population,
--	e.gdp,
--	e2.population population_minus_year,
--	e2.gdp gdp_minus_year,
	round(((e.population/e2.population)-1)*100, 2) population_percent_diff,
	round(((e.gdp/e2.gdp)-1)*100, 2) gdp_percent_diff
FROM economies e
LEFT JOIN economies e2 
	ON e.country = e2.country AND e.YEAR-1 = e2.YEAR;

-- Úkol 6: Počty věřících v tabulce religions pro rok 2020 přepočítejte na procentní podíl.
WITH population_sum AS (
	SELECT
		country,
		YEAR,
		SUM(population) AS sum_of_popul
	FROM religions r 
	GROUP BY 1, 2
)
SELECT 
	r.*,
	ps.sum_of_popul,
	round((r.population/ps.sum_of_popul)*100, 2) AS percent_of_population
FROM religions r
LEFT JOIN population_sum ps
	ON r.country = ps.country AND r.YEAR = ps.YEAR
WHERE r.population > 0
ORDER BY 1, 2;
-- btw řešení dle akademie počítá imo špatně

-- ### COVID-19: JOIN ### 
-- Úkol 1a: Vytvořte view z lookup_table, kde je sloupec provincie null
CREATE OR REPLACE VIEW v_lookup_provice_null AS 
SELECT * FROM lookup_table lt 
WHERE province IS null;

SELECT * FROM v_lookup_provice_null;

-- Úkol 1b: Spojte pomocí left join tabulku covid19_basic s view vytvořeným v předchozím úkolu přes country
SELECT *
FROM covid19_basic cb 
LEFT JOIN v_lookup_provice_null vlpn
	ON cb.country = vlpn.country;

-- Úkol 2: Spojte tabulky covid19_basic a covid19_basic_difference pomocí left join
SELECT *
FROM covid19_basic cb
LEFT JOIN covid19_basic_differences cbd 
	ON cb.country = cbd.country AND cb.`date` = cbd.`date` ;

/*
Úkol 3: Spojte tabulky covid19_detail_us a covid19_detail_us_differences skrze sloupce date, country, admin2. 
Z tabulky covid19_detail_us vyberte všechny sloupce a tabulky covid19_detail_us_differences jen confirmed a přejmenujte ho na confirmed_diff. 
Pro spojení použijte left join
*/
SELECT
	cdu.*,
	cdud.confirmed confirmed_diff
FROM covid19_detail_us cdu 
LEFT JOIN covid19_detail_us_differences cdud
	ON cdu.`date` = cdud.`date` AND cdu.country = cdud.country AND cdu.admin2 = cdud.admin2;

-- Úkol 4: Spojte pomocí left join tabulky covid19_detail_us, covid19_detail_us_differences a lookup_table
SELECT 
	*
FROM covid19_detail_us cdu
LEFT JOIN covid19_detail_us_differences cdud
	ON cdu.`date` = cdud.`date` AND cdu.country = cdud.country AND cdu.admin2 = cdud.admin2
LEFT JOIN lookup_table lt 
	ON cdu.country = lt.country AND cdu.province = lt.province ;

-- Úkol 5: Spojte pomocí left join tabulky covid19_detail_global a covid19_detail_global_differences
SELECT *
FROM covid19_detail_global cdg 
LEFT JOIN covid19_detail_global_differences cdgd 
	ON cdgd.country = cdg.country AND cdgd.`date` = cdg.`date` AND cdgd.province = cdg.province ;

-- Úkol 6: Spojte pomocí left join tabulky covid19_detail_global , covid19_detail_global_differences a lookup_table
SELECT *
FROM covid19_detail_global cdg 
LEFT JOIN covid19_detail_global_differences cdgd 
	ON cdgd.country = cdg.country AND cdgd.`date` = cdg.`date` AND cdgd.province = cdg.province 
LEFT JOIN lookup_table lt 
	ON lt.country = cdg.country AND lt.province = cdg.province ;

-- Úkol 7: Jaký je průbeh počtu nakažených na milion obyvatel v Česke republice a v Německu
WITH lookup_table AS (
SELECT
	country,
	population
FROM lookup_table lt 
WHERE country IN ('Germany', 'Czechia') AND province IS null
GROUP BY 1
)
SELECT
	cb.`date` ,
	cb.country ,
	cb.confirmed ,
	lt.population,
	round(cb.confirmed/(lt.population/1000000), 2) confirmed_per_million_ppl
FROM covid19_basic cb
LEFT JOIN lookup_table lt 
	ON cb.country = lt.country 
WHERE cb.country IN ('Germany', 'Czechia')
ORDER BY `date` desc;

-- Úkol 8: Seřaďte státy podle počtu celkově nakažených na milion obyvatel k 30.8.2020?
-- btw engeto řešení není seřazené
SELECT 
	cb.*,
	lt.population,
	round(cb.confirmed/(lt.population/1000000), 2) confirmed_per_million_ppl
FROM covid19_basic cb 
LEFT JOIN lookup_table lt 
	ON cb.country = lt.country AND lt.province IS NULL
WHERE `date` = '2020-08-30'
ORDER BY 7 desc;

-- Úkol 9: Ukaž celosvětový průběh celkově nakaženych na milion obyvatel
SELECT 
	`date`,
	sum(cb.confirmed)/(sum(lt.population)/1000000) confirmed_per_million_ppl
FROM covid19_basic cb 
LEFT JOIN lookup_table lt 
	ON cb.country = lt.country AND lt.province IS NULL
GROUP BY `date` 
ORDER BY `date`;

-- Úkol 10: Z tabulky lookup_table vyberte pouze země s populací menší než milion 
-- a připojte k této tabulce průběh jejich nakažených. (Použijte inner join)
SELECT
--	lt.country,
	cb.*
FROM lookup_table lt 
JOIN covid19_basic cb 
	ON lt.country = cb.country 
WHERE population < 1000000 AND province IS NULL;

-- Úkol 11: Udělejte seznam všech zemí pro všechny datumy z tabulky covid19_basic
SELECT DISTINCT 
	cb.`date`,
	cb2.country 
FROM
	(
	SELECT DISTINCT 
	`date` 
	FROM covid19_basic cb 
	) cb
CROSS JOIN
	(
	SELECT DISTINCT 
	country
	FROM covid19_basic cb 
	)cb2 
ORDER BY 1 ;

-- Úkol 12: Udělejte seznam všech zemí pro všechny datumy z tabulky covid19_basic. K této tabulce připojte přírůstky a kde nejsou data vložte 0.
SELECT * FROM covid19_basic_differences cbd;

SELECT DISTINCT 
	cb.`date`,
	cb2.country,
	CASE WHEN cbd.confirmed IS NULL THEN 0 ELSE cbd.confirmed END AS confirmed 
FROM
	(
	SELECT DISTINCT 
	`date` 
	FROM covid19_basic cb 
	) cb
CROSS JOIN
	(
	SELECT DISTINCT 
	country
	FROM covid19_basic cb 
	)cb2 
LEFT JOIN covid19_basic_differences cbd 
	ON cb.`date` = cbd.`date` AND cb2.country = cbd.country ;