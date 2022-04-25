--Select *
--From PortfolioProject..CovidDeaths
--order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Selecting data we will be using
Select location, date, total_cases,new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

-- Likelyhood of death if COVID contraced in Canada
Select location, date, total_cases,total_deaths, Round(total_deaths/total_cases, 4)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2

-- total cases vs population
Select location, date, population, total_cases, Round(total_cases/population, 4)*100 AS CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2

--Lookup of countries with highest case percentage
Select Location, Population, MAX(total_cases) as HighestInfCount, MAX(ROUND(total_cases/population,4)*100) AS PercentPopInfected
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Where continent IS NOT NULL
GROUP BY Location, Population
--HAVING PercentPopInfected IS NOT NULL
order by 4 DESC

-- Showing Countriest With Highest Death Count per Pop
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent IS NOT NULL
GROUP BY Location
order by TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null and location not like '%inco%'
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

--Select location, date, total_cases,total_deaths, Round(total_deaths/total_cases, 4)*100 AS DeathPercentage
--From PortfolioProject..CovidDeaths
--Where continent is not null
--GROUP BY date
--order by 1,2

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY date
order by 1,2

-- total death pctg
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null
-- GROUP BY date
order by 1,2




Select *
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vax
	On dth.location = vax.location
	and dth.date = vax.date

-- Using CTE

With PopsVsVax (Continent, Location, date, Population, New_Vaccinations, RollingVax)
as
(
-- Total population vs Vaccination (Canada in comment)
Select dth.continent, dth.location, dth.date, dth.population, vax.new_vaccinations, 
SUM(Cast(vax.new_vaccinations as int)) OVER (Partition by dth.Location Order by dth.location, dth.Date) As RollingVax
-- ,Round((RollingVax/dth.population)*100, 4) as PctVax
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vax
	On dth.location = vax.location
	and dth.date = vax.date
where dth.continent is not null
-- And dth.location like '%canad%'
--Order by 2,3
)
Select *, Round((RollingVax/population)*100, 4) as PctVax
From PopsVsVax
Where location like '%Canad%'

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVax numeric
)

Insert into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vax.new_vaccinations, 
SUM(Cast(vax.new_vaccinations as bigint)) OVER (Partition by dth.Location Order by dth.location, dth.Date) As RollingVax
-- ,Round((RollingVax/dth.population)*100, 4) as PctVax
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vax
	On dth.location = vax.location
	and dth.date = vax.date
where dth.continent is not null
-- And dth.location like '%canad%'
--Order by 2,3

Select *, Round((RollingVax/population)*100, 4) as PctVax
From #PercentPopulationVaccinated
-- Where location like '%Canad%'

--Creating view to store data for later visuals

Create View PctVax as
Select dth.continent, dth.location, dth.date, dth.population, vax.new_vaccinations, 
SUM(Cast(vax.new_vaccinations as bigint)) OVER (Partition by dth.Location Order by dth.location, dth.Date) As RollingVax
-- ,Round((RollingVax/dth.population)*100, 4) as PctVax
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vax
	On dth.location = vax.location
	and dth.date = vax.date
where dth.continent is not null
-- And dth.location like '%canad%'
-- Order by 2,3

-- check to see if view created
SELECT 
OBJECT_SCHEMA_NAME(o.object_id) schema_name,o.name
FROM
sys.objects as o
WHERE
o.type = 'V';

-- drop view if exists dbo.PercentPopulationVaccinated  -- dropping old views


Create View PopsVsVax as
With PopsVsVax (Continent, Location, date, Population, New_Vaccinations, RollingVax)
as
(
-- Total population vs Vaccination (Canada in comment)
Select dth.continent, dth.location, dth.date, dth.population, vax.new_vaccinations, 
SUM(Cast(vax.new_vaccinations as int)) OVER (Partition by dth.Location Order by dth.location, dth.Date) As RollingVax
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vax
	On dth.location = vax.location
	and dth.date = vax.date
where dth.continent is not null
-- And dth.location like '%canad%'
--Order by 2,3
)
Select *, Round((RollingVax/population)*100, 4) as PctVax
From PopsVsVax
Where location like '%Canad%'



Create View TotalDeath as 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null

Create View ContinentTotals as
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null and location not like '%inco%'
Group by location

Create View LikelyhoodDeathCA as
-- Likelyhood of death if COVID contraced in Canada
Select location, date, total_cases,total_deaths, Round(total_deaths/total_cases, 4)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Canada%'


Create View PopVsDeathCA as
Select location, date, population, total_cases, Round(total_cases/population, 4)*100 AS CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%Canada%'


--Quick drops:
--Drop View if exists ContinentTotals
--Drop View if exists LikelyhoodDeathCA
--Drop View if exists PctVax
--Drop View if exists PopsVsVax
--Drop View if exists PopVsDeathCA
--Drop View if exists TotalDeath