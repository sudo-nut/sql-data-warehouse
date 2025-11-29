-- 1) Populate dim_artist (avoid duplicates)
INSERT INTO dim_artist (artist_name, first_seen)
SELECT DISTINCT s.artist_name, MIN(CAST(NULLIF(s.release_date,'') AS DATE))
FROM stg_tracks s
WHERE s.artist_name IS NOT NULL
ON CONFLICT (artist_name) DO NOTHING;


-- 2) Populate dim_market
INSERT INTO dim_market (market_code, region)
SELECT DISTINCT s.market, NULL
FROM stg_tracks s
WHERE s.market IS NOT NULL
ON CONFLICT (market_code) DO NOTHING;


-- 3) Populate dim_date
INSERT INTO dim_date (date, day, month, year, quarter)
SELECT DISTINCT s.stream_date::date,
       EXTRACT(DAY FROM s.stream_date::date)::int,
       EXTRACT(MONTH FROM s.stream_date::date)::int,
       EXTRACT(YEAR FROM s.stream_date::date)::int,
       EXTRACT(QUARTER FROM s.stream_date::date)::int
FROM stg_tracks s
WHERE s.stream_date IS NOT NULL
ON CONFLICT (date) DO NOTHING;


-- 4) Populate dim_song (link to artist)
INSERT INTO dim_song (raw_track_id, title, artist_id, album, duration_ms, popularity, danceability, energy, tempo)
SELECT DISTINCT s.raw_track_id,
       s.title,
       a.artist_id,
       s.album,
       s.duration_ms,
       s.popularity,
       s.danceability,
       s.energy,
       s.tempo
FROM stg_tracks s
LEFT JOIN dim_artist a ON a.artist_name = s.artist_name
ON CONFLICT (raw_track_id) DO NOTHING;


-- 5) Populate fact_streams
INSERT INTO fact_streams (song_id, date_id, market_id, streams_count, popularity_score)
SELECT ds.song_id,
       dd.date_id,
       dm.market_id,
       COUNT(*) as streams_count,
       MAX(ds.popularity) as popularity_score
FROM stg_tracks s
JOIN dim_song ds ON ds.raw_track_id = s.raw_track_id
JOIN dim_date dd ON dd.date = s.stream_date::date
JOIN dim_market dm ON dm.market_code = s.market
GROUP BY ds.song_id, dd.date_id, dm.market_id;
