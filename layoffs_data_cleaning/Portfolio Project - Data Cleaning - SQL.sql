-- DATA CLEANING

-- 1. remove duplicates
-- 2. standardize the data (spelling, outlier...)
-- 3. null or blank values
-- 4. remove any columns

SELECT * 
FROM world_layoffs.layoffs;

-- backup
create TABLE layoffs_staging Like layoffs; -- replicates only the schema
insert layoffs_staging select * from layoffs; -- inserts the data
select * from layoffs_staging; -- verifes the table data

-- shorter version
-- create table layoffs_staging AS select * from layoffs -- replicates both schema and data in one go
-- select * from layoffs_staging


-- 1. Remove Duplicates

# First let's check for duplicates
SELECT *
FROM world_layoffs.layoffs_staging;

-- identify duplicates using CTE

with duplicate_cte AS
(
select *, row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num -- date is a sql keyword so use backtick
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

-- to confirm
select * 
from layoffs_staging
where company like "ODA"; -- we confirmed it is not duplicated, so we need to partition over all cols

select * 
from layoffs_staging
where company like "yahoo"; -- duplicated

-- to remove it, it can be done in MSQL server, postgress by adding DELETE but not in mySQL

-- we create another copy table to remove it from this table where row_num = 2

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_staging2;

insert into layoffs_staging2
select *, row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num -- date is a sql keyword so use backtick
from layoffs_staging;

select * 
from layoffs_staging2
where row_num > 1;

-- removing duplicates
SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- now duplicated rows are removed, we dont need row_num anymore.


-- standardizing data (finding issues in the data and fixing it)

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2
order by 1;
-- group by industry

select *
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct(location) from layoffs_staging2 group by 1;

SELECT location, COUNT(*) 
FROM layoffs_staging2
GROUP BY location
HAVING COUNT(*) > 1;

select distinct(country) from layoffs_staging2 group by 1;

select distinct * from layoffs_staging2 where country like 'United States%' order by 1;

select distinct country, trim(trailing '.' from country) from layoffs_staging2 order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select * from layoffs staging2;

select `DATE`from layoffs staging2;

select `DATE`, -- type=text
str_to_date(`DATE`,'%m/%d/%Y')
from layoffs staging2;

update layoffs_staging2
set `DATE` = str_to_date(`DATE`,'%m/%d/%Y'); -- still in text format when checked

-- format it correct, let's change to date columns

alter table layoffs_staging2
modify column `date` DATE;



-- NULL / BLANK values

-- row wise
SELECT *
FROM layoffs_staging2
WHERE location IS NULL
   OR company IS NULL
   OR industry IS NULL
   OR total_laid_off IS NULL
   OR percentage_laid_off IS NULL
   OR `date` IS NULL
   OR stage IS NULL
   OR country IS NULL
   OR funds_raised_millions IS NULL;
-- column wise, null or blanks
SELECT
    -- Checking for both NULL or blank values
    SUM(location IS NULL OR location = '') AS null_or_blank_location,
    SUM(company IS NULL OR company = '') AS null_or_blank_company,
    SUM(industry IS NULL OR industry = '') AS null_or_blank_industry,
    SUM(total_laid_off IS NULL OR total_laid_off = '') AS null_or_blank_total_laid_off,
    SUM(percentage_laid_off IS NULL OR percentage_laid_off = '') AS null_or_blank_percentage_laid_off,
    SUM(stage IS NULL OR stage = '') AS null_or_blank_stage,
    SUM(country IS NULL OR country = '') AS null_or_blank_country,
    SUM(funds_raised_millions IS NULL OR funds_raised_millions = '') AS null_or_blank_funds_raised_millions
FROM layoffs_staging2;


-- identifying similar rows with null and values
select * from layoffs_staging2
where company = 'Airbnb';

select * from layoffs_staging2
where industry is null;

 -- updating blank values to null before the final update
update layoffs_staging2
set industry = NULL
where industry = '';
 
select * from layoffs_staging2
where industry is null;

-- inner join, filling nulls with their similar rows
select t1.company, t1.industry, t2.company, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;
 
 -- now update the ones with values with the null ones
update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

-- remove if only sure
select * 
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

delete from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;

-- now we can delete layoffs_staging 2
-- we can check the row count to make sure
SELECT COUNT(*) FROM layoffs_staging; -- 2361
SELECT COUNT(*) FROM layoffs_staging2; -- 1999

drop table layoffs;
drop table layoffs_staging;
rename table layoffs_staging2 to layoffs;