/*
============================================================
 Hospital Analytics Project
 File: 03_data_quality_validation.sql
 Database: HospitalAnalyst
 Platform: Microsoft SQL Server

 Purpose:
 Performs data quality validation across the hospital
 database before analytical reporting.

 Validation areas include:
 - NULL checks
 - Duplicate detection
 - Domain/category validation
 - Numeric range validation
 - Date logic validation
 - Referential integrity / orphan detection
 - Cross-table business-rule validation

 Author: Nesa Jahan
============================================================
*/

USE HospitalAnalyst;
GO


/* =========================================================
   DATA QUALITY VALIDATION APPROACH
   =========================================================

   Before performing analytical queries, each table was
   reviewed based on its schema and business meaning.

   The validation process followed these general steps:

   1. Inspect table structure and data types.
   2. Check important columns for NULL values.
   3. Identify unexpected duplicate values.
   4. Profile categorical columns using GROUP BY.
   5. Validate numeric values and reasonable ranges.
   6. Validate chronological relationships between dates.
   7. Check foreign-key relationships for orphan records.
   8. Validate business rules across related tables.

   Not every validation rule applies to every column.
   Validation was selected based on the meaning and role
   of each attribute.
*/
/* =========================================================
   1. SCHEMA INSPECTION
   ========================================================= */

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Patient'
ORDER BY ORDINAL_POSITION;

/* =========================================================
   2. NULL VALIDATION
   Example: Employee
   ========================================================= */

SELECT
    employee_id,
    employee_name,
    gender,
    role,
    employee_type,
    date_of_joining,
    department_id
FROM dbo.employee
WHERE employee_name IS NULL
   OR gender IS NULL
   OR role IS NULL
   OR employee_type IS NULL
   OR date_of_joining IS NULL
   OR department_id IS NULL;

/* =========================================================
   3. DUPLICATE DETECTION
   Example: Department Name
   ========================================================= */

SELECT
    department_name,
    COUNT(*) AS DuplicateCount
FROM dbo.Department
GROUP BY department_name
HAVING COUNT(*) > 1;

/* =========================================================
   4. DOMAIN / CATEGORY VALIDATION
   Example: Employee Role
   ========================================================= */

SELECT
    role,
    COUNT(*) AS TotalEmployees
FROM dbo.employee
GROUP BY role
ORDER BY TotalEmployees DESC;

/* =========================================================
   5. NUMERIC RANGE VALIDATION
   Example: Doctor Experience
   ========================================================= */

SELECT
    MIN(experience_years) AS MinimumExperience,
    MAX(experience_years) AS MaximumExperience,
    AVG(CAST(experience_years AS DECIMAL(10,2)))
        AS AverageExperience
FROM dbo.doctor;


-- Detect invalid negative experience values.

SELECT *
FROM dbo.doctor
WHERE experience_years < 0;

/* =========================================================
   6. DATE LOGIC VALIDATION
   ========================================================= */


-- Discharge date should not occur before admission date.

SELECT
    admission_id,
    admission_date,
    discharge_date
FROM dbo.admission
WHERE discharge_date < admission_date;


-- Diagnostic tests should occur during the admission period.

SELECT
    pd.patient_diagnostic_id,
    pd.test_date,
    a.admission_date,
    a.discharge_date
FROM dbo.patient_diagnostic AS pd
INNER JOIN dbo.admission AS a
    ON pd.admission_id = a.admission_id
WHERE pd.test_date < a.admission_date
   OR pd.test_date > a.discharge_date;


-- Policy end date should not occur before policy start date.

SELECT
    patient_insurance_id,
    policy_start_date,
    policy_end_date
FROM dbo.patient_insurance
WHERE policy_end_date < policy_start_date;

/* =========================================================
   7. REFERENTIAL INTEGRITY / ORPHAN DETECTION
   Example: Ward -> Department
   ========================================================= */

SELECT
    w.ward_id,
    w.department_id
FROM dbo.ward AS w
LEFT JOIN dbo.Department AS d
    ON w.department_id = d.department_id
WHERE d.department_id IS NULL;

/*
LEFT JOIN is used instead of INNER JOIN because orphan
detection requires preserving child rows even when no
matching parent record exists.
*/

/* =========================================================
   8. CROSS-TABLE BUSINESS-RULE VALIDATION

   Example:
   Employees referenced by the Doctor table should have
   the role 'Doctor' in the Employee table.
   ========================================================= */

SELECT
    d.doctor_id,
    d.employee_id,
    e.employee_name,
    e.role
FROM dbo.doctor AS d
INNER JOIN dbo.employee AS e
    ON d.employee_id = e.employee_id
