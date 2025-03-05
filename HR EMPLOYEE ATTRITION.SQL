-- What is the overall attrition rate?
select 
(count(CASE WHEN Attrition = 'yes' then 1 end) * 100) / count(*) AS ATTRITION_RATE
from employee

