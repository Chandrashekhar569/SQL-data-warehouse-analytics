/*
=====================================================================
Script Name   : SetupDataWarehouse.sql
Purpose       : 
    - Safely drop and recreate the 'DataWarehouse' database.
    - Initialize a multi-layered schema architecture: bronze, silver, gold.
    - Used in ETL/data warehousing workflows to enforce data segregation.

WARNING       :
    - This script forcefully drops the 'DataWarehouse' database if it exists,
      terminating all active connections using ROLLBACK IMMEDIATE.
    - Ensure critical data is backed up before running this in production.
=====================================================================
*/

-- Switch to master context to manage database operations
USE master;
GO

-- Drop 'DataWarehouse' if it exists, and terminate active sessions
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Recreate the database
CREATE DATABASE DataWarehouse;
GO

-- Switch to the newly created database
USE DataWarehouse;
GO

-- Create schemas representing stages of data processing
CREATE SCHEMA bronze;   -- Raw ingested data
GO

CREATE SCHEMA silver;   -- Cleaned and transformed data
GO

CREATE SCHEMA gold;     -- Aggregated, business-ready data
GO
