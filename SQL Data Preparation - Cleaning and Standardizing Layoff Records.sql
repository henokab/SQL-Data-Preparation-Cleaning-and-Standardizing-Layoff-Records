-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Handle Null or Blank values
-- 4. Remove any unnecessary columns

-- Display original data in layoffs table
SELECT * 
FROM layoffs_staging;

-- Create a copy of the layoffs table (structure only)
SELECT *
INTO layoffs_staging2
FROM layoffs
WHERE 1 = 0;

-- Insert data into layoffs_staging2 from layoffs table
INSERT INTO layoffs_staging2
SELECT * 
FROM layoffs;

-- Identify duplicates using a Common Table Expression (CTE)
WITH duplicate_cte AS (
    SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY company, [location], industry, total_laid_off, 
    percentage_laid_off, [date], country, funds_raised_millions ORDER BY company) AS row_num
    FROM layoffs_staging2
)
-- Delete duplicates from layoffs_staging2, keeping only the first occurrence
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

-- Standardize company names by trimming whitespace
UPDATE layoffs_staging2
SET company = LTRIM(RTRIM(company));

-- Standardize country names by trimming whitespace
UPDATE layoffs_staging2
SET country = LTRIM(RTRIM(country));

-- Update specific industry values to 'Crypto'
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Update country names to 'United States' where applicable
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Update the industry column using non-null values from the same company
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- Remove rows with null values in total_laid_off and percentage_laid_off
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Update the [date] column to only keep the date portion
UPDATE layoffs_staging2
SET [date] = CAST([date] AS DATE);

-- Change the column type to DATE (if necessary)
ALTER TABLE layoffs_staging2
ALTER COLUMN [date] DATE;

-- Optional: Display the cleaned-up data
SELECT * 
FROM layoffs_staging2;
