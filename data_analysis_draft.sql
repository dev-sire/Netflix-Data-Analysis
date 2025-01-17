use netflix;
select * from netflix;

-- 1. Count the Number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*) as total_count
FROM netflix
GROUP BY type;

-- 2. List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
	AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(duration, ' ', 1), ' ', -1) AS UNSIGNED) > 5;
    
-- 3. List all Movies With Duration more than 90 minutes
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;
    
-- 4. Count the Number of Content Items in Each Genre
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre,
       COUNT(*) AS total_content
FROM netflix,
     (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) AS n
WHERE n.n <= 1 + (LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', '')))
GROUP BY genre;

-- 4. Find Average Duration of all content

SELECT
    CASE
        WHEN type = 'Movie' THEN 'Movie'
        ELSE 'TV Show'
    END AS content_type,
    AVG(duration) AS avg_duration
FROM
    netflix
GROUP BY
    content_type;


-- 6. Find the Most Frequent Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS ranked
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE ranked = 1;

-- 7. Find the Top 3 Countries with the Most Content on Netflix

SELECT country, COUNT(*) AS total_content
FROM (
    SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n.n), ',', -1) AS country
    FROM netflix, 
         (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) AS n
    WHERE n.n <= 1 + (LENGTH(country) - LENGTH(REPLACE(country, ',', '')))
) AS subquery
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 3;

-- 8. Find each year and the average numbers of content release in United States on netflix.
SELECT
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'United States') * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'United States'
GROUP BY country, release_year
ORDER BY avg_release DESC
limit 5;

-- 9. categorize movies as good, bad or adults based on their description and ratings
SELECT
    category,
    COUNT(*) AS content_count
FROM (
    SELECT
        CASE
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            WHEN rating IN ('R', 'NC-17', 'TV-MA') THEN 'Adults'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;

-- 10. Identify directors who have directed both movies and TV Shows
SELECT 
    director,
    COUNT(DISTINCT CASE WHEN type = 'Movie' THEN show_id END) AS no_of_movies,
    COUNT(DISTINCT CASE WHEN type = 'TV Show' THEN show_id END) AS no_of_tvshow
FROM 
    netflix
WHERE 
    director IS NOT NULL 
GROUP BY 
    director
HAVING 
    COUNT(DISTINCT type) > 1;
    
-- 11. Find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them
SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', 1), ' ', -1) AS Director, 
    COUNT(DISTINCT CASE WHEN FIND_IN_SET('Comedies', listed_in) THEN show_id END) AS No_Of_Comedy_Genre,
    COUNT(DISTINCT CASE WHEN FIND_IN_SET('Horror Movies', listed_in) THEN show_id END) AS No_Of_Horror_Genre
FROM 
    netflix
WHERE 
    type = 'Movie' 
    AND (FIND_IN_SET('Comedies', listed_in) > 0 OR FIND_IN_SET('Horror Movies', listed_in) > 0)
    AND director IS NOT NULL 
GROUP BY 
    director
HAVING
    COUNT(DISTINCT CASE WHEN FIND_IN_SET('Comedies', listed_in) THEN 1 END) > 0 
    AND COUNT(DISTINCT CASE WHEN FIND_IN_SET('Horror Movies', listed_in) THEN 1 END) > 0;
    
-- 12 Find the most prolific directors
SELECT 
    director as Director, 
    COUNT(*) AS Directed_In
FROM 
    netflix
WHERE 
    director IS NOT NULL 
GROUP BY 
    Director
ORDER BY 
    Directed_In DESC
LIMIT 10;

-- 13 Find the most prolific actors
SELECT 
    Actor_Name, 
    COUNT(*) AS Worked_In
FROM 
    (
        SELECT 
            TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n.n), ',', -1)) AS Actor_Name
        FROM 
            netflix, 
            (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS n
        WHERE 
            n.n <= 1 + (LENGTH(cast) - LENGTH(REPLACE(cast, ',', '')))
    ) AS actors
GROUP BY 
    Actor_Name
ORDER BY
    Worked_In DESC
LIMIT 10;