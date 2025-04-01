# 🧹 Layoffs Dataset: Data Cleaning & EDA

## 📌 Overview
This project showcases SQL-based data cleaning and exploratory data analysis (EDA) on a real-world layoffs dataset. The objective is to transform raw data into a clean, analysis-ready format and extract key business insights.

## 📊 Dataset
- **Source**: [Kaggle - Layoffs Dataset](https://www.kaggle.com/)
- **Size**: ~2,000 rows, 10+ columns
- **Fields**: Company, Location, Industry, Total Laid Off, Percentage Laid Off, Stage, Country, Funds Raised, Date

## 🔍 Key Objectives
- Clean the dataset by removing duplicates and correcting inconsistent or missing entries
- Standardize text fields (e.g., trimming whitespace, formatting country names)
- Convert text-based date values to `DATE` format
- Handle null values through imputation and deletion
- Create a cleaned version of the dataset for analysis

## 📈 EDA Highlights
- Identified companies with the highest total and percentage layoffs
- Analyzed layoffs by year, industry, country, and funding stage
- Explored trends over time using rolling metrics
- Highlighted outliers such as 100% layoffs and massive startup failures

## 🧠 Skills & Concepts Applied
- Joins & Subqueries
- Common Table Expressions (CTEs)
- Temporary Tables
- Window Functions (e.g., `ROW_NUMBER()`, `SUM() OVER`)
- Data Type Conversion
- Data Cleaning (deduplication, standardization, null handling)

## 🧪 Sample SQL Snippet
```sql
WITH duplicate_cte AS (
  SELECT *, 
         ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
         ) AS row_num
  FROM layoffs_staging
)
DELETE FROM duplicate_cte
WHERE row_num > 1;
