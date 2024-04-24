/*
Cleaning Data in SQL Queries
*/

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate2, CONVERT(Date, SaleDate)
From PortofolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDate2 Date;

Update NashvilleHousing
SET SaleDate2 = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortofolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortofolioProject.dbo.NashvilleHousing a
JOIN PortofolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortofolioProject.dbo.NashvilleHousing a
JOIN PortofolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortofolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortofolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertyDivideCity Nvarchar(255);

Update NashvilleHousing
SET PropertyDivideCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortofolioProject.dbo.NashvilleHousing



Select OwnerAddress
From PortofolioProject.dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress,',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
From PortofolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerDivideCity Nvarchar(255);

Update NashvilleHousing
SET OwnerDivideCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortofolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortofolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortofolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				   UniqueID
				   ) row_num

From PortofolioProject.dbo.NashvilleHousing
--order by ParcelID
)

Select * 
From RowNumCTE
where row_num > 1





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortofolioProject.dbo.NashvilleHousing

ALTER TABLE PortofolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortofolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


