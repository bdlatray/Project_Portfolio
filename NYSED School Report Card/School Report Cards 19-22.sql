/* Data year is the year of the test given in April-June
	--> 2018-19 school year is 2019
	--> 2019-20 data not available due to COVID-19 pandemic
	--> 2020-21 school year is 2021 
	--> 2021-22 school year is 2022 */


/* Look at Math 3-8 Proficiency Levels - Union of 2019, 2021, 2022 data tables */
-- 2019 Grades 3-8 Math
SELECT entity_cd, 
	entity_name, 
	year,
	subgroup_name, 
	assessment_name,
	ROUND(SUM(num_prof::NUMERIC)/SUM(num_tested::NUMERIC)*100, 1) AS percent_proficient_2019
FROM math19
WHERE entity_name LIKE '%County' AND assessment_name NOT IN ('Combined7Math', 'Combined8Math','MATH3_8','RegentsMath7','RegentsMath8')
GROUP BY entity_cd, entity_name, year, subgroup_name, assessment_name

UNION ALL

-- 2021 Grades 3-8 Math
SELECT entity_cd, 
	entity_name, 
	year,
	subgroup_name, 
	assessment_name, 
	ROUND(SUM(num_prof::NUMERIC)/SUM(num_tested::NUMERIC)*100, 1) AS percent_proficient_2021
FROM math21
WHERE entity_name LIKE '%County' AND assessment_name NOT IN ('Combined7Math', 'Combined8Math','MATH3_8','RegentsMath7','RegentsMath8')
GROUP BY entity_cd, entity_name, year, subgroup_name, assessment_name

UNION ALL

-- 2022 Grades 3-8 Math
SELECT entity_cd, 
	entity_name, 
	year,
	subgroup_name, 
	assessment_name, 
	ROUND(SUM(num_prof::NUMERIC)/SUM(num_tested::NUMERIC)*100, 1) AS percent_proficient_2022
FROM math22
WHERE entity_name LIKE '%County' AND assessment_name NOT IN ('Combined7Math', 'Combined8Math','MATH3_8','RegentsMath7','RegentsMath8')
GROUP BY entity_cd, entity_name, year, subgroup_name, assessment_name
ORDER BY entity_name, subgroup_name, assessment_name


-------------------------------------


/* Look into Math Algebra I, Geometry, Algebra II Regents Exam Scores
	Aggregated by County and Sub Group - Union of 2019, 2021, 2022 data tables	*/

-- 2019 Math Regents Data
SELECT entity_cd, entity_name, year, subject, subgroup_name, tested, per_prof
FROM regents19
WHERE subject IN ('Regents Common Core Algebra I', 'Regents Common Core Algebra II', 'Regents Common Core Geometry')
	AND	entity_name LIKE '%County'
	AND per_prof IS NOT NULL

UNION ALL 

-- 2021 Math Regents Data
SELECT entity_cd, entity_name, year, subject, subgroup_name, tested, per_prof
FROM regents21
WHERE subject IN ('Regents Common Core Algebra I', 'Regents Common Core Algebra II', 'Regents Common Core Geometry')
	AND	entity_name LIKE '%County'
	AND per_prof IS NOT NULL

UNION ALL 

-- 2022 Math Regents Data
SELECT entity_cd, entity_name, year, subject, subgroup_name, tested, per_prof
FROM regents22
WHERE subject IN ('Regents Common Core Algebra I', 'Regents Common Core Algebra II', 'Regents Common Core Geometry')
	AND	entity_name LIKE '%County'
	AND per_prof IS NOT NULL
ORDER BY entity_cd


-------------------------------------


/* Join and look into State Expenditures */
-- 2019 Expenditures joined with 2019 Regents Data
SELECT r1.entity_cd, r1.entity_name, e1.year, e1.per_fed_state_local_exp AS per_student_exp, r1.subject, r1.subgroup_name, r1.tested, r1.per_prof
FROM regents19 AS r1

JOIN expend19 AS e1
	ON r1.entity_cd = e1.entity_cd
	
WHERE r1.subject IN ('Regents Common Core Algebra I', 'Regents Common Core Algebra II', 'Regents Common Core Geometry')
	AND r1.per_prof IS NOT NULL
ORDER BY e1.year, e1.entity_cd


-- 2019 Expenditures joined with 2019 Grades 3-8 Math Data
SELECT r1.entity_cd, r1.entity_name, e1.year, e1.per_fed_state_local_exp AS per_student_exp, r1.assessment_name, r1.subgroup_name, r1.num_tested, r1.per_prof
FROM math19 AS r1

JOIN expend19 AS e1
	ON r1.entity_cd = e1.entity_cd
	
WHERE r1.assessment_name NOT IN ('Combined7Math', 'Combined8Math','MATH3_8','RegentsMath8')
	AND r1.per_prof IS NOT NULL
ORDER BY e1.year, e1.entity_cd


-- 2021 Expenditures joined with 2021 Math Regents Data
SELECT r1.entity_cd, r1.entity_name, e1.year, e1.per_fed_state_local_exp AS per_student_exp, r1.subject, r1.subgroup_name, r1.tested, r1.per_prof
FROM regents21 AS r1

JOIN expend21 AS e1
	ON r1.entity_cd = e1.entity_cd
	
WHERE r1.subject IN ('Regents Common Core Algebra I', 'Regents Common Core Algebra II', 'Regents Common Core Geometry')
	AND r1.per_prof IS NOT NULL
ORDER BY e1.year, e1.entity_cd


-- 2021 Expenditures joined with 2021 Grades 3-8 Math Data
SELECT r1.entity_cd, r1.entity_name, e1.year, e1.per_fed_state_local_exp AS per_student_exp, r1.assessment_name, r1.subgroup_name, r1.num_tested, r1.per_prof
FROM math21 AS r1

JOIN expend21 AS e1
	ON r1.entity_cd = e1.entity_cd
	
WHERE r1.assessment_name NOT IN ('Combined7Math', 'Combined8Math','MATH3_8','RegentsMath8')
	AND r1.per_prof IS NOT NULL
ORDER BY e1.year, e1.entity_cd





------------------------------------
------------------------------------
------------------------------------
------------------------------------
------------------------------------
------------------------------------
------------------------------------
------------------------------------


/* make updates */
UPDATE regents19 SET subject='Regents Common Core Algebra I' WHERE subject ='REG_COMALG1'
UPDATE regents19 SET subject='Regents Common Core Algebra II' WHERE subject ='REG_COMALG2'
UPDATE regents19 SET subject='Regents Common Core Geometry' WHERE subject ='REG_COMGEOM'
UPDATE regents19 SET per_prof=NULL WHERE per_prof =''
UPDATE regents19 SET tested=NULL WHERE tested ='s'
UPDATE math21 SET not_tested=NULL WHERE not_tested=0
