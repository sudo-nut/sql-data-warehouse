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


-- ========================================
-- WINDOW FUNCTION QUERIES
-- ========================================

-- 5) Rank songs by total streams using ROW_NUMBER, RANK, and DENSE_RANK
SELECT 
    s.title,
    a.artist_name,
    SUM(f.streams_count) AS total_streams,
    ROW_NUMBER() OVER (ORDER BY SUM(f.streams_count) DESC) AS row_num,
    RANK() OVER (ORDER BY SUM(f.streams_count) DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY SUM(f.streams_count) DESC) AS dense_rank
FROM fact_streams f
JOIN dim_song s ON f.song_id = s.song_id
JOIN dim_artist a ON s.artist_id = a.artist_id
GROUP BY s.title, a.artist_name
ORDER BY total_streams DESC
LIMIT 20;


-- 6) Running total of streams by date
SELECT 
    d.date,
    SUM(f.streams_count) AS daily_streams,
    SUM(SUM(f.streams_count)) OVER (ORDER BY d.date) AS running_total
FROM fact_streams f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.date
ORDER BY d.date;


-- 7) Compare each day's streams to the previous day using LAG
SELECT 
    d.date,
    SUM(f.streams_count) AS daily_streams,
    LAG(SUM(f.streams_count), 1) OVER (ORDER BY d.date) AS prev_day_streams,
    SUM(f.streams_count) - LAG(SUM(f.streams_count), 1) OVER (ORDER BY d.date) AS stream_change
FROM fact_streams f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.date
ORDER BY d.date;


-- 8) Top 3 songs per market using window functions
WITH ranked_songs AS (
    SELECT 
        dm.market_code,
        s.title,
        a.artist_name,
        SUM(f.streams_count) AS total_streams,
        ROW_NUMBER() OVER (PARTITION BY dm.market_code ORDER BY SUM(f.streams_count) DESC) AS rank_in_market
    FROM fact_streams f
    JOIN dim_song s ON f.song_id = s.song_id
    JOIN dim_artist a ON s.artist_id = a.artist_id
    JOIN dim_market dm ON f.market_id = dm.market_id
    GROUP BY dm.market_code, s.title, a.artist_name
)
SELECT market_code, title, artist_name, total_streams, rank_in_market
FROM ranked_songs
WHERE rank_in_market <= 3
ORDER BY market_code, rank_in_market;


-- 9) Moving average of streams (3-day window)
SELECT 
    d.date,
    SUM(f.streams_count) AS daily_streams,
    AVG(SUM(f.streams_count)) OVER (
        ORDER BY d.date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3day
FROM fact_streams f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.date
ORDER BY d.date;


-- 10) Percentile ranking of songs by popularity
SELECT 
    s.title,
    a.artist_name,
    s.popularity,
    PERCENT_RANK() OVER (ORDER BY s.popularity) AS percentile_rank,
    NTILE(4) OVER (ORDER BY s.popularity) AS quartile
FROM dim_song s
JOIN dim_artist a ON s.artist_id = a.artist_id
ORDER BY s.popularity DESC;


-- 11) Lead function to compare with next day's streams
SELECT 
    d.date,
    SUM(f.streams_count) AS daily_streams,
    LEAD(SUM(f.streams_count), 1) OVER (ORDER BY d.date) AS next_day_streams,
    LEAD(SUM(f.streams_count), 1) OVER (ORDER BY d.date) - SUM(f.streams_count) AS stream_change_next
FROM fact_streams f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.date
ORDER BY d.date;


-- 12) First and last stream dates per song using FIRST_VALUE and LAST_VALUE
SELECT DISTINCT
    s.title,
    a.artist_name,
    FIRST_VALUE(d.date) OVER (
        PARTITION BY s.song_id 
        ORDER BY d.date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_stream_date,
    LAST_VALUE(d.date) OVER (
        PARTITION BY s.song_id 
        ORDER BY d.date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_stream_date
FROM fact_streams f
JOIN dim_song s ON f.song_id = s.song_id
JOIN dim_artist a ON s.artist_id = a.artist_id
JOIN dim_date d ON f.date_id = d.date_id
ORDER BY s.title;
