/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

CREATE VIEW gold.dim_product AS
 SELECT
  ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key ) AS product_key,
  pn.prd_id as product_id,
  pn.prd_key as product_number,
  pn.prd_nm as product_name,
  pn.cat_id as category_id,
  pc.cat as category,
  pc.subcat as subcategory,
  pc.maintenance,
  pn.prd_cost as cost,
  pn.prd_line as product_line,
  pn.prd_start_dt as start_date
 FROM silver.crm_prd_info as pn
 LEFT JOIN silver.erp_px_cat_giv2 as pc on pn.cat_id = pc.id
 WHERE pn.prd_end_dt IS NULL
