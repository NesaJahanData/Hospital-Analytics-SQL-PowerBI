USE HospitalAnalyst;
GO

/* =========================================================
   Hospital Analytics - SQL Analysis
   ========================================================= */


/* 1. Monthly Admissions Trend */
SELECT
    YEAR(admission_date) AS admission_year,
    MONTH(admission_date) AS admission_month,
    COUNT(*) AS total_admissions
FROM admission
GROUP BY
    YEAR(admission_date),
    MONTH(admission_date)
ORDER BY
    admission_year,
    admission_month;


/* 2. Admissions by Department */
SELECT
    d.department_name,
    COUNT(a.admission_id) AS total_admissions
FROM admission a
JOIN Department d
    ON a.department_id = d.department_id
GROUP BY
    d.department_name
ORDER BY
    total_admissions DESC;


/* 3. Admissions by Disease Category */
SELECT
    ds.disease_category,
    COUNT(a.admission_id) AS total_admissions
FROM admission a
JOIN disease ds
    ON a.disease_id = ds.disease_id
GROUP BY
    ds.disease_category
ORDER BY
    total_admissions DESC;


/* 4. Average Length of Stay by Department */
SELECT
    d.department_name,
    AVG(
        CAST(
            DATEDIFF(DAY, a.admission_date, a.discharge_date)
            AS DECIMAL(10,2)
        )
    ) AS avg_length_of_stay
FROM admission a
JOIN Department d
    ON a.department_id = d.department_id
WHERE a.discharge_date IS NOT NULL
GROUP BY
    d.department_name
ORDER BY
    avg_length_of_stay DESC;


/* 5. Diagnostic Test Results by Test Category */
SELECT
    dt.test_category,
    COUNT(pd.patient_diagnostic_id) AS total_tests,
    SUM(
        CASE
            WHEN pd.result_status = 'Abnormal' THEN 1
            ELSE 0
        END
    ) AS abnormal_tests
FROM patient_diagnostic pd
JOIN diagnostic_test dt
    ON pd.test_id = dt.test_id
GROUP BY
    dt.test_category
ORDER BY
    total_tests DESC;


/* 6. Prescriptions by Drug Category */
SELECT
    d.drug_category,
    COUNT(p.prescription_id) AS total_prescriptions
FROM prescription p
JOIN drug d
    ON p.drug_id = d.drug_id
GROUP BY
    d.drug_category
ORDER BY
    total_prescriptions DESC;


/* 7. Billing Summary by Department */
SELECT
    d.department_name,
    COUNT(b.bill_id) AS total_bills,
    SUM(b.total_amount) AS total_billing,
    SUM(b.insurance_covered_amount) AS insurance_covered,
    SUM(b.patient_payable_amount) AS patient_payable
FROM billing b
JOIN admission a
    ON b.admission_id = a.admission_id
JOIN Department d
    ON a.department_id = d.department_id
GROUP BY
    d.department_name
ORDER BY
    total_billing DESC;


/* 8. Billing by Payment Status */
SELECT
    payment_status,
    COUNT(bill_id) AS total_bills,
    SUM(total_amount) AS total_billing,
    AVG(total_amount) AS average_bill
FROM billing
GROUP BY
    payment_status
ORDER BY
    total_billing DESC;


/* 9. Drugs at or Below Reorder Level */
SELECT
    d.drug_name,
    d.brand_name,
    di.current_stock,
    di.reorder_level,
    di.inventory_status
FROM drug_inventory di
JOIN drug d
    ON di.drug_id = d.drug_id
WHERE di.current_stock <= di.reorder_level
ORDER BY
    di.current_stock;


/* 10. Rank Departments by Total Billing - CTE + RANK */
WITH DepartmentBilling AS
(
    SELECT
        d.department_name,
        SUM(b.total_amount) AS total_billing
    FROM billing b
    JOIN admission a
        ON b.admission_id = a.admission_id
    JOIN Department d
        ON a.department_id = d.department_id
    GROUP BY
        d.department_name
)
SELECT
    department_name,
    total_billing,
    RANK() OVER (
        ORDER BY total_billing DESC
    ) AS billing_rank
FROM DepartmentBilling
ORDER BY
    billing_rank;


/* 11. Monthly Admissions Compared with Previous Month - CTE + LAG */
WITH MonthlyAdmissions AS
(
    SELECT
        YEAR(admission_date) AS admission_year,
        MONTH(admission_date) AS admission_month,
        COUNT(*) AS total_admissions
    FROM admission
    GROUP BY
        YEAR(admission_date),
        MONTH(admission_date)
)
SELECT
    admission_year,
    admission_month,
    total_admissions,
    LAG(total_admissions) OVER (
        ORDER BY admission_year, admission_month
    ) AS previous_month_admissions,
    total_admissions -
    LAG(total_admissions) OVER (
        ORDER BY admission_year, admission_month
    ) AS admission_change
FROM MonthlyAdmissions
ORDER BY
    admission_year,
    admission_month;


/* 12. Patients with More Admissions Than the Average Patient - CTE + Subquery */
WITH PatientAdmissionCounts AS
(
    SELECT
        patient_id,
        COUNT(*) AS admission_count
    FROM admission
    GROUP BY
        patient_id
)
SELECT
    patient_id,
    admission_count
FROM PatientAdmissionCounts
WHERE admission_count >
(
    SELECT AVG(CAST(admission_count AS DECIMAL(10,2)))
    FROM PatientAdmissionCounts
)
ORDER BY
    admission_count DESC;
