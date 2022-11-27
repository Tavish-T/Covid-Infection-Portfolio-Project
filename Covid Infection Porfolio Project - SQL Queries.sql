-------------------------
--->>> Verify Data <<<---
-------------------------

Select *
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

Select *
FROM ProjectPortfolio..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4



--><><><><><><><><><><><--
--->>> Covid Deaths <<<---
--><><><><><><><><><><><--

-----------------------
--->>> COUNTRIES <<<---
-----------------------

SELECT location, date, total_cases, new_cases, Total_deaths, population
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you get covid in Canada

SELECT location, date, total_cases, Total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location Like 'Canada'AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of Canadian population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationInfectedPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location Like 'Canada' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PopulationInfectedPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopulationInfectedPercentage Desc

-- Showing Countries with the Highest Death Count Per Population

SELECT Location, population,  MAX(cast(total_deaths as INT)) AS HighestDeathCount, MAX(cast(total_deaths as INT)/population)*100 AS PopulationDeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopulationDeathPercentage Desc

------------------------
--->>> CONTINENTS <<<---
------------------------

SELECT location, date, total_cases, new_cases, Total_deaths, population
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NULL
AND location NOT LIKE '%income%'
AND location NOT LIKE '%Union%'
AND location NOT LIKE '%World%'
AND location NOT LIKE '%International%'
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you get covid across the continents

SELECT location, date, total_cases, Total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NULL
AND location NOT LIKE '%income%'
AND location NOT LIKE '%Union%'
AND location NOT LIKE '%World%'
AND location NOT LIKE '%International%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the Continent's population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationInfectedPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NULL
AND location NOT LIKE '%income%'
AND location NOT LIKE '%Union%'
AND location NOT LIKE '%World%'
AND location NOT LIKE '%International%'
ORDER BY 1,2

-- Continents with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PopulationInfectedPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NULL
AND location NOT LIKE '%income%'
AND location NOT LIKE '%Union%'
AND location NOT LIKE '%World%'
AND location NOT LIKE '%International%'
GROUP BY location, population
ORDER BY PopulationInfectedPercentage DESC

-- Continents with the highest death count per population

SELECT location, population,  MAX(cast(total_deaths as INT)) AS HighestDeathCount, MAX(cast(total_deaths as INT)/population)*100 AS PopulationDeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NULL
AND location NOT LIKE '%income%'
AND location NOT LIKE '%Union%'
AND location NOT LIKE '%World%'
AND location NOT LIKE '%International%'
GROUP BY location, population
ORDER BY PopulationDeathPercentage DESC

-------------------
--->>> WORLD <<<---
-------------------

SELECT date, SUM(new_cases) AS Total_cases,SUM(CAST(new_deaths AS INT)) AS Total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

--><><><><><><><><><><><><><><><><><><><--
--->>> Join With Covid Vaccinations <<<---
--><><><><><><><><><><><><><>><><><><>><--

Select *
FROM ProjectPortfolio..CovidDeaths AS Death
JOIN ProjectPortfolio..CovidVaccinations AS Vaccin
	ON death.location = vaccin.location
	AND death.date = Vaccin.date

-- Total Population vs Vaccinations
Select death.continent, Death.location, Death.date, Death.population, Vaccin.new_vaccinations,
SUM (CONVERT (BIGINT,Vaccin.new_vaccinations)) OVER ( PARTITION by Death.Location ORDER BY Death.location, Death.Date) AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths AS Death
JOIN ProjectPortfolio..CovidVaccinations AS Vaccin
	ON death.location = vaccin.location
	AND death.date = Vaccin.date
WHERE Death.continent IS NOT NULL
ORDER BY 2,3

 --- Using a CTE

 WITH PopVsVaccin (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
 AS
 (Select death.continent, Death.location, Death.date, Death.population, Vaccin.new_vaccinations,
SUM (CONVERT (BIGINT,Vaccin.new_vaccinations)) OVER ( PARTITION by Death.Location ORDER BY Death.location, Death.Date) AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths AS Death
JOIN ProjectPortfolio..CovidVaccinations AS Vaccin
	ON death.location = vaccin.location
	AND death.date = Vaccin.date
WHERE Death.continent IS NOT NULL
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopVsVaccin


-- Using a Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
Select death.continent, Death.location, Death.date, Death.population, Vaccin.new_vaccinations,
SUM (CONVERT (BIGINT,Vaccin.new_vaccinations)) OVER ( PARTITION by Death.Location ORDER BY Death.location, Death.Date) AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths AS Death
JOIN ProjectPortfolio..CovidVaccinations AS Vaccin
	ON death.location = vaccin.location
	AND death.date = Vaccin.date
WHERE Death.continent IS NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

--><><><><><><><><><>
--->>> The END <<<---
--><><><><><><><><><>