-- What is the overall attrition rate?
select 
(count(CASE WHEN Attrition = 'yes' then 1 end) * 100) / count(*) AS ATTRITION_RATE
from employee;

-- Which departments have the highest attrition?
SELECT Department,
(count(CASE WHEN Attrition = 'yes' then 1 end) * 100) / count(*) AS ATTRITION_RATE
FROM employee
group by Department
order by ATTRITION_RATE desc;

-- Are employees with low job satisfaction more likely to leave?
SELECT t2.JobSatisfaction, count(*) as total_employees,
sum(case when t1.Attrition = 'yes' then 1 else 0 end ) as employee_left,
round(100.0 * sum(case when t1.Attrition = 'yes' then 1 else 0 end )/ count(*) ,2) as Attrition_rate 
 FROM employee t1
 inner join personal t2
 on t1.EmployeeID = t2.EmployeeID
 group by t2.JobSatisfaction
 order by Attrition_rate desc;
 
 alter table employee drop column Column1;
 
 -- How does tenure (years at the company) affect attrition?
SELECT 
(case when TotalWorkingYears < 10 then 'less than 10 years '
when TotalWorkingYears between 10 and 20 then '10 -20 years '
when TotalWorkingYears between 21 and 30 then '21 -30 years '
else 'above 30' end) as tenure ,
 sum(case when Attrition = 'yes' then 1 else 0 end ) as employee_left,
round(100.0 * sum(case when Attrition = 'yes' then 1 else 0 end )/ count(*) ,2) as Attrition_rate 
 FROM employee
group by (case when TotalWorkingYears < 10 then 'less than 10 years '
when TotalWorkingYears between 10 and 20 then '10 -20 years '
when TotalWorkingYears between 21 and 30 then '21 -30 years '
else 'above 30' end)
order by Attrition_rate desc;

-- What is the average job satisfaction score per department?
SELECT Department,round(avg(JobSatisfaction), 1) as avg_jobsatisfaction
 FROM employee t1
 inner join personal t2
 on t1.EmployeeID = t2.EmployeeID
 group by Department
 order by avg_jobsatisfaction desc;
 
 -- Is there a correlation between work-life balance and attrition?
SELECT WorkLifeBalance,count(*) as total_employees, 
sum(case when Attrition = 'yes' then 1 else 0 end) as attrited_employees,
(sum(case when Attrition = 'yes'then 1 else 0 end) * 100 /count(*)) attrition_rate
 FROM employee t1
  inner join personal t2
 on t1.EmployeeID = t2.EmployeeID
 group by  WorkLifeBalance
 order by attrition_rate desc;
 
 -- Are employees with low environmental satisfaction more likely to leave?
SELECT EnvironmentSatisfaction,count(*) as total_employees, 
sum(case when Attrition = 'yes' then 1 else 0 end) as attrited_employees,
(sum(case when Attrition = 'yes'then 1 else 0 end) * 100 /count(*)) attrition_rate
 FROM employee t1
  inner join personal t2
 on t1.EmployeeID = t2.EmployeeID
 group by EnvironmentSatisfaction
 order by attrition_rate desc;
 
  -- Do employees with low salaries leave more often?
 with t3 as(SELECT avg(MonthlyIncome)as avg_income
  from job)
  select
 case
   when t2.MonthlyIncome < (select avg_income from t3) then 'low_income'
else 'high_income' end as income_category,
count(distinct case when t1.attrition = 'yes' then t1.EmployeeID end )as attrited_employees,
 count(*)as total_employee,
round(100 * count(distinct case when attrition = 'yes' then t1.EmployeeID end ) / count(*), 1)as attrition_rate
 FROM employee t1
 inner join (select employeeid,monthlyincome from job )t2
 on t1.employeeid = t2.employeeid
 group by income_category
 order by attrition_rate desc;
 
 
 -- What is the average time between promotions for those who left vs. stayed?
SELECT case when Attrition = 'yes' then 'stayed' else 'left' end as attrition_status,
 ROUND(AVG(YearsInCurrentRole - YearsSinceLastPromotion), 1)as avg_promotion_time
 FROM employee_attrition.employee
 group by attrition_status
 order by avg_promotion_time desc;
 
 -- Are high-performing employees getting promoted?
