
/*
LEKCE 3_15.5.2024:
- local host má adresu 127.0.0.1
- obecně default port je 3306, občas je plný kvůli jinému systému/DB
- DBs je hodně dobrý zálohovat (dump/backup)
- z toho pak děláme obnovnu (restore)

- připojování nové DB
	- vlevo nahoře New Database connection
	- server Host: localhost
	- port: dle situace
	- username je důležitý, zde je to root (v práci to ale málokdo má)
	- případně pak heslo, pokud jsme nastavovali
	
- tvorba nové DB
	- dobrá volba charsetu: utf8mb4

- restornutí zálohy
	- pravým na DB
	- Tools --> Restore database

- záloha
	- podobně skrze Tools, jen Dump database
	- tam nasetupuju, kterou DB a jaký settings
	- výsledkem je vygenerovaný SQL soubor k potenciální obnově

- export CSV z tabulky
	- pravým na tabulku
	- Export data
	- a tam si vyberu typ filu, vlastnosti a tak
	- je dobrý u csv checknout třeba oddělovač
*/

/* ##### Fce COUNT() ##### */
-- Úkol 1: Spočítejte počet řádků v tabulce czechia_price.
select
	count(1)		-- tohle řešení technicky doplní ke všem řádkům jedničku a ty sečte
from czechia_price cp ;

-- count(1) je asi trochu lepší, hlavně na velkých datech
-- hodí se na ověřování ETL

select
	count(*)		-- tohle se podívá na každý záznam
from czechia_price cp ;

-- Úkol 2: Spočítejte počet řádků v tabulce czechia_payroll s konkrétním sloupcem jako argumentem funkce COUNT().
select 
	COUNT(id)		-- tohle se hodí, protože je to primární klíč --> VŽDY to BUDE VYPLNĚNÉ (COUNT nebere NULL jako hodnotu)
from czechia_payroll cp; 

-- Úkol 3: Z kolika záznamů v tabulce czechia_payroll jsme schopni vyvodit průměrné počty zaměstnanců?
select COUNT(id)
from czechia_payroll cp 
where value_type_code = 316
and value is not null;

-- Úkol 4: Vypište všechny cenové kategorie a počet řádků každé z nich v tabulce czechia_price.
select
	category_code,
	count(id)
from czechia_price cp
group by 1; 			-- btw MariaDB nehodí chybu, když NEDÁM group by!

-- Úkol 5: Rozšiřte předchozí dotaz o dadatečné rozdělení dle let měření.
select
	category_code,
	year(date_from),
	count(id)
from czechia_price cp
group by 1, 2;

/* ##### Fce SUM() ##### */
-- Úkol 1: Sečtěte všechny průměrné počty zaměstnanců v datové sadě průměrných platů v České republice.
select sum(value) 
from czechia_payroll cp 
where value_type_code = 316 and value is not null;

-- Úkol 2: Sečtěte průměrné ceny pro jednotlivé kategorie pouze v Jihomoravském kraji.
select
	cp.category_code,
	SUM(cp.value)
from czechia_price cp 
left join czechia_region cr 
on cr.code = cp.region_code
where cr.name = 'Jihomoravský kraj'
group by 1;

-- Úkol 3: Sečtěte průměrné ceny potravin za všechny kategorie, u kterých měření probíhalo od (date_from) 15. 1. 2018.
select
	sum(value)
from czechia_price cp
where date_from >= cast('2018-01-15' as date);	
-- cast je vždy lepší, když pracujeme s datem, když by to náhodou byl string
-- je tam důležité pak to as datovy_typ, kde volím na co to vlastně chci převádět

-- Úkol 4: Vypište tři sloupce z tabulky czechia_price: kód kategorie, počet řádků pro ni a sumu hodnot průměrných cen. 
-- To vše pouze pro data v roce 2018.
select	
	category_code,
	count(value),
	sum(value)
from czechia_price cp
where year(date_from) = '2018'
group by 1;

/* ##### Další agregační funkce ##### */
-- Úkol 1: Vypište maximální hodnotu průměrné mzdy z tabulky czechia_payroll.
select
	max(value)
from czechia_payroll cp
where value_type_code = 5958;

-- Úkol 2: Na základě údajů v tabulce czechia_price vyberte pro každou kategorii potravin její minimum v letech 2015 až 2017.
select
	category_code,
	min(value)
from czechia_price cp 
where year(date_from) >= 2015 and year(date_from) <= 2017
group by 1;

-- Úkol 3: Vypište kód (případně i název) odvětví s historicky nejvyšší průměrnou mzdou.
select
	cpib.name,
	MAX(cp.value)
from czechia_payroll cp
left join czechia_payroll_industry_branch cpib 
	on cp.industry_branch_code  = cpib.code
