-- COPY local CSV into staging table (Postgres)
-- Adjust the file path to your raw CSV file location on your machine.


\copy stg_tracks(raw_track_id, title, artist_name, album, release_date, duration_ms, popularity, danceability, energy, key, loudness, mode, speechiness, acousticness, instrumentalness, liveness, valence, tempo, track_genre, market, stream_date) FROM 'data/raw.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- If your CSV columns differ, adapt the column list above to match.
