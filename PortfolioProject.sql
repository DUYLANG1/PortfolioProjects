select * from CovidDeaths
where continent is not null
order by 3,4

--Total cases vs total deaths
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) * 100 as Death
from CovidDeaths
where location like '%viet%' and continent is not null
order by 1,2


--Looking at total cases vs population
select location, date, total_cases, population, (cast(total_cases as float)/population) * 100 as PercentageCovid
from CovidDeaths
where location like '%states%' and continent is not null
order by 1,2


--Countries wiht highest rate infection
select location, population, max(cast(total_cases as int)) as HighestInfection, max((cast(total_cases as float)/population)) * 100 
	as PercentageCovid
from CovidDeaths
--where location like '%eng%' and continent is not null
group by location,population
order by PercentageCovid desc


--Showing countries with highest Death count per population
select location, max(cast(total_deaths as float)) as DeathCount
from CovidDeaths
--where location like '%viet%'
where continent is not null
group by location
order by DeathCount desc



--Break things with continent


--Showing continent with highest death count per population
select continent, max(cast(total_deaths as float)) as DeathCount
from CovidDeaths
--where location like '%viet%'
where continent is not null
group by continent
order by DeathCount desc


--GLOBAL NUMBERS
select sum(new_cases) as total_new_cases, sum(new_deaths) as  total_new_deaths
	,sum(new_deaths)/NULLIF(sum(new_cases),0) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2



--Look at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated

from CovidDeaths dea join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with PopvsVac
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum( cast(vac.new_vaccinations as bigint) ) over (partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population) * 100
from PopvsVac
order by 2,3


--TEMP TABLE
drop table if exists #PercentPopulationVacciated
create table #PercentPopulationVacciated
(
Continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVacciated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum( cast(vac.new_vaccinations as bigint) ) over (partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVacciated


-- Creating view to store data for later visualizations
;go
create view PercentPopulationVacciated as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		,sum( cast(vac.new_vaccinations as bigint) ) over (partition by dea.location 
		order by dea.location, dea.date) as RollingPeopleVaccinated
	from CovidDeaths dea join CovidVaccinations vac
		on dea.location = vac.location 
		and dea.date = vac.date
	where dea.continent is not null
)
;go

select * from PercentPopulationVacciated