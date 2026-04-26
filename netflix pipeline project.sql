 USE netflixproject;


CREATE TABLE netflix_raw (
    show_id      VARCHAR(10),
    type         VARCHAR(20),
    title        VARCHAR(200),
    director     VARCHAR(200),
    cast         VARCHAR(1000),
    country      VARCHAR(200),
    date_added   VARCHAR(50),
    release_year VARCHAR(10),
    rating       VARCHAR(20),
    duration     VARCHAR(20),
    listed_in    VARCHAR(200),
    description  VARCHAR(1000)
);

USE netflixproject;

BULK INSERT netflix_raw
FROM ''
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

USE netflixproject;

BULK INSERT netflix_raw
FROM 'C:\SQL DATA\netflix_titles.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK,
    FORMAT = 'CSV'
);

BULK INSERT netflix_raw
FROM 'C:\SQL DATA\netflix_titles.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK,
    FORMAT = 'CSV',
    MAXERRORS = 100,
    ERRORFILE = 'C:\SQL Data\netflix_errors.log'
);

USE netflixproject;

TRUNCATE TABLE netflix_raw;

BULK INSERT netflix_raw
FROM 'C:\SQLData\netflix_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = 'RAW',
    TABLOCK,
    FORMAT = 'CSV',
    MAXERRORS = 100,
    ERRORFILE = 'C:\SQLData\netflix_errors.log'
);

TRUNCATE TABLE netflix_raw;

BULK INSERT netflix_raw
FROM 'C:\SQLData\netflix_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = 'RAW',
    TABLOCK,
    FORMAT = 'CSV',
    MAXERRORS = 100,
    ERRORFILE = 'C:\SQLData\netflix_errors.log'
);

USE netflixproject;

TRUNCATE TABLE netflix_raw;

BULK INSERT netflix_raw
FROM 'C:\SQLData\netflix_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    FORMAT = 'CSV',
    MAXERRORS = 100,
    ERRORFILE = 'C:\SQLData\netflix_errors.log'
);

USE netflixproject;

TRUNCATE TABLE netflix_raw;

BULK INSERT netflix_raw
FROM 'C:\SQLData\netflix_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    MAXERRORS = 100,
    ERRORFILE = 'C:\SQLData\netflix_errors.log'
);

USE netflixproject;

TRUNCATE TABLE netflix_raw;

BULK INSERT netflix_raw
FROM 'C:\SQLData\netflix_pipe.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

SELECT TOP 10 * FROM netflix_raw;

SELECT count(*) as total_rows
from netflix_raw

SELECT TOP 10
        show_id,type,title,director,cast,country,date_added,release_year,rating,duration,listed_in,description
from netflix_raw;

SELECT type,
        count(*) as total_shown
from netflix_raw
group by type;

select 
Sum(Case when show_id is null then 1 else 0 end) as null_show_id,
Sum(Case when type is null then 1 else 0 end )  as null_type,
Sum(Case when title is null then 1 else 0 end ) as null_title,
Sum(Case when director is null then 1 else 0 end) as null_director,
Sum(Case when cast is null then 1 else 0 end) as null_cast,
SUM(CASE WHEN country      IS NULL THEN 1 ELSE 0 END) AS null_country,
SUM(CASE WHEN date_added   IS NULL THEN 1 ELSE 0 END) AS null_date_added,
SUM(CASE WHEN release_year IS NULL THEN 1 ELSE 0 END) AS null_release_year,
SUM(CASE WHEN rating       IS NULL THEN 1 ELSE 0 END) AS null_rating,
SUM(CASE WHEN duration     IS NULL THEN 1 ELSE 0 END) AS null_duration,
SUM(CASE WHEN listed_in    IS NULL THEN 1 ELSE 0 END) AS null_listed_in,
SUM(CASE WHEN description  IS NULL THEN 1 ELSE 0 END) AS null_description
from netflix_raw;

SELECT DISTINCT show_id from netflix_raw;
SELECT DISTINCT title from netflix_raw;
SELECT DISTINCT description from netflix_raw;
SELECT DISTINCT listed_in from netflix_raw;
SELECT DISTINCT rating from netflix_raw;


SELECT title, type, COUNT(*) AS occurrences
FROM netflix_raw
GROUP BY title, type
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

