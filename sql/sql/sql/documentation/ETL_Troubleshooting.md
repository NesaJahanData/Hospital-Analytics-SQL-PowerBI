# ETL Troubleshooting & Lessons Learned

## Overview

During the Hospital Analytics project, multiple issues were encountered while importing CSV data into SQL Server.

Rather than modifying or deleting source data without investigation, each issue was diagnosed by comparing the source files with the SQL Server schema, reviewing error messages, checking data types, and validating relationships between tables.

This document summarizes the major ETL issues encountered, how they were diagnosed, and how they were resolved.

---

## 1. BULK INSERT File Access Error

### Problem

SQL Server returned an operating system error while attempting to access a CSV file during `BULK INSERT`.

### Cause

The source CSV file was being used by another application, preventing SQL Server from accessing it.

### Resolution

The application using the CSV file was closed and the import was executed again.

### Lesson Learned

File-system errors are different from SQL syntax or data-quality errors. When `BULK INSERT` fails, file accessibility and permissions should be checked before changing SQL code.

---

## 2. CSV Import / Provider Error

### Problem

An import attempt produced an SQL Server provider-related error while using CSV-specific import options.

### Resolution

The import was simplified by explicitly defining the CSV structure using:

- `FIELDTERMINATOR`
- `ROWTERMINATOR`
- `FIELDQUOTE`
- `FIRSTROW`

### Lesson Learned

When an import method fails, simplifying the loading configuration can help isolate whether the problem is caused by the source file, SQL Server configuration, or the destination schema.

---

## 3. Duplicate Primary Key During Re-Import

### Problem

A duplicate primary-key error occurred while loading the Department table.

### Cause

The import had already been executed successfully, and running the insert again attempted to load the same primary-key values.

### Resolution

Existing row counts and table contents were checked before repeating the import.

### Lesson Learned

Before rerunning an ETL operation, verify whether the previous execution inserted data successfully.

Useful checks include:

```sql
SELECT COUNT(*)
FROM dbo.Department;

SELECT TOP (10) *
FROM dbo.Department;
```

---

## 4. Source-to-Destination Data Type Mismatches

Several CSV columns contained values that did not match the initially selected SQL Server data types.

### Patient Contact Number

Phone numbers were initially treated as numeric-style values.

They were stored as `NVARCHAR(50)` instead because phone numbers are identifiers and may contain formatting characters.

### Drug Unit Cost

Drug cost required decimal precision.

The destination column was defined as:

```sql
DECIMAL(18,2)
```

### Manufacturer Reliability Rating

Reliability ratings contained decimal values.

The column was therefore stored as:

```sql
DECIMAL(18,2)
```

### Lesson Learned

A SQL data type should be selected based on the meaning and actual contents of the source attribute, not only on how the first few values appear.

---

## 5. Blank and NULL Source Values

Some source attributes contained blank values.

One example was `reference_id` in `billing_detail`.

Instead of forcing every record to contain a value, the source pattern and business meaning were investigated.

The column was allowed to contain `NULL` where appropriate.

### Lesson Learned

Missing values should not automatically be replaced with artificial values such as `0`.

The correct treatment depends on the business meaning of the attribute.

---

## 6. Column Order Mismatch

### Problem

In some imports, the order of fields in the source file did not align cleanly with the destination-table structure.

### Resolution

The source structure and destination schema were compared before loading.

Where necessary, staging or preprocessing was used so that values could be transformed and loaded into the appropriate destination columns.

### Lesson Learned

Successful ETL requires validating both data types and column mappings.

A table can contain the correct columns and still receive incorrect data if source and destination positions are mismatched.

---

## 7. Foreign Key Violations

### Problem

Some child-table imports initially failed because required parent records had not yet been loaded.

### Example

Doctor records referenced employees through `employee_id`.

### Resolution

Parent tables were loaded before dependent child tables and relationships were validated after loading.

### Lesson Learned

Import order matters in relational databases.

A typical loading sequence is:

**Parent tables → dependent tables → bridge/transaction tables**

---

## 8. Staging and Data Cleaning

Direct loading was used when the CSV structure matched the destination table.

When source values or column structures required transformation, the data was inspected and cleaned before loading into the final relational table.

Staging/preprocessing is useful when:

- Data types require conversion
- Column order requires adjustment
- Source values require cleaning
- Direct loading would risk corrupting the destination data

### Lesson Learned

The goal of ETL is not simply to make an import succeed.

The goal is to preserve data integrity while creating a reliable analytical dataset.

---

# Key Takeaways

This ETL process reinforced several important practices:

- Read SQL Server error messages before changing code.
- Inspect source data before changing destination data types.
- Validate row counts after every import.
- Check parent-child relationships before enforcing foreign keys.
- Do not replace missing values without understanding their meaning.
- Use staging or preprocessing when direct loading is inappropriate.
- Document data-quality issues rather than silently modifying uncertain data.
- Validate imported data before beginning analytical reporting.
