--Selecting all data from the db
Select *
From tempdb.dbo.[Nashville.Housing]

--Standardizing Date Format
Select SaleDateConverted,CONVERT(Date,SaleDate)
From tempdb.dbo.[Nashville.Housing]

Update [Nashville.Housing]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Nashville.Housing]
Add SaleDateConverted Date;

Update [Nashville.Housing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address data

Select *
From tempdb.dbo.[Nashville.Housing]
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From tempdb.dbo.[Nashville.Housing] a
JOIN  tempdb.dbo.[Nashville.Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From tempdb.dbo.[Nashville.Housing] a
JOIN  tempdb.dbo.[Nashville.Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking address into Individual Column (Address,City,State)
Select PropertyAddress
From tempdb.dbo.[Nashville.Housing]
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING (PropertyAddress , 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From tempdb.dbo.[Nashville.Housing]


ALTER TABLE [Nashville.Housing]
Add PropertySplitAddress Nvarchar(255)

Update [Nashville.Housing]
SET PropertySplitAddress = SUBSTRING (PropertyAddress , 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Nashville.Housing]
Add PropertySplitCity Nvarchar(255)

Update [Nashville.Housing]
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From tempdb.dbo.[Nashville.Housing]

Select OwnerAddress
From tempdb.dbo.[Nashville.Housing]

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From tempdb.dbo.[Nashville.Housing]

ALTER TABLE [Nashville.Housing]
Add OwnerSplitAddress Nvarchar(255)

Update [Nashville.Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [Nashville.Housing]
Add OwnerSplitCity Nvarchar(255)

Update [Nashville.Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [Nashville.Housing]
Add OwnerSplitState Nvarchar(255)

Update [Nashville.Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Changing Y & N to 'Yes','No' in 'SoldAsVacant' Column

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From tempdb.dbo.[Nashville.Housing]
GROUP BY SoldAsVacant
order by 2

Select SoldAsVacant
,CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
      WHEN  SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
	  END
From tempdb.dbo.[Nashville.Housing]

Update [Nashville.Housing]
SET SoldAsVacant = CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
      WHEN  SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
	  END

--Removing Duplicates

WITH RowNumCTE As(
Select *,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				  UniqueID
				  ) row_num
From tempdb.dbo.[Nashville.Housing]
--ORDER BY ParcelID
)
--Select * (first use select & order to check how many rows are duplicate and then use delete to remove those duplicate rows)
DELETE 
FROM RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress


--Delete unused columns

Select *
From tempdb.dbo.[Nashville.Housing]

ALTER TABLE tempdb.dbo.[Nashville.Housing]
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE tempdb.dbo.[Nashville.Housing]
DROP COLUMN SaleDate