select top 390 title ,date_added
from netflix_raw
order by date_added;

select title,type,release_year,
count(*) as occurences 
from netflix_raw
group by title,type,release_year
having count(*)>1
order by title DESC;


USE NetflixProject;

CREATE TABLE netflix_clean (
    show_id      VARCHAR(20)    NOT NULL,
    type         VARCHAR(20)    NOT NULL,
    title        VARCHAR(300)   NOT NULL,
    director     VARCHAR(300)   NOT NULL,
    cast         VARCHAR(2000)  NOT NULL,
    country      VARCHAR(300)   NOT NULL,
    date_added   DATE               NULL,
    release_year INT            NOT NULL,
    rating       VARCHAR(20)    NOT NULL,
    duration     VARCHAR(50)    NOT NULL,
    listed_in    VARCHAR(300)   NOT NULL,
    description  NVARCHAR(MAX)  NOT NULL
);

select count(*) from netflix_raw;

SELECT 
show_id,

trim(type) as type,
trim(title) as title,


    -- Replace NULL directors
    ISNULL(NULLIF(TRIM(director), ''), 'Unknown') AS director,

    -- Replace NULL cast
    ISNULL(NULLIF(TRIM(cast), ''), 'Not Specified') AS cast,

    -- Replace NULL country
    ISNULL(NULLIF(TRIM(country), ''), 'Unknown') AS country,

    -- Convert date_added to proper DATE format
    TRY_CONVERT(DATE, TRIM(date_added), 107) AS date_added,

    -- Convert release_year to integer
    CAST(TRIM(release_year) AS INT) AS release_year,

    -- Replace NULL rating
    ISNULL(NULLIF(TRIM(rating), ''), 'Not Rated') AS rating,

    -- Replace NULL duration
    ISNULL(NULLIF(TRIM(duration), ''), 'Not Specified') AS duration,

    -- Trim listed_in
    TRIM(listed_in) AS listed_in,

    -- Trim description
    TRIM(description) AS description

FROM netflix_raw

-- Remove duplicates — keep first occurrence
WHERE show_id IN (
    SELECT MIN(show_id)
    FROM netflix_raw
    GROUP BY title, type, release_year
)

-- Drop rows with NULL release_year
AND release_year IS NOT NULL
AND TRIM(release_year) != '';

INSERT INTO netflix_clean
SELECT
    show_id,
    TRIM(type)                                              AS type,
    TRIM(title)                                             AS title,
    ISNULL(NULLIF(TRIM(director), ''), 'Unknown')           AS director,
    ISNULL(NULLIF(TRIM(cast), ''), 'Not Specified')         AS cast,
    ISNULL(NULLIF(TRIM(country), ''), 'Unknown')            AS country,
    TRY_CONVERT(DATE, TRIM(date_added), 107)                AS date_added,
    TRY_CAST(TRIM(release_year) AS INT)                     AS release_year,
    ISNULL(NULLIF(TRIM(rating), ''), 'Not Rated')           AS rating,
    ISNULL(NULLIF(TRIM(duration), ''), 'Not Specified')     AS duration,
    TRIM(listed_in)                                         AS listed_in,
    TRIM(description)                                       AS description
FROM netflix_raw
WHERE show_id IN (
    SELECT MIN(show_id)
    FROM netflix_raw
    GROUP BY title, type, release_year
)
AND release_year IS NOT NULL
AND TRIM(release_year) != ''
AND ISNUMERIC(TRIM(release_year)) = 1;

SELECT DISTINCT release_year, ISNUMERIC(TRIM(release_year)) AS is_numeric,
    TRY_CAST(TRIM(release_year) AS INT) AS cast_result
FROM netflix_raw
WHERE TRY_CAST(TRIM(release_year) AS INT) IS NULL
AND release_year IS NOT NULL
AND TRIM(release_year) != '';

