/*
================================================================
Quality Checks
================================================================
Script Purpose:
    This script performs various wuality checks for data consistency, accuracy and 
    and stsnadardization accross the 'silver' schema. it includes checks for:
    * Null or duplicate primary keys.
    * Unwanted spaces in string fields.
    * dATA standardication and consistency.
    *Invalid date ranges and orders.
    Data consistenct between related fields.


Usage Notes:
    *Run these checks after data loading silver layer.
    *Investigate and resolve any discrepancies found during the checks.
================================================================
*/
  

-- Check for unwanted spaces
-- Expectation: No results
SELECT cst_firstname
FROM bronze.crm_cust_info
where cst_firstname != TRIM(cst_firstname);



--Data Standardization and consistency
SELECT DISTINCT cst_gndr 
FROM silver.crm_cust_info;

SELECT *
FROM silver.crm_cust_info;

SELECT
  prd_id,
  REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
  SUBSTRING(prd_key, 7, CHARACTER_LENGTH(prd_key)) AS prd_key,
  prd_nm,
  prd_cost,
  CASE UPPER(TRIM(prd_line))
       WHEN 'M' THEN 'Mountain'
       WHEN 'R' THEN 'Road'
       WHEN 'S' THEN 'Other Sales'
       WHEN 'T' THEN 'Touring'
       ELSE 'N/A'
  END AS prd_line,
  prd_start_dt,
  DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY) AS prd_end_dt_test
FROM bronze.crm_prd_info;

SELECT * FROM silver.crm_prd_info
-- check fro nulls or negative numbers
-- expectin = no results
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;


-- Choosing a subsequent data in a column
SELECT
  prd_id,
  prd_key,
  prd_nm,
  prd_start_dt,
  prd_end_dt,
  DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY) AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN('AC-HE-HL-U509-R', 'AC-HE-HL-U509');



SELECT DISTINCT
  sls_sales,
  sls_quantity,
  sls_price
FROM silver.crm_sales_details
WHERE sls_quantity != TRIM(sls_quantity)

SELECT
  CASE WHEN sls_sales <= 0 THEN ROUND(sls_price * sls_quantity) ELSE sls_sales
  END AS sls_sales,
  CASE WHEN sls_price <= 0 THEN ROUND(ABS(sls_sales) / sls_quantity) ELSE sls_price
  END AS sls_price,
  sls_quantity
FROM bronze.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity


CREATE TABLE silver.crm_sales_details(
      sls_ord_num NVARCHAR(50),
      sls_prd_key NVARCHAR(50),
      sls_cust_id INT,
      sls_order_dt DATE,
      sls_ship_dt DATE,
      sls_due_dt DATE,
      sls_sales INT,
      sls_quantity INT,
      sls_price INT,
      dwh_create_date DATETIME DEFAULT NOW()
    );


-- Cleaning the Customer ID from ERP TABLE

SELECT 
  CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
    ELSE cid
  END AS cid,
  CASE WHEN bdate > CURDATE() THEN NULL
    ELSE bdate
  END AS bdate,
  CASE 
        WHEN UPPER(TRIM(REGEXP_REPLACE(gen, '[[:cntrl:]]', ''))) IN ('M', 'MALE') THEN 'Male'
        WHEN UPPER(TRIM(REGEXP_REPLACE(gen, '[[:cntrl:]]', ''))) IN ('F', 'FEMALE') THEN 'Female'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12

-- Identify Out of Range Dates

SELECT DISTINCT
  bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' or bdate > CURDATE()

-- Data Standardization & Consistency
SELECT DISTINCT 
    gen, 
    CASE 
        WHEN UPPER(TRIM(REGEXP_REPLACE(gen, '[[:cntrl:]]', ''))) IN ('M', 'MALE') THEN 'Male'
        WHEN UPPER(TRIM(REGEXP_REPLACE(gen, '[[:cntrl:]]', ''))) IN ('F', 'FEMALE') THEN 'Female'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;


SELECT
  id,
  cat,
  subcat,
  maintenance
FROM bronze.erp_px_cat_giv2


SELECT *
FROM silver.erp_px_cat_giv2


