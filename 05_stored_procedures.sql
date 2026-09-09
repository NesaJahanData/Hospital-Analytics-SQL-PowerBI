USE HospitalAnalyst;
GO

/* =========================================================
   Hospital Analytics - Stored Procedures
   ========================================================= */


/* =========================================================
   1. Get Admissions by Date Range
   Parameters + Validation + JOIN
   ========================================================= */

CREATE PROCEDURE usp_GetAdmissionsByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN

    IF @StartDate > @EndDate
    BEGIN
        THROW 50001, 'Start date cannot be after end date.', 1;
    END;

    SELECT
        a.admission_id,
        a.patient_id,
        a.admission_date,
        a.discharge_date,
        a.admission_type,
        a.admission_status,
        d.department_name
    FROM admission a
    JOIN Department d
        ON a.department_id = d.department_id
    WHERE a.admission_date BETWEEN @StartDate AND @EndDate
    ORDER BY a.admission_date;

END;
GO


/* =========================================================
   2. Get Patient Admission History
   Parameter + IF Validation
   ========================================================= */

CREATE PROCEDURE usp_GetPatientAdmissionHistory
    @PatientID INT
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Patient
        WHERE patient_id = @PatientID
    )
    BEGIN
        THROW 50002, 'Patient ID was not found.', 1;
    END;

    SELECT
        a.admission_id,
        a.admission_date,
        a.discharge_date,
        a.admission_type,
        a.admission_status,
        d.department_name,
        ds.disease_name
    FROM admission a
    JOIN Department d
        ON a.department_id = d.department_id
    JOIN disease ds
        ON a.disease_id = ds.disease_id
    WHERE a.patient_id = @PatientID
    ORDER BY a.admission_date DESC;

END;
GO


/* =========================================================
   3. Department Billing Summary
   Multiple Parameters + Validation + Aggregation
   ========================================================= */

CREATE PROCEDURE usp_GetDepartmentBillingSummary
    @DepartmentID INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Department
        WHERE department_id = @DepartmentID
    )
    BEGIN
        THROW 50003, 'Department ID was not found.', 1;
    END;

    IF @StartDate > @EndDate
    BEGIN
        THROW 50004, 'Start date cannot be after end date.', 1;
    END;

    SELECT
        d.department_name,
        COUNT(b.bill_id) AS total_bills,
        SUM(b.total_amount) AS total_billing,
        SUM(b.insurance_covered_amount) AS insurance_covered,
        SUM(b.patient_payable_amount) AS patient_payable,
        AVG(b.total_amount) AS average_bill
    FROM billing b
    JOIN admission a
        ON b.admission_id = a.admission_id
    JOIN Department d
        ON a.department_id = d.department_id
    WHERE
        a.department_id = @DepartmentID
        AND a.admission_date BETWEEN @StartDate AND @EndDate
    GROUP BY
        d.department_name;

END;
GO


/* =========================================================
   4. Get Abnormal Diagnostic Tests by Doctor
   Parameter + Validation + Multi-table JOIN
   ========================================================= */

CREATE PROCEDURE usp_GetAbnormalTestsByDoctor
    @DoctorID INT
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM doctor
        WHERE doctor_id = @DoctorID
    )
    BEGIN
        THROW 50005, 'Doctor ID was not found.', 1;
    END;

    SELECT
        pd.patient_diagnostic_id,
        a.patient_id,
        dt.test_name,
        dt.test_category,
        pd.test_date,
        pd.result_status,
        d.doctor_id,
        e.employee_name AS doctor_name
    FROM patient_diagnostic pd
    JOIN admission a
        ON pd.admission_id = a.admission_id
    JOIN diagnostic_test dt
        ON pd.test_id = dt.test_id
    JOIN doctor d
        ON pd.doctor_id = d.doctor_id
    JOIN employee e
        ON d.employee_id = e.employee_id
    WHERE
        pd.doctor_id = @DoctorID
        AND pd.result_status = 'Abnormal'
    ORDER BY
        pd.test_date DESC;

END;
GO


/* =========================================================
   5. Restock Drug Inventory
   Validation + Transaction + TRY/CATCH + UPDATE
   ========================================================= */

CREATE PROCEDURE usp_RestockDrugInventory
    @DrugID INT,
    @QuantityAdded INT
AS
BEGIN

    IF @QuantityAdded <= 0
    BEGIN
        THROW 50006, 'Quantity added must be greater than zero.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM drug_inventory
        WHERE drug_id = @DrugID
    )
    BEGIN
        THROW 50007, 'Drug inventory record was not found.', 1;
    END;

    BEGIN TRY

        BEGIN TRANSACTION;

        UPDATE drug_inventory
        SET
            current_stock = current_stock + @QuantityAdded,
            inventory_status =
                CASE
                    WHEN current_stock + @QuantityAdded <= reorder_level
                        THEN 'Low'
                    ELSE 'Normal'
                END,
            last_restock_date = CAST(GETDATE() AS DATE)
        WHERE drug_id = @DrugID;

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;

END;
GO
