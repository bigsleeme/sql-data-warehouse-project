/*
================================================================================
DDL Script: Create Silver Tables in Google Cloud SQL
================================================================================
Script purpose:
  This scrip creates table in the 'Silver' schema, dropping existing tables if
  they exist.
  Run the script to redefine the DDL structure of 'Silver' tables.
================================================================================
*/

    DROP TABLE IF EXISTS silver.crm_cust_info;
    CREATE TABLE silver.crm_cust_info(
        cst_id INT,
        cst_key NVARCHAR(50),
        cst_firstname NVARCHAR(50),
        cst_lastname NVARCHAR(50),
        cst_material_status NVARCHAR(50),
        cst_gndr NVARCHAR(50),
        cst_create_date DATE,
        dwh_create_date DATETIME DEFAULT NOW()
    );

    DROP TABLE IF EXISTS silver.crm_prd_info;
    CREATE TABLE silver.crm_prd_info(
        prd_id INT,
        prd_key NVARCHAR(50),
        prd_nm NVARCHAR(50),
        prd_cost INT,
        prd_line NVARCHAR(50),
        prd_start_dt DATE,
        prd_end_dt DATE,
        dwh_create_date DATETIME DEFAULT NOW()
    );

    DROP TABLE IF EXISTS silver.crm_sales_details;
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

    DROP TABLE IF EXISTS silver.erp_cust_az12;
    CREATE TABLE silver.erp_cust_az12(
      cid NVARCHAR(50),
      bdate DATE,
      gen VARCHAR(50),
      dwh_create_date DATETIME DEFAULT NOW()
    );

    DROP TABLE IF EXISTS silver.erp_loc_a1o1;
    CREATE TABLE silver.erp_loc_a1o1(
      cid NVARCHAR(50),
      cntry VARCHAR(50),
      dwh_create_date DATETIME DEFAULT NOW()
    );

    DROP TABLE IF EXISTS silver.erp_px_cat_giv2;
    CREATE TABLE silver.erp_px_cat_giv2(
      id VARCHAR(50),
      cat VARCHAR(50),
      subcat VARCHAR(50),
      maintenance VARCHAR(50),
      dwh_create_date DATETIME DEFAULT NOW()
    );

