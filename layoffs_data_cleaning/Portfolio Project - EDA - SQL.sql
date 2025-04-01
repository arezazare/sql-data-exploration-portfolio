-- EDA (Explanatory Data Analysis)

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

SELECT * 
FROM world_layoffs.layoffs;

-- EASIER QUERIES

-- percentage_laid_off isn't useful as we don't know the total size of the company, therefore, total_laid_off is a better option.
SELECT MAX(total_laid_off) -- 12000
FROM world_layoffs.layoffs;

SELECT MAX(percentage_laid_off) -- 1 means 100% of the people were laid off
FROM world_layoffs.layoffs;

select *
from layoffs
where percentage_laid_off = 1 -- companies that lost all their employees
order by total_laid_off DESC; -- e.g: Laterra, laid of 2434 people

-- check max laid_off for each company
select company, sum(total_laid_off)
from layoffs
group by company
order by 2 DESC;


select industry, sum(total_laid_off)
from layoffs
group by industry
order by 2 DESC;

select country, sum(total_laid_off)
from layoffs
group by country
order by 2 DESC;

-- check min and max date for all layoffs
select min(`date`), max(`date`)
from layoffs;

-- Looking at Percentage to see how big these layoffs were
SELECT MIN(percentage_laid_off), MAX(percentage_laid_off)  
FROM world_layoffs.layoffs
WHERE percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM world_layoffs.layoffs
WHERE percentage_laid_off = 1;

-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
FROM world_layoffs.layoffs
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow raised like 2 billion dollars and went under - ouch

-- year identifier for total_laid_off, 2023 has the highest and 2021 lowest
select year(`date`), sum(total_laid_off)
from layoffs
group by year(`date`)
order by 1 DESC;


-- SOMEWHAT TOUGHER AND MOSTLY USING GROUP BY--------------------------------------------------------------------------------------------------

-- Companies with the biggest single Layoff

SELECT company, total_laid_off
FROM world_layoffs.layoffs
ORDER BY 2 DESC
LIMIT 5;
-- now that's just on a single day

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- by location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- this it total in the past 3 years or in the dataset

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs
where year(date) is not null
GROUP BY YEAR(date)
ORDER BY 1 ASC;

SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs
GROUP BY industry
ORDER BY 2 DESC;


SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs
GROUP BY stage
ORDER BY 2 DESC;

-- TOUGHER QUERIES------------------------------------------------------------------------------------------------------------------------------------

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.


-- inspect the total layoffs by year
select substring(`date`,1,7) as `yyyymm` , sum(total_laid_off) 
from layoffs 
where substring(`date`,1,7) is not null
group by yyyymm
order by 1 ASC;

-- getting the total rolling with CTE
with Rolling_Total as 
(
select substring(`date`,1,7) as yyyymm, sum(total_laid_off) as laid_off
from layoffs 
where substring(`date`,1,7) is not null
group by yyyymm
order by 1 ASC
) -- a month by month progression of the total layoffs as it accumulates the sum in each months
select yyyymm, laid_off, sum(laid_off) over(order by yyyymm) as rolling_total
from Rolling_Total;


-- inspect the first one
SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
FROM layoffs
GROUP BY company, YEAR(date);

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;