-- Add indexes for query performance

-- Indexes on fact table foreign keys (for JOIN performance)
CREATE INDEX IF NOT EXISTS idx_fact_song ON fact_streams(song_id);
CREATE INDEX IF NOT EXISTS idx_fact_date ON fact_streams(date_id);
CREATE INDEX IF NOT EXISTS idx_fact_market ON fact_streams(market_id);

-- Composite index for common query patterns (date + song)
CREATE INDEX IF NOT EXISTS idx_fact_date_song ON fact_streams(date_id, song_id);

-- Composite index for market analysis (market + song)
CREATE INDEX IF NOT EXISTS idx_fact_market_song ON fact_streams(market_id, song_id);

-- Index on dim_song for artist lookups
CREATE INDEX IF NOT EXISTS idx_song_artist ON dim_song(artist_id);

-- Index on dim_date for date range queries
CREATE INDEX IF NOT EXISTS idx_date_year_month ON dim_date(year, month);

-- Index on dim_artist for name lookups (already has UNIQUE, but explicit index helps)
CREATE INDEX IF NOT EXISTS idx_artist_name ON dim_artist(artist_name);

-- Index on streams_count for aggregation queries
CREATE INDEX IF NOT EXISTS idx_fact_streams_count ON fact_streams(streams_count);

-- Foreign keys are defined in CREATE TABLE statements; adjust if using other DB.
