/*
==========================================================
DDL Script: Create Gold Views
==========================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
    - They support BI tools, dashboards, and ad-hoc analysis.
==========================================================
*/

-- ==========================================================
-- Create Dimension: gold.dim_customers
-- ==========================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;

CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,  -- Surrogate key for dimension table
    ci.cst_id AS customer_id,                                 -- Unique customer ID from CRM
    ci.cst_key AS customer_number,                            -- Internal customer reference number
    ci.cst_firstname AS first_name,                           -- Customer's first name
    ci.cst_lastname AS last_name,                             -- Customer's last name
    la.cntry AS country,                                      -- Country from ERP location data
    ci.cst_marital_status AS marital_status,                  -- Marital status from CRM
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr            -- Prefer CRM gender if valid
        ELSE COALESCE(ca.gen, 'n/a')                          -- Fallback to ERP gender
    END AS gender,
    ca.bdate AS birth_date,                                   -- Birth date from ERP
    ci.cst_create_date AS create_date                         -- Customer creation date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO

-- ==========================================================
-- Create Dimension: gold.dim_products
-- ==========================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id AS product_id,                                                 -- Unique product ID
    pn.prd_key AS product_number,                                            -- Internal product reference
    pn.prd_nm AS product_name,                                               -- Product name
    pn.cat_id AS category_id,                                                -- Foreign key to category
    pc.cat AS category,                                                      -- Category name
    pc.subcat AS subcategory,                                                -- Subcategory name
    pc.maintenance AS maintenance,                                           -- Maintenance classification
    pn.prd_cost AS cost,                                                     -- Product cost
    pn.prd_line AS product_line,                                             -- Product line/series
    pn.prd_start_dt AS start_date                                            -- Product launch date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;  -- Exclude historical/inactive products
GO

-- ==========================================================
-- Create Fact Table: gold.fact_sales
-- ==========================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;

CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num     AS order_number,   -- Unique sales order number
    pr.product_key     AS product_key,    -- FK to dim_products
    cu.customer_key    AS customer_key,   -- FK to dim_customers
    sd.sls_order_dt    AS order_date,     -- Order placement date
    sd.sls_ship_dt     AS shipping_date,  -- Shipment date
    sd.sls_due_dt      AS due_date,       -- Due/delivery date
    sd.sls_sales       AS sales_amount,   -- Total sales amount
    sd.sls_quantity    AS quantity,       -- Quantity sold
    sd.sls_price       AS price           -- Unit price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO
