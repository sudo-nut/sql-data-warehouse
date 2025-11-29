-- Add indexes for query performance
CREATE INDEX IF NOT EXISTS idx_fact_song ON fact_streams(song_id);
CREATE INDEX IF NOT EXISTS idx_fact_date ON fact_streams(date_id);
CREATE INDEX IF NOT EXISTS idx_fact_market ON fact_streams(market_id);


-- Foreign keys are defined in CREATE TABLE statements; adjust if using other DB.
