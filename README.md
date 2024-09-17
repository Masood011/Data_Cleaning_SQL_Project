# Data_Cleaning_SQL_Project

## Project Overview 
This Data Analysis project aims to Clean and prepare a dataset on global layoffs to ensure its accuracy and reliability for subsequent analysis. Finding missing data and outliers and then deleting nulls and white spaces. Standardizing data and adopting efficient cleaning procedures, I wish to compile this data to further study layoffs worldwide and demonstrate how SQL can be used for data cleaning.  

### Dataset

 - <b> Source </b>: Kaggle. ([View](https://www.kaggle.com/datasets/swaptr/layoffs-2022/data))
 - <b> Format </b>: CSV
 - <b> Size </b>: 268.55 kB
 - <b> Columns </b>: 9
 - <b> Rows </b>: 2362 rows
 - The Source of the original data is layoffs.fyi. ([Source](https://layoffs.fyi/))
   

<b><h3>  1. Data Backup: </h3>

```sql
-- Created a backup of the 'layoffs' table as 'layoffs_unclean'.
CREATE TABLE layoffs_unclean
  LIKE layoffs;
SELECT * 
  FROM layoffs_unclean;
  INSERT layoffs_unclean
SELECT *
  FROM layoffs; 
```
</b>


<b><h3> 2. Removing Duplicate Records:</h3></b> 
They are two methods for removing duplicates:<br>
<b> Method 1: Selecting Duplicates with ROW_NUMBER </b> <br>
<b>
```sql
-- This method uses ROW_NUMBER() to identify and select duplicate rows based on
-- specified columns. It then displays them for review.

SELECT *,
  ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
  ) AS row_num
FROM layoffs;
```

Method 2: Deleting Duplicates with CTE (Common Table Expression)
```sql
-- This method creates a CTE to identify duplicates and then deletes them  from the original table.

WITH duplicate_cte AS (
SELECT *,
  ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
                 `date`, stage, country, funds_raised_millions   
  ) AS row_num
FROM layoffs
)
DELETE
  FROM duplicate_cte
  WHERE row_num > 1;

Choosing the Right Method:
• Method 1 can be used for a quick review of duplicates before deletion.
• Method 2 can be used for permanent removal, ensuring we understand the deletion criteria.
```
</b>

<b><h3> 3. Standardizing Data: </h3>

a) Removing White Spaces:
```sql
-- Trims leading and trailing whitespaces from the 'company' column.

SELECT company, TRIM(company)
  FROM layoffs_2;
  UPDATE layoffs_2
  SET company = TRIM(company);
```

b) Standardizing Text:

```sql
-- Standardized industry names as they were similar names but different rows aligned them with one name.

SELECT DISTINCT(industry)
  FROM layoffs_2;
  UPDATE layoffs_2
  SET industry = 'Crypto'
  WHERE industry LIKE 'Crypto%';
```
</b>

<b> c) Standardizing Country Names:

```sql
-- Removed trailing periods from country names and trimmed whitespaces.
SELECT DISTINCT country
  FROM layoffs_2
  WHERE country LIKE 'United States%'
  ORDER BY 1; 
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
  FROM layoffs_2
  ORDER BY 1;
  UPDATE layoffs_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
```
</b>

<b><h3>4. Standardizing Date Format:</h3>
```sql

-- Converted the 'date' column to a consistent format (YYYY-MM-DD).
SELECT `date`,
  STR_TO_DATE(`date`,'%m/%d/%Y') AS us_date
  FROM layoffs_2;
  UPDATE layoffs_2
  SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');
ALTER TABLE layoffs_2
MODIFY COLUMN `date` DATE;
```
</b>

<b><h3>5. Handling Missing Values:</h3>
```sql

-- Identifies NULL or empty values in 'industry', replaced and deleted a few.
SELECT * 
  FROM layoffs_2
  WHERE industry IS NULL
  OR industry = '';

-- I choose to:
--- Delete rows with missing values but filtered them with industry and company name in order to avoid unwanted deletion.

UPDATE layoffs_2
  SET industry = NULL
  WHERE industry = '';

-- Identified companies with missing industry and filled them 
-- based on matching companies.

SELECT l1.industry, l2.industry
  FROM layoffs_2 l1
  JOIN layoffs_2 l2
      ON l1.company = l2.company
  WHERE (l1.industry IS NULL OR l1.industry = '')
  AND l2.industry IS NOT NULL;
  UPDATE layoffs_2 l1
JOIN layoffs_2 l2
	ON l1.company = l2.company
SET l1.industry = l2.industry
WHERE (l1.industry IS NULL);
```
</b>

<b><h3> 6. Removing Unnecessary Columns : </h3>
```sql

-- Removed the temporary 'row_num' column.
ALTER TABLE layoffs_2
DROP COLUMN row_num;
```
</b>



