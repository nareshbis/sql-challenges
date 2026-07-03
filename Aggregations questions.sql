-- Intermediate Aggregation questions to practice
																											-- Week-1 Date June 12, 2026; 9:52AM
-- 1.Find the total number of customers in each country.
SELECT Country,count(*) as Total_Customers
FROM classicmodels.customers 
GROUP BY Country
-- HAVING Total_Customers > 5 (This is an additional line if we want to apply a filter)
ORDER BY Total_Customers desc;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 2.Find the average credit limit by country.
SELECT Country,avg(creditlimit) avg_cl
FROM classicmodels.customers 
GROUP BY country
ORDER BY avg_cl DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 3.Find the maximum and minimum credit limit for each country.
SELECT country,MAX(creditlimit) Highest_CL,MIN(creditlimit) Lowest_CL
FROM classicmodels.customers
GROUP BY country;

-- 	Interview follow up - difference between max and min cls
	SELECT country, MAX(creditlimit) Highest_CL,MIN(creditlimit) Lowest_CL, MAX(creditlimit)-MIN(creditlimit) as credit_limit_range
	FROM classicmodels.customers
	WHERE creditlimit > 0      -- This is to know the actual credit limit difference between max and min
	GROUP BY country
	ORDER BY credit_limit_range desc;

-- Followup (If I want to exclude the credit limit 0 values)
SELECT country,MAX(creditlimit) Highest_CL,MIN(creditlimit) Lowest_CL
FROM classicmodels.customers
WHERE creditlimit > 0
GROUP BY country;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 4.Find the total credit limit for each sales representative.
SELECT salesrepemployeenumber,
	   COUNT(salesrepemployeenumber) count,    -- This I've added to know how many times the sales rep repeated
	   SUM(creditlimit) as Total
FROM classicmodels.customers
GROUP BY salesRepEmployeeNumber
ORDER BY Total desc;
	-- (Followup) Just wanted to know the salesre count
		SELECT salesrepemployeenumber, COUNT(salesrepemployeenumber) count
		FROM classicmodels.customers
		GROUP BY salesRepEmployeeNumber
		ORDER BY count desc;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 5.Count customers in each city.
SELECT city,count(*) as Total_customers  -- First I wrote the count(customernumber), but the optimal way is to write count(*)
FROM classicmodels.customers
GROUP BY city 
order by total_customers DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 6.Find countries having more than 10 customers.
SELECT country,count(country) as Total_Customers
	FROM classicmodels.customers 
	GROUP BY country
	HAVING count(*) > 10;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 7.Find sales representatives managing more than 5 customers.
SELECT salesrepemployeenumber,
	count(*) Total_Customers
	FROM classicmodels.customers 
	WHERE salesRepEmployeeNumber IS NOT NULL
	GROUP BY salesRepEmployeeNumber 
	HAVING total_customers > 5
	ORDER BY total_customers DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 8.Find countries where the average credit limit exceeds 50,000.
SELECT country,ROUND(avg(creditlimit)) avg_cl
	FROM classicmodels.customers 
	GROUP BY country 
	HAVING avg_cl > 50000
	ORDER BY avg_cl DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 9.Find cities with the highest number of customers.
WITH CTE AS 
			(SELECT city,COUNT(*) as no_of_customers 
			FROM classicmodels.customers 
			GROUP BY city 
			ORDER BY no_of_customers DESC)
		SELECT * FROM CTE 
		  WHERE no_of_customers =
		  	(SELECT MAX(no_of_customers) 
		  	  FROM CTE);

select city as cityname from classicmodels.customers 
where cityname = 'Lille'	
-- ---------------------------------------------------------------------------------------------------------------------------------------------
																												   -- Date June 15, 2026; 9:52AM 
-- 10.Find the total credit exposure (sum of credit limits) by country.
SELECT country,sum(creditlimit) CreditExposure
FROM classicmodels.customers 
GROUP BY country
ORDER BY CreditExposure desc;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- Advanced Aggregation Questions
-- 1.Find the top 5 countries by total credit limit.
WITH Cr_Limit AS (
SELECT country,
	sum(creditlimit) CL,
	DENSE_RANK() OVER (ORDER BY sum(creditlimit) DESC) AS rnk
FROM classicmodels.customers
group by COUNTRY
ORDER BY CL DESC)
SELECT *
FROM cr_limit
WHERE rnk <=5;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- (Tricky question aggregation of aggregations)
-- 2.Find countries where the total credit limit is above the overall average country total. 
WITH CTE AS (
SELECT country,sum(creditlimit) as Total_Cl
FROM classicmodels.customers
GROUP BY country
ORDER BY Total_Cl DESC
)
	SELECT * FROM CTE 
	WHERE Total_Cl > (
		SELECT AVG(Total_Cl) FROM CTE);
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- This is also trickly bitl lilltle different thant 2Q
-- 3.Find sales representatives whose average customer credit limit is above the company average.
WITH CTE AS (SELECT salesrepemployeenumber,avg(creditlimit) as Avg_cl
	FROM classicmodels.customers
	WHERE salesRepEmployeeNumber IS NOT NULL
	GROUP BY salesrepemployeenumber)
