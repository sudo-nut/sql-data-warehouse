# Star Schema ERD - SQL Data Warehouse

## Schema Overview
This data warehouse implements a **Star Schema** for analyzing music streaming data.

## Tables Structure

### Central Fact Table
**fact_streams** (Fact Table - Center of the Star)
- fact_id (PK, SERIAL)
- song_id (FK → dim_song)
- date_id (FK → dim_date)
- market_id (FK → dim_market)
- streams_count (BIGINT)
- popularity_score (INTEGER)
- inserted_at (TIMESTAMP)

### Dimension Tables (Points of the Star)

**dim_song** (Song Dimension)
- song_id (PK)
- raw_track_id (UNIQUE)
- title
- artist_id (FK → dim_artist)
- album
- duration_ms
- popularity
- danceability
- energy
- tempo

**dim_artist** (Artist Dimension)
- artist_id (PK)
- artist_name (UNIQUE)
- country
- first_seen (DATE)

**dim_date** (Date Dimension)
- date_id (PK)
- date (UNIQUE)
- day
- month
- year
- quarter

**dim_market** (Market/Geography Dimension)
- market_id (PK)
- market_code (UNIQUE)
- region

**stg_tracks** (Staging Table - Raw Data Landing)
- raw_track_id
- title
- artist_name
- album
- release_date
- duration_ms
- popularity
- danceability
- energy
- key
- loudness
- mode
- speechiness
- acousticness
- instrumentalness
- liveness
- valence
- tempo
- track_genre
- market
- stream_date

## Relationships

```
                    dim_date
                       |
                       | (1:M)
                       |
    dim_artist ─(1:M)─ dim_song ─(1:M)─ fact_streams ─(M:1)─ dim_market
                                              |
                                           (Measures)
                                         streams_count
                                         popularity_score
```

### Foreign Key Relationships:
1. **fact_streams.song_id** → **dim_song.song_id** (Many-to-One)
2. **fact_streams.date_id** → **dim_date.date_id** (Many-to-One)
3. **fact_streams.market_id** → **dim_market.market_id** (Many-to-One)
4. **dim_song.artist_id** → **dim_artist.artist_id** (Many-to-One)

## Data Flow (ETL Pipeline)

1. **Extract**: CSV data loaded into `stg_tracks` (staging table)
2. **Transform**: 
   - Populate dimension tables from staging
   - Deduplicate and normalize data
   - Create surrogate keys
3. **Load**: Populate `fact_streams` with foreign keys to dimensions

## Star Schema Benefits

✅ **Simple JOIN queries** - All dimensions connect directly to fact table
✅ **Fast query performance** - Fewer JOINs required
✅ **Easy to understand** - Intuitive structure
✅ **Optimized for analytics** - Perfect for aggregations and reporting
✅ **Indexed properly** - Foreign keys and common query patterns indexed

## Query Examples

### Typical Analysis Patterns:
- Time-based analysis (streams by date/month/year)
- Geographic analysis (streams by market)
- Artist/Song performance analysis
- Ranking and trending (using window functions)
- Moving averages and growth trends
