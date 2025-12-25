#!/bin/bash

# SQL Data Warehouse - Setup and Execution Script
# This script demonstrates how to set up the data warehouse
# Run each step manually or execute this entire script

# Set your database name
DB_NAME="music_warehouse"

echo "========================================"
echo "SQL Data Warehouse - Setup Script"
echo "========================================"
echo ""

# Step 1: Create database (run this manually if needed)
echo "Step 1: Create Database"
echo "Run: CREATE DATABASE $DB_NAME;"
echo ""
read -p "Press Enter after creating the database..."

# Step 2: Create schema (sequences, tables)
echo ""
echo "Step 2: Creating schema (sequences and tables)..."
psql -d $DB_NAME -f sql/00_create_schema.sql
if [ $? -eq 0 ]; then
    echo "✓ Schema created successfully"
else
    echo "✗ Error creating schema"
    exit 1
fi

# Step 3: Load staging data
echo ""
echo "Step 3: Loading CSV data into staging table..."
echo "Note: Update the file path in 01_load_staging.sql if needed"
psql -d $DB_NAME -f sql/01_load_staging.sql
if [ $? -eq 0 ]; then
    echo "✓ Data loaded successfully"
else
    echo "✗ Error loading data"
    exit 1
fi

# Step 4: Transform and load dimensions and fact table
echo ""
echo "Step 4: Running ETL pipeline (populating dimensions and fact table)..."
psql -d $DB_NAME -f sql/02_transform.sql
if [ $? -eq 0 ]; then
    echo "✓ ETL completed successfully"
else
    echo "✗ Error in ETL process"
    exit 1
fi

# Step 5: Create indexes
echo ""
echo "Step 5: Creating indexes for query performance..."
psql -d $DB_NAME -f sql/03_indexes.sql
if [ $? -eq 0 ]; then
    echo "✓ Indexes created successfully"
else
    echo "✗ Error creating indexes"
    exit 1
fi

# Step 6: Run sample queries
echo ""
echo "Step 6: Running sample analytical queries..."
echo "Press Enter to see query results..."
read
psql -d $DB_NAME -f sql/04_queries.sql

echo ""
echo "========================================"
echo "✓ Setup Complete!"
echo "========================================"
echo ""
echo "You can now:"
echo "1. Connect to the database: psql -d $DB_NAME"
echo "2. Run additional queries from sql/04_queries.sql"
echo "3. Explore the data in DataGrip"
echo ""
echo "Table counts:"
psql -d $DB_NAME -c "SELECT 'dim_artist' as table_name, COUNT(*) as count FROM dim_artist
                      UNION ALL SELECT 'dim_song', COUNT(*) FROM dim_song
                      UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
                      UNION ALL SELECT 'dim_market', COUNT(*) FROM dim_market
                      UNION ALL SELECT 'fact_streams', COUNT(*) FROM fact_streams;"
