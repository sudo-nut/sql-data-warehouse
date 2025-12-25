-- Use PostgreSQL syntax
-- Create sequences for primary keys
CREATE SEQUENCE IF NOT EXISTS seq_artist_id START 1;
CREATE SEQUENCE IF NOT EXISTS seq_song_id START 1;
CREATE SEQUENCE IF NOT EXISTS seq_market_id START 1;
CREATE SEQUENCE IF NOT EXISTS seq_date_id START 1;


-- Staging table (raw data landing zone)
CREATE TABLE IF NOT EXISTS stg_tracks (
    raw_track_id         TEXT,
    title                TEXT,
    artist_name          TEXT,
    album                TEXT,
    release_date         TEXT,
    duration_ms          BIGINT,
    popularity           INTEGER,
    danceability         FLOAT,
    energy               FLOAT,
    key                  INTEGER,
    loudness             FLOAT,
    mode                 INTEGER,
    speechiness          FLOAT,
    acousticness         FLOAT,
    instrumentalness     FLOAT,
    liveness             FLOAT,
    valence              FLOAT,
    tempo                FLOAT,
    track_genre          TEXT,
    market               TEXT,
    stream_date          DATE -- if dataset contains date
);


-- Dimension: artist
CREATE TABLE IF NOT EXISTS dim_artist (
    artist_id    INTEGER PRIMARY KEY DEFAULT nextval('seq_artist_id'),
    artist_name  TEXT UNIQUE,
    country      TEXT,
    first_seen   DATE
);


-- Dimension: song
CREATE TABLE IF NOT EXISTS dim_song (
    song_id       INTEGER PRIMARY KEY DEFAULT nextval('seq_song_id'),
    raw_track_id  TEXT UNIQUE,
    title         TEXT,
    artist_id     INTEGER REFERENCES dim_artist(artist_id),
    album         TEXT,
    duration_ms   BIGINT,
    popularity    INTEGER,
    danceability  FLOAT,
    energy        FLOAT,
    tempo         FLOAT
);


-- Dimension: market
CREATE TABLE IF NOT EXISTS dim_market (
    market_id    INTEGER PRIMARY KEY DEFAULT nextval('seq_market_id'),
    market_code  TEXT UNIQUE,
    region       TEXT
);


-- Dimension: date (simple date dimension)
CREATE TABLE IF NOT EXISTS dim_date (
    date_id   INTEGER PRIMARY KEY DEFAULT nextval('seq_date_id'),
    date      DATE UNIQUE,
    day       INTEGER,
    month     INTEGER,
    year      INTEGER,
    quarter   INTEGER
);


-- Fact table: streams (one row per track per date per market)
CREATE TABLE IF NOT EXISTS fact_streams (
    fact_id           SERIAL PRIMARY KEY,
    song_id           INTEGER REFERENCES dim_song(song_id),
    date_id           INTEGER REFERENCES dim_date(date_id),
    market_id         INTEGER REFERENCES dim_market(market_id),
    streams_count     BIGINT DEFAULT 1,
    popularity_score  INTEGER,
    inserted_at       TIMESTAMP DEFAULT now()
);
