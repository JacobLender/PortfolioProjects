SELECT * FROM PortfolioProject..Covid_Deaths;

SELECT * FROM PortfolioProject..Covid_Vaccinations;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_Deaths
ORDER BY 1,2;

-- Looking at total cases vs total deaths w/ death percentage

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE location LIKE  'United States'
ORDER BY 1,2;

-- Looking at total cases vs population w/ population infection percentage

SELECT location, date, total_cases, Population, (total_cases/Population)*100 AS infectionPercentage
FROM PortfolioProject..Covid_Deaths
WHERE location LIKE  'United States'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population


SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS infectionPercentage
FROM PortfolioProject..Covid_Deaths
--WHERE location LIKE  'United States'
GROUP BY location, population
ORDER BY 1,2;

-- Things broken down by continent

-- Showing continents with highest death rate per population

SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount, MAX(population) AS Population
FROM PortfolioProject..Covid_Deaths
--WHERE location LIKE  'United States'
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount desc;


-- Looking at countries with highest death rate compared to population

SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount, MAX(population) AS Population
FROM PortfolioProject..Covid_Deaths
--WHERE location LIKE  'United States'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount desc;

-- Global Numbers

--Cases, Deaths, Death Percentage by Date

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths
--WHERE location LIKE '%United States%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Aggregate Cases, Death, Death Percentage

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths
--WHERE location LIKE '%United States%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs. Vaccinations
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS bigint)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,
	DEA.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..Covid_Deaths DEA
JOIN PortfolioProject..Covid_Vaccinations VAC
ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3;

-- Using a CTE
WITH PopvsVac (continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS bigint)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,
	DEA.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..Covid_Deaths DEA
JOIN PortfolioProject..Covid_Vaccinations VAC
ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) * 100 AS Percent_Pop_Vaccinated
FROM PopvsVac;

-- Using a Temp Table instead of CTE

DROP Table if exists #PercentPopulationVaccinated
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
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS bigint)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,
	DEA.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..Covid_Deaths DEA
JOIN PortfolioProject..Covid_Vaccinations VAC
ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100 AS Percent_Pop_Vaccinated
FROM #PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS bigint)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,
	DEA.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..Covid_Deaths DEA
JOIN PortfolioProject..Covid_Vaccinations VAC
ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated