CREATE SCHEMA staging;
CREATE SCHEMA warehouse;

DROP TABLE IF EXISTS staging.raw_customer_churn;
CREATE TABLE staging.raw_customer_churn (
    customerID TEXT,
    gender TEXT,
    SeniorCitizen INT,
    Partner TEXT,
    Dependents TEXT,
    tenure INT,
    PhoneService TEXT,
    MultipleLines TEXT,
    InternetService TEXT,
    OnlineSecurity TEXT,
    OnlineBackup TEXT,
    DeviceProtection TEXT,
    TechSupport TEXT,
    StreamingTV TEXT,
    StreamingMovies TEXT,
    Contract TEXT,
    PaperlessBilling TEXT,
    PaymentMethod TEXT,
    MonthlyCharges TEXT,
    TotalCharges TEXT,
    Churn TEXT
);
SELECT COUNT(*) FROM staging.raw_customer_churn;

SELECT COUNT(*)
FROM staging.raw_customer_churn
WHERE TotalCharges = '' OR TotalCharges IS NULL;

-- DimCustomer
CREATE TABLE warehouse.dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customerID TEXT,
    gender TEXT,
    SeniorCitizen INT,
    Partner TEXT,
    Dependents TEXT
);

ALTER TABLE warehouse.dim_customer
ADD CONSTRAINT unique_customer UNIQUE (customerID);
-- DimService
CREATE TABLE warehouse.dim_service (
    service_key SERIAL PRIMARY KEY,
    PhoneService TEXT,
    MultipleLines TEXT,
    InternetService TEXT,
    OnlineSecurity TEXT,
    OnlineBackup TEXT,
    DeviceProtection TEXT,
    TechSupport TEXT,
    StreamingTV TEXT,
    StreamingMovies TEXT
);

ALTER TABLE warehouse.dim_service
ADD CONSTRAINT unique_service UNIQUE
(PhoneService, MultipleLines, InternetService,
 OnlineSecurity, OnlineBackup, DeviceProtection,
 TechSupport, StreamingTV, StreamingMovies);
-- DimContract
CREATE TABLE warehouse.dim_contract (
    contract_key SERIAL PRIMARY KEY,
    Contract TEXT,
    PaperlessBilling TEXT
);

ALTER TABLE warehouse.dim_contract
ADD CONSTRAINT unique_contract UNIQUE (Contract, PaperlessBilling);
-- DimPayment
CREATE TABLE warehouse.dim_payment (
    payment_key SERIAL PRIMARY KEY,
    PaymentMethod TEXT
);

ALTER TABLE warehouse.dim_payment
ADD CONSTRAINT unique_payment UNIQUE (PaymentMethod);
-- Insert Customers
INSERT INTO warehouse.dim_customer
(customerID, gender, SeniorCitizen, Partner, Dependents)
SELECT DISTINCT
    customerID, gender, SeniorCitizen, Partner, Dependents
FROM staging.raw_customer_churn;

-- Insert Services
INSERT INTO warehouse.dim_service
(PhoneService, MultipleLines, InternetService,
 OnlineSecurity, OnlineBackup, DeviceProtection,
 TechSupport, StreamingTV, StreamingMovies)
SELECT DISTINCT
    PhoneService, MultipleLines, InternetService,
    OnlineSecurity, OnlineBackup, DeviceProtection,
    TechSupport, StreamingTV, StreamingMovies
FROM staging.raw_customer_churn;

-- Insert Contract
INSERT INTO warehouse.dim_contract
(Contract, PaperlessBilling)
SELECT DISTINCT Contract, PaperlessBilling
FROM staging.raw_customer_churn;

-- Insert Payment
INSERT INTO warehouse.dim_payment
(PaymentMethod)
SELECT DISTINCT PaymentMethod
FROM staging.raw_customer_churn;

-- FactTable
CREATE TABLE warehouse.fact_customer_churn (
    customer_key INT REFERENCES warehouse.dim_customer(customer_key),
    service_key INT REFERENCES warehouse.dim_service(service_key),
    contract_key INT REFERENCES warehouse.dim_contract(contract_key),
    payment_key INT REFERENCES warehouse.dim_payment(payment_key),
    tenure INT,
    MonthlyCharges NUMERIC(10,2),
    TotalCharges NUMERIC(10,2),
    Churn TEXT
);
-- load fact table
INSERT INTO warehouse.fact_customer_churn
(customer_key, service_key, contract_key, payment_key,
 tenure, MonthlyCharges, TotalCharges, Churn)

