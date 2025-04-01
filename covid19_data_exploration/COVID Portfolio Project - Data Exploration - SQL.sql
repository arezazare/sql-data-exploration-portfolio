/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- initial inspectation
select
location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- total cases vs total deaths
select
location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location like "%Iran%"
order by 1,2;

-- total cases vs population
-- shows what percentage on population got covid
select
location, date, total_cases, population, (total_cases/population)*100 as death_percentage
from coviddeaths
where location like "%Iran%"
order by 1,2;

-- countries with highest infection rate compared to population
select
location, population, 
max(total_cases) as highest_infection_count, 
max(total_cases/population)*100 as population_infection_percentage 
from coviddeaths
group by location, population
order by population_infection_percentage DESC;

-- countries with highest death count per population
select location, max(total_deaths) as total_death_count 
from coviddeaths
group by location
order by total_death_count DESC;

-- continent with most death counts
select continent, max(total_deaths) as total_death_count 
from coviddeaths
where continent is not null
group by continent
order by total_death_count DESC;

-- GLOBAL NUMBERS
select date, sum(total_cases) as total_cases, sum(new_deaths) as total_deaths, 
sum(total_deaths) / sum(total_cases) * 100 as death_percentage
from coviddeaths
where continent is not null
group by date
order by 1,2;


select sum(total_cases) as total_cases, sum(new_deaths) as total_deaths, 
sum(total_deaths) / sum(total_cases) * 100 as death_percentage
from coviddeaths
where continent is not null
order by 1,2;


-- join both tables
select * from coviddeaths dea
inner join covidvaccine vac
on dea.location = vac.location
and dea.date = vac.date;


-- total population vs vacinnations
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations -- result is per day
from coviddeaths dea
inner join covidvaccine vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- rolling count
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from coviddeaths dea
inner join covidvaccine vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- using CTE, no of cols should be the same for CTE and the table

-- temp table

create table #percentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric,
rollingPeopleVaccinated numeric
)

insert into #percentagePopulationVaccinated
 -- paste the above code
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(new_vaccinations) 
over(partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from coviddeaths dea
inner join covidvaccine vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- create view to store data for visualisation
-- create view ...