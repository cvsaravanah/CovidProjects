Select * 
from PortfolioProject..CovidDeaths 
order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2;

--Looking at total cases vs total deaths
--It shows the percentage of deaths who got covid


Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2;

--Looking at total cases vs total population
--It shows the percentage of population who got covid

Select location,date,population,total_cases,(total_cases/population)*100 as covid_percentage
from PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2;

--Looking at countries with highest infectiong rate compared to population

Select location,population,max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as covid_percentage
from PortfolioProject..CovidDeaths
group by location,population
order by covid_percentage desc;

--Showing countries with highest death count per population

Select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not NULL
group by location
order by TotalDeathCount desc;

--Showing continents with highest death count per population

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not NULL
group by continent
order by TotalDeathCount desc;

--Global view of daily cases per day

Select date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths ,
SUM(CAST(new_deaths as int)) /SUM(new_cases) * 100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

--Global view of daily cases as total

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths ,
SUM(CAST(new_deaths as int)) /SUM(new_cases) * 100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;


--Looking at Total population vs Vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform calculation 

With popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select * ,(rollingpeoplevaccinated/population) * 100 as TotalVaccinations
from popvsvac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

