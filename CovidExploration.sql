/* COVID 19 DATA SEARCH */

-- Check the tables that be used
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- DATA EXPLORATION IN GLOBAL SCOPE
-- Select data that is going to be used
SELECT location, date, total_cases, new_cases, CAST(total_deaths AS INT), new_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY total_deaths DESC

-- The percentage of total cases and total deaths compared to population
SELECT SUM(total_cases) AS GlobalTotalCases, SUM(CAST(total_deaths AS INT)) AS GlobalTotalDeaths, (SUM(CAST(total_deaths AS INT))/SUM(total_cases))*100 as GlobalDeathPercentage,
(SUM(total_cases)/SUM(population))*100 AS GlobalInfectionRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND date = '2022-01-20'

-- Countries Highest With Infection Rate compares to Population
SELECT location, population, MAX(total_cases) as HighestInfectionSum,  MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
 
 -- Countries With Highest Deaths Rate compared to Population
 SELECT location, population, MAX(CAST(total_deaths AS INT)) AS HighestDeathsSum, MAX((CAST(total_deaths AS INT)/population))*100 PercentPopulationDead
 FROM PortfolioProject..CovidDeaths
 GROUP BY location, population
ORDER BY PercentPopulationDead DESC

-- Vaccinations compared to Population
----- Step 1: Create a subquery that includes Population and Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationsCount
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date

----- Step 2: Use CTE to consider the previous as a subquery to calculate Percentage of Vaccinations compared to Population
WITH PopAndVac (continent, location, date, population, new_vaccination, RollingVaccinationsCount)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationsCount
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT *, (RollingVaccinationsCount/Population)*100
FROM PopAndVac
ORDER BY location, date

-- DATA EXPLORATION IN CONTINENT SCOPE
-- Continent Rank of Highest With Infection Rate compared to Population
SELECT continent, MAX(total_cases) as ContinentHighestInfectionSum,  (MAX(total_cases)/MAX(population))*100 as ContinentPercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY ContinentPercentPopulationInfected DESC

-- Continent Rank of Highest With Deaths Rate compared to Population
SELECT continent, (MAX(CONVERT(INT,total_deaths))/MAX(population))*100 as ContinentPercentPopulationDead
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY ContinentPercentPopulationDead DESC

-- Continent Rank of Highest With Deaths Rate compared to Population
SELECT dea.continent, MAX(CAST(vac.total_vaccinations AS INT)) AS VaccinationsCount
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent


-- DATA EXPLORATION IN THE UK's SCOPE
SELECT location, date, total_cases, new_cases, CAST(total_deaths AS INT), new_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE location = 'United Kingdom'
ORDER BY total_deaths DESC

SELECT MAX(total_cases) AS UKHighestInfectionCases, MAX(CAST(total_deaths AS INT)) AS UKHighestDeaths
FROM PortfolioProject..CovidDeaths
WHERE location = 'United Kingdom'