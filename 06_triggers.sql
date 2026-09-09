USE HospitalAnalyst;
GO

/* =========================================================
   Hospital Analytics - Triggers
   ========================================================= */


/* =========================================================
   Audit Table 1 - Admission Inserts
   ========================================================= */

CREATE TABLE Admission_Audit
(
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    admission_id INT,
    patient_id INT,
    admission_date DATE,
    action_type VARCHAR(20),
    changed_at DATETIME2 DEFAULT GETDATE()
);
GO


/* =========================================================
   1. AFTER INSERT
   Audit new admissions using inserted
   ========================================================= */

CREATE TRIGGER trg_Admission_AfterInsert
ON admission
AFTER INSERT
AS
BEGIN

    INSERT INTO Admission_Audit
    (
        admission_id,
        patient_id,
        admission_date,
        action_type
    )
    SELECT
        admission_id,
        patient_id,
        admission_date,
        'INSERT'
    FROM inserted;

END;
GO


/* =========================================================
   Audit Table 2 - Billing Updates
   ========================================================= */

CREATE TABLE Billing_Audit
(
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    bill_id INT,
    old_total_amount DECIMAL(18,2),
    new_total_amount DECIMAL(18,2),
    old_payment_status VARCHAR(50),
    new_payment_status VARCHAR(50),
    changed_at DATETIME2 DEFAULT GETDATE()
);
GO


/* =========================================================
   2. AFTER UPDATE
   Compare deleted and inserted values
   ========================================================= */

CREATE TRIGGER trg_Billing_AfterUpdate
ON billing
AFTER UPDATE
AS
BEGIN

    INSERT INTO Billing_Audit
    (
        bill_id,
        old_total_amount,
        new_total_amount,
        old_payment_status,
        new_payment_status
    )
    SELECT
        d.bill_id,
        d.total_amount,
        i.total_amount,
        d.payment_status,
        i.payment_status
    FROM deleted d
    JOIN inserted i
        ON d.bill_id = i.bill_id;

END;
GO


/* =========================================================
   Audit Table 3 - Deleted Prescriptions
   ========================================================= */

CREATE TABLE Prescription_Audit
(
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    prescription_id INT,
    admission_id INT,
    drug_id INT,
    dosage VARCHAR(100),
    action_type VARCHAR(20),
    changed_at DATETIME2 DEFAULT GETDATE()
);
GO


/* =========================================================
   3. AFTER DELETE
   Keep deleted prescription information
   ========================================================= */

CREATE TRIGGER trg_Prescription_AfterDelete
ON prescription
AFTER DELETE
AS
BEGIN

    INSERT INTO Prescription_Audit
    (
        prescription_id,
        admission_id,
        drug_id,
        dosage,
        action_type
    )
    SELECT
        prescription_id,
        admission_id,
        drug_id,
        dosage,
        'DELETE'
    FROM deleted;

END;
GO


/* =========================================================
   4. AFTER INSERT, UPDATE
   Validate Billing Amounts
   total = insurance covered + patient payable
   ========================================================= */

CREATE TRIGGER trg_Billing_ValidateAmounts
ON billing
AFTER INSERT, UPDATE
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE total_amount <>
              insurance_covered_amount + patient_payable_amount
    )
    BEGIN

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW 50010,
              'Billing total must equal insurance covered amount plus patient payable amount.',
              1;

    END;

END;
GO


/* =========================================================
   5. AFTER INSERT, UPDATE
   Validate Insurance Policy Dates
   ========================================================= */

CREATE TRIGGER trg_PatientInsurance_ValidateDates
ON patient_insurance
AFTER INSERT, UPDATE
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE policy_end_date < policy_start_date
    )
    BEGIN

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW 50011,
              'Policy end date cannot be before policy start date.',
              1;

    END;

END;
GO
