-- Exploratory Data Analysis --


-- 1. MAX laid-off or MAX percentage_laid_off

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging;

-- Result-- 12000
-- Result-- 1.0 (100%)

--2. Having 100% laid off

SELECT *
FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions 

--3. Companies who laid off

SELECT company, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY company
ORDER BY 2

--4. MIN and MAX date

SELECT MIN(date), MAX(date)
FROM layoffs_staging;

--5. TOP 10 Industries who laid-off

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC
LIMIT 10;

--6. TOP 10 Countries who laid-off

SELECT country, SUM(total_laid_off)
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY 2 DESC
LIMIT 10;

--7. Stage vise laid off

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY stage
ORDER BY 2 DESC;

--8. Total laid off in each year and month

SELECT TO_CHAR(date, 'YYYY-MM') AS month, 
SUM(total_laid_off)
FROM layoffs_staging
WHERE TO_CHAR(date, 'YYYY-MM') IS NOT NULL
GROUP BY month
ORDER BY month;

--9. Total laid off in each year

SELECT TO_CHAR(date, 'YYYY') AS year, 
SUM(total_laid_off)
FROM layoffs_staging
GROUP BY year
ORDER BY 1;

--10. Month vise increase in the total laid off

WITH Rolling_Total AS
(
SELECT TO_CHAR(date, 'YYYY-MM') AS month, SUM(total_laid_off) AS total_off
FROM layoffs_staging
WHERE TO_CHAR(date, 'YYYY-MM') IS NOT NULL
GROUP BY month
)
SELECT month, total_off, SUM(total_off) OVER (ORDER BY month) AS rolling_total
FROM Rolling_Total;

--11. Companies who laid off based on year

SELECT company, TO_CHAR(date, 'YYYY') AS year, SUM(total_laid_off)
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY company, TO_CHAR(date, 'YYYY')
ORDER BY 3 DESC;

--12. TOP 5 companies who laid off

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, TO_CHAR(date, 'YYYY') AS year, SUM(total_laid_off)
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY company, TO_CHAR(date, 'YYYY')
), 
Company_Year_Rank AS 
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5;


