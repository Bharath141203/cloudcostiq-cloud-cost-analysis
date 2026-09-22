create database cloudcost_iq;
use cloudcost_iq;
CREATE TABLE cloud_billing_data (
    Resource_ID VARCHAR(100),
    Cloud_Provider VARCHAR(50),
    Service_Name VARCHAR(100),
    Resource_Type VARCHAR(100),
    Region VARCHAR(100),
    Department VARCHAR(100),
    Environment VARCHAR(50),
    Instance_Type VARCHAR(100),
    Billing_Date DATE,
    Monthly_Cost_INR DECIMAL(15,2),
    CPU_Utilization_Pct DECIMAL(5,2),
    Memory_Utilization_Pct DECIMAL(5,2),
    Storage_Usage_GB DECIMAL(15,2),
    Network_Usage_GB DECIMAL(15,2),
    Running_Hours DECIMAL(10,2),
    Requests_Count BIGINT,
    Resource_Status VARCHAR(50),
    Utilization_Status VARCHAR(50),
    Potential_Saving_INR DECIMAL(15,2),
    Optimized_Cost_INR DECIMAL(15,2),
    Month VARCHAR(20),
    Year INT,
    Utilization_Score_Pct DECIMAL(5,2),
    Cost_per_Running_Hour_INR DECIMAL(15,2),
    Savings_Pct DECIMAL(5,2)
);
-- -- 
SELECT * FROM cloudcost_iq.cloud_billing_data
LIMIT 10;
--  -- 
SELECT COUNT(*) AS Total_Rows
FROM cloud_billing_data;
-- -- 
describe cloudcost_iq.cloud_billing_data;

-- Total clous cost --

select sum(Monthly_Cost_INR) as Total_Cloud_Cost 
from cloudcost_iq.cloud_billing_data;

-- Total Potential savings --

select sum(Potential_Saving_INR) as Total_Potential_Savings
from cloudcost_iq.cloud_billing_data;

-- cost by cloud Provider --

select Cloud_provider,sum(Monthly_cost_INR) as Total_Cost
from cloudcost_iq.cloud_billing_data
group by Cloud_Provider order by Total_Cost desc;

-- monthly cost trend --
select Year,Month(Billing_Date) as Month_Number,
monthname(Billing_Date) as Month_Name,
sum(Monthly_Cost_INR) as Total_Cost
from cloudcost_iq.cloud_billing_data
group by year,month(Billing_Date),monthname(Billing_Date)
order by year,Month_Number;

-- Underutilized Resources --
select Resource_ID,Cloud_Provider,Service_Name,Monthly_Cost_INR,CPU_Utilization_Pct,Memory_Utilization_Pct,Potential_Saving_INR
from cloudcost_iq.cloud_billing_data
where Utilization_Status ="Underutilized"
order by Potential_Saving_INR Desc;

-- Top 10 costly underutilized resources -- 

select Resource_ID,Cloud_Provider,Service_Name,Monthly_Cost_INR,CPU_Utilization_Pct,Memory_Utilization_Pct,Potential_Saving_INR
from cloudcost_iq.cloud_billing_data
where utilization_status = "Underutilized"
order by Monthly_Cost_INR desc limit 10;

-- savings by provider --

select Cloud_Provider,sum(Potential_Saving_INR) as Potential_Savings
from cloudcost_iq.cloud_billing_data
group by Cloud_Provider order by Potential_Savings Desc;

-- Savings by Department --

select Department,sum(Monthly_Cost_INR) as Total_Cost,sum(Potential_Saving_INR) as Potential_Savings
from cloudcost_iq.cloud_billing_data group by Department
order by Potential_Savings desc;

-- service wise analysis --

select Service_Name,count(*) as Resource_Count,sum(Monthly_Cost_INR) as Total_Cost,
sum(Potential_Saving_INR) as Potential_Savings
from cloudcost_iq.cloud_billing_data
group by Service_Name
order by Total_Cost desc;

-- calculate overall savings % --
select sum(Monthly_Cost_INR) as Total_Cost,sum(Potential_Saving_INR) as Potential_Savings,
round(sum(Potential_Saving_INR)/sum(Monthly_Cost_INR) * 100,2) as Overall_Savings_Pct
from cloudcost_iq.cloud_billing_data;

-- Fomula Apply--
set sql_safe_updates = 0;
UPDATE cloudcost_iq.cloud_billing_data
SET Optimized_Cost_INR = Monthly_Cost_INR - Potential_Saving_INR;
set sql_safe_updates = 1;

-- optimization Impact --

select sum(Monthly_Cost_INR) as Current_Cost,
sum(Potential_Saving_INR) as Potential_Savings,
sum(Optimized_Cost_INR) as Optimized_Cost
from cloudcost_iq.cloud_billing_data;