SELECT
    dc.customer_key,
    ds.service_key,
    dct.contract_key,
    dp.payment_key,
    r.tenure,
    NULLIF(TRIM(r.MonthlyCharges), '')::NUMERIC(10,2),
    NULLIF(TRIM(r.TotalCharges), '')::NUMERIC(10,2),
    r.Churn

FROM staging.raw_customer_churn r

JOIN warehouse.dim_customer dc
    ON r.customerID = dc.customerID

JOIN warehouse.dim_service ds
    ON r.PhoneService = ds.PhoneService
   AND r.MultipleLines = ds.MultipleLines
   AND r.InternetService = ds.InternetService
   AND r.OnlineSecurity = ds.OnlineSecurity
   AND r.OnlineBackup = ds.OnlineBackup
   AND r.DeviceProtection = ds.DeviceProtection
   AND r.TechSupport = ds.TechSupport
   AND r.StreamingTV = ds.StreamingTV
   AND r.StreamingMovies = ds.StreamingMovies

JOIN warehouse.dim_contract dct
    ON r.Contract = dct.Contract
   AND r.PaperlessBilling = dct.PaperlessBilling

JOIN warehouse.dim_payment dp
    ON r.PaymentMethod = dp.PaymentMethod;

-- Row Count Check
SELECT COUNT(*) 
FROM staging.raw_customer_churn;

-- Row Count Check
SELECT COUNT(*) 
FROM warehouse.fact_customer_churn;

-- Churn Distribution
SELECT Churn, COUNT(*) AS total_customers
FROM warehouse.fact_customer_churn
GROUP BY Churn;

-- Churn Rate %
SELECT 
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)::numeric 
        / COUNT(*) * 100, 2
    ) AS churn_rate_percent
FROM warehouse.fact_customer_churn;

-- Churn by Gender
SELECT 
    dc.gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN f.Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers
FROM warehouse.fact_customer_churn f
JOIN warehouse.dim_customer dc
    ON f.customer_key = dc.customer_key
GROUP BY dc.gender;

-- Churn by Contract Type
SELECT 
    dct.Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN f.Churn = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM warehouse.fact_customer_churn f
JOIN warehouse.dim_contract dct
    ON f.contract_key = dct.contract_key
GROUP BY dct.Contract
ORDER BY churned DESC;

-- Churn by Payment Method
SELECT 
    dp.PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN f.Churn = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM warehouse.fact_customer_churn f
JOIN warehouse.dim_payment dp
    ON f.payment_key = dp.payment_key
GROUP BY dp.PaymentMethod
ORDER BY churned DESC;

-- Average Monthly Charges (Churn vs Non-Churn)
SELECT 
    Churn,
    ROUND(AVG(MonthlyCharges),2) AS avg_monthly_charges
FROM warehouse.fact_customer_churn
GROUP BY Churn;

-- Tenure Analysis
SELECT 
    Churn,
    ROUND(AVG(tenure),2) AS avg_tenure
FROM warehouse.fact_customer_churn
GROUP BY Churn;

-- Create Power BI View
CREATE OR REPLACE VIEW warehouse.vw_customer_churn_analysis AS

SELECT
    dc.customerID,
    dc.gender,
    dc.SeniorCitizen,
    dc.Partner,
    dc.Dependents,
    ds.InternetService,
    dct.Contract,
    dp.PaymentMethod,
    f.tenure,
    f.MonthlyCharges,
    f.TotalCharges,
    f.Churn
FROM warehouse.fact_customer_churn f
JOIN warehouse.dim_customer dc ON f.customer_key = dc.customer_key
JOIN warehouse.dim_service ds ON f.service_key = ds.service_key
JOIN warehouse.dim_contract dct ON f.contract_key = dct.contract_key
JOIN warehouse.dim_payment dp ON f.payment_key = dp.payment_key;

-- customer_churn_prediction Table
CREATE TABLE warehouse.customer_churn_prediction (
    customerID TEXT,
    churn_probability NUMERIC(5,4),
    risk_segment TEXT
); 