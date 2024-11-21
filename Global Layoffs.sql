
/* World Layoffs 
 Data cleaning 
*/

USE [Worldlayoffs];
GO


SELECT *
INTO layoffs_clean
FROM layoffs;  -- 'working solely on layoffs_clean, original table layoffs stays untouched' 

-- Deleted duplicates

WITH duplicateCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions
ORDER BY company) AS [row number]
FROM layoffs_clean )
DELETE
FROM duplicateCTE 
WHERE [row number] > 1;

--standardization 

SELECT company, TRIM (company)
FROM layoffs_clean;

UPDATE layoffs_clean
SET company = TRIM(company);


UPDATE layoffs_clean
SET industry ='Crypto'
where industry like 'crypto%';

/* 
Data Entry Error, 'United States.' 
Correct Entry, 'United States'
*/

UPDATE layoffs_clean
SET country = 'United States'
WHERE country LIKE 'United State%';


 SELECT *
from layoffs_clean
WHERE location LIKE '%eldorf'
ORDER BY 1;

UPDATE layoffs_clean
SET location = 'Dusseldorf'
WHERE location LIKE '%eldorf'

/*datatype [total_laid_off, percentage_laid_off, date
Date format [date 


sp_help 'layoffs_clean';
*/

SELECT [Date], [company],
TRY_CONVERT(DATE, date) AS [converted date]
FROM layoffs_clean;

SELECT *
From layoffs_clean
WHERE TRY_CONVERT(DATE, [date]) IS NULL; -- [Company] Blackbaud, [Date] NULL, [Funds_raised_millions] NULL 

ALTER TABLE layoffs_clean
ADD [Correct Date] DATE;

UPDATE layoffs_clean
SET [Correct Date] = TRY_CONVERT(DATE, [date]);


ALTER TABLE layoffs_clean
DROP COLUMN [Date];

EXEC sp_rename '[layoffs_clean].[Correct Date]', 'Date', 'COLUMN';


sp_help 'layoffs_clean';

SELECT * 
FROM layoffs_clean;

SELECT [total_laid_off], [company],
TRY_CONVERT (INT, total_laid_off) AS [laid off]
FROM layoffs_clean;
/*
ALTER TABLE layoffs_clean
ALTER COLUMN total_laid_off INT; --ERROR! Conversion failed when converting the nvarchar value 'NULL' to data type int.
*/

-- [Total laid off] 
ALTER TABLE layoffs_clean
ADD [Total laid off] INT;

UPDATE layoffs_clean
SET [Total laid off] = TRY_CONVERT(INT,total_laid_off);

ALTER TABLE layoffs_clean
DROP COLUMN total_laid_off;

--[Percentage laid off] 
/*
SELECT *
FROM layoffs_clean
WHERE [percentage_laid_off] != 'NULL'
AND CAST([percentage_laid_off] AS decimal(10, 2)) >1;
*/

USE [Worldlayoffs];
GO

SELECT percentage_laid_off, company,
TRY_CONVERT(DECIMAL (10, 2), percentage_laid_off) AS laid_off_percent
FROM layoffs_clean
WHERE [percentage_laid_off] != 'NULL';

UPDATE layoffs_clean
SET [percentage_laid_off] =TRY_CONVERT(DECIMAL (10, 2), percentage_laid_off);



 /* company                   industry                          
    Airbnb                    NULL
    Bally's Interactive      'NULL'
    Juul                      NULL
    Carvana                   NULL
	*/
	
    SELECT *
	FROM layoffs_clean t1
	JOIN layoffs_clean t2
	ON t1.company = t2.company
	WHERE (t1.industry IS NULL OR t1.industry = 'NULL')
	AND (t2.industry IS NOT NULL AND t2.industry != 'NULL');

	UPDATE t1
	SET t1.industry = t2.industry
	FROM layoffs_clean t1
	JOIN layoffs_clean t2
	ON t1.company = t2.company
	WHERE (t1.industry IS NULL OR t1.industry = 'NULL')
	AND (t2.industry IS NOT NULL AND t2.industry != 'NULL');

	/*
	SELECT *
FROM layoffs
WHERE [company] = 'Bally''s Interactive';
	
	SELECT *
FROM layoffs_clean
WHERE [company] = 'Bally''s Interactive';

Bally''s Interactive belongs to the 'online gambling and sports betting industry' ='others'
*/
 

UPDATE layoffs_clean
SET industry = 'Other'
WHERE company = 'Bally''s Interactive';


 SELECT *
 FROM layoffs_clean
 WHERE /* [Total laid off]  IS NULL 
 AND*/ [percentage_laid_off] IS NULL;

DELETE 
FROM layoffs_clean
WHERE [Total laid off]  IS NULL 
 AND [percentage_laid_off] IS NULL;


 SELECT *
 FROM layoffs_clean;