Select *
From PortofolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortofolioProject.dbo.CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
Where continent is not null
order by 1,2



--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PopulationPercentage
FROM PortofolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
order by 1,2


--Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, Population
order by TotalDeathCount desc

--Let's BREAK Things Down BY CONTINENT

--Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date 
--Where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3



Select *
From PercentPopulationVaccinated