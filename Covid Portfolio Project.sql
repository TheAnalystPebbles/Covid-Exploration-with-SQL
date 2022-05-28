--Let's view the tables

SELECT * 
FROM Portfolio_Project..CovidDeaths$
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT * 
FROM Portfolio_Project..Covidvaccinations$
WHERE continent is NOT NULL
ORDER BY 3,4

--Select data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths$
WHERE continent is NOT NULL
ORDER BY 1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in Nigeria

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths$
WHERE location = 'Nigeria'
AND continent is NOT NULL
ORDER BY 1,2

--Total cases vs Population
--Shows the percentage of the population that has Covid in Nigeria

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentofPopulationInfected
FROM Portfolio_Project..CovidDeaths$
WHERE location = 'Nigeria'
AND continent is NOT NULL
ORDER BY 1,2

--Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
PercentofPopulationInfected
FROM Portfolio_Project..CovidDeaths$
GROUP BY location, population
ORDER BY PercentofPopulationInfected desc

--Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths$
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Continents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths$
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

 --Global Numbers Per Day

SELECT date, SUM(new_cases) AS totalnewcases, SUM(CAST(new_deaths AS INT)) AS totalnewdeaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentae
FROM Portfolio_Project..CovidDeaths$
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

--Overall Global Number

SELECT SUM(new_cases) AS totalnewcases, SUM(CAST(new_deaths AS INT)) AS totalnewdeaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentae
FROM Portfolio_Project..CovidDeaths$
WHERE continent is NOT NULL
ORDER BY 1,2

--Let's combine the Death and Vaccination tables

SELECT * 
FROM Portfolio_Project..CovidDeaths$ dth
JOIN Portfolio_Project..Covidvaccinations$ vac
	ON dth.location = vac.location
	AND dth.date = vac.date

--Total Population vs Vaccinations

SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY  dth.location ORDER BY dth.location,
dth.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths$ dth
JOIN Portfolio_Project..Covidvaccinations$ vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent is NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY  dth.location ORDER BY dth.location,
dth.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths$ dth
JOIN Portfolio_Project..Covidvaccinations$ vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent is NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentRollingPeopleVaccinated
FROM PopvsVac

--TEMPORARY TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY  dth.location ORDER BY dth.location,
dth.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths$ dth
JOIN Portfolio_Project..Covidvaccinations$ vac
	ON dth.location = vac.location
	AND dth.date = vac.date
--WHERE dth.continent is NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for Visualizations

Create View PercentPopulationVaccinated AS
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY  dth.location ORDER BY dth.location,
dth.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths$ dth
JOIN Portfolio_Project..Covidvaccinations$ vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent is NOT NULL

SELECT *
FROM PercentPopulationVaccinated
