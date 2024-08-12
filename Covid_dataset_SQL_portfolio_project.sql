select * from dbo.CovidDeaths 
order by 3,4


select * from dbo.CovidVaccinations
order by 3,4

select location , date , total_cases,new_cases, total_deaths,population 
from dbo.CovidDeaths 
order by 1,2


-- looking at total cases vs total deaths  
-- shows the liklihood of dying if u contract covid in your country 
select location , date , total_cases, total_deaths,population , (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2 


-- looking at the total cases vs the population 
-- shows what percentage of population got covid

select location , date , population , total_cases, (total_cases/population)*100 as covidpercentage
from PortfolioProject..CovidDeaths
--where location like 'India'
order by 1,2 


 -- looking at countries with highest infection rate 

select location ,  population , MAX(total_cases) AS highestinfectioncount, Max((total_cases/population))*100 as covidpercentage
from PortfolioProject..CovidDeaths
--where location like 'India'
group by location , population 
order by covidpercentage desc 

-- this is showing the coutries with highest death count per population

select location ,  population , MAX(cast(total_deaths as int))  AS totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like 'India'
group by location , population 
order by totaldeathcount desc


-- LETS BREAK THIS DOWN BY CONTINENT 

select location , MAX(cast(total_deaths as int))  AS totaldeathcount
from PortfolioProject..CovidDeaths
where continent  is null
--where location like 'India'
group by location 
order by totaldeathcount desc


-- showing the continent with highest death counts 

select continent, MAX(cast(total_deaths as int))  AS totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like 'India'
group by continent
order by totaldeathcount desc

-- GLobal Numbers  

select   date , SUM(new_cases) as totalcases,  SUM(cast(new_deaths as int)) as deathprecentage , sum(cast(new_deaths as int))/sum(new_cases) as deathpercentage
from PortfolioProject..CovidDeaths
where continent  is not null 
group by date  
order by 2,3 desc 


-- LOOKING AT TOTAL  POPULATION VS VACCINATIONS

select  D.location ,  D.continent , D.population , D.date , v.new_vaccinations , SUM(cast(V.new_vaccinations as bigint)) over (partition by
D.Location order by D.Location, D.date) as people_vaccinated
from PortfolioProject..CovidDeaths  D
join PortfolioProject..CovidVaccinations V 
ON D.location = V.location and D.date = V.date 
WHERE D.continent IS NOT NULL
ORDER BY 1,2,3


-- USE CTE

with PopvsVac (location , continent , population , date , new_vaccinations, people_vaccinated )
as (

select  D.location ,  D.continent , D.population , D.date , v.new_vaccinations ,
SUM(cast(V.new_vaccinations as bigint)) over (partition by
D.Location order by D.Location, D.date) as people_vaccinated
from PortfolioProject..CovidDeaths  D
join PortfolioProject..CovidVaccinations V 
ON D.location = V.location and D.date = V.date 
WHERE D.continent IS NOT NULL

) 


select * , (people_vaccinated/population)*100 as percentageofvaccination 
from PopvsVac


-- USE Temptable 
Drop table if exists #population
create table #population (
continent nvarchar(255),
location nvarchar(255),
population numeric ,
date datetime,
new_vaccinations numeric , 
people_vaccinated numeric
);

insert into #population
select  D.location ,  D.continent , D.population , D.date , v.new_vaccinations ,
SUM(cast(V.new_vaccinations as bigint)) over (partition by
D.Location order by D.Location, D.date) as people_vaccinated
from PortfolioProject..CovidDeaths  D
join PortfolioProject..CovidVaccinations V 
ON D.location = V.location and D.date = V.date 
WHERE D.continent IS NOT NULL 

select * , (people_vaccinated/population)*100 as percentage 
from #population


--creating  view to store later visualizations 

create view percentagepopulation as 
select  D.location ,  D.continent , D.population , D.date , v.new_vaccinations ,
SUM(cast(V.new_vaccinations as bigint)) over (partition by
D.Location order by D.Location, D.date) as people_vaccinated
from PortfolioProject..CovidDeaths  D
join PortfolioProject..CovidVaccinations V 
ON D.location = V.location and D.date = V.date 
WHERE D.continent IS NOT NULL 

select * from percentagepopulation