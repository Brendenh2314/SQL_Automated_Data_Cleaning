-- ==========================
-- Automated Data Cleaning Script
-- ==========================
-- This script creates a procedure to automate the cleaning of raw data from the `us_household_income` table.
-- It copies the raw data to a new cleaned table, removes duplicates, and standardizes data entries.
-- An event is scheduled to run the procedure every 30 days.
-- Debugging and verification queries are included to validate the cleaning process.

-- View raw data before running any cleaning
SELECT * 
FROM us_project.us_household_income;

SELECT * 
FROM us_project.us_household_income_cleaned;

-- =================================
-- Create the Procedure for Data Cleaning
-- =================================
DELIMITER $$

-- Drop the procedure if it already exists
DROP PROCEDURE IF EXISTS Copy_and_Clean_Data;

-- Create the new procedure
CREATE PROCEDURE Copy_and_Clean_Data()
BEGIN
    -- Step 1: Create a cleaned table if it does not already exist
    CREATE TABLE IF NOT EXISTS `us_household_income_cleaned` (
        `row_id` INT DEFAULT NULL,
        `id` INT DEFAULT NULL,
        `State_Code` INT DEFAULT NULL,
        `State_Name` TEXT,
        `State_ab` TEXT,
        `County` TEXT,
        `City` TEXT,
        `Place` TEXT,
        `Type` TEXT,
        `Primary` TEXT,
        `Zip_Code` INT DEFAULT NULL,
        `Area_Code` INT DEFAULT NULL,
        `ALand` INT DEFAULT NULL,
        `AWater` INT DEFAULT NULL,
        `Lat` DOUBLE DEFAULT NULL,
        `Lon` DOUBLE DEFAULT NULL,
        `TimeStamp` TIMESTAMP DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

    -- Step 2: Copy raw data into the cleaned table and add a timestamp
    INSERT INTO us_household_income_cleaned
    SELECT *, CURRENT_TIMESTAMP
    FROM us_project.us_household_income;

    -- Step 3: Data Cleaning Steps

    -- 3.1: Remove duplicates based on the `id` field while keeping the earliest timestamp
    DELETE FROM us_household_income_cleaned 
    WHERE row_id IN (
        SELECT row_id
        FROM (
            SELECT row_id, id,
                ROW_NUMBER() OVER (
                    PARTITION BY id, `TimeStamp`
                    ORDER BY id, `TimeStamp`
                ) AS row_num
            FROM us_household_income_cleaned
        ) duplicates
        WHERE row_num > 1
    );

    -- 3.2: Standardize State Names
    UPDATE us_household_income_cleaned
    SET State_Name = 'Georgia'
    WHERE State_Name = 'georia';

    -- 3.3: Standardize text fields (e.g., make all text uppercase for consistency)
    UPDATE us_household_income_cleaned
    SET County = UPPER(County),
        City = UPPER(City),
        Place = UPPER(Place),
        State_Name = UPPER(State_Name);

    -- 3.4: Fix specific typographical errors in the `Type` field
    UPDATE us_household_income_cleaned
    SET `Type` = 'CDP'
    WHERE `Type` = 'CPD';

    UPDATE us_household_income_cleaned
    SET `Type` = 'Borough'
    WHERE `Type` = 'Boroughs';

END$$

DELIMITER ;

-- =================================
-- Call the Procedure Manually
-- =================================
CALL Copy_and_Clean_Data();

-- =================================
-- Automate the Procedure with an Event
-- =================================
-- Drop the event if it already exists
DROP EVENT IF EXISTS run_data_cleaning;

-- Create a new event to run the procedure every 30 days
CREATE EVENT run_data_cleaning
    ON SCHEDULE EVERY 30 DAY
    DO CALL Copy_and_Clean_Data();

-- =================================
-- Debugging and Verification Queries
-- =================================

-- Raw Dataset: Check for duplicates and count rows
-- Helps to verify the original state of the raw dataset
SELECT row_id, id, row_num
FROM (
    SELECT row_id, id,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY id
        ) AS row_num
    FROM us_household_income
) duplicates
WHERE row_num > 1;

SELECT COUNT(row_id) AS Raw_Row_Count
FROM us_household_income;

SELECT State_Name, COUNT(State_Name) AS State_Count
FROM us_household_income
GROUP BY State_Name;

-- Cleaned Dataset: Verify changes after running the procedure
-- Ensures that duplicates have been removed and standardizations applied
SELECT row_id, id, row_num
FROM (
    SELECT row_id, id,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY id
        ) AS row_num
    FROM us_household_income_cleaned
) duplicates
WHERE row_num > 1;

SELECT COUNT(row_id) AS Cleaned_Row_Count
FROM us_household_income_cleaned;

SELECT State_Name, COUNT(State_Name) AS State_Count
FROM us_household_income_cleaned
GROUP BY State_Name;
