-- SQL Project -- Spotify dataset
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;
SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

/*
-- -------------------------------------
-- Data Analysis - Easy Category
-- -------------------------------------
Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.
*/

-- Q1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify 
WHERE stream > 1000000000;

-- Q2. List all albums along with their respective artists.

SELECT DISTINCT album, artist
FROM spotify
ORDER BY 1;

-- Q3. Get the total number of comments for tracks where licensed = TRUE.

SELECT sum(comments) as total_comments FROM spotify 
WHERE licensed = 'true';

-- Q4. Find all tracks that belong to the album type single.

SELECT * FROM spotify
WHERE album_type = 'single';

-- Q5. Count the total number of tracks by each artist.

SELECT artist,
count(*) as total_no_songs
FROM spotify
GROUP BY artist
ORDER BY total_no_songs DESC;

/*
-- --------------------------------------
-- Medium Level
-- --------------------------------------
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- Q6. Calculate the average danceability of tracks in each album.

SELECT album,
avg(danceability) as avg_danceability
FROM spotify 
GROUP BY album
ORDER BY avg_danceability DESC;

-- Q7. Find the top 5 tracks with the highest energy values

SELECT track,
max(energy) 
FROM spotify
GROUP BY track
ORDER BY max(energy) DESC
LIMIT 5;

-- Q8. List all tracks along with their views and likes where official_video = TRUE.

SELECT track,
sum(views) as total_views,
sum(likes) as total_likes
WHERE official_video = 'true'
GROUP BY track
ORDER BY total_views DESC

-- Q9. For each album, calculate the total views of all associated tracks.

SELECT album,track,
sum(views) as total_views
FROM spotify
GROUP BY album,track
ORDER BY total_views DESC;

-- Q10. Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM
(SELECT track,
COALESCE(SUM(CASE WHEN most_played_on='Youtube' THEN stream END),0) as streamed_on_youtube,
COALESCE(SUM(CASE WHEN most_played_on='Spotify' THEN stream END),0) as streamed_on_spotify
FROM spotify
GROUP BY track) as a
WHERE streamed_on_spotify>streamed_on_youtube
AND streamed_on_youtube<>0;

/*
-- ---------------------------------------------------------------
-- Advanced Level 
-- ---------------------------------------------------------------
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/


-- Q11. Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranking_artist AS
(SELECT artist,track,
sum(views) as total_views,
DENSE_RANK() OVER(PARTITION BY artist ORDER BY sum(views)DESC) as rnk
FROM spotify
GROUP BY artist,track
ORDER BY artist,total_views DESC)
SELECT * FROM ranking_artist
WHERE rnk<=3;


-- Q12. Write a query to find tracks where the liveness score is above the average.

SELECT track,artist,liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- Q13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH cte AS
(SELECT album,
MAX(energy) as highest_energy,
MIN(energy) as lowest_energy
FROM spotify
GROUP BY album)
SELECT album,
highest_energy-lowest_energy as energy_diff
FROM cte
ORDER BY energy_diff DESC;


-- Q14. Find tracks where the energy-to-liveness ratio is greater than 1.2.

WITH cte AS
(SELECT track,
energy/liveness as ratio
FROM spotify)
SELECT track,ratio 
FROM cte 
WHERE ratio > 1.2
ORDER BY ratio DESC;

-- Q15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

WITH cte AS
(SELECT *,
SUM(likes) OVER(ORDER BY views DESC) AS cum_likes
FROM spotify)
SELECT track,views,
likes,cum_likes
FROM cte;





















