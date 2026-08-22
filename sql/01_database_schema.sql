/*
============================================================
 Hospital Analytics Project
 Database: HospitalAnalyst
 Platform: Microsoft SQL Server

 Purpose:
 Creates the relational database schema used for the
 Hospital Analytics portfolio project, including 19 tables,
 primary keys, and foreign-key relationships.

 Author: Nesa Jahan
============================================================
*/USE HospitalAnalyst;
GO

/* =========================================================
   TABLE: Department
   ========================================================= */
CREATE TABLE dbo.Department (
    department_id INT NOT NULL,
    department_name NVARCHAR(100) NOT NULL,
    department_type NVARCHAR(50) NULL,
    floor_number INT NULL,
    status NVARCHAR(20) NULL,

    CONSTRAINT PK_Department
        PRIMARY KEY (department_id)
);
GO


/* =========================================================
   TABLE: Patient
   ========================================================= */
CREATE TABLE dbo.Patient (
    patient_id INT NOT NULL,
    gender NVARCHAR(20) NULL,
    birthdate DATE NULL,
    blood_group NVARCHAR(5) NULL,
    city NVARCHAR(50) NULL,
    contact_number NVARCHAR(50) NULL,

    CONSTRAINT PK_Patient
        PRIMARY KEY (patient_id)
);
GO


/* =========================================================
   TABLE: Disease
   ========================================================= */
CREATE TABLE dbo.disease (
    disease_id INT NOT NULL,
    disease_name NVARCHAR(100) NULL,
    disease_category NVARCHAR(100) NULL,

    CONSTRAINT PK_Disease
        PRIMARY KEY (disease_id)
);
GO


/* =========================================================
   TABLE: Drug Manufacturer
   ========================================================= */
CREATE TABLE dbo.drug_manufacturer (
    manufacturer_id INT NOT NULL,
    manufacturer_name NVARCHAR(100) NULL,
    country NVARCHAR(50) NULL,
    reliability_rating DECIMAL(18,2) NULL,
    contract_status NVARCHAR(20) NULL,

    CONSTRAINT PK_DrugManufacturer
        PRIMARY KEY (manufacturer_id)
);
GO


/* =========================================================
   TABLE: Insurance Provider
   ========================================================= */
CREATE TABLE dbo.insurance_provider (
    insurance_provider_id INT NOT NULL,
    provider_name NVARCHAR(100) NULL,
    provider_type NVARCHAR(20) NULL,
    contact_details NVARCHAR(255) NULL,
    coverage_limit DECIMAL(18,2) NULL,

    CONSTRAINT PK_InsuranceProvider
        PRIMARY KEY (insurance_provider_id)
);
GO


/* =========================================================
   TABLE: Ward
   ========================================================= */
CREATE TABLE dbo.ward (
    ward_id INT NOT NULL,
    ward_name NVARCHAR(100) NULL,
    ward_type NVARCHAR(50) NULL,
    total_beds INT NULL,
    department_id INT NULL,

    CONSTRAINT PK_Ward
        PRIMARY KEY (ward_id),

    CONSTRAINT FK_ward_department
        FOREIGN KEY (department_id)
        REFERENCES dbo.Department(department_id)
);
GO


/* =========================================================
   TABLE: Bed
   ========================================================= */
CREATE TABLE dbo.bed (
    bed_id INT NOT NULL,
    bed_number NVARCHAR(20) NULL,
    bed_status NVARCHAR(50) NULL,
    ward_id INT NULL,

    CONSTRAINT PK_Bed
        PRIMARY KEY (bed_id),

    CONSTRAINT FK_ward_bed
        FOREIGN KEY (ward_id)
        REFERENCES dbo.ward(ward_id)
);
GO


/* =========================================================
   TABLE: Employee
   ========================================================= */
CREATE TABLE dbo.employee (
    employee_id INT NOT NULL,
    employee_name NVARCHAR(100) NULL,
    gender NVARCHAR(50) NULL,
    role NVARCHAR(50) NULL,
    employee_type NVARCHAR(50) NULL,
    date_of_joining DATE NULL,
    department_id INT NULL,

    CONSTRAINT PK_Employee
        PRIMARY KEY (employee_id),

    CONSTRAINT FK_employee_department
        FOREIGN KEY (department_id)
        REFERENCES dbo.Department(department_id)
);
GO


