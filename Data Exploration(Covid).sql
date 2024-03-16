Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vs total deaths

select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_per_Cent
from PortfolioProject..CovidDeaths where location like 'india' and  continent is not null
order by 1,2

--Percentage of people affected

select location,date,total_cases, population,(total_cases/population)*100 as people_affected_per_cent
from PortfolioProject..CovidDeaths where location like 'india' and  continent is not null
order by 1,2

--countries with highest infection rate 
select location,max(total_cases) as max_cases, population,max((total_cases/population)*100) as people_affected_per_cent
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by people_affected_per_cent desc


--Showing Countries with Highest death count by population
select location,population, max(cast(total_deaths as int)) as total_deaths,(max(total_deaths)/population)*100 as death_ppc
from PortfolioProject..CovidDeaths
where continent is not null 
group by location,population
order by death_ppc desc

--Global Numbers date wise
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by date

--Vaccination table
select * from PortfolioProject..CovidVaccinations

--Join
Select * from PortfolioProject..CovidDeaths dea join
  PortfolioProject..CovidDeaths vac on
  dea.location=vac.location and dea.date=vac.date

-- data on new vaccination

select dea.continent,dea.location,dea.date,dea.new_vaccinations from PortfolioProject..CovidDeaths dea join
PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations!='NULL'
order by 2,3

--Rolling people vaccinated

select dea.continent,dea.location,dea.date,dea.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by(dea.location) order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations!='NULL'
order by 2,3

--vaccination population percentage using CTE

with vacbypop(continent,location,population,date,new_vaccinations,RollingPeopleVaccinated) as
(
select dea.continent,dea.location,dea.population,dea.date,dea.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by(dea.location) order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations!='NULL'
)

select *, (RollingPeopleVaccinated/population)*100 from vacbypop
order by 2,3

--vaccination population percentage using Temp table

drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
population numeric,
date datetime,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)

insert into #percentagepopulationvaccinated
select dea.continent,dea.location,dea.population,dea.date,dea.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by(dea.location) order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations!='NULL'

select *, (RollingPeopleVaccinated/population)*100 from #percentagepopulationvaccinated
order by 2,3

--creating view of percentage population vaccinated
use PortfolioProject
go
create view percentagepopulationvaccinatedview as
select dea.continent,dea.location,dea.population,dea.date,dea.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by(dea.location) order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations!='NULL'

--application of (use and go) was reffered from stackoverflow as view was not updating in ssms

select * from percentagepopulationvaccinatedview
