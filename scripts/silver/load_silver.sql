DROP PROCEDURE IF EXISTS silver.load_silver;

CREATE PROCEDURE silver.load_silver()
BEGIN
  DECLARE start_time DATETIME;
  DECLARE end_time DATETIME;
  
  -- Cleaning, Normalizing, and inserting crm_cust_info into silver layer database
  SET start_time = NOW();
  INSERT INTO silver.crm_cust_info(

    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_material_status,
    cst_gndr,
    cst_create_date
  )
  SELECT 
  cst_id,
  cst_key,
  TRIM(cst_firstname) AS cst_firstname,
  TRIM(cst_lastname) AS cst_lastname,
  CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'SINGLE'
        WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'MARRIED'
        ELSE 'N/A'
  END cst_material_status, -- Normalize marital status value to readable format
  CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
        ELSE 'N/A'
  END cst_gndr, -- Normalize gender value to readable format
  cst_create_date
  FROM (
  SELECT 
  *,
  ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY  cst_create_date DESC) AS flag_last
  FROM bronze.crm_cust_info
  WHERE cst_id IS NOT NULL) AS subquery_alias WHERE flag_last = 1; -- select the most recent record per customer
  SET end_time = NOW();


  -- Cleaning, Normalizing, and inserting crm_prd_info into silver layer database
  SET start_time = NOW();
  INSERT INTO silver.crm_prd_info(
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
  )
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
  SET end_time = NOW();


  -- Cleaning, Normalizing, and inserting crm_sales_details into silver layer database
  SET start_time = NOW();
  INSERT INTO silver.crm_sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
  )
  SELECT
    T.sls_ord_num,
    T.sls_prd_key,
    T.sls_cust_id,
    T.sls_order_dt,
    T.sls_ship_dt,
    T.sls_due_dt,
    T.sls_quantity * T.sls_price AS new_sls_sales,
    T.sls_quantity,
    T.sls_price
  FROM
  (SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_price IS NULL OR sls_quantity IS NULL 
      THEN ROUND(sls_price * sls_quantity, 0)     
      ELSE sls_sales
    END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
    sls_quantity,
    CASE WHEN sls_price IS NULL OR sls_price <= 0 OR sls_quantity <= 0 OR sls_quantity IS NULL 
      THEN ROUND(ABS(sls_sales) / NULLIF(sls_quantity, 0), 0) 
      ELSE sls_price
    END AS sls_price -- Derive price if original value is invalid
  FROM bronze.crm_sales_details Where sls_order_dt!=0) AS T;
  SET end_time = NOW();



  -- Cleaning, Normalizing, and inserting erp_cust_az12 into silver layer database
  SET start_time = NOW();
  INSERT INTO silver.erp_cust_az12(
    cid,
    bdate,
    gen
  )
  SELECT 
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) -- Remove 'NAS' prefix if present
      ELSE cid
    END AS cid,
    CASE WHEN bdate > CURDATE() THEN NULL
      ELSE bdate -- Setting future birthdates to NULL
    END AS bdate,
    CASE 
          WHEN UPPER(TRIM(REGEXP_REPLACE(gen, '[[:cntrl:]]', ''))) IN ('M', 'MALE') THEN 'Male'
          WHEN UPPER(TRIM(REGEXP_REPLACE(gen, '[[:cntrl:]]', ''))) IN ('F', 'FEMALE') THEN 'Female'
          ELSE 'n/a'
      END AS gen -- Normalizing gender values and handle unknown cases
  FROM bronze.erp_cust_az12;



  -- Cleaning, Normalizing, and inserting erp_loc_a1o1 into silver layer database
  SET start_time = NOW();
  INSERT INTO silver.erp_loc_a1o1(
    cid,
    cntry
  )
  SELECT
    REPLACE(cid, '-', '') AS cid, -- Removing '-' from the customer's id to mactch original customer's id
    CASE WHEN TRIM(REGEXP_REPLACE(cntry, '[[:cntrl:]]', '')) = 'DE' THEN 'Germany'
        WHEN TRIM(REGEXP_REPLACE(cntry, '[[:cntrl:]]', '')) IN ('US', 'USA') THEN 'United States'
        WHEN cntry ='' OR cntry IS NULL THEN 'n/a'
      ELSE cntry
    END AS cntry -- Normalizing country Values 
  FROM bronze.erp_loc_a1o1;
  SET end_time = NOW();


  -- Cleaning, Normalizing, and inserting erp_px_cat_giv2 into silver layer database
  SET start_time = NOW();
  INSERT INTO silver.erp_px_cat_giv2(
    id,
    cat,
    subcat,
    maintenance
  )
  SELECT
    id,
    cat,
    subcat,
    TRIM(REGEXP_REPLACE(maintenance, '[[:cntrl:]]', '')) AS maintenance -- Normalizing maintenance by removing control characters
  FROM bronze.erp_px_cat_giv2;
END
