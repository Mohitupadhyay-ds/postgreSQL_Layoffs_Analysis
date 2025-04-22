---DATA CLEANING---


-- Perform Following Operations
--1. Remove Duplicates
--2. Standardize the Data 
--3. Null Values or Blank Values
--4. Remove any columns


---Start Here---

CREATE TABLE layoffs_staging
AS TABLE layoff

SELECT * 
FROM layoffs_staging;

--1. Remove Duplicates

WITH duplicate_cte AS
(
SELECT *, 
ROW NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
--This query cannot be executed, we need to fulfil an order by condition--

--Query to be executed--
WITH duplicate_cte AS 
(
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, date, stage, country, funds_raised_millions 
ORDER BY ctid  --Use system-generated unique row identifier
) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

DELETE FROM layoffs_staging
WHERE ctid IN 
(
SELECT ctid FROM 
( 
WITH duplicate_cte AS 
(
SELECT ctid, ROW_NUMBER() 
OVER
(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, date, stage, country, funds_raised_millions 
ORDER BY ctid -- Ensures a consistent ordering
) 
AS row_num
FROM layoffs_staging
)
SELECT ctid FROM duplicate_cte 
WHERE row_num > 1 -- Keep only row_num = 1
) 
AS subquery
);
--all duplicates removed--


--2. Standardize the Data--

SELECT *
FROM layoffs_staging;

SELECT company, TRIM(company)
FROM layoffs_staging;

UPDATE layoffs_staging
SET company = TRIM(company);

SELECT DISTINCT industry 
FROM layoffs_staging
ORDER BY 1;

SELECT *
FROM layoffs_staging
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging
ORDER BY 1;

UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


--3. Null Values or Blank Values

SELECT * 
FROM layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT DISTINCT industry
FROM layoffs_staging;

SELECT *
FROM layoffs_staging
WHERE industry IS NULL;

SELECT *
FROM layoffs_staging
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging AS t1
JOIN layoffs_staging AS t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL; 

UPDATE layoffs_staging AS t1
SET industry = t2.industry
FROM layoffs_staging AS t2
WHERE t1.company = t2.company
AND t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
--we will delete this data

DELETE 
FROM layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
