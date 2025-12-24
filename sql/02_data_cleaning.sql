-- =========================================
-- DATA CLEANING
-- =========================================

-- -------------------------------------------------
-- 1. Detect duplicate records using CTE
-- -------------------------------------------------
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off,
                     percentage_laid_off, `date`, stage, country,
                     funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- NOTE:
-- DELETE is not allowed directly on CTEs in MySQL,
-- so we create a new staging table with row_num

-- -------------------------------------------------
-- 2. Create new staging table with row_num
-- -------------------------------------------------

CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert data with row numbers
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
                 percentage_laid_off, `date`, stage, country,
                 funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Verify duplicates
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Remove duplicate records
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- -------------------------------------------------
-- 3. Standardize text columns
-- -------------------------------------------------

-- Clean company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Fix industry naming inconsistencies
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Clean country names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- -------------------------------------------------
-- 4. Convert date column to DATE datatype
-- -------------------------------------------------

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY `date` DATE;

-- -------------------------------------------------
-- 5. Handle NULL and blank values
-- -------------------------------------------------

-- Replace blank industry with NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Fill missing industry values using self join
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- Remove rows with no layoff information
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- -------------------------------------------------
-- 6. Drop helper column
-- -------------------------------------------------

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final cleaned data
SELECT *
FROM layoffs_staging2;