INSERT INTO netflix_clean
SELECT
    show_id,
    TRIM(type)                                              AS type,
    TRIM(title)                                             AS title,
    ISNULL(NULLIF(TRIM(director), ''), 'Unknown')           AS director,
    ISNULL(NULLIF(TRIM(cast), ''), 'Not Specified')         AS cast,
    ISNULL(NULLIF(TRIM(country), ''), 'Unknown')            AS country,
    TRY_CONVERT(DATE, TRIM(date_added), 107)                AS date_added,
    TRY_CAST(TRIM(release_year) AS INT)                     AS release_year,
    ISNULL(NULLIF(TRIM(rating), ''), 'Not Rated')           AS rating,
    ISNULL(NULLIF(TRIM(duration), ''), 'Not Specified')     AS duration,
    TRIM(listed_in)                                         AS listed_in,
    TRIM(description)                                       AS description
FROM netflix_raw
WHERE show_id IN (
    SELECT MIN(show_id)
    FROM netflix_raw
    GROUP BY title, type, release_year
)
AND release_year IS NOT NULL
AND TRIM(release_year) != ''
AND ISNUMERIC(TRIM(release_year)) = 1
AND TRY_CAST(TRIM(release_year) AS INT) IS NOT NULL
AND TRIM(release_year) NOT LIKE '%-%'
AND TRIM(release_year) NOT LIKE '%/%';

SELECT COUNT(*) AS clean_rows FROM netflix_clean;

SELECT COUNT(*) AS unknown_directors 
FROM netflix_clean 
WHERE director = 'Unknown';

SELECT COUNT(*) AS unknown_countries 
FROM netflix_clean 
WHERE country = 'Unknown';

SELECT DISTINCT release_year 
FROM netflix_clean 
ORDER BY release_year;

SELECT TOP 10 title, date_added 
FROM netflix_clean
WHERE date_added IS NOT NULL
ORDER BY date_added;

SELECT TOP 10 title, date_added 
FROM netflix_clean
WHERE date_added IS NOT NULL
ORDER BY date_added;

SELECT title, type, release_year, COUNT(*) AS occurrences
FROM netflix_clean
GROUP BY title, type, release_year
HAVING COUNT(*) > 1;

SELECT type, COUNT(*) AS total
FROM netflix_clean
GROUP BY type;

select type,
        count(*) as total_titles
 from netflix_clean
 group by type
 order by total_titles DESC

 select country,
        count(*)  as total_titles
from netflix_clean
group by country
order by total_titles DESC;



 select rating,
        count(*)  as total_titles
from netflix_clean
group by rating
order by total_titles DESC;

select date_added,
        count(*)  as total_titles
from netflix_clean
group by date_added
order by total_titles DESC;

select top 10
        listed_in,
        count(*)  as total_titles
from netflix_clean
group by listed_in
order by total_titles DESC;

SELECT
    DATEPART(YEAR, date_added)  AS year_added,
    COUNT(*)                    AS total_titles
FROM netflix_clean
WHERE date_added IS NOT NULL
GROUP BY DATEPART(YEAR, date_added)
ORDER BY year_added;


SELECT AVG(CAST(REPLACE(duration, ' min', '') AS INT)) AS avg_duration
FROM netflix_clean
WHERE type = 'Movie'
AND duration != 'Not Specified';

-- Movies longer than the average duration
SELECT 
    title,
    country,
    duration,
    release_year
FROM netflix_clean
WHERE type = 'Movie'
AND duration != 'Not Specified'
AND CAST(REPLACE(duration, ' min', '') AS INT) > (
    SELECT AVG(CAST(REPLACE(duration, ' min', '') AS INT))
    FROM netflix_clean
    WHERE type = 'Movie'
    AND duration != 'Not Specified'
)
ORDER BY release_year DESC;

SELECT 
    title,
    duration,
    CAST(REPLACE(duration, ' min', '') AS INT) AS duration_mins,
    (SELECT AVG(CAST(REPLACE(duration, ' min', '') AS INT))
     FROM netflix_clean
     WHERE type = 'Movie'
     AND duration != 'Not Specified') AS avg_duration
FROM netflix_clean
WHERE type = 'Movie'
AND duration != 'Not Specified'
ORDER BY duration_mins DESC;

SELECT 
    title,
    director,
    release_year
FROM netflix_clean
WHERE director IN (
    SELECT director
    FROM netflix_clean
    WHERE director != 'Unknown'
    GROUP BY director
    HAVING COUNT(*) > 3
)
ORDER BY director;

