-- The NYC Public School Test Result Scores data

SELECT *
FROM schools
LIMIT 10;


-- Finding missing values

SELECT 
    (SELECT COUNT(school_name)
     FROM schools
     WHERE percent_tested IS NULL
    ) AS num_tested_missing, 
    COUNT(school_name) AS num_schools
FROM schools;


-- Schools by building code

SELECT COUNT( DISTINCT building_code) AS num_school_buildings
FROM schools;


-- Best schools for math

SELECT school_name, average_math
FROM schools
WHERE average_math >= 640
ORDER BY average_math DESC;


-- Lowest reading score

SELECT MIN(average_reading) AS lowest_reading
FROM schools;


-- Best writing school

SELECT school_name, MAX(average_writing) AS max_writing
FROM schools
GROUP BY school_name
ORDER BY max_writing DESC
LIMIT 1;


-- Top 10 schools

SELECT school_name, average_math + average_reading + average_writing AS average_sat
FROM schools
GROUP BY school_name
ORDER BY average_sat DESC
LIMIT 10;


-- Ranking boroughs

SELECT borough, COUNT(*) AS num_schools , (SUM(average_math) + SUM(average_reading) + SUM(average_writing)) / COUNT(*) AS average_borough_sat
FROM schools
GROUP BY borough
ORDER BY average_borough_sat DESC;

-- Brooklyn numbers

SELECT school_name, average_math
FROM schools
WHERE borough = 'Brooklyn'
GROUP BY school_name
ORDER BY average_math DESC
LIMIT 5;