/* =========================================================
   TABLE: Doctor
   ========================================================= */
CREATE TABLE dbo.doctor (
    doctor_id INT NOT NULL,
    specialization NVARCHAR(50) NULL,
    qualification NVARCHAR(50) NULL,
    experience_years INT NULL,
    employee_id INT NULL,

    CONSTRAINT PK_Doctor
        PRIMARY KEY (doctor_id),

    CONSTRAINT FK_doctor_employee
        FOREIGN KEY (employee_id)
        REFERENCES dbo.employee(employee_id)
);
GO


/* =========================================================
   TABLE: Diagnostic Test
   ========================================================= */
CREATE TABLE dbo.diagnostic_test (
    test_id INT NOT NULL,
    test_name NVARCHAR(50) NULL,
    test_category NVARCHAR(20) NULL,
    standard_cost DECIMAL(18,2) NULL,
    department_id INT NULL,

    CONSTRAINT PK_DiagnosticTest
        PRIMARY KEY (test_id),

    CONSTRAINT FK_department_diagnostic_test
        FOREIGN KEY (department_id)
        REFERENCES dbo.Department(department_id)
);
GO


/* =========================================================
   TABLE: Drug
   ========================================================= */
CREATE TABLE dbo.drug (
    drug_id INT NOT NULL,
    drug_name NVARCHAR(100) NULL,
    brand_name NVARCHAR(255) NULL,
    drug_category NVARCHAR(100) NULL,
    unit_cost DECIMAL(18,2) NULL,
    manufacturer_id INT NULL,

    CONSTRAINT PK_Drug
        PRIMARY KEY (drug_id),

    CONSTRAINT FK_drug_manufacturer_drug
        FOREIGN KEY (manufacturer_id)
        REFERENCES dbo.drug_manufacturer(manufacturer_id)
);
GO


/* =========================================================
   TABLE: Drug Inventory
   ========================================================= */
CREATE TABLE dbo.drug_inventory (
    inventory_id INT NOT NULL,
    current_stock INT NULL,
    reorder_level INT NULL,
    inventory_status NVARCHAR(20) NULL,
    last_restock_date DATE NULL,
    drug_id INT NULL,

    CONSTRAINT PK_DrugInventory
        PRIMARY KEY (inventory_id),

    CONSTRAINT FK_drug_drug_inventory
        FOREIGN KEY (drug_id)
        REFERENCES dbo.drug(drug_id)
);
GO


/* =========================================================
   TABLE: Admission
   ========================================================= */
CREATE TABLE dbo.admission (
    admission_id INT NOT NULL,
    admission_date DATE NULL,
    discharge_date DATE NULL,
    admission_type NVARCHAR(50) NULL,
    admission_status NVARCHAR(50) NULL,
    patient_id INT NULL,
    department_id INT NULL,
    ward_id INT NULL,
    bed_id INT NULL,
    disease_id INT NULL,

    CONSTRAINT PK_Admission
        PRIMARY KEY (admission_id),

    CONSTRAINT FK_patient_admission
        FOREIGN KEY (patient_id)
        REFERENCES dbo.Patient(patient_id),

    CONSTRAINT FK_department_admission
        FOREIGN KEY (department_id)
        REFERENCES dbo.Department(department_id),

    CONSTRAINT FK_ward_admission
        FOREIGN KEY (ward_id)
        REFERENCES dbo.ward(ward_id),

    CONSTRAINT FK_bed_admission
        FOREIGN KEY (bed_id)
        REFERENCES dbo.bed(bed_id),

    CONSTRAINT FK_disease_admission
        FOREIGN KEY (disease_id)
        REFERENCES dbo.disease(disease_id)
);
GO


/* =========================================================
   TABLE: Billing
   ========================================================= */
