
SELECT *
FROM covid19.covid_deaths
ORDER BY location;


-- Select Data that we are going to be starting with
SELECT 
    location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM covid19.covid_deaths
ORDER BY location;


-- Total Cases vs Total Deaths
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths , 
    (total_deaths/total_cases)*100 AS total_death_pec
FROM covid19.covid_deaths
ORDER BY location;


-- Total Cases vs Total Deaths in US
SELECT 
    location, 
    STR_TO_DATE( date, '%m/%d/%Y') AS Date, 
    total_cases, population , 	
    ROUND((total_cases/population)*100,2) AS total_cases_pec
FROM covid19.covid_deaths
WHERE location = "United States"
ORDER BY Date;


-- Locations with Highest Infection Rate compared to Population
SELECT 
    location, 
    MAX(total_cases) AS Highest_cases , 
    population ,  
    Max(ROUND((total_cases/population)*100,2)) AS Highest_Cases_Pec
FROM covid19.covid_deaths
GROUP BY location
ORDER BY total_cases_pec DESC;


-- Locations with Highest Death Count per Population
SELECT 
    location, 
    MAX(CAST(total_deaths AS UNSIGNED)) AS Highest_Deaths
FROM covid19.covid_deaths
WHERE continent != ""
GROUP BY location
ORDER BY Total_Deaths DESC;


-- Global Confirmed Cases and Deaths
SELECT 
	STR_TO_DATE( date, '%m/%d/%Y') AS Date,
    SUM(new_cases) AS Confirmed_cases,
    SUM(new_deaths) AS Deaths
FROM covid19.covid_deaths
WHERE continent != ""
GROUP BY DATE
ORDER BY Date


-- Global Total Cases and Total Deaths
SELECT 
	STR_TO_DATE( date, '%m/%d/%Y') AS Date,
    SUM(total_cases) AS total_cases,
    SUM(total_deaths) AS total_deaths
FROM covid19.covid_deaths
WHERE continent != ""
GROUP BY DATE
ORDER BY Date



-- Countries Death per Population
SELECT 
    continent, 
    SUM(CAST(new_deaths AS UNSIGNED)) AS Total_Deaths 
FROM covid19.covid_deaths
GROUP BY continent
ORDER BY Total_Deaths DESC;


-- GLOBAL NUMBERS
SELECT 
    sum(new_cases) AS total_cases, 
    sum(new_deaths) AS total_deaths
FROM covid19.covid_deaths
WHERE continent != "";


-- Creating View to perform Calculation on Partition By in previous query and store data for later visualizations
CREATE VIEW PopVSVac AS
SELECT 
    d.continent, 
    d.location, 
    d.date, 
    d.population,  
    v.new_vaccinations, 
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.date) AS total_vaccinations
FROM covid19.covid_deaths AS d
JOIN covid19.covid_vaccinations AS v ON 
       d.location = v.location AND d.date = v.date
WHERE d.continent != ""
ORDER BY location, date;

SELECT *, ROUND((total_vaccinations/population)*100,2) AS Vac_per_of_pop
FROM PopVsVac
