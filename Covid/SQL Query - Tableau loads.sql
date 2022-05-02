-- Tableau data 1 
-- total death pctg
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null
-- GROUP BY date
order by 1,2

-- Tableau data 2
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null and location not like '%inco%'
Group by location
order by TotalDeathCount desc

-- Tableau data 3
-- For Tableau load, changing NULL to 0 with Coalesce(___, 0) to prevent being read as str
--Lookup of countries with highest case percentage
Select Location, Coalesce(Population, 0), Coalesce(MAX(total_cases), 0) as HighestInfCount, Coalesce(MAX(ROUND(total_cases/population,4)*100), 0) AS PercentPopInfected
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
GROUP BY Location, Population
--HAVING PercentPopInfected IS NOT NULL
order by 4 DESC


-- Tableau data 4
Select Location, Coalesce(date,0) as Date, Coalesce(Population, 0) as Population, Coalesce(MAX(total_cases), 0) as HighestInfCount, Coalesce(MAX(ROUND(total_cases/population,4)*100), 0) AS PercentPopInfected
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
and location not like '%inco%'
GROUP BY Location, Population, date
order by 4 DESC

-- Tableau data 5
With PopsVsVax (Population, Fully_Vaccinated)
as
(
SELECT AVG(dth.population) as Population, MAX(cast(people_fully_vaccinated as bigint)) as Fully_Vaccinated
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vax
	On dth.location = vax.location
	--and dth.date = vax.date
where dth.iso_code = 'OWID_WRL'

)

Select Population, Fully_Vaccinated, Round((Fully_Vaccinated/Population)*100, 2) as PercentFullyVaccinated
From PopsVsVax

-- Tableau Data 6

Select Location, Coalesce(SUM(new_cases),0) as total_cases, 
	Coalesce(SUM(cast(new_deaths as int)),0) as total_deaths, Coalesce((SUM(cast(new_deaths as int))/Sum(new_cases)*100),0) as DeathPercentage
From PortfolioProject..CovidDeaths
Where iso_code not like '%owid%'
Group by location