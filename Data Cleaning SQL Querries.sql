Select * 
From PortfolioProject.dbo.NashvilleHousing


-- I. Saledate Standardization

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Alter Table NashvilleHousing
--Drop Column SaleDateConverted;

-- II. Populate empty property address "cells"

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


-- Some of the rows have empty Property Addresses, however, we can see that they have the same Property ID as the rows with filled Property Address.
-- If we take for example (Where UniqueID = 25014 OR UniqueID = 54585) 301 Mystic Hill property, it has two different Unique IDs, but shares
-- the ParcelID and Address. This is observed in all other cases where Parcel ID is the same. Therefore, we can assume that if Property Address is 
-- empty, but shares Parcel ID with another entry, the actual address is the same. Let's examplify what is said here and populate 
-- the empty Property Adresses:

Select *
From PortfolioProject.dbo.NashvilleHousing
Where UniqueID = 25014
OR UniqueID = 54585
Order by ParcelID

-- Using Self-Join connect the table with itself where parcel ID matches, but Unique ID does not

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) -- Where a.PA is null, populate with b.PA
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
Order By a.ParcelID


-- Populate the "cells" now (a as alias for NashvilleHousing:

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- III. Break down address into separate columns

Select PropertyAddress, HouseNumber
From PortfolioProject.dbo.NashvilleHousing

-- PropertyAddress is populated with [House Number as interger], space, [street name], comma, [city name]
-- Space and comma as delimiters, comma as hard delimiter

--SUBSTRING(PropertyAddress, 1, CHARINDEX(' ', PropertyAddress)) as Address
-- From PortfolioProject.dbo.NashvilleHousing

-- Check if extracting the string between start and first delimiter from PropertyAddress 
-- would result in interger, then extract, else Null
Select 
CASE 
	WHEN ISNUMERIC(SUBSTRING(PropertyAddress,1, CHARINDEX(' ', PropertyAddress))) = 1 
	THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(' ', PropertyAddress))
	ELSE NULL
	End as HouseNumber
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add HouseNumber Varchar(6);

Update PortfolioProject.dbo.NashvilleHousing
SET HouseNumber = CASE WHEN ISNUMERIC(SUBSTRING(PropertyAddress,1, CHARINDEX(' ', PropertyAddress))) = 1 
THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(' ', PropertyAddress)) 
WHEN SUBSTRING(PropertyAddress, 1, CHARINDEX(' ', PropertyAddress)) = '0, '
THEN Null
ELSE Null End

Select PropertyAddress, HouseNumber
From PortfolioProject.dbo.NashvilleHousing

-- House Number extraction succesful, dropping as not neccesary currently
Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column HouseNumber;

--Extract City from PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity NvarChar(255);

-- Extract after and before comma:
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Alter table, add and set columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitFullAddress NvarChar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitFullAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Select *
From PortfolioProject.dbo.NashvilleHousing

-- Splitting from OwnerAddress the address, the city and the state
Select OwnerAddress, PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
ORDER BY [UniqueID ]


Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing
Order By [UniqueID ]

--Address
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SplitOwnerAddress NvarChar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET SplitOwnerAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

--City
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SplitOwnerCity NvarChar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET SplitOwnerCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

-- State
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SplitOwnerState NvarChar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET SplitOwnerState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing
ORDER BY [UniqueID ]

-- "Sold As Vacant" column contains multiple differently formed inputs. Fixing this by replacing them with a simple Yes/No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select Distinct(SoldAsVacant),
CASE
	WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes' WHEN SoldAsVacant='N' THEN 'No' ELSE SoldAsVacant END

-- IV. Remove Duplicates 
-- not a standard practice to remove rows from SQL, this is just example of finding and deleting rows
-- Identify Duplicates:
-- 1) UniqueID does not return duplicates
-- 2) We expect that a real duplicate would be case when PropertyAddress, SalDeDate, SalePrice, ParcelID & LegalReference
-- 3) Select and identify via Row_Number and Partition by:

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing

-- Create CTE to select only duplicate rows

With row_num as
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
Select *
From row_num
Where row_num <> 1
---- Drop rows:
--Delete FROM row_num
--WHERE row_num <> 1;
--Dropped 104 rows with duplicate entries

-- V. Delete Columns that are uneccesary

-- Not the best practice, better to create views than to drop columns from raw dataset
-- Here we are dropping columns from which we have extracted data, separated by delimiter:

--ALTER TABLE PortfolioProject.dbo.NashvilleHousing
--DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate;


-- Check:
Select *
FROM PortfolioProject.dbo.NashvilleHousing