USE netflixproject;

WITH director_counts AS (
select
director,
    count(*) as total_shows
from netflix_clean
where director != 'unknown'
group by director)

SELECT TOP 10
    director,
    total_shows
FROM director_counts
ORDER BY total_shows DESC;

WITH country_content AS (
    SELECT
        country,
        type,
        COUNT(*) AS total_titles
    FROM netflix_clean
    WHERE country != 'Unknown'
    GROUP BY country, type
)
SELECT TOP 10
    country,
    type,
    total_titles
FROM country_content
ORDER BY total_titles DESC;


WITH 
-- CTE 1: Count movies per country
movies AS (
    SELECT 
        country,
        COUNT(*) AS total_movies
    FROM netflix_clean
    WHERE type = 'Movie'
    AND country != 'Unknown'
    GROUP BY country
),
-- CTE 2: Count TV shows per country
tv_shows AS (
    SELECT 
        country,
        COUNT(*) AS total_tv_shows
    FROM netflix_clean
    WHERE type = 'TV Show'
    AND country != 'Unknown'
    GROUP BY country
)
-- Main query: combine both CTEs
SELECT TOP 10
    m.country,
    m.total_movies,
    t.total_tv_shows,
    m.total_movies + t.total_tv_shows AS total_content
FROM movies m
JOIN tv_shows t ON m.country = t.country
ORDER BY total_content DESC;


--PART 4
USE netflixproject;

CREATE TABLE dim_ratings (
    rating          VARCHAR(20)     PRIMARY KEY,
    rating_desc     VARCHAR(100)    NOT NULL,
    audience        VARCHAR(50)     NOT NULL
);

CREATE TABLE dim_country (
    country         VARCHAR(300)    PRIMARY KEY,
    region          VARCHAR(100)    NOT NULL,
    continent       VARCHAR(50)     NOT NULL
);

INSERT INTO dim_ratings VALUES
('G',       'General Audiences',            'All Ages'),
('PG',      'Parental Guidance',            'All Ages'),
('PG-13',   'Parents Strongly Cautioned',   'Ages 13+'),
('R',       'Restricted',                   'Ages 17+'),
('NC-17',   'Adults Only',                  'Ages 18+'),
('TV-Y',    'All Children',                 'All Ages'),
('TV-Y7',   'Directed to Older Children',   'Ages 7+'),
('TV-G',    'General Audience',             'All Ages'),
('TV-PG',   'Parental Guidance',            'All Ages'),
('TV-14',   'Parents Strongly Cautioned',   'Ages 14+'),
('TV-MA',   'Mature Audience Only',         'Ages 17+'),
('NR',      'Not Rated',                    'Unknown'),
('Not Rated', 'Not Rated',                  'Unknown'),
('UR',      'Unrated',                      'Unknown');

INSERT INTO dim_country VALUES
('United States',   'North America',    'Americas'),
('United Kingdom',  'Europe',           'Europe'),
('India',           'South Asia',       'Asia'),
('Canada',          'North America',    'Americas'),
('France',          'Europe',           'Europe'),
('Japan',           'East Asia',        'Asia'),
('South Korea',     'East Asia',        'Asia'),
('Germany',         'Europe',           'Europe'),
('Australia',       'Oceania',          'Oceania'),
('Spain',           'Europe',           'Europe'),
('Mexico',          'Latin America',    'Americas'),
('Brazil',          'Latin America',    'Americas'),
('Nigeria',         'West Africa',      'Africa'),
('Kenya',           'East Africa',      'Africa'),
('China',           'East Asia',        'Asia'),
('Unknown',         'Unknown',          'Unknown');

select * from netflix_clean;
SELECT 
    n.title,
    n.type,
    n.rating,
    r.rating_desc,
    r.audience
FROM netflix_clean n
INNER JOIN dim_ratings r ON n.rating = r.rating
ORDER BY n.title;

-- All netflix titles with rating description where available
SELECT 
    n.title,
    n.type,
    n.rating,
    r.rating_desc,
    r.audience
FROM netflix_clean n
LEFT JOIN dim_ratings r ON n.rating = r.rating
ORDER BY r.rating_desc;

-- Find ratings in netflix_clean that are NOT in dim_ratings
SELECT DISTINCT
    n.rating,
    r.rating_desc