where cp.value_type_code = 5958
group by cp.industry_branch_code
order by 2 desc
limit 1;

/*
Úkol 4: Pro každou kategorii potravin určete její minimum, maximum a vytvořte nový sloupec s názvem difference, 
ve kterém budou hodnoty "rozdíl do 10 Kč", "rozdíl do 40 Kč" a "rozdíl nad 40 Kč" na základě rozdílu minima a maxima. 
Podle tohoto rozdílu data seřaďte.
*/
select
	category_code,
	min(value),
	max(value),
	max(value)-min(value),
	case
		when (max(value)-min(value)) < 10 then 'rozdil do 10 CZK'
		when (max(value)-min(value)) < 40 then 'rozdil do 40 CZK'
		else 'rozdil nad 40 CZK'
	end as difference	
from czechia_price cp 
group by 1
order by 4;

-- Úkol 5: Vyberte pro každou kategorii potravin minimum, maximum a aritmetický průměr (v našem případě průměr z průměrů) 
-- zaokrouhlený na dvě desetinná místa.
select
	category_code,
	min(value),
	max(value),
	round(avg(value), 2)
from czechia_price cp 
group by 1;

-- Úkol 6: Rozšiřte předchozí dotaz tak, že data budou rozdělena i podle kódu kraje a seřazena sestupně podle aritmetického průměru.
select
	category_code,
	region_code,
	min(value),
	max(value),
	round(avg(value), 2)
from czechia_price cp 
group by 1, 2
order by 5 DESC;

/* ##### Další operace v klauzuli SELECT ##### */
-- Úkol 1: Vyzkoušejte si následující dotazy. Co vypisují a proč?
SELECT SQRT(-16); -- mělo by hodit chybu, ale opět MDB to zkusí
SELECT 10/0;		-- obdobně ... dělit nulou nemůžu žejo
SELECT FLOOR(1.56); -- default zaokrouhleno dolů
SELECT FLOOR(-1.56);-- ---------//-----------
SELECT CEIL(1.56);	-- default nahoru
SELECT CEIL(-1.56); -- ------//----
SELECT ROUND(1.56);	-- tohle dává nejvíc smysl ... zaokrouhluje na nejbližší + lze specifikovat počet desetinných míst
SELECT ROUND(-1.56); -- ----------------------------------//------------------------------------------------------

-- Úkol 2: Vypočítejte průměrné ceny kategorií potravin bez použití funkce AVG() s přesností na dvě desetinná místa.
select
	category_code,
	round(SUM(value)/count(value), 2) as avg_price
from czechia_price cp 
group by 1;

-- Úkol 3: Jaké datové typy budou mít hodnoty v následujících dotazech?
SELECT 1; 
SELECT 1.0;
SELECT 1 + 1;
SELECT 1 + 1.0;
SELECT 1 + '1';	-- jakoby decimal, je to ale fuj fuj
SELECT 1 + 'a';	-- vrátí 1, ale má to být ERROR
SELECT 1 + '12tatata';

-- Úkol 4: Vyzkoušejte si spustit dotazy, jež operují s textovými řetězci.
SELECT CONCAT('Hi, ', 'Engeto lektor here!');
SELECT CONCAT('We have ', COUNT(DISTINCT category_code), ' price categories.') AS info
FROM czechia_price;
SELECT name,
    SUBSTRING(name, 1, 2) AS prefix,	-- POZOR, sql bere index od 1, ne od nuly!
    SUBSTRING(name, -2, 2) AS suffix,
    LENGTH(name),						-- ALE CHAR_LENGTH je lepší, protože řeší nebere bity, ale znaky (problém s diakritikou)
    substring(name, -2, -1) as does_backwards_work
FROM czechia_price_category;

-- Úkol 5: Vyzkoušejte si operátor modulo (zbytek po celočíselném dělení).
select
	5 % 5,
	5 % 10,
	5 % 0,
	1.2 % 1,
	2 % 1.2;
SELECT 123456789874 % 11;
SELECT 123456759874 % 11;
SELECT 55225055 % 11;

-- Úkol 6: Využijte operátor modulo na zjištění sudosti populace v tabulce economies.
select
	country,
	population,
	case
		when population % 2 = 0 then 'sudé'
		else 'liché'
	end as 'sudost'
from economies e 
order by 3
-- desc
;

/* ##### BONUSOVÁ CVIČENÍ ##### */
/* ##### Countries: Další cvičení ##### */
/*
Úkol 1:
Zjistěte celkovou populaci kontinentů.
Zjistěte průměrnou rozlohu států rozdělených podle kontinentů
Zjistěte počty států podle rozdělených podle hlavního náboženství
Státy vhodně seřaďte.
*/
select
	continent,
	SUM(population)
