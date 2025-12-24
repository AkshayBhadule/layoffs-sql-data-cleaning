-- =========================================
-- DATABASE & INITIAL DATA LOAD
-- =========================================

USE world_layoffs;

-- Check raw data
SELECT * FROM layoffs;
SHOW TABLES;

-- =========================================
-- Create staging table (schema copy)
-- =========================================

CREATE TABLE layoffs_staging
LIKE layoffs;

-- Verify table creation
SELECT * FROM layoffs_staging;

-- Copy data from raw table
INSERT INTO layoffs_staging
SELECT * FROM layoffs;
