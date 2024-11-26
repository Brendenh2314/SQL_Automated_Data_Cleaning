# Automated Data Cleaning Script for US Household Income Dataset

This project demonstrates an automated approach to cleaning raw data from a `us_household_income` table using SQL. The process includes creating a stored procedure, standardizing data entries, removing duplicates, and scheduling regular maintenance.

## Key Features

1. **Procedure Creation**: Automates data cleaning and populates a new table (`us_household_income_cleaned`).
2. **Duplicate Removal**: Deletes duplicate entries based on the `id` field while retaining the earliest record.
3. **Standardization**: Fixes typographical errors, standardizes text fields (e.g., uppercase transformation), and cleans inconsistent data entries.
4. **Scheduled Automation**: Schedules the procedure to run every 30 days for consistent maintenance.
5. **Debugging Queries**: Includes validation queries to check the cleaning process and verify dataset changes.

## Steps in the Code

1. **View Raw Data**:
   Use queries to inspect the initial state of the dataset.

2. **Procedure for Data Cleaning**:
   - Create a new cleaned table if it doesn’t exist.
   - Copy data from the raw table into the cleaned table.
   - Perform cleaning actions like removing duplicates and fixing errors.

3. **Schedule Automation**:
   Set up an event to execute the cleaning procedure every 30 days.

4. **Validation Queries**:
   Validate row counts, state counts, and duplicate removal before and after the cleaning process.

## Dataset

The dataset used in this project is included as a CSV file:
[US Household Income Dataset](USHouseholdIncome.csv)

## How to Use

1. Run the provided SQL script in a compatible SQL environment.
2. Verify the changes using the debugging queries.
3. Ensure the event scheduler is enabled to automate the cleaning process.

Feel free to explore and modify the script to suit your specific use case.

