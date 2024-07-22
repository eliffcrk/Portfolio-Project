
--COVID DATA EXPLORATION 

--SKILL; Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

--SELECT [iso_code]
--      ,[continent]
--      ,[location]
--      ,[date]
--      ,[population]
--      ,[total_cases]
--      ,[new_cases]
--      ,[new_cases_smoothed]
--      ,[total_deaths]
--      ,[new_deaths]
--      ,[new_deaths_smoothed]
--      ,[total_cases_per_million]
--      ,[new_cases_per_million]
--      ,[new_cases_smoothed_per_million]
--      ,[total_deaths_per_million]
--      ,[new_deaths_per_million]
--      ,[new_deaths_smoothed_per_million]
--      ,[reproduction_rate]
--      ,[icu_patients]
--      ,[icu_patients_per_million]
--      ,[hosp_patients]
--      ,[hosp_patients_per_million]
--      ,[weekly_icu_admissions]
--      ,[weekly_icu_admissions_per_million]
--      ,[weekly_hosp_admissions]
--      ,[weekly_hosp_admissions_per_million]
--  FROM [newdatabase].[dbo].[Coviddeaths];

SELECT  [location],[date],[total_cases],[new_cases],[total_deaths],[population]
FROM [newdatabase].[dbo].[Coviddeaths] as deaths
order by 1,2;

--Lookin at total cases vs total deaths 
--Shows likelihood of dying if you contract covid  in your country 

SELECT  [location],[date],[total_cases],[total_deaths] ,   (CAST(total_deaths AS float) / total_cases) * 100 AS Death_percentage
FROM [newdatabase].[dbo].[Coviddeaths] as deaths
WHERE location like '%states%'
order by 3 desc;

-- Looking at total cases vs population


SELECT [location],[date],[total_cases],[population], ROUND((CAST (total_cases AS float)/population)*100 ,3) as percentages
from[newdatabase].[dbo].[Coviddeaths] as deaths;


-- Looking at the countries with highest infection rate compared to population 


SELECT [location],[population],MAX([total_cases]) AS Highest_InfectionRate,MAX( ROUND((CAST (total_cases AS float)/population)*100 ,2)) as percentages_InfectedPopulation
from[newdatabase].[dbo].[Coviddeaths] as deaths
Group by location, population
order by percentages_InfectedPopulation desc;


--Showing countries with highest death count per population

select [location],MAX([total_deaths]) AS TotalDeathCOUNT 
from [newdatabase].[dbo].[Coviddeaths] as deaths
where continent is not null
group by location
order by TotalDeathCOUNT desc;



select [continent],MAX(CAST([total_deaths] AS int)) AS TotalDeathCOUNT 
from [newdatabase].[dbo].[Coviddeaths] as deaths
where continent is not null
group by continent
order by TotalDeathCOUNT desc;

--GLOBAL NUMBERS

SELECT location,SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS FLOAT)) as total_deaths
from [newdatabase].[dbo].[Coviddeaths] as deaths
group by location
order by 1;

-- TOTAL 
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, ROUND(SUM(CAST(new_deaths AS float))/SUM(new_cases)* 100 , 2) AS death_percentage
from [newdatabase].[dbo].[Coviddeaths] as deaths
where continent is not null
order by 1;

SELECT*
from[newdatabase].[dbo].[Coviddeaths] as dea
join [newdatabase].[dbo].[CovidVaccinations] as vac
ON dea.location=vac.location 
and dea.date=vac.date;

--Looking at Total Population vs Vaccianation 
--What is the total number of people who are vaccinated

SELECT  dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location ,dea.date ) AS rollingpeople_vaccinated,
---(rollingpeople_vaccinated / population) *100
FROM [newdatabase].[dbo].[Coviddeaths] as dea
JOIN [newdatabase].[dbo].[CovidVaccinations] as vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null 
order by 2,3;

--USE CTE 

with popvsVac (Continent , location , date, population ,New_vaccinations, rollingpeople_vaccinated)
as 
(
SELECT  dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location ,dea.date ) AS rollingpeople_vaccinated
---(rollingpeople_vaccinated / population) *100
FROM [newdatabase].[dbo].[Coviddeaths] as dea
JOIN [newdatabase].[dbo].[CovidVaccinations] as vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null 
--order by 2,3;
)
select * ,round((cast(rollingpeople_vaccinated as float) / population) *100, 2) as percentages_of
from popvsVac


-- TEMP TABLE 

DROP TABLE if exists #percentpopulationvaccinated1
Create table  #percentpopulationvaccinated1
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric ,
New_vaccinations numeric ,
rollingpeople_vaccinated numeric)

insert into  #percentpopulationvaccinated1
SELECT  dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location ,dea.date ) AS rollingpeople_vaccinated
---(rollingpeople_vaccinated / population) *100
FROM [newdatabase].[dbo].[Coviddeaths] as dea
JOIN [newdatabase].[dbo].[CovidVaccinations] as vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null 

select * ,round((cast(rollingpeople_vaccinated as float) / population) *100, 2) as percentages_of
from #percentpopulationvaccinated1



-- Creating view to store data for later visualizations 


Create view Percentpopulationvaccinated1 as 
SELECT  dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location ,dea.date ) AS rollingpeople_vaccinated
---(rollingpeople_vaccinated / population) *100
FROM [newdatabase].[dbo].[Coviddeaths] as dea
JOIN [newdatabase].[dbo].[CovidVaccinations] as vac
    ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null 
--order by 2,3


select *from Percentpopulationvaccinated1;

