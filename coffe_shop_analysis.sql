select *
from public.coffee_shop
limit 100;

-- OVERVIEW ANALYSIS 
-- Total Sales for the Dataset = 698812.33 dollars
SELECT SUM(transaction_total)
FROM public.coffee_shop;

-- Total transactions = 149116
select distinct count(transaction_id)
from public.coffee_shop;

-- Avarage sale per transaction = 4.69
select 
    ROUND(SUM(transaction_total)/ count(transaction_id),2) as avarage_sale
from public.coffee_shop;

-- Add new day and month column
ALTER TABLE coffee_shop
ADD COLUMN day_name VARCHAR(20),
ADD COLUMN month_name VARCHAR(20);

UPDATE coffee_shop
SET 
    day_name = TO_CHAR(transaction_date, 'FMDay'),
    month_name = TO_CHAR(transaction_date, 'FMMonth');


-- Total sales by days of week
select  day_name,
sum(transaction_total) as total
from public.coffee_shop
group by day_name
order by total desc;

-- Total sales by month 
select month_name,
sum(transaction_total) as total
from public.coffee_shop
group by month_name
order by total desc;

-- Total sales by hour
select EXTRACT(HOUR from transaction_time) as transaction_hour,
sum(transaction_total) as total
from public.coffee_shop
group by transaction_hour
order by transaction_hour;

-- PRODUCT ANALYSIS
-- Total sales by product category 

select sum(transaction_total)as total,
product_category
from public.coffee_shop
group by product_category
order by total desc;

-- Average sales per category 
select round(avg(transaction_total),2) as average,
product_category
from public.coffee_shop
group by product_category
order by average desc;

-- Total sale breakdown, top 3 

-- Coffee top sales
select sum(transaction_total) as total,
product_type
from public.coffee_shop
where product_category = 'Coffee'
group by product_type
order by total desc;

-- Branded top sales
select sum(transaction_total) as total,
product_type
from public.coffee_shop
where product_category = 'Branded'
group by product_type
order by total desc;

-- Tea top sales 
select sum(transaction_total) as total,
product_type
from public.coffee_shop
where product_category = 'Tea' 
group by product_type
order by total desc;

-- All Chocolate sales 
select sum(transaction_total) as total,
product_type
from public.coffee_shop
where product_category IN ('Packaged Chocolate','Drinking Chocolate')
group by product_type
order by total desc;

-- Coffe and tea products sales
select sum(transaction_total) as total,
product_type
from public.coffee_shop
where product_category IN ('Loose Tea','Coffee beans')
group by product_type
order by total desc;


-- STORE PERFOMANCE 

-- Total sales by store 
select store_id,
store_location,
sum(transaction_total) as total
from public.coffee_shop
group by store_id, store_location;

-- Total transactions by store 
select store_id,
store_location,
count(transaction_id) as total
from public.coffee_shop
group by store_id, store_location
order by total;

-- Average transaction size per store 
select store_id,
store_location,
round(avg(transaction_total),2) as total
from public.coffee_shop
group by store_id, store_location
order by total;

-- CUSTOMER BEHEVIOR 

-- Most popular days(transaction)
select  day_name,
count(transaction_id) as total
from public.coffee_shop
group by day_name
order by total desc;
-- Average transactions per day 
select  day_name,
round(avg(transaction_id),2) as total
from public.coffee_shop
group by day_name
order by total desc;

-- Peack hours by transactions 
select EXTRACT(HOUR from transaction_time) as transaction_hour,
sum(transaction_id) as total
from public.coffee_shop
group by transaction_hour
order by total desc
limit 5;

-- SEASONALITY

-- Changes MoM in sales 
WITH MonthlySales AS (
    SELECT
        TO_CHAR(transaction_date, 'YYYY-MM') AS month, 
        SUM(transaction_total) AS total_sales
    FROM
        coffee_shop
    GROUP BY
        TO_CHAR(transaction_date, 'YYYY-MM')
),
MonthlyGrowth AS (
    SELECT
        month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales
    FROM
        MonthlySales
)
SELECT
    month,
    total_sales,
    previous_month_sales,
    ROUND(((total_sales - previous_month_sales) / previous_month_sales) * 100, 2) AS mom_growth_percentage
FROM
    MonthlyGrowth
ORDER BY
    month;


-- Detailed analysis 

-- Store perfomance by tome slots 

SELECT store_location, sum(transaction_total),
        CASE 
		when EXTRACT(HOUR from transaction_time) IN(6,7,8,9,10,11) then 'Morning'
		when EXTRACT(HOUR from transaction_time) IN(12,13,14,15) then 'Afternoon'
		when EXTRACT(HOUR from transaction_time) IN(16,17,18,19,20) then 'Evening'
END as time_slot
from public.coffee_shop
group by time_slot, store_location
order by store_location, time_slot desc;

-- Day-of-Week Store Performance

SELECT 
    store_location,
    day_name,
    SUM(transaction_total) AS total_sales
FROM 
    public.coffee_shop
GROUP BY 
    store_location, day_name
ORDER BY 
    store_location, total_sales DESC;

-- Top 5 products in each location 
WITH RankedProducts AS (
    SELECT 
        store_location,
        product_type,
        SUM(transaction_qty) AS total_quantity_sold,
        RANK() OVER (PARTITION BY store_location ORDER BY SUM(transaction_qty) DESC) AS rank_per_location
    FROM 
        public.coffee_shop
    GROUP BY 
        store_location, product_type
)
SELECT 
    store_location,
    product_type,
    total_quantity_sold
FROM 
    RankedProducts
WHERE 
    rank_per_location <= 5
ORDER BY 
    store_location, rank_per_location;


