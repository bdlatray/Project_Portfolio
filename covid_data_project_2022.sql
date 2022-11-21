/* Covid Deaths data */

SELECT location, continent, date, total_cases, new_cases, total_deaths, population

FROM covid.covid_death

WHERE continent != ''

ORDER BY location, date
    
    
/* Infection Rate: New Cases vs. Population (United States) */
/* Calculates the overall Covid case rate as a percent of the total population
   in the United States between 01-2020 and 11-2022 */

SELECT location, date, total_cases, population, ROUND(((total_cases/population) * 100),2) AS infection_rate_US

FROM covid.covid_death

WHERE location = 'United States'
    
ORDER BY location, date


/* Death Count by Country */

SELECT location, MAX(CAST(total_deaths AS signed)) AS death_count_country
    
FROM covid.covid_death

WHERE continent != ''

GROUP BY location

ORDER BY death_count_country DESC
    
    
    
/* Death Count by Continent */


SELECT continent, MAX(CAST(total_deaths AS signed)) AS death_count_continent
    
FROM covid.covid_death

WHERE continent != ''

GROUP BY continent

ORDER BY death_count_continent DESC


/* Death Percentage: Total Deaths vs. Total Cases (United States) */
/* Calculates the overall percent of Covid cases ending in death
   in the United States between 01-2020 and 11-2022 */

SELECT location, date, total_cases, total_deaths, ROUND(((total_deaths/total_cases) * 100),2) AS death_percent_US

FROM covid.covid_death

WHERE location = 'United States'
    
ORDER BY location, date DESC


/* GLOBAL NUMBERS */

/* Total Global Death Count */

SELECT date, SUM(new_deaths) AS total_deaths, SUM(new_cases) AS total_cases, 
    (SUM(new_deaths)/SUM(new_cases) * 100) AS global_death_rate
    
FROM covid.covid_death

WHERE continent != ''

GROUP BY date

ORDER BY date
  
    
/* Total Global Death Count by date */
/* From 01-2020 to 11-2022 */

-- Visualization #1

SELECT SUM(new_deaths) AS total_deaths, SUM(new_cases) AS total_cases, (SUM(new_deaths)/SUM(new_cases) * 100) AS global_death_rate
    
FROM covid.covid_death

WHERE continent != ''

ORDER BY 1, 2


-- Visualization #2

SELECT location, SUM(new_deaths) AS total_death_count

FROM covid.covid_death

WHERE continent = ''
    AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper Middle Income', 'Lower Middle Income', 'low income')
    
GROUP BY location

ORDER BY total_death_count DESC


/* Infection Rate by Country: Max Total Cases vs. Population by Country */
/* Calculates overall infection rate by country, sorted by highest infection rate
   using max total cases as of 11-2022 */

-- Visualization #3

SELECT location, population, MAX(total_cases) AS highest_infection_count, 
    MAX(total_cases/population) * 100 AS infection_rate_country

FROM covid.covid_death

WHERE continent != ''

GROUP BY location, population
    
ORDER BY infection_rate_country DESC


-- Visualization #4

SELECT location, population, date, MAX(total_cases) AS highest_infection_count, 
    MAX(total_cases/population) * 100 AS infection_rate_country

FROM covid.covid_death

WHERE continent != ''

GROUP BY location, population, date
    
ORDER BY infection_rate_country DESC




/* Covid Vaccinations Data */

/* Total Population versus New Vaccinations by Country */

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations

FROM covid.covid_vax vax
    
    JOIN covid_death dea
    ON dea.location = vax.location 
        AND dea.date = vax.date

WHERE dea.continent != ''

ORDER BY dea.location, dea.date
    

/* Rolling Vaccinations by Country */


SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
    SUM(vax.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) AS rolling_vaccination_count_country

FROM covid.covid_vax vax
    
    JOIN covid_death dea
    ON dea.location = vax.location 
        AND dea.date = vax.date

WHERE dea.continent != ''

ORDER BY dea.location, dea.date


/* Vaccination Rates by Country */

/* CTE */

WITH pop_vac(continent, location, date, population, new_vaccinations, rolling_vaccination_count_country) AS

    (SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
        SUM(vax.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) AS rolling_vaccination_count_country
    
    FROM covid.covid_vax vax
        
        JOIN covid_death dea
        ON dea.location = vax.location 
            AND dea.date = vax.date
    
    WHERE dea.continent != '')

SELECT *, ROUND((rolling_vaccination_count_country)/population * 100,2) AS vaccination_rate_country
FROM pop_vac;


/* TEMP TABLE
   Looks at rolling percent of population that is vaccinated by country */

DROP TEMPORARY TABLE IF EXISTS PopulationVaccinated;

CREATE TEMPORARY TABLE IF NOT EXISTS PopulationVaccinated 
    AS (SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
        SUM(vax.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) AS rolling_vaccination_count_country
            
        FROM covid.covid_vax vax
        
            JOIN covid_death dea
            ON dea.location = vax.location 
                AND dea.date = vax.date
            
        WHERE dea.continent != '');

SELECT *, ROUND((rolling_vaccination_count_country)/population * 100,2) AS vaccination_rate_country

FROM PopulationVaccinated;


/* Create View
   Create view for data visualization
   Rolling vaccination rates by country */

CREATE VIEW PopulationVaccinated
    AS (SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
        SUM(vax.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) AS rolling_vaccination_count_country
            
        FROM covid.covid_vax vax
                
            JOIN covid_death dea
            ON dea.location = vax.location 
                AND dea.date = vax.date
            
        WHERE dea.continent != '');
        

