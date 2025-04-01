# 🦠 COVID-19 Data Exploration

## 📌 Overview
This project involves SQL-based data exploration of global COVID-19 cases, deaths, and vaccinations. The goal is to extract meaningful insights and trends from the dataset using advanced SQL techniques.

## 📊 Dataset
- **Tables Used**: `coviddeaths`, `covidvaccine`
- **Source**: Kaggle (via provided `.csv` files or SQL database)
- **Columns**: Date, Location, Total Cases, Total Deaths, New Cases, Population, Vaccinations

## 🔍 Key Objectives
- Analyze infection rates and mortality by country and over time
- Compare COVID-19 cases to population
- Track vaccinations by date and continent
- Identify countries with highest infection and death rates
- Build CTEs and Temp Tables for population-level metrics

## 🧠 Skills & Concepts Applied
- Joins
- CTEs (Common Table Expressions)
- Temporary Tables
- Window Functions (`OVER`, `PARTITION BY`)
- Aggregate Functions (e.g., `SUM`, `MAX`)
- Creating Views
- Data Type Conversions

## 📈 Sample Queries
```sql
SELECT location, date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS death_rate
FROM coviddeaths
WHERE location = 'Iran';
