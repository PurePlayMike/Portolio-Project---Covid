Select *
From CovidProject..CovidDeaths
Order by 4,6

--Select *
--From CovidProject..CovidVax
--Order by 3,4

-- Select Data to be used

Select Location, date, total_cases, New_cases, total_deaths, population
From CovidProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths in United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where Location like '%States'
Order by 1,2

-- Looking at Total Cases vs Population in United States
Select Location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage, (total_cases/population)*100 as CasesPercentage
From CovidProject..CovidDeaths
Where Location like '%States'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Highest Death Count per Population by Continent

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

-- Global Number of cases, deaths, and PercentDeath each day

Select date, SUM(new_cases) 'total_cases', SUM(cast(new_deaths as int)) 'total_deaths', SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentDeath
From CovidProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Global Number overall cases, deaths, and PercentDeath

Select SUM(new_cases) 'total_cases', SUM(cast(new_deaths as int)) 'total_Deaths', SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentDeath
From CovidProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Joining Covid Deaths and Covid Vaccine tables

Select *
From CovidProject..CovidDeaths cd
Join CovidProject..CovidVax cv
	on cd.location = cv.location
	and cd.date = cv.date

-- Rolling People Vaccinated % of Population
--Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
--, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) 'RollingPeopleVaccinated'
--, (RollingVaccinatedCount/population)*100
--From CovidProject..CovidDeaths cd
	--Join CovidProject..CovidVax cv
		--on cd.location = cv.location
		--and cd.date = cv.date
--Where cd.continent is not null


-- Total Population vs Vaccinations, and use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
	Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
	, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) 'RollingPeopleVaccinated'
	--, (RollingVaccinatedCount/population)*100
	From CovidProject..CovidDeaths cd
	Join CovidProject..CovidVax cv
		on cd.location = cv.location
		and cd.date = cv.date
	Where cd.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 'PercentVaccinated'
From PopvsVac
--Where new_vaccinations is not null

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) 'RollingPeopleVaccinated'
--, (RollingVaccinatedCount/population)*100
From CovidProject..CovidDeaths cd
Join CovidProject..CovidVax cv
	on cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 'PercentVaccinated'
From #PercentPopulationVaccinated
Order by 2,3


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) 'RollingPeopleVaccinated'
--, (RollingVaccinatedCount/population)*100
From CovidProject..CovidDeaths cd
Join CovidProject..CovidVax cv
	on cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null

Select *
From PercentPopulationVaccinated