SELECT * FROM CTE 
    WHERE avg_cl > (SELECT AVG(creditlimit) FROM classicmodels.customers);
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 4.Find the percentage contribution of each country's total credit limit to the overall company credit limit.
WITH CTE AS (SELECT country,sum(creditlimit) as Total_CL
	FROM classicmodels.customers 
	GROUP BY country)
SELECT country, CONCAT(ROUND((Total_CL / sum(Total_CL) over () *100),2),'%') as Percentage_Contribution
FROM CTE;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 5.Find countries where the maximum customer credit limit is more than twice the country's average credit limit.
SELECT country,
	   MAX(creditlimit) as Max_cl,
	   AVG(creditlimit) as Avg_cl
FROM classicmodels.customers 
GROUP BY country
HAVING MAX(creditlimit) > 2* AVG(creditlimit);
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 6.Find cities where total credit limit exceeds 100000.
SELECT city , sum(creditlimit) as Total_CL
FROM classicmodels.customers 
GROUP BY city 
HAVING Total_CL > 100000     -- In MYSQL we can use alias in HAVING filter
ORDER BY total_cl desc;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 7.Find the difference between the highest and lowest credit limit within each country.
SELECT country,
	   MAX(creditlimit) as Max_CL,
	   MIN(creditlimit) as Min_CL,
	   MAX(creditlimit) -  MIN(creditlimit) as Credit_Range
FROM classicmodels.customers
WHERE creditLimit > 0  -- If the business says to exclude countries where credit limit is 0 (this will gives us the actual credit range)
GROUP BY country
ORDER BY credit_range desc;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 8.Find the country with the greatest concentration of credit limit (highest total credit limit) 
WITH CTE AS (SELECT country,sum(creditlimit) as Total_cl
FROM classicmodels.customers 
GROUP BY country)
	SELECT * FROM CTE 
	WHERE total_cl = (
	SELECT MAX(total_cl) FROM CTE);  -- This will give the results even the total_cl is a tie
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 9.Find sales reps handling the largest total credit exposure.
WITH CTE AS (SELECT salesrepemployeenumber ,sum(creditlimit) as Total_CL
FROM classicmodels.customers
WHERE salesrepemployeenumber IS NOT NULL AND creditlimit > 0
GROUP BY salesrepemployeenumber)
	SELECT * FROM CTE
	WHERE Total_CL = (SELECT MAX(Total_cl) FROM CTE);
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 10.Find countries where the top customer contributes more than 50% of that country's total credit limit.
																												   -- Date June 17, 2026; 9:52AM 
WITH CTE AS (SELECT country,customernumber,creditlimit,
	   SUM(creditlimit) OVER (PARTITION BY country) as Country_Total,
	   DENSE_RANK() OVER (PARTITION BY country ORDER BY creditlimit desc) as Rnk
FROM classicmodels.customers)
SELECT * FROM CTE;
	SELECT country,customernumber,creditlimit,Country_Total,
	CONCAT(ROUND((creditlimit / country_total)*100,0),"%") AS Pct_Contribution
	FROM CTE 
	WHERE rnk = 1 AND 
	creditlimit > 0.5 * country_total;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- Aggregation + HAVING Challenge Questions
-- 1.Find countries having both more than 5 customers and total credit limit greater than 200000
SELECT country , sum(creditlimit) as Total_CL, count(*) as Total_Customers
FROM classicmodels.customers 
GROUP BY country
HAVING total_customers > 5 AND 
Total_CL > 200000
ORDER BY Total_Customers desc;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 2.Find sales reps with at least 3 customers and average credit limit above 75,000.
SELECT salesrepemployeenumber , count(*) As Total_Customers, ROUND(AVG(creditlimit)) as Avg_CL
FROM classicmodels.customers 
WHERE salesRepEmployeeNumber IS NOT NULL            -- IS NOT NULL instead of > 0
GROUP BY salesRepEmployeeNumber 
HAVING COUNT(*) >= 3 AND AVG(creditlimit) > 75000   -- I missed >= as it said at least 3 customers
ORDER BY COUNT(*) DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 3.Find cities with at least 2 customers and average credit limit below the overall company average.
SELECT city,AVG(creditlimit) as City_Avg, COUNT(*) AS Total_Customers
FROM classicmodels.customers
GROUP BY city
HAVING COUNT(*) >= 2 AND
AVG(creditlimit) < (SELECT AVG(creditlimit) FROM classicmodels.customers)
ORDER BY COUNT(*) DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 4.Find countries where total credit limit is greater than the sum of total credit limits of all countries with fewer than 2 customers.
WITH Country_Data AS (SELECT country,sum(creditlimit) as Total_CL,count(*) as Total_Customers
FROM classicmodels.customers 
GROUP BY country)
SELECT * FROM country_data 
WHERE total_cl > (SELECT SUM(total_cl) FROM country_data WHERE total_customers < 2);
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 5.Find the top 3 countries by average credit limit.
WITH Country_Avg AS (SELECT country,AVG(creditlimit) as Avg_CL,
DENSE_RANK() OVER (ORDER BY AVG(creditlimit) DESC) AS Rnk
FROM classicmodels.customers 
GROUP BY country)
SELECT country, Avg_CL,Rnk FROM Country_Avg WHERE Rnk <=3;
-- ---------------------------------------------------------------------------------------------------------------------------------------------


































































