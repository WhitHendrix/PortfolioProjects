SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

--SELECT *
--FROM CovidVaccinations
--ORDER BY location, date

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

--Total Cases versus Total Deaths for US
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, date

--Total Cases versus Population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CovidPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

--Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS MaxCovidPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MaxCovidPercentage DESC

--Highest Death Count by Location
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Highest Death Count by Continent
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(total_cases) AS MaxTotalCases, MAX(cast(total_deaths as int)) AS MaxTotalDeaths, MAX((cast(total_deaths as int)/total_cases))*100 AS MaxDeathPercentage
FROM CovidDeaths
WHERE continent IS NULL AND location NOT IN ('European Union','lower middle income', 'high income', 'World', 'low income', 'Upper middle income', 'International')
GROUP BY location
ORDER BY MaxDeathPercentage DESC

--Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, SUM(new_cases)

--Total Global cases, deaths, and death percentage
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY SUM(new_cases)

--Covid Vaccinations Data
SELECT *
FROM CovidVaccinations

--Join Deaths and Vaccinations tables
SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Vaccinations versus Population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date

--CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopVaccinated
FROM PopvsVac

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopVaccinated
FROM #PercentPopulationVaccinated

--View Creation

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

CREATE VIEW USTotalCasesTotalDeaths AS
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
--ORDER BY location, date

SELECT *
FROM USTotalCasesTotalDeaths

CREATE VIEW TotalCasesPopulation AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CovidPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL

SELECT *
FROM TotalCasesPopulation
ORDER BY location, date

CREATE VIEW MaxCovidPercentage AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS MaxCovidPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
--ORDER BY MaxCovidPercentage DESC

SELECT *
FROM MaxCovidPercentage
ORDER BY MaxCovidPercentage DESC

CREATE VIEW DeathCountLocation AS
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC

SELECT *
FROM DeathCountLocation
ORDER BY TotalDeathCount DESC

CREATE VIEW DeathCountContinent AS
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC

SELECT *
FROM DeathCountContinent
ORDER BY TotalDeathCount DESC

CREATE VIEW MaxDeathPercentage AS
SELECT location, MAX(total_cases) AS MaxTotalCases, MAX(cast(total_deaths as int)) AS MaxTotalDeaths, MAX((cast(total_deaths as int)/total_cases))*100 AS MaxDeathPercentage
FROM CovidDeaths
WHERE continent IS NULL AND location NOT IN ('European Union','lower middle income', 'high income', 'World', 'low income', 'Upper middle income', 'International')
GROUP BY location
--ORDER BY MaxDeathPercentage DESC

SELECT *
FROM MaxDeathPercentage
ORDER BY MaxDeathPercentage DESC