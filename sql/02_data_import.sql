/*
============================================================
 Hospital Analytics Project
 File: 02_data_import.sql
 Database: HospitalAnalyst
 Platform: Microsoft SQL Server

 Purpose:
 Documents the data-loading process used to import the
 hospital CSV datasets into SQL Server.

 The project used BULK INSERT for data ingestion.
 During the import process, several source-data issues were
 identified and resolved, including data type mismatches,
 CSV formatting issues, column-order mismatches, and
 inconsistent source values.

 Author: Nesa Jahan
============================================================
*/USE HospitalAnalyst;
GO

/* =========================================================
   DATA IMPORT METHOD
   =========================================================

   CSV files were loaded into SQL Server using BULK INSERT.

   Generic import pattern:

   BULK INSERT dbo.TableName
   FROM '<PATH_TO_DATASET>\file.csv'
   WITH (
       FIRSTROW = 2,
       FIELDTERMINATOR = ',',
       ROWTERMINATOR = '0x0a',
       FIELDQUOTE = '"',
       TABLOCK
   );

   Notes:
   - FIRSTROW = 2 skips the CSV header row.
   - FIELDTERMINATOR identifies comma-separated columns.
   - ROWTERMINATOR identifies the end of each record.
   - FIELDQUOTE handles values enclosed in double quotes.
   - TABLOCK can improve bulk-load performance.
*/


/* =========================================================
   EXAMPLE: Department Import
   ========================================================= */

BULK INSERT dbo.Department
FROM '<PATH_TO_DATASET>\department.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    FIELDQUOTE = '"',
    TABLOCK
);
GO

/* =========================================================
   IMPORT TROUBLESHOOTING AND DATA TYPE CORRECTIONS
   =========================================================

   Several data-quality and schema issues were identified
   during the CSV import process. The destination schema was
   adjusted where necessary to preserve source values and
   prevent conversion errors.
*/


/* ---------------------------------------------------------
   1. Patient Contact Number
   ---------------------------------------------------------

   Issue:
   Patient contact numbers contained formatting that should
   not be treated as numeric data.

   Resolution:
   contact_number was stored as NVARCHAR(50).

   Reason:
   Phone numbers are identifiers rather than values used in
   mathematical calculations. A character data type also
   preserves formatting and avoids numeric conversion errors.
*/


/* ---------------------------------------------------------
   2. Drug Unit Cost
   ---------------------------------------------------------

   Issue:
   Drug unit cost contained monetary decimal values.

   Resolution:
   unit_cost was stored as DECIMAL(18,2).

   Reason:
   DECIMAL provides fixed precision and is appropriate for
   monetary values where exact numeric representation is
   required.
*/


/* ---------------------------------------------------------
   3. Drug Manufacturer Reliability Rating
   ---------------------------------------------------------

   Issue:
   reliability_rating contained decimal values and could not
   be represented correctly using an integer data type.

   Resolution:
   reliability_rating was stored as DECIMAL(18,2).
*/


/* ---------------------------------------------------------
   4. Billing Detail Reference ID
   ---------------------------------------------------------

   Issue:
   reference_id contained missing/blank source values during
   the import process.

   Resolution:
   The column was designed to allow NULL values.

   Note:
   reference_id is context-dependent based on charge_type,
   so it was not defined as a direct foreign key to a single
   reference table.
*/


/* ---------------------------------------------------------
   5. CSV / BULK INSERT Troubleshooting
   ---------------------------------------------------------

   During development, BULK INSERT errors were investigated
   by checking:

   - Source CSV structure
   - Destination column order
   - SQL Server destination data types
   - Blank and NULL source values
   - Field and row delimiters
   - Quoted CSV values
   - File accessibility

   Where direct loading was not appropriate, source data was
   inspected and cleaned before being loaded into the final
   relational tables.
*/
