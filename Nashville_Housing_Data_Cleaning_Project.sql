-- Preview first 10 rows of data
SELECT * FROM housing
LIMIT 10

----------------------------------------------------
-- Standardize date format
SELECT saledate, DATE(saledate)
FROM housing

ALTER TABLE housing
ADD saledate2 DATE

UPDATE housing
SET saledate2 = DATE(saledate);

----------------------------------------------------
-- Clean Property Address data

SELECT *
FROM housing
WHERE propertyaddress is NULL

-- parcelid is linked to propertyaddress
SELECT *
FROM housing
ORDER BY parcelid

SELECT housing_a.parcelid, housing_b.parcelid, 
	housing_a.propertyaddress, housing_b.propertyaddress,
	COALESCE(housing_a.propertyaddress, housing_b.propertyaddress)
FROM housing housing_a
	JOIN housing housing_b
		ON housing_a.parcelid = housing_b.parcelid
		AND housing_a.uniqueid != housing_b.uniqueid
WHERE housing_a.propertyaddress is NULL

-- update null values in propertyaddress
UPDATE housing AS housing_a
SET propertyaddress = COALESCE(housing_a.propertyaddress, housing_b.propertyaddress)
FROM housing AS housing_b
	WHERE housing_a.parcelid = housing_b.parcelid
		AND housing_a.uniqueid != housing_b.uniqueid
		AND housing_a.propertyaddress is NULL


----------------------------------------------------
-- Separate property address into multiple columns 
-- (address, city)

SELECT propertyaddress,
	SPLIT_PART(propertyaddress, ',', 1) AS address,
	SPLIT_PART(propertyaddress, ',', 2) AS city
FROM housing

ALTER TABLE housing
	ADD property_address varchar(250),
	ADD property_city varchar(250)

UPDATE housing
	SET property_address = SPLIT_PART(propertyaddress, ',', 1),
		property_city = SPLIT_PART(propertyaddress, ',', 2)
		
		
---------------------------------------------------
-- Separate owner address into multiple columns 
-- (address, city, state)

SELECT owneraddress, 
	SPLIT_PART(owneraddress,',',1) AS address,
	SPLIT_PART(owneraddress,',',2) AS city,
	SPLIT_PART(owneraddress,',',3) AS state
FROM housing

ALTER TABLE housing
	ADD owner_address varchar(250),
	ADD owner_city varchar(250),
	ADD owner_state varchar(250)

UPDATE housing
	SET owner_address = SPLIT_PART(owneraddress,',',1),
	owner_city = SPLIT_PART(owneraddress,',',2),
	owner_State = SPLIT_PART(owneraddress,',',3)
	
	
---------------------------------------------------
-- Clean "sold as vacant" field by changing Y to Yes, N to No
	
SELECT soldasvacant, COUNT(soldasvacant)
FROM housing
GROUP BY soldasvacant
	ORDER BY 2

SELECT soldasvacant, 
	CASE 
		WHEN soldasvacant = 'Y' THEN 'Yes'
		WHEN soldasvacant = 'N' THEN 'No'
		ELSE soldasvacant
	END
FROM housing

UPDATE housing
	SET soldasvacant = 
	CASE 
		WHEN soldasvacant = 'Y' THEN 'Yes'
		WHEN soldasvacant = 'N' THEN 'No'
		ELSE soldasvacant
	END


---------------------------------------------------
-- Find and remove duplicates 

WITH duplicate AS(
	SELECT *,
		ROW_NUMBER()
		OVER(PARTITION BY parcelid, 
			propertyaddress, 
			saleprice,
			saledate,
			legalreference
			ORDER BY uniqueid) row_num
	FROM housing), 
	
	to_delete AS (
	SELECT *
		FROM duplicate
		WHERE row_num > 1)
		
--SELECT *
--FROM to_delete

DELETE
	FROM housing
	USING to_delete
	WHERE housing.uniqueid = to_delete.uniqueid


---------------------------------------------------
-- Delete unnecessary columns

ALTER TABLE housing
	DROP COLUMN owneraddress,
	DROP COLUMN propertyaddress, 
	DROP COLUMN saledate
	
ALTER TABLE housing
RENAME COLUMN saledate2 TO saledate