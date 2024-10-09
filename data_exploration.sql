/*
COVID-19 Data Exploration

Skills used: Joins, (Common Table Expression) CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- SELECT * FROM portfolioproject.coviddeaths
-- ORDER BY 3,4

-- test adjusting format of date from text to datetime
SELECT STR_TO_DATE(date, '%Y-%m-%d')
AS formatted_date
FROM portfolioproject.coviddeaths;

SELECT 
	country, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM
	portfolioproject.coviddeaths
ORDER BY
	country ASC, date ASC;

-- use the str to date conversion to update the table    
UPDATE portfolioproject.coviddeaths
SET date = STR_TO_DATE(date, '%Y-%m-%d');

UPDATE portfolioproject.covidvaccinations
SET date = STR_TO_DATE(date, '%Y-%m-%d');

/* 
DATA EXPLORATION QUERIES
*/

-- Total Cases vs Total Deaths by Country + Date
-- Likelihood of death if contract COVID
SELECT 
	country, 
    date, 
    total_cases, 
    total_deaths,
    (total_deaths/total_cases)*100 as DeathPercentage
FROM
	portfolioproject.coviddeaths
WHERE
	continent IS NOT NULL
 ORDER BY
	country ASC, date ASC;
    
-- Total Cases vs Population
-- Percentage of population infected with COVID
SELECT
	country,
    date,
    total_cases,
    population,
    (total_cases/population)*100 as PercentPopulationInfected
FROM
	portfolioproject.coviddeaths
ORDER BY
	PercentPopulationInfected DESC;
    
-- Countries with Highest Infection Rate compared to Population
SELECT
	country,
    population,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases/population))*100 as PercentPopulationInfected
FROM
	portfolioproject.coviddeaths
GROUP BY country, population
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count per Population
SELECT
	country,
    MAX(total_deaths) as TotalDeathCount
FROM
	portfolioproject.coviddeaths
WHERE
	continent IS NOT NULL
GROUP BY country, population
ORDER BY TotalDeathCount DESC;

-- Continents with Highest Death Count per Population
SELECT
	continent,
    MAX(total_deaths) as TotalDeathCount
FROM
	portfolioproject.coviddeaths
WHERE
	continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global stats
SELECT
	SUM(new_cases) as totalCases,
    SUM(new_deaths) as totalDeaths,
    ((SUM(new_deaths))/(SUM(new_cases)))*100 as deathPercentage
FROM
	portfolioproject.coviddeaths
WHERE
	continent IS NOT NULL;

-- Total Population vs Vaccinations
-- Percentage of population that has received at least one COVID vaccine
SELECT
	coviddeaths.continent,
    coviddeaths.country,
    coviddeaths.date,
	covidvaccinations.new_vaccinations,
    
