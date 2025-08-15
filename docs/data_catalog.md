# 📘 Data Dictionary for Gold Layer

## Overview
The **Gold Layer** is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** that model specific business metrics.

---

## 🧍‍♂️ Table: `gold.dim_customers`

### Purpose
Stores customer details enriched with demographic and geographic data, combining CRM and ERP sources.

### Columns

| Column Name       | Data Type      | Description                                                                 |
|-------------------|----------------|-----------------------------------------------------------------------------|
| `customer_key`    | `INT`          | Surrogate key uniquely identifying each customer record in the dimension.  |
| `customer_id`     | `INT`          | Unique numerical identifier assigned to each customer.                     |
| `customer_number` | `NVARCHAR(50)` | Alphanumeric identifier used for tracking and referencing.                 |
| `first_name`      | `NVARCHAR(50)` | The customer's first name, as recorded in the system.                      |
| `last_name`       | `NVARCHAR(50)` | The customer's last name or family name.                                   |
| `country`         | `NVARCHAR(50)` | The country of residence for the customer (e.g., 'Australia').             |
| `marital_status`  | `NVARCHAR(50)` | The marital status of the customer (e.g., 'Married', 'Single').           |
| `gender`          | `NVARCHAR(10)` | Gender from CRM or fallback to ERP if unavailable.                         |
| `birth_date`      | `DATE`         | Date of birth from ERP.                                                    |
| `create_date`     | `DATE`         | Customer creation date from CRM.                                           |

---

## 📦 Table: `gold.dim_products`

### Purpose
Stores product details enriched with category metadata, excluding historical/inactive products.

### Columns

| Column Name       | Data Type       | Description                                                                 |
|-------------------|-----------------|-----------------------------------------------------------------------------|
| `product_key`     | `INT`           | Surrogate key uniquely identifying each product record.                     |
| `product_id`      | `INT`           | Unique product identifier from CRM.                                         |
| `product_number`  | `NVARCHAR(50)`  | Internal product reference number.                                          |
| `product_name`    | `NVARCHAR(100)` | The name of the product.                                                    |
| `category_id`     | `INT`           | Foreign key to category metadata.                                           |
| `category`        | `NVARCHAR(50)`  | Product category name.                                                      |
| `subcategory`     | `NVARCHAR(50)`  | Subcategory under the main category.                                        |
| `maintenance`     | `NVARCHAR(20)`  | Maintenance classification or flag.                                         |
| `cost`            | `DECIMAL(18,2)` | Product cost.                                                               |
| `product_line`    | `NVARCHAR(50)`  | Line or series the product belongs to.                                      |
| `start_date`      | `DATE`          | Product launch/start date.                                                  |

---

## 💰 Table: `gold.fact_sales`

### Purpose
Captures sales transactions with links to customer and product dimensions for enriched analysis.

### Columns

| Column Name     | Data Type       | Description                                                                 |
|-----------------|-----------------|-----------------------------------------------------------------------------|
| `order_number`  | `NVARCHAR(50)`  | Unique sales order number.                                                  |
| `product_key`   | `INT`           | Foreign key referencing `gold.dim_products`.                                |
| `customer_key`  | `INT`           | Foreign key referencing `gold.dim_customers`.                               |
| `order_date`    | `DATE`          | Date when the order was placed.                                             |
| `shipping_date` | `DATE`          | Date when the order was shipped.                                            |
| `due_date`      | `DATE`          | Expected delivery or payment due date.                                      |
| `sales_amount`  | `DECIMAL(18,2)` | Total sales amount for the order line.                                      |
| `quantity`      | `INT`           | Number of units sold.                                                       |
| `price`         | `DECIMAL(18,2)` | Unit price of the product.                                                  |

---

## 📌 Notes

- All views are created under the `gold` schema.
- Surrogate keys are generated using `ROW_NUMBER()` for dimensional consistency.
- Joins are performed using `LEFT JOIN` to preserve data completeness.
- The `fact_sales` table supports star schema modeling for efficient BI queries.

---

## 📅 Last Updated
*August 2025*