FROM netflix_clean n
LEFT JOIN dim_ratings r ON n.rating = r.rating
WHERE r.rating_desc IS NULL;

-- Join netflix_clean with both dimension tables
SELECT 
    n.title,
    n.type,
    n.country,
    c.region,
    c.continent,
    n.rating,
    r.rating_desc,
    r.audience,
    n.release_year
FROM netflix_clean n
LEFT JOIN dim_ratings r  ON n.rating  = r.rating
LEFT JOIN dim_country c  ON n.country = c.country
ORDER BY n.title;

-- Total titles per continent
SELECT 
    c.continent,
    COUNT(*) AS total_titles,
    SUM(CASE WHEN n.type = 'Movie' THEN 1 ELSE 0 END) AS total_movies,
    SUM(CASE WHEN n.type = 'TV Show' THEN 1 ELSE 0 END) AS total_tv_shows
FROM netflix_clean n
LEFT JOIN dim_country c ON n.country = c.country
WHERE c.continent != 'Unknown'
GROUP BY c.continent
ORDER BY total_titles DESC;

SELECT 
    n.rating,
    COUNT(*) AS total_titles
FROM netflix_clean n
LEFT JOIN dim_ratings r ON n.rating = r.rating
WHERE r.rating_desc IS NULL
GROUP BY n.rating
ORDER BY total_titles DESC;

INSERT INTO dim_ratings VALUES
('TV-Y7-FV', 'Fantasy Violence for Older Children', 'Ages 7+');

-- See the affected rows first
SELECT show_id, title, rating, duration
FROM netflix_clean
WHERE rating LIKE '%min%';

-- Update the rows where duration ended up in rating column
UPDATE netflix_clean
SET rating = 'Not Rated'
WHERE rating LIKE '%min%';

-- Confirm no more min values in rating
SELECT DISTINCT rating FROM netflix_clean ORDER BY rating;

-- Confirm dim_ratings now has TV-Y7-FV
SELECT * FROM dim_ratings WHERE rating = 'TV-Y7-FV';

CREATE VIEW vw_content_overview AS
SELECT
    n.title,
    n.type,
    n.country,
    c.region,
    c.continent,
    n.rating,
    r.rating_desc,
    r.audience,
    n.release_year,
    n.date_added,
    n.duration,
    n.listed_in
FROM netflix_clean n
LEFT JOIN dim_ratings r ON n.rating = r.rating
LEFT JOIN dim_country c ON n.country = c.country;

CREATE VIEW vw_country_performance AS
SELECT
    c.continent,
    n.country,
    COUNT(*) AS total_titles,
    SUM(CASE WHEN n.type = 'Movie' THEN 1 ELSE 0 END) AS total_movies,
    SUM(CASE WHEN n.type = 'TV Show' THEN 1 ELSE 0 END) AS total_tv_shows
FROM netflix_clean n
LEFT JOIN dim_country c ON n.country = c.country
GROUP BY c.continent, n.country;

CREATE VIEW vw_rating_summary AS
SELECT
    r.rating,
    r.rating_desc,
    r.audience,
    COUNT(*) AS total_titles,
    SUM(CASE WHEN n.type = 'Movie' THEN 1 ELSE 0 END) AS total_movies,
    SUM(CASE WHEN n.type = 'TV Show' THEN 1 ELSE 0 END) AS total_tv_shows
FROM netflix_clean n
LEFT JOIN dim_ratings r ON n.rating = r.rating
GROUP BY r.rating, r.rating_desc, r.audience;

CREATE VIEW vw_yearly_trend AS
SELECT
    release_year,
    COUNT(*) AS total_titles,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS total_movies,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS total_tv_shows
FROM netflix_clean
GROUP BY release_year;

CREATE VIEW vw_director_performance AS
SELECT
    director,
    COUNT(*) AS total_titles,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS total_movies,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS total_tv_shows,
    MIN(release_year) AS first_title_year,
    MAX(release_year) AS latest_title_year
FROM netflix_clean
WHERE director != 'Unknown'
GROUP BY director;

SELECT TOP 10 * FROM vw_content_overview ORDER BY release_year DESC;

