# Hospital Analytics – SQL Server & Power BI

## Project Overview

This is an end-to-end healthcare data analytics portfolio project built using Microsoft SQL Server and Power BI.

The project focuses on designing and validating a relational hospital database, performing ETL and data-quality analysis, developing analytical SQL queries and KPIs, and ultimately building an interactive Power BI dashboard.

The dataset contains information related to patients, admissions, departments, wards, beds, employees, doctors, diagnostic tests, prescriptions, drugs, billing, insurance, and hospital operations.

---

## Technologies

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL
- Python for selected data-cleaning tasks
- Power BI *(planned)*

---

## Database

The `HospitalAnalyst` relational database contains **19 interconnected tables** representing major hospital operational areas.

Key entities include:

- Patients and admissions
- Departments, wards, and beds
- Employees and doctors
- Diseases and diagnostic tests
- Drugs, prescriptions, and inventory
- Billing and billing details
- Insurance providers and patient policies
- Staff assignments

Primary and foreign key relationships were implemented to maintain referential integrity between related entities.

---

## Project Workflow

### 1. Database Design & Schema

**Completed**

- Created 19 relational SQL Server tables
- Defined appropriate SQL data types
- Implemented primary keys
- Implemented foreign key relationships
- Validated referential integrity

### 2. ETL & Data Import

**Completed**

Hospital CSV files were loaded into SQL Server primarily using `BULK INSERT`.

Import issues were investigated and resolved, including:

- Data type mismatches
- CSV formatting issues
- File-access errors
- Column-order mismatches
- Blank and NULL values
- Parent-child loading dependencies
- Primary-key and foreign-key errors
- Cases requiring staging or preprocessing

### 3. Data Quality Validation

**Completed**

Data was validated before analytical reporting using:

- NULL checks
- Duplicate detection
- Domain/category validation
- Numeric range validation
- Date logic validation
- Orphan detection
- Referential-integrity checks
- Cross-table business rules

Important data-quality findings were documented rather than automatically modifying uncertain source data.

### 4. SQL Analysis & KPI Development

**In Progress**

The next phase includes analytical SQL queries focused on hospital operations, patient activity, clinical trends, billing, insurance, inventory, and performance indicators.

Planned techniques include:

- Multi-table joins
- Aggregations
- CTEs
- Subqueries
- Window functions
- Views
- Stored procedures
- Advanced analytical SQL

### 5. Power BI

**Planned**

The validated SQL Server database will be connected to Power BI for:

- Data modeling
- Power Query transformations
- DAX measures
- KPI development
- Interactive visualizations
- Dashboard development

---

## Key Data Quality Findings

Several notable findings were identified during validation:

- A significant portion of billing dates occurred before their associated admission dates and were documented as a source-data limitation rather than automatically corrected.
- Duplicate insurance policy numbers were investigated and found to belong to different insurance providers.
- Several manufacturer names appeared more than once and were retained as potential, rather than confirmed, duplicates.
- Drug inventory status was validated against stock and reorder levels.
- Foreign-key relationships were validated for orphan records.

---

## Repository Structure

```text
Hospital-Analytics-SQL-PowerBI/
│
├── README.md
│
├── sql/
│   ├── 01_database_schema.sql
│   ├── 02_data_import.sql
│   └── 03_data_quality_validation.sql
│
├── documentation/
│   └── ETL_Troubleshooting.md
│
└── powerbi/
    └── Planned
```

---

## Current Project Status

Database Design: **Completed**  
Data Import / ETL: **Completed**  
Data Quality Validation: **Completed**  
SQL Analysis: **In Progress**  
Power BI Dashboard: **Planned**

---

## Project Goal

The goal of this project is to demonstrate an end-to-end data analytics workflow, from relational database design and ETL troubleshooting through data validation, SQL analysis, data modeling, and business intelligence reporting.
