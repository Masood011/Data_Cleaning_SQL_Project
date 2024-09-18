-- Data Cleaning


SELECT *
FROM layoffs;

-- 1. Create a Backup of Database
-- 2. Remove Duplicates
-- 3. Standardize Data
-- 4. Null Values or blank values



-- 1. Created a Backup of layoffs table as layoffs_unclean


CREATE TABLE layoffs_unclean
LIKE layoffs;

SELECT * 
FROM layoffs_unclean;

INSERT layoffs_unclean
SELECT *
FROM layoffs;


-- 2. Remove Duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs
WHERE company = 'Casper';

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_2` (
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


SELECT * 
FROM layoffs_2;

INSERT INTO layoffs_2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs;

DELETE
FROM layoffs_2
WHERE row_num > 1;

SELECT *
FROM layoffs_2
WHERE row_num > 1;

-- 3. Removing White Spaces
---- Trimming White space
---- Standardizing text  

SELECT company, TRIM(company)
FROM layoffs_2;

UPDATE layoffs_2
SET company = TRIM(company);

SELECT DISTINCT(industry)
FROM layoffs_2;

UPDATE layoffs_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

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

SELECT DISTINCT country
FROM layoffs_2
ORDER BY 1; 

-- 3. Standardizing Data
------- Consistent Date Format
------- Standardize Time Zones

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y') AS us_date
FROM layoffs_2;

UPDATE layoffs_2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT `date`
FROM layoffs_2;


ALTER TABLE layoffs_2
MODIFY COLUMN `date` DATE;

SELECT * 
FROM layoffs_2
WHERE industry IS NULL
OR industry = '';

UPDATE layoffs_2
SET industry = NULL
WHERE industry = '';

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

SELECT *
FROM layoffs_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_2
ORDER BY 1;

ALTER TABLE layoffs_2
DROP COLUMN row_num;