from countries c
where continent is not null
group by 1
order by 2 DESC;

select
	continent,
	round(avg(surface_area), 2)
from countries c
where continent is not null
group by 1
order by 2 DESC;

select
	religion,
	count(country)
from countries c
where religion is not null
group by 1
order by 2 DESC;

/*
Úkol 2:
Zjistěte celkovou populaci, průměrnou populaci a počet států pro každý kontinent
Zjistěte celkovou rozlohu kontinentu a průměrnou rozlohu států ležících na daném kontinentu
Zjistěte celkovou populaci a počet států rozdělených podle hlavního náboženství
 */
select
	continent,
	sum(population),
	round(avg(population)),
	count(country)
from countries c 
where continent is not null
group by 1
order by 2 desc;

select
	continent,
	sum(surface_area),
	round(avg(surface_area), 2)
from countries c 
group by 1;

select 
	religion,
	sum(population),
	count(country)
from countries c 
group by 1

-- Úkol 3: Pro každý kontinent zjistěte podíl počtu vnitrozemských států (sloupec landlocked), 
-- podíl populace žijící ve vnitrozemských státech a podíl rozlohy vnitrozemských států.
select
	continent,
	round(sum(case when landlocked = 1 then 1 else 0 end)/count(*), 2) as ct_of_inland,
	round(sum(case when landlocked = 1 then population else 0 end)/sum(population), 2) as inland_popul,
	round(sum(case when landlocked = 1 then surface_area else 0 end)/sum(surface_area), 2) as inland_surface
from countries c 
where continent is not null and landlocked is not null
group by 1;

-- Úkol 4: Zjistěte celkovou populaci ve státech rozdělených podle kontinentů a regionů (sloupec region_in_world). 
-- Seřaďte je podle kontinentů abecedně a podle populace sestupně.
select
	continent,
	region_in_world ,
	sum(population)
from countries c 
group by 1, 2
order by 1 asc, 3 desc;

-- Úkol 5: Zjistěte celkovou populaci a počet států rozdělených podle kontinentů a podle náboženství. 
-- Kontinenty seřaďte abecedně a náboženství v rámci kontinentů sestupně podle populace.
select 
	continent,
	religion,
	sum(population),
	count(country)
from countries c 
group by 1, 2
order by 1, 3 desc;

-- Úkol 6: Zjistěte průměrnou roční teplotu v regionech Afriky.
select
	region_in_world,
	avg(yearly_average_temperature)
from countries c 
where continent  = 'Africa'
group by 1;

/* ##### COVID-19: funkce SUM() ##### */
-- Úkol 1: Vytvořte v tabulce covid19_basic nový sloupec, 
-- kde od confirmed odečtete polovinu recovered a přejmenujete ho jako novy_sloupec. Seřaďte podle data sestupně.
select 
	*,
	confirmed - 0.5 * recovered as novy_sloupec
from covid19_basic cb
order by date desc;

-- Úkol 2: Kolik lidí se celkem uzdravilo na celém světě k 30.8.2020?
select 
	sum(recovered)
from covid19_basic cb
where date = '2020-08-30';

-- Úkol 3: Kolik lidí se celkem uzdravilo, a kolik se jich nakazilo na celém světě k 30.8.2020?
select 
	sum(recovered),
	sum(confirmed)
from covid19_basic cb
where date = '2020-08-30';

-- Úkol 4: Jaký je rozdíl mezi nakaženými a vyléčenými na celém světě k 30.8.2020?
select 
	sum(confirmed) - sum(recovered)
from covid19_basic cb
where date = '2020-08-30';

-- Úkol 5: Z tabulky covi19_basic_differences zjistěte, kolik lidí se celkem nakazilo v České republice k 30.8.2020.
select
	sum(confirmed)
from covid19_basic_differences cbd 
where country = 'Czechia' and date = '2020-08-30';

-- Úkol 6: Kolik lidí se nakazilo v jednotlivých zemích během srpna 2020?
select
	country,
	sum(confirmed)
from covid19_basic_differences cbd 
where date like '2020-08-%'
group by 1;

-- Úkol 7: Kolik lidí se nakazilo v České republice, na Slovensku a v Rakousku mezi 20.8.2020 a 30.8.2020 včetně?
select 
	sum(confirmed)
from covid19_basic_differences cbd 
where country in ('Czechia', 'Slovakia', 'Austria') and date >= '2020-08-20' and date <= '2020-08-30';

-- Úkol 8: Jaký byl největší přírůstek v jednotlivých zemích?
select 
	country,
	max(confirmed)
from covid19_basic_differences cbd 
group by 1;

