select *
from PortforlioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortforlioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortforlioProject..CovidDeaths
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from PortforlioProject..CovidDeaths
where location like '%africa%'
order by 1,2


--Looking at total cases vs Population
--Shows what percentage got covid

Select Location, date, total_cases, total_deaths, Population, (total_cases/population)*100 DeathPercentage
from PortforlioProject..CovidDeaths
where location like '%africa%'
order by 1,2

--Looking at countries with highest infection rate compared to Population

Select Location, Population, max(total_cases) HighestInfectionCount,
max((total_cases/population))*100 PercentPopulationInfected
from PortforlioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location, Population
order by PercentPopulationInfected desc

--Showing countries with tht=e highest death count per Population

Select Location, max(cast(total_deaths as int)) TotalDeathCount
from PortforlioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc

--Breaking things down by continent

Select continent, max(cast(total_deaths as int)) TotalDeathCount
from PortforlioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing the continent with the highest death count per Population

Select continent, max(cast(total_deaths as int)) TotalDeathCount
from PortforlioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers

Select date, sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))
/sum(new_cases)*100 DeathPercentage
from PortforlioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
group by date
order by 1,2

Select sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))
/sum(new_cases)*100 DeathPercentage
from PortforlioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
--group by date
order by 1,2



--Looking at Total vs Vaccinations

SELECT *
from PortforlioProject..CovidDeaths dea
join PortforlioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/POpulation)*100
from PortforlioProject..CovidDeaths dea
join PortforlioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3 

  --USING CTE

  with PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
  as
  (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/POpulation)*100
from PortforlioProject..CovidDeaths dea
join PortforlioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
  select *, (RollingPeopleVaccinated/Population)*100
  from PopvsVac

  --TEMP TABLE

  drop table if exists #PercentagePopulationVaccinated
  Create table #PercentagePopulationVaccinated
  (
  Continent nvarchar(255),
  location nvarchar(255),
  DAte datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )


 Insert into #PercentagePopulationVaccinated
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/POpulation)*100
from PortforlioProject..CovidDeaths dea
join PortforlioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  --where dea.continent is not null
  --order by 2,3

  select *, (RollingPeopleVaccinated/POpulation)*100
  from #PercentagePopulationVaccinated


  --Creating a View to store Data for later Visualizations

  Create view PercentagePopulationVaccinated as
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/POpulation)*100
from PortforlioProject..CovidDeaths dea
join PortforlioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
  --order by 2,3

  select *
  from PercentagePopulationVaccinated