SELECT TOP 10 * FROM vw_country_performance ORDER BY total_titles DESC;

SELECT TOP 10 * FROM vw_rating_summary ORDER BY total_titles DESC;

SELECT * FROM vw_yearly_trend ORDER BY release_year DESC

SELECT TOP 10 * FROM vw_director_performance ORDER BY total_titles DESC;

use netflixproject;

--Question 1 — Which directors consistently produce content across multiple decades?
WITH director_decades AS (
    SELECT
        director,
        COUNT(DISTINCT release_year/10*10) AS decades_active,
        MIN(release_year) AS first_year,
        MAX(release_year) AS latest_year,
        COUNT(*) AS total_titles
    FROM netflix_clean
    WHERE director != 'Unknown'
    GROUP BY director
)
SELECT TOP 10
    director,
    total_titles,
    first_year,
    latest_year,
    latest_year - first_year AS years_active,
    decades_active
FROM director_decades
WHERE decades_active > 1
ORDER BY years_active DESC;

--Question 2 — Content growth rate year over year

WITH yearly AS (
    SELECT
        release_year,
        COUNT(*) AS total_titles
    FROM netflix_clean
    GROUP BY release_year
),
growth AS (
    SELECT
        release_year,
        total_titles,
        LAG(total_titles) OVER (ORDER BY release_year) AS prev_year_titles
    FROM yearly
)
SELECT
    release_year,
    total_titles,
    prev_year_titles,
    total_titles - prev_year_titles AS growth,
    CASE
        WHEN prev_year_titles IS NULL THEN 'N/A'
        WHEN total_titles > prev_year_titles THEN 'Growth'
        WHEN total_titles < prev_year_titles THEN 'Decline'
        ELSE 'Flat'
    END AS trend
FROM growth
ORDER BY release_year DESC;


--Question 3 — Top 3 genres per continent
WITH genre_continent AS (
    SELECT
        c.continent,
        n.listed_in AS genre,
        COUNT(*) AS total_titles
    FROM netflix_clean n
    LEFT JOIN dim_country c ON n.country = c.country
    WHERE c.continent != 'Unknown'
    GROUP BY c.continent, n.listed_in
),
ranked AS (
    SELECT
        continent,
        genre,
        total_titles,
        ROW_NUMBER() OVER (
            PARTITION BY continent
            ORDER BY total_titles DESC
        ) AS rank
    FROM genre_continent
)
SELECT
    continent,
    genre,
    total_titles,
    rank
FROM ranked
WHERE rank <= 3
ORDER BY continent, rank;

SELECT title, country, COUNT(*) OVER(PARTITION BY country) AS total
FROM netflix_clean;

--Question 1 — Which directors consistently produce content across multiple decades?
WITH director_decades AS (
    SELECT
        director,
        COUNT(*)                    AS total_titles,
        MIN(release_year)           AS first_year,
        MAX(release_year)           AS latest_year,
        MAX(release_year) - MIN(release_year) AS career_span
    FROM netflix_clean
    WHERE director != 'Unknown'
    GROUP BY director
    HAVING COUNT(*) >= 3
)
SELECT TOP 10
    director,
    total_titles,
    first_year,
    latest_year,
    career_span
FROM director_decades
ORDER BY career_span DESC;

--Question 2 — What percentage of content comes from each continent?
WITH continent_counts AS (
    SELECT
        c.continent,
        COUNT(*) AS total_titles
    FROM netflix_clean n
    LEFT JOIN dim_country c ON n.country = c.country
    GROUP BY c.continent
),
total AS (
    SELECT COUNT(*) AS grand_total
    FROM netflix_clean
)
SELECT
    continent,
    total_titles,
    grand_total,
    CAST(total_titles * 100.0 / grand_total AS DECIMAL(5,2)) AS percentage
FROM continent_counts
CROSS JOIN total
ORDER BY percentage DESC;

--Question 3 — How has content grown year over year?
WITH yearly AS (
    SELECT
        release_year,
        COUNT(*) AS total_titles
    FROM netflix_clean
    GROUP BY release_year
)
SELECT
    release_year,
    total_titles,
    SUM(total_titles) OVER (ORDER BY release_year) AS running_total
FROM yearly
ORDER BY release_year;


