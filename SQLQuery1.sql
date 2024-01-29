Select * 
from PortfolioProject.dbo.CovidDeaths


--Select * 
--from PortfolioProject.dbo.CovidVaccinations

-- Wanted Data
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths 
order by 1,2

-- Total cases Vs Total deaths
-- Likelihood of dying of someone contracted Covid in a country

Select location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%Jordan'
order by 1,2

-- Total cases vs population
-- Likelihood of getting covid in a centain country

Select location, date, population, total_cases,
(total_cases/population)*100 as InfectionPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%Jordan'
order by 1,2


-- countries with the highest infection rate compared based on population

Select location, population, max(total_cases) as HighestInfectionCount,
 max((total_cases/population))*100 as PopulationPercentageInfected
 From PortfolioProject..CovidDeaths
 Group by location, population
 order by PopulationPercentageInfected desc

-- countries with the highest deaths count
Select location, max(total_deaths) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathsCount desc

-- showing the highest deaths count based on the continent
Select continent, max(total_deaths) as TotalDeathsCount
from PortfolioProject..CovidDeaths
Group by continent
order by TotalDeathsCount desc

-- Global Numbers
Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, 
	sum(new_deaths)/sum(new_cases) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- by date
Select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, 
	sum(new_deaths)/sum(new_cases) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(CONVERT(bigint, vac.new_vaccinations))
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using a CTE to get the PercentagePopulationVaccinated

with PopvsVac ( Continent, location, date, population, new_vaccinations, RollingPeopleVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(CONVERT(bigint, vac.new_vaccinations))
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinations/population)*100 as PercentagePopulationVaccinated
from PopvsVac

-- Using a Temp Table to the PercentagePopulationVaccinated
Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinations numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(CONVERT(bigint, vac.new_vaccinations))
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinations/population)*100 as PercentagePopulationVaccinated
from #PercentagePopulationVaccinated
order by 2, 3


-- Creating a View for later Visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(CONVERT(bigint, vac.new_vaccinations))
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
