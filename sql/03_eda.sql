-- =========================================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- =========================================

-- Max layoffs by company
SELECT company, MAX(total_laid_off)
FROM layoffs_staging2
GROUP BY company;

-- Layoffs by year
SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY year
ORDER BY year DESC;

-- Layoffs by funding stage
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;

-- Average layoffs per company
SELECT company, AVG(total_laid_off) AS avg_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY avg_layoffs DESC;

-- Monthly layoffs
SELECT SUBSTRING(`date`, 1, 7) AS month,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY month
ORDER BY month ASC;

-- Rolling total of layoffs
WITH Rolling_Total AS (
    SELECT SUBSTRING(`date`, 1, 7) AS month,
           SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    GROUP BY month
)
SELECT month,
       total_off,
       SUM(total_off) OVER (ORDER BY month) AS rolling_total
FROM Rolling_Total;

-- Total layoffs by company
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC;

-- Yearly layoffs per company
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, year
ORDER BY total_layoffs DESC;

-- Top 5 companies by layoffs per year
WITH company_year AS (
    SELECT company,
           YEAR(`date`) AS year,
           SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, year
),
company_year_rank AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY year
               ORDER BY total_laid_off DESC
           ) AS ranking
    FROM company_year
    WHERE year IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;