CREATE TABLE dbo.billing (
    bill_id INT NOT NULL,
    bill_date DATE NULL,
    total_amount DECIMAL(18,2) NULL,
    insurance_covered_amount DECIMAL(18,2) NULL,
    patient_payable_amount DECIMAL(18,2) NULL,
    payment_status NVARCHAR(50) NULL,
    payment_mode NVARCHAR(50) NULL,
    admission_id INT NULL,

    CONSTRAINT PK_Billing
        PRIMARY KEY (bill_id),

    CONSTRAINT FK_admission_billing
        FOREIGN KEY (admission_id)
        REFERENCES dbo.admission(admission_id)
);
GO


/* =========================================================
   TABLE: Billing Detail
   ========================================================= */
CREATE TABLE dbo.billing_detail (
    billing_detail_id INT NOT NULL,
    charge_type NVARCHAR(50) NULL,
    reference_id INT NULL,
    amount DECIMAL(18,2) NULL,
    bill_id INT NULL,

    CONSTRAINT PK_BillingDetail
        PRIMARY KEY (billing_detail_id),

    CONSTRAINT FK_billing_billing_details
        FOREIGN KEY (bill_id)
        REFERENCES dbo.billing(bill_id)
);
GO


/* =========================================================
   TABLE: Prescription
   ========================================================= */
CREATE TABLE dbo.prescription (
    prescription_id INT NOT NULL,
    dosage NVARCHAR(50) NULL,
    frequency NVARCHAR(50) NULL,
    duration_days INT NULL,
    admission_id INT NULL,
    drug_id INT NULL,

    CONSTRAINT PK_Prescription
        PRIMARY KEY (prescription_id),

    CONSTRAINT FK_admission_prescription
        FOREIGN KEY (admission_id)
        REFERENCES dbo.admission(admission_id),

    CONSTRAINT FK_drug_prescription
        FOREIGN KEY (drug_id)
        REFERENCES dbo.drug(drug_id)
);
GO


/* =========================================================
   TABLE: Patient Diagnostic
   ========================================================= */
CREATE TABLE dbo.patient_diagnostic (
    patient_diagnostic_id INT NOT NULL,
    test_date DATE NULL,
    result_status NVARCHAR(20) NULL,
    admission_id INT NULL,
    test_id INT NULL,
    doctor_id INT NULL,

    CONSTRAINT PK_PatientDiagnostic
        PRIMARY KEY (patient_diagnostic_id),

    CONSTRAINT FK_admission_patient_diagnostic
        FOREIGN KEY (admission_id)
        REFERENCES dbo.admission(admission_id),

    CONSTRAINT FK_diagnostic_test_patient_diagnostic
        FOREIGN KEY (test_id)
        REFERENCES dbo.diagnostic_test(test_id),

    CONSTRAINT FK_doctor_patient_diagnostic
        FOREIGN KEY (doctor_id)
        REFERENCES dbo.doctor(doctor_id)
);
GO


/* =========================================================
   TABLE: Patient Insurance
   ========================================================= */
CREATE TABLE dbo.patient_insurance (
    patient_insurance_id INT NOT NULL,
    policy_number NVARCHAR(30) NULL,
    coverage_percentage INT NULL,
    policy_start_date DATE NULL,
    policy_end_date DATE NULL,
    patient_id INT NULL,
    insurance_provider_id INT NULL,

    CONSTRAINT PK_PatientInsurance
        PRIMARY KEY (patient_insurance_id),

    CONSTRAINT FK_patient_patient_insurance
        FOREIGN KEY (patient_id)
        REFERENCES dbo.Patient(patient_id),

    CONSTRAINT FK_insurance_provider_patient_insurance
        FOREIGN KEY (insurance_provider_id)
        REFERENCES dbo.insurance_provider(insurance_provider_id)
);
GO


/* =========================================================
   TABLE: Staff Assignment
   ========================================================= */
CREATE TABLE dbo.staff_assignment (
    assignment_id INT NOT NULL,
    shift NVARCHAR(20) NULL,
    employee_id INT NULL,
    ward_id INT NULL,

    CONSTRAINT PK_StaffAssignment
        PRIMARY KEY (assignment_id),

    CONSTRAINT FK_Assignment_employee
        FOREIGN KEY (employee_id)
        REFERENCES dbo.employee(employee_id),

    CONSTRAINT FK_Assignment_ward
        FOREIGN KEY (ward_id)
        REFERENCES dbo.ward(ward_id)
);
GO
