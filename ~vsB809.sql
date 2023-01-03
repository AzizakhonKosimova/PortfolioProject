
select * from PortfolioProject1..covid_deaths
order by 3,4;

select * from PortfolioProject1..covid_vaccinations
order by 3,4;



--Looking at Total Cases vs Total Deaths
select location, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeaths from PortfolioProject1..covid_deaths
order by 3; 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 from PortfolioProject1..covid_deaths where location like 'Uzbekistan'; 

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

select d.location, d.date, d.total_cases, d.total_deaths, v.population, (d.total_cases/ v.population)*100 as Prop_of_Cases from PortfolioProject1..covid_deaths d join PortfolioProject1..covid_vaccinations v on d.date = v.date where d.location like '%states'; 

--Looking at the countries with the highest infection rate compared to population
select d.location, max(d.total_cases), v.population, max((d.total_cases/ v.population)*100) as Max_Prop_of_Cases 
from PortfolioProject1..covid_deaths d 
join PortfolioProject1..covid_vaccinations v 
on d.date = v.date 
group by d.location, v.population 
order by max((d.total_cases/ v.population)*100);

--Looking at the countries with the highest death count per population
select location, max(cast(total_deaths as int))
from PortfolioProject1..covid_deaths 
where continent is not null
group by location
order by max(total_deaths) desc;

--By continent
select location, max(cast(total_deaths as int))
from PortfolioProject1..covid_deaths 
where continent is null
group by location
order by max(total_deaths) desc;


--Continents with the highest death count

select continent, max(cast(total_deaths as int))
from PortfolioProject1..covid_deaths 
where continent is not null
group by continent
order by max(total_deaths) desc;

--Global Numbers 

select date, sum(cast(new_cases as int)) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100
from PortfolioProject1..covid_deaths 
where continent is not null
group by date
order by date;


--Looking at Total Population vs Vaccinations
 select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over(partition by dea.location)
 from PortfolioProject1..covid_deaths dea
 join PortfolioProject1..covid_vaccinations vac
 on dea.date = vac.date
 and dea.location=vac.location
 where dea.continent is not null and vac.new_vaccinations is not null
 order by 2,3;

 select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject1..covid_deaths dea
 join PortfolioProject1..covid_vaccinations vac
 on dea.date = vac.date
 and dea.location=vac.location
 where dea.continent is not null and vac.new_vaccinations is not null
 order by 2,3;

 --USING CTE
 with PopvsVac (Continent, Location, Date, Population, New_Vaccinatins, RollingPeopleVaccinated)
   as
  (
 select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject1..covid_deaths dea
 join PortfolioProject1..covid_vaccinations vac
 on dea.date = vac.date
 and dea.location=vac.location
 where dea.continent is not null and vac.new_vaccinations is not null
 )
select *, (RollingPeopleVaccinated/Population)* 100 from PopvsVac
order by 2,3;


--TEMP TABLE

drop table if exists#PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject1..covid_deaths dea
 join PortfolioProject1..covid_vaccinations vac
 on dea.date = vac.date
 and dea.location=vac.location
 where dea.continent is not null and vac.new_vaccinations is not null
 
 select *, (RollingPeopleVaccinated/Population)* 100 from #PercentPopulationVaccinated
order by 2,3;

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject1..covid_deaths dea
 join PortfolioProject1..covid_vaccinations vac
 on dea.date = vac.date
 and dea.location=vac.location
 where dea.continent is not null and vac.new_vaccinations is not null

 
 select * from PercentPopulationVaccinated