-- Úkol 9: Zjistěte největší přírůstek v zemích začínajících na C.
select 
	country,
	max(confirmed)
from covid19_basic_differences cbd 
where country like 'C%'
group by 1;

-- Úkol 10: Zjistěte celkový přírůstek všech zemí s populací nad 50 milionů. Tabulku seřaďte podle datumu od srpna 2020.
select 
	cbd.country,
	sum(cbd.confirmed)
from covid19_basic_differences cbd 
	left join countries c 
	on cbd.country = c.country 
where c.population > 50000000 and cbd.date >= '2020-08-01'
group by 1;

-- Úkol 11: Zjistěte celkový počet nakažených v Arkansasu (použijte tabulku covid19_detail_us_differences).
select 
	sum(confirmed)
from covid19_detail_us_differences cdud 
where province = 'Arkansas';

-- Úkol 12: Zjistětě nejlidnatější provincii v Brazílii.
select 
	province,
	max(confirmed)
from covid19_detail_global cdg 
where country = 'Brazil' and province != 'Unknown'
group by 1
order by 2 desc
limit 1;

-- Úkol 13: Zjistěte celkový a průměrný počet nakažených denně po dnech a seřaďte podle data sestupně 
-- (průměr zaokrouhlete na dvě desetinná čísla)
select
	date,
	round(avg(confirmed), 2),
	sum(confirmed)
from covid19_basic_differences cbd 
group by 1
order by 1 desc;

-- Úkol 14: Zjistěte celkový počet nakažených lidí v jednotlivých provinciích USA dne 30.08.2020 (použijte tabulku covid19_detail_us).
select
	province,
	sum(confirmed)
from covid19_detail_us cdu
where `date` = '2020-08-30'
group by 1;

-- Úkol 15: Zjistěte celkový přírůstek podle datumu a země.
select 
	country,
	`date`,
	sum(confirmed)
from covid19_basic_differences cbd 
group by 1, 2;

/* ##### COVID-19: funkce AVG() a COUNT() ##### */
-- Úkol 1: Zjistěte průměrnou populaci ve státech ležících severně od 60 rovnoběžky.
select 
	avg(population)
from lookup_table
where lat > 60;

/*
Úkol 2: Zjistěte průměrnou, nejvyšší a nejnižší populaci v zemích ležících severně od 60 rovnoběžky. 
Spočítejte, kolik takových zemích je. Vytvořte sloupec max_min_ratio, ve kterém nejvyšší populaci vydělíte nejnižší.
*/
select 
	avg(population),
	max(population),
	min(population),
	count(*),
	max(population)/min(population) as max_min_ratio
from lookup_table lt
where lat > 60;

-- Úkol 3: Zjistěte průměrnou populaci a rozlohu v zemích seskupených podle náboženství. Zjistěte také počet zemí pro každé náboženství.
select 
	religion ,
	avg(population),
	avg(surface_area),
	count(country)
from countries c 
group by 1;

-- Úkol 4: Zjistěte počet zemí, kde se platí dolarem (jakoukoli měnou, která má v názvu dolar). 
-- Zjistěte nejvyšší a nejnižší populaci mezi těmito zeměmi.
select 
	count(country),
	min(population),
	max(population)
from countries c 
where lower(currency_name) like '%dollar%';

-- Úkol 5: Zjistěte, kolik zemí platících Eurem leží v Evropě a kolik na jiných kontinentech.
select 
	count(case when continent = 'Europe' then 1 else null end) as europe,
	count(case when continent != 'Europe' then 1 else null end) as non_europe
from countries c 
where currency_code = 'EUR';

-- Úkol 6: Zjistěte, pro kolik zemí známe průměrnou výšku jejích obyvatel.
select
	count(*)
from countries c
where avg_height is not null; 

-- Úkol 7: Zjistěte průměrnou výšku obyvatel na jednotlivých kontinentech.
select
	continent,
	round(avg(avg_height), 2)
from countries c
where avg_height is not null
group by 1;

-- úkol 8-9:
SELECT region_in_world ,
    round( avg(population_density), 2 ) AS simple_avg_density,
    round( sum(surface_area*population_density) / sum(surface_area), 2 ) AS weighted_avg_density,
    round(sum(population)/sum(surface_area),2), 
    -- plocha krát hustota plochy je přece počet lidí, ne? hustota je XY lidí/km2, takže když násobím počtem km2, přijdu to ten dělitel
    round(abs(avg(population_density)-sum(surface_area*population_density) / sum(surface_area)), 2) as diff_avg_density
FROM countries c 
WHERE population_density IS NOT NULL AND region_in_world IS NOT null and population is not null and surface_area is not null
GROUP BY region_in_world  


