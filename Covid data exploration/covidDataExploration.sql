-- select * 
-- from coviddeaths
-- where continent is not null
-- order by 3,4

-- select * 
-- from covidvaccinations
-- order by 3,4

-- selecting data 

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths

-- total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathRatio
from coviddeaths
where location = "bhutan"

-- highest country by infection ratio 

select location, population, MAX(total_cases) as highestInfection, MAX(total_cases/population)*100 as infectionRatio
from coviddeaths
group by location, population
order by infectionRatio desc

-- country with highest death count per population 

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeath
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeath DESC;

-- by continent

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeath
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeath DESC;

-- global numbers

select date, sum(new_cases) as totalCases, sum(cast(new_deaths as UNSIGNED)) as totalDeaths, (sum(cast(new_deaths as UNSIGNED))/sum(new_cases))*100 as deathPercentage 
from coviddeaths
where continent IS NOT NULL 
group by date
order by date

-- total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as UNSIGNED)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- using cte

with PopVsVac(continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as UNSIGNED)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (rollingPeopleVaccinated/population)*100
from PopVsVac
order by 2,3


-- using temp table

drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
 location nvarchar(255), 
 date datetime, 
 population numeric, 
 new_vaccinations numeric, 
 rollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as UNSIGNED)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date

select *, (rollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated


-- creating view to store data for visualization

create view percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as UNSIGNED)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date

select *
from percentPopulationVaccinated
