/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
--Retrive the data 
SELECT * FROM CovidDeaths
SELECT * FROM CovidVaccinations

SELECT * FROM CovidDeaths
Order by 3,4 --show the null value in third and forth column (assending the 3 and 4th column)

-- Select Data that we are going to be starting with 
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2   -- (shorting order(ase) one and two columns)	


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Persentage
FROM CovidDeaths
Where location like '%states%'
Order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Persentage_Population
FROM CovidDeaths
--Where location like '%states%'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, 
       MAX(total_cases) AS Highest_Case, 
       MAX(total_cases/ population) * 100 AS Percentage_Population_Infected
FROM CovidDeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population 
ORDER BY Percentage_Population_Infected DESC;

-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
--CAST() function converts a value (of any type) into a specified datatype. Syntax:  CAST(expression AS datatype(length))

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2

--Show all columns table1 and table2 on the basis of location and date
SELECT * FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location =vac.location
AND dea.date= vac.date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
----------Using Window function (use over and partition by )
--Covert datatype varchar to int using CONVERT functon 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
--Common Table Expressions (CTE) is a temporary result set that is returned by a single statement to be used further within the same statement.

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
----------A temp table, also known as a temporary SQL table is a type of table that allows our database to store and process intermediate results.
---The main differences between CTEs and Temporary Tables are: Storage: CTEs are not physically stored on disk, while temporary tables are. Lifespan: CTEs exist only for the duration of the query execution, while temporary tables can exist beyond a single query execution.

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
From CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
--A view is a virtual table whose contents are defined by a query. Like a table, a view consists of a set of named columns and rows of data. Unless indexed, a view does not exist as a stored set of data values in a database. 
-- Views can help control and restrict access to sensitive data, providing a layer of security and ensuring that users can only see the data they are authorized to access.


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 