SELECT  t2.PerformanceRating, count(T1.EmployeeID) as TOTAL_employee,
SUM(case when  t1.YearsSinceLastPromotion < 3 then 1 else 0 end) as PROMOTED_COUNT,
SUM(case when  t1.YearsSinceLastPromotion >= 3 then 1 else 0 end) as NOT_PROMOTED_COUNT,
round( 100 * SUM(case when  t1.YearsSinceLastPromotion < 3 then 1 else 0 end)/count(T1.EmployeeID), 2) AS PROMOTION_RATE
 FROM employee_attrition.employee T1
 INNER JOIN personal T2
 ON T1.EmployeeID = T2.EmployeeID
 where t2.PerformanceRating > 3 
 group by PerformanceRating;
 
 -- Are younger or older employees leaving more?
SELECT 
	CASE WHEN AGE < 30 then 'YOUNGER_AGE'
   when AGE BETWEEN 30 AND 50 THEN 'MIDDLE_AGE'
   when AGE > 50 then 'OLDER_AGE'
    else 'OTHER' END AS AGE_GROUP,
    COUNT(EMPLOYEEID) AS TOTAL_EMPLOYEES,
    SUM(CASE WHEN Attrition = 'YES' THEN 1 ELSE 0 END) AS EMPLOYEE_LEFT,
    ROUND(100 * SUM(CASE WHEN Attrition = 'YES' THEN 1 ELSE 0 END)/ COUNT(EMPLOYEEID), 2) ATTRITION_RATE
 FROM employee_attrition.employee
 group by AGE_GROUP
 order by ATTRITION_RATE DESC;
 
 
 -- Is marital status linked to attrition?
SELECT distinct MaritalStatus,
count(EmployeeID) TOTAL_EMPLOYEES,
SUM(CASE WHEN Attrition = 'YES' THEN 1 ELSE 0 END) AS EMPLOYEES_LEFT,
round(100 * SUM(CASE WHEN Attrition = 'YES' THEN 1 ELSE 0 END)/count(EmployeeID), 1) ATTRITED_EMPLOYEES
FROM employee_attrition.employee
GROUP BY MaritalStatus
order by ATTRITED_EMPLOYEES desc;


-- Does education level impact retention?
SELECT Education, count(T1.EmployeeID) TOTAL_EMPLOYEE,
SUM(case when T1.Attrition = 'NO' THEN 1 ELSE 0 END ) AS RETAINED_EMPLOYEE,
ROUND(100 * SUM(case when T1.Attrition = 'NO' THEN 1 ELSE 0 END )/ count(T1.EmployeeID), 1)RETENTION_LEVEL
 FROM employee_attrition.employee T1
 INNER JOIN education T2
 ON T1.EmployeeID = T2.EmployeeID
 group by Education
 order by RETENTION_LEVEL desc;
 
 SELECT MonthlyIncome
 FROM employee_attrition.employee t1
 inner join education t2
on t1.EmployeeID = t2.EmployeeID
inner join job t3
on t1.EmployeeID = t3.EmployeeID
inner join personal t4 
on t1.EmployeeID = t4.EmployeeID
order by MonthlyIncome ASC;


SELECT 
    CASE 
        WHEN jobsatisfaction IN (1, 2) THEN 'Low'
        WHEN jobsatisfaction = 3 THEN 'Medium'
        ELSE 'High'
    END AS job_satisfaction,
    
    CASE 
        WHEN  worklifebalance IN (1, 2) THEN 'Low'
        WHEN  worklifebalance = 3 THEN 'Medium'
        ELSE 'High'
    END AS  work_life_balance,
    
    
    CASE 
        WHEN monthlyincome < 3000 THEN 'Low'
        WHEN monthlyincome BETWEEN 3000 AND 6000 THEN 'Lower-Mid'
        WHEN monthlyincome BETWEEN 6001 AND 10000 THEN 'Upper-Mid'
        WHEN monthlyincome BETWEEN 10001 AND 15000 THEN 'High'
        ELSE 'Very High'
    END AS MONTHLY_INCOME,
    CASE 
        WHEN yearssincelastpromotion > 5 THEN 'No Promotion'
        WHEN yearssincelastpromotion BETWEEN 2 AND 5 THEN 'Delayed Promotion'
        ELSE 'Recently Promoted'
    END AS promotion_status,

    COUNT(T1.employeeid) AS total_employees,
    
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(T1.employeeid), 2) AS attrition_rate

FROM employee T1
join personal T2
ON T1.EmployeeID = T2.EmployeeID
JOIN  job T3
ON T1.EmployeeID = T3.EmployeeID

GROUP BY job_satisfaction,worklifebalance, MONTHLY_INCOME, promotion_status
ORDER BY attrition_rate ASC;


 
 
