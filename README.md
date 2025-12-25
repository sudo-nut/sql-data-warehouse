# SQL Data Warehouse Project

SQL Data Warehouse is a hands-on project where you design, build, and query a local SQL data warehouse using an analytical schema (Star Schema or Snowflake).

## 🎯 Project Goals

Learn SQL and database design through practical implementation of:
- ✅ Star schema design
- ✅ Table creation with proper relationships
- ✅ CSV data import and ETL pipeline
- ✅ Complex queries using JOINs and WINDOW functions
- ✅ Performance optimization with indexes

## 📊 Architecture

This project implements a **Star Schema** for analyzing music streaming data with:
- 1 Fact Table: `fact_streams` (streaming events)
- 4 Dimension Tables: `dim_song`, `dim_artist`, `dim_date`, `dim_market`
- 1 Staging Table: `stg_tracks` (raw data landing zone)

See [`diagrams/ERD.md`](diagrams/ERD.md) for detailed schema documentation.

## 🗂️ Project Structure

```
sql-data-warehouse/
├── data/
│   └── raw.csv                  # Sample streaming data (30 records)
├── diagrams/
│   ├── ERD.md                   # Detailed ERD documentation
│   └── star_schema_ascii.txt    # Visual star schema diagram
├── sql/
│   ├── 00_create_schema.sql     # Create tables and sequences
│   ├── 01_load_staging.sql      # Load CSV into staging table
│   ├── 02_transform.sql         # ETL: populate dimensions and fact table
│   ├── 03_indexes.sql           # Create performance indexes
│   └── 04_queries.sql           # Analysis queries (JOINs + WINDOW functions)
└── README.md
```

## 🚀 Setup Instructions

### Prerequisites
- PostgreSQL 12+ installed locally
- DataGrip or psql client
- Database created (e.g., `music_warehouse`)

### Step-by-Step Setup

1. **Create a database**
   ```sql
   CREATE DATABASE music_warehouse;
   ```

2. **Connect to the database**
   ```bash
   psql -d music_warehouse
   # or use DataGrip to connect
   ```

3. **Execute SQL scripts in order**
   ```bash
   # Run these in sequence
   psql -d music_warehouse -f sql/00_create_schema.sql
   psql -d music_warehouse -f sql/01_load_staging.sql
   psql -d music_warehouse -f sql/02_transform.sql
   psql -d music_warehouse -f sql/03_indexes.sql
   
   # Run queries to analyze data
   psql -d music_warehouse -f sql/04_queries.sql
   ```

   **Important**: Update the file path in `01_load_staging.sql` to match your local environment:
   ```sql
   -- Edit this line to use absolute path
   \copy stg_tracks(...) FROM '/absolute/path/to/data/raw.csv' WITH ...
   ```

## 📝 SQL Scripts Overview

### 00_create_schema.sql
Creates all sequences, dimension tables, staging table, and fact table with proper foreign key relationships.

### 01_load_staging.sql
Uses PostgreSQL `\copy` command to load CSV data into the staging table.

### 02_transform.sql
ETL pipeline that:
1. Populates dimension tables from staging (with deduplication)
2. Creates foreign key relationships
3. Loads fact table with aggregated streaming data

### 03_indexes.sql
Creates strategic indexes for:
- Foreign key lookups
- Common query patterns
- Aggregation performance
- Composite indexes for multi-column queries

### 04_queries.sql
Demonstrates various SQL capabilities:

**Basic Queries (1-4):**
- Top 10 most streamed songs
- Streams by month
- Top markets for specific artists
- Songs with highest popularity

**Window Function Queries (5-12):**
- `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()` - Song rankings
- `SUM() OVER()` - Running totals
- `LAG()` - Compare to previous day
- `LEAD()` - Compare to next day
- `PARTITION BY` - Top 3 songs per market
- `ROWS BETWEEN` - Moving averages
- `PERCENT_RANK()`, `NTILE()` - Percentile rankings
- `FIRST_VALUE()`, `LAST_VALUE()` - First/last stream dates

## 🔍 Sample Queries

### Basic Analysis with JOINs
```sql
-- Top 10 most streamed songs
SELECT s.title, a.artist_name, SUM(f.streams_count) AS total_streams
FROM fact_streams f
JOIN dim_song s ON f.song_id = s.song_id
JOIN dim_artist a ON s.artist_id = a.artist_id
GROUP BY s.title, a.artist_name
ORDER BY total_streams DESC
LIMIT 10;
```

### Window Function Analysis
```sql
-- Running total of streams by date
SELECT 
    d.date,
    SUM(f.streams_count) AS daily_streams,
    SUM(SUM(f.streams_count)) OVER (ORDER BY d.date) AS running_total
FROM fact_streams f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.date
ORDER BY d.date;
```

## 📊 Sample Data

The `data/raw.csv` file contains 30 sample records with:
- 15 unique tracks from popular artists
- Multiple markets (US, UK, CA, AU, KR, JP)
- Date range: January 15-28, 2023
- Realistic streaming metrics and audio features

## 🎓 Learning Outcomes

After completing this project, you will understand:

✅ **Star Schema Design** - How to model data for analytics  
✅ **ETL Processes** - Extract, transform, and load data pipelines  
✅ **SQL JOINs** - Inner joins across multiple tables  
✅ **Window Functions** - Advanced analytical queries  
✅ **Indexing Strategies** - Query performance optimization  
✅ **Data Warehousing** - Fact and dimension table concepts  
✅ **PostgreSQL** - Database creation and management  

## 🛠️ Tools Used

- **PostgreSQL** - Open-source relational database
- **DataGrip** - Database IDE (or use psql CLI)
- **CSV** - Data format for raw input

## 📚 Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Window Functions Tutorial](https://www.postgresql.org/docs/current/tutorial-window.html)
- [Star Schema Design](https://en.wikipedia.org/wiki/Star_schema)

## 🤝 Contributing

Feel free to fork this project and add your own:
- Additional sample data
- New analytical queries
- Schema enhancements
- Visualization scripts

## 📄 License

This is an educational project for learning SQL and data warehousing concepts.
