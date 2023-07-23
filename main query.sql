use project1;


-- select data we are using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths order by 1,2;

--total cases vs total deaths
--shows the likelihood of dying if you contracted COVID in your country 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercent
from CovidDeaths where location like'%india%' order by 1,2;

-- looking at the total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as casepercent
from CovidDeaths where location like'%india%' order by 1,2;

--which country has highest infection rate?

select location, max(total_cases) as highest_infection_count,
population, max(total_cases/population)*100 as max_percent_infected
from CovidDeaths group by Location, Population order by 4 desc;

--show countries with highest death rate per population

select location, max(cast(total_deaths as int)) as highest_deaths
from CovidDeaths where continent is not null group by location order by 2 desc;

-- show by continent

select location, max(cast(total_deaths as int)) as highest_deaths
from CovidDeaths where continent is null group by location order by 2 desc;


-- showing continents with higest deathcounts

select continent, max(cast(total_deaths as int)) as highest_deaths
from CovidDeaths where continent is not null group by continent order by 2 desc;

-- global numbers

select date, SUM(new_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths,
(sum(cast(total_deaths as int))/SUM(new_cases))*100 as death_percentages
from CovidDeaths
where continent is not null
group by date
order by 1,2;
 
 -- total cases, deaths in the world
select SUM(new_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths,
(sum(cast(total_deaths as int))/SUM(new_cases))*100 as death_percentages
from CovidDeaths
where continent is not null
--group by date
order by 1,2;

-- total population vs vaccinations

select dth.continent,dth.location, dth.date, dth.population, vcc.new_vaccinations,
SUM(CONVERT(int, vcc.new_vaccinations)) OVER (partition by dth.location ORDER BY dth.location,dth.date)
as roll_vaccinations
from CovidDeaths  as dth join
CovidVaccinations as vcc
on dth.location = vcc.location
and dth.date = vcc.date
where dth.continent is not null
order by 1,2,3;

--USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, roll_vaccinations)
as 
(select dth.continent,dth.location, dth.date, dth.population, vcc.new_vaccinations,
SUM(CONVERT(int, vcc.new_vaccinations)) OVER (partition by dth.location ORDER BY dth.location,dth.date)
as roll_vaccinations
from CovidDeaths  as dth join
CovidVaccinations as vcc
on dth.location = vcc.location
and dth.date = vcc.date
where dth.continent is not null
)
select *, roll_vaccinations/population*100 
from popvsvac;


--TEMP TABLE
drop table if exists #percentpopvaccinated;
create table #percentpopvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
roll_vaccinations
);

insert into #percentpopvaccinated
select dth.continent,dth.location, dth.date, dth.population, vcc.new_vaccinations,
SUM(CONVERT(int, vcc.new_vaccinations)) OVER (partition by dth.location ORDER BY dth.location,dth.date)
as roll_vaccinations
from CovidDeaths  as dth join
CovidVaccinations as vcc
on dth.location = vcc.location
and dth.date = vcc.date
where dth.continent is not null;

select *, roll_vaccinations/population*100 
from #percentpopvaccinated;


-- create view to store data for later visualizations
create view percentpopvaccinated as
select dth.continent,dth.location, dth.date, dth.population, vcc.new_vaccinations,
SUM(CONVERT(int, vcc.new_vaccinations)) OVER (partition by dth.location ORDER BY dth.location,dth.date)
as roll_vaccinations
from CovidDeaths  as dth join
CovidVaccinations as vcc
on dth.location = vcc.location
and dth.date = vcc.date
where dth.continent is not null;

select * from percentpopvaccinated;
