-- 1) Top 10 most streamed songs overall
SELECT s.title, a.artist_name, SUM(f.streams_count) AS total_streams
FROM fact_streams f
JOIN dim_song s ON f.song_id = s.song_id
JOIN dim_artist a ON s.artist_id = a.artist_id
GROUP BY s.title, a.artist_name
ORDER BY total_streams DESC
LIMIT 10;


-- 2) Streams by month
SELECT d.year, d.month, SUM(f.streams_count) AS total_streams
FROM fact_streams f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month
ORDER BY d.year, d.month;


-- 3) Top markets for a given artist
SELECT dm.market_code, SUM(f.streams_count) AS streams
FROM fact_streams f
JOIN dim_song s ON f.song_id = s.song_id
JOIN dim_artist a ON s.artist_id = a.artist_id
JOIN dim_market dm ON f.market_id = dm.market_id
WHERE a.artist_name = 'Taylor Swift'
GROUP BY dm.market_code
ORDER BY streams DESC;


-- 4) Songs with highest average popularity
SELECT s.title, AVG(s.popularity) as avg_popularity
FROM dim_song s
GROUP BY s.title
ORDER BY avg_popularity DESC
LIMIT 20;