WHERE e.role <> 'Doctor';

/* =========================================================
   9. KEY DATA QUALITY FINDINGS
   =========================================================

   The validation process identified several important
   observations and data-quality findings.
*/


/* ---------------------------------------------------------
   Billing Date Inconsistency
   ---------------------------------------------------------

   A significant number of billing records had bill dates
   earlier than their related admission dates.

   Result:
   22,407 out of 45,000 billing records were affected.

   Because the dataset is synthetic and the correct source
   date could not be determined with confidence, the records
   were not automatically updated or deleted.

   The issue was retained and documented as a data-quality
   limitation.
*/

SELECT COUNT(*) AS BillsBeforeAdmission
FROM dbo.billing AS b
INNER JOIN dbo.admission AS a
    ON b.admission_id = a.admission_id
WHERE b.bill_date < a.admission_date;


/* ---------------------------------------------------------
   Billing Timeline Distribution
   ---------------------------------------------------------

   Billing records were also profiled relative to the
   admission period.

   Observed:
   - 22,407 bills before admission
   - 106 bills during the admission period
   - 22,487 bills after discharge

   A bill issued after discharge is not automatically
   considered invalid because business processes may allow
   post-discharge billing.
*/

SELECT COUNT(*) AS BillsDuringAdmission
FROM dbo.billing AS b
INNER JOIN dbo.admission AS a
    ON b.admission_id = a.admission_id
WHERE b.bill_date >= a.admission_date
  AND b.bill_date <= a.discharge_date;


/* ---------------------------------------------------------
   Patient Insurance Policy Numbers
   ---------------------------------------------------------

   Four policy numbers appeared more than once globally.

   Further investigation showed that each duplicate policy
   number belonged to a different insurance provider.

   Therefore:
   - policy_number alone was not globally unique.
   - the combination of insurance_provider_id + policy_number
     was unique.

   The duplicate policy numbers were retained because they
   were not confirmed to be data errors.
*/

SELECT
    policy_number,
    COUNT(*) AS PolicyCount
FROM dbo.patient_insurance
GROUP BY policy_number
HAVING COUNT(*) > 1;


SELECT
    insurance_provider_id,
    policy_number,
    COUNT(*) AS PolicyCount
FROM dbo.patient_insurance
GROUP BY
    insurance_provider_id,
    policy_number
HAVING COUNT(*) > 1;


/* ---------------------------------------------------------
   Billing Detail Reference ID
   ---------------------------------------------------------

   reference_id was populated for Room charges and NULL for
   Drug, Test, and Procedure charges.

   This pattern suggests that reference_id is context-
   dependent rather than a universal foreign key.

   No undocumented relationship was assumed based only on
   matching identifier ranges.
*/

SELECT
    charge_type,
    COUNT(*) AS TotalRows,
    COUNT(reference_id) AS NonNullReferenceIDs,
    SUM(
        CASE
            WHEN reference_id IS NULL THEN 1
            ELSE 0
        END
    ) AS NullReferenceIDs
FROM dbo.billing_detail
GROUP BY charge_type;


/* ---------------------------------------------------------
   Drug Manufacturer Name Duplicates
   ---------------------------------------------------------

   A small number of manufacturer names appeared more than
   once.

   These were treated as potential duplicates rather than
   automatically deleted because identical names do not
   necessarily prove duplicate entities.
*/

SELECT
    manufacturer_name,
    COUNT(*) AS ManufacturerCount
FROM dbo.drug_manufacturer
GROUP BY manufacturer_name
HAVING COUNT(*) > 1;


/* ---------------------------------------------------------
   Drug Inventory Business Rule
   ---------------------------------------------------------

   Inventory status was validated against current stock and
   reorder level.

   Expected rule:
   - Low: current_stock <= reorder_level
   - Normal: current_stock > reorder_level

   No inconsistent records were identified.
*/

SELECT
    inventory_id,
    inventory_status,
    current_stock,
    reorder_level
FROM dbo.drug_inventory
WHERE
      (inventory_status = 'Normal'
       AND current_stock <= reorder_level)
   OR (inventory_status = 'Low'
       AND current_stock > reorder_level);

/* =========================================================
   VALIDATION SUMMARY
   =========================================================

   The validation phase confirmed:
   - Primary-key uniqueness
   - Foreign-key integrity
   - No orphan records
   - Valid NULL patterns
   - Valid categorical domains
   - Reasonable numeric ranges
   - Consistent date logic in most clinical tables
   - Documented exceptions and business-rule limitations

   These checks were completed before beginning analytical
   SQL queries and KPI development.
*/
