SELECT *
FROM candles_dataset

---- Pretify the database

-- Fix rating
Select Rank, Name, Round(Rating,1) as Rating, n_of_rating,Links
FROM candles_dataset

UPDATE [Candle-19]..candles_dataset
Set Rating = Round(Rating,1)

-- add Amazon website to Links
Select Rank, Name, Concat('https://www.amazon.co.uk',Links)
FROM candles_dataset

ALTER TABLE dbo.candles_dataset
ALTER COLUMN Links varchar(255)

UPDATE [Candle-19]..candles_dataset
Set Links = Concat('https://www.amazon.co.uk',Links)


---- Prep the database for analyzing

-- Drop rows with low n_of_rating

Select *
From candles_dataset
Where n_of_rating > 10000

DELETE 
FROM candles_dataset
WHERE n_of_rating < 10000;

-- Drop rows with low rating
Select *
From candles_dataset
Where Rating > 4.5

DELETE 
FROM candles_dataset
WHERE Rating < 4.5;

-- Insulate only Yankee Candle and Woodwick products

Select *
FROM candles_dataset
WHERE Name like '%Yankee%'
OR Name like '%Woodwick%'

Select *
FROM candles_dataset
WHERE Name NOT like '%Yankee%' 
AND NAME NOT LIKE '%Woodwick%'

DELETE 
FROM candles_dataset
WHERE Name NOT like '%Yankee%' 
AND NAME NOT LIKE '%Woodwick%';

-- Parse Brand and product name apart
Select *, 
	TRIM(PARSENAME(Replace(Name,'|','.'),3)) as Brand,
	TRIM(PARSENAME(Replace(Name,'|','.'),2)) as Product
From candles_dataset

ALTER TABLE candles_dataset
Add Brand VarChar(255);

UPDATE [Candle-19]..candles_dataset
Set Brand = TRIM(PARSENAME(Replace(Name,'|','.'),3))

ALTER TABLE candles_dataset
Add ProductName VarChar(255);

UPDATE [Candle-19]..candles_dataset
Set ProductName = TRIM(PARSENAME(Replace(Name,'|','.'),2))

ALTER TABLE candles_dataset
DROP Column Name;

-- Database:

SELECT Rank, Brand, ProductName, Rating, n_of_rating, Links
FROM candles_dataset