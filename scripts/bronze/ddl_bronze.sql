/*
================================================================================
DDL Script: Create Bronze Tables in Google Cloud SQL
================================================================================
Script purpose:
  This scrip creates table in the 'bronze' schema, dropping existing tables if
  they exist.
  Run the script to redefine the DDL structure of 'bronze' tables.
================================================================================
*/


CALL bronze.load_bronze();

DROP PROCEDURE IF EXISTS bronze.load_bronze;

CREATE PROCEDURE bronze.load_bronze()
BEGIN

    DROP TABLE IF EXISTS bronze.crm_cust_info;
    CREATE TABLE bronze.crm_cust_info(
        cst_id INT,
        cst_key NVARCHAR(50),
        cst_firstname NVARCHAR(50),
        cst_lastname NVARCHAR(50),
        cst_material_status NVARCHAR(50),
        cst_gndr NVARCHAR(50),
        cst_create_date DATE
    );

    DROP TABLE IF EXISTS bronze.crm_prd_info;
    CREATE TABLE bronze.crm_prd_info(
        prd_id INT,
        prd_key NVARCHAR(50),
        prd_nm NVARCHAR(50),
        prd_cost INT,
        prd_line NVARCHAR(50),
        prd_start_dt DATE,
        prd_end_dt DATE
    );

    DROP TABLE IF EXISTS bronze.crm_sales_details;
    CREATE TABLE bronze.crm_sales_details(
      sls_ord_num NVARCHAR(50),
      sls_prd_key NVARCHAR(50),
      sls_cust_id INT,
      sls_order_dt DATE,
      sls_ship_dt DATE,
      sls_due_dt DATE,
      sls_sales INT,
      sls_quantity INT,
      sls_price INT
    );

    DROP TABLE IF EXISTS bronze.erp_cust_az12;
    CREATE TABLE bronze.erp_cust_az12(
      cid NVARCHAR(50),
      bdate DATE,
      gen VARCHAR(50)
    );

    DROP TABLE IF EXISTS bronze.erp_loc_a1o1;
    CREATE TABLE bronze.erp_loc_a1o1(
      cid NVARCHAR(50),
      cntry VARCHAR(50)
    );

    DROP TABLE IF EXISTS bronze.erp_px_cat_giv2;
    CREATE TABLE bronze.erp_px_cat_giv2(
      id VARCHAR(50),
      cat VARCHAR(50),
      subcat VARCHAR(50),
      maintenance VARCHAR(50)
    );


    DELETE from bronze.crm_cust_info
    WHERE cst_id = 0;

    select *
    from bronze.crm_cust_info;

END
