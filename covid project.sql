/*
Covid 19 Data Exploration Project
	Skills Used: Order by, Group by, Naming Columns, Joins, CTE's, Temp Table, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Select all data from Covid Death and Covid Vaccination Tables

Select *
From CovidProject..CovidDeaths
Order by 3,4

Select *
From CovidProject..CovidVax
Order by 3,4

-- Select starting data to look at from Covid Deaths

Select Location, date, total_cases, New_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Total Deaths in United States and calculating the death percentage everyday

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where Location like '%States' and continent is not null
Order by 1,2


-- Looking at Total Deaths/Total Cases and Total Cases/Population in United States

Select Location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage, (total_cases/population)*100 as CasesPercentage
From CovidProject..CovidDeaths
Where Location like '%States' and continent is not null
Order by 1,2

-- Total Cases vs Population
-- Rolling Percent of Population infected each day by country

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

-- Looking at Countries with Highest Death rate compared to Population

Select Location, Population, MAX(cast(Total_deaths as int)) TotalDeathCount, Max(cast(total_deaths as int))/Max(population)*100 as PercentPopulationDeath
From CovidProject..CovidDeaths
Where continent is not null
Group by Location, population
Order by PercentPopulationDeath desc

-- Looking at Countries with Highest Death Rate and Infection Rate Compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, MAX(cast(Total_deaths as int)) TotalDeathCount 
, Max((total_cases/population))*100 as PercentPopulationInfected, Max(cast(total_deaths as int))/Max(population)*100 as PercentPopulationDeath
From CovidProject..CovidDeaths
Where continent is not null
Group by Location, population
Order by PercentPopulationDeath desc


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

-- Rolling People Vaccinated, using convert instead of cast

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) 'RollingPeopleVaccinated'
												--Adds new vaccinations to already vaccinated (Rolling) each day. Need to order by date in partition to get "rolling".
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths cd
	Join CovidProject..CovidVax cv
		on cd.location = cv.location
		and cd.date = cv.date
Where cd.continent is not null
Order by 2,3

-- Total Population vs Vaccinations, and use CTE, %Vaccinated goes over 100% possibly due to second and third round being administered

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
	Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
	, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) 'RollingPeopleVaccinated' 
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
From CovidProject..CovidDeaths cd
Join CovidProject..CovidVax cv
	on cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 'PercentVaccinated'
From #PercentPopulationVaccinated
--Where New_vaccination is not null
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