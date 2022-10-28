USE NH_DATABASE;

SELECT * 
from nashville_housing;

-- Formatin Sale Date
UPDATE nashville_housing
SET SaleDate = STR_TO_DATE( SaleDate, '%m/%d/%Y');
ALTER TABLE nashville_housing    
MODIFY COLUMN SaleDate DATE;


-- Add missing PropertyAddress
UPDATE nashville_housing AS a
JOIN nashville_housing AS b
	ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
SET A.PropertyAddress = IF(a.PropertyAddress = "", b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress = "" AND b.PropertyAddress != "";


-- Breaking out Address into Individual Columns (Address, City, State)
SELECT 
	PropertyAddress, 
    SUBSTRING_INDEX(PropertyAddress, ', ', 1) , 
    SUBSTRING_INDEX(PropertyAddress, ', ', -1) 
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD Property_Address VARCHAR(50) AFTER PropertyAddress,
ADD Property_City VARCHAR(50) AFTER Property_Address;

UPDATE nashville_housing
SET Property_Address = SUBSTRING_INDEX(PropertyAddress, ', ', 1) , 
	Property_City = SUBSTRING_INDEX(PropertyAddress, ', ', -1);
    
ALTER TABLE nashville_housing
DROP COLUMN PropertyAddress;


SELECT 
	OwnerAddress,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1) AS Owner_Address,
	SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS Owner_Sity,
	SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS Owner_State
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD Owner_Address VARCHAR(50) AFTER OwnerAddress,
ADD Owner_Sity VARCHAR(50) AFTER Owner_Address,
ADD Owner_State VARCHAR(2) AFTER Owner_Sity;

UPDATE nashville_housing
SET Owner_Address = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', 1), ', ', -1),
	Owner_Sity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', 2), ', ', -1),
    Owner_State = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', 3), ', ', -1);
    
ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress;


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT SoldAsVacant, COUNT(*)
FROM nashville_housing
GROUP BY SoldAsVacant;

UPDATE nashville_housing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = "Y" Then "Yes"
	WHEN SoldAsVacant = "N" Then "NO"
	ELSE SoldAsVacant 
END;


-- Remove Duplicates and Create View
CREATE VIEW cleand_nashville_housing AS
SELECT *
FROM (Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 Property_Address,
				 SalePrice,
				 SaleDate,
				 LegalReference,
                 Acreage,
                 TotalValue,
                 Bedrooms
				 ORDER BY
					UniqueID
					) row_num
From nashville_housing
) AS UniqueRows
WHERE UniqueRows.row_num = 1;


SELECT * 
FROM cleand_nashville_housing;
