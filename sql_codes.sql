show databases;
use orders_data_analysis;

show tables;

-- select * from orders_data_analysis_table;
-- desc orders_data_analysis_table;

-- drop table orders_data_analysis_table;
create table df_orders (
	order_id int primary key,
    order_date date,
    ship_mode varchar(20),
    segment varchar(20),
    country varchar(20),
    city varchar(20),
    state varchar(20),
    postal_code varchar(20),
    region varchar(20),
    category varchar(20),
    sub_category varchar(20),
    product_id varchar(20),
    quantity int,
    discount decimal(7,2),
    sale_price decimal(7,2),
    profit decimal(7,2)
);

select * from df_orders;

drop table df_orders;

-- Data Analytics part
-- Questions

-- Find top 10 highest revenue generating products

select product_id, sum(sale_price) as total_sale_price from df_orders group by product_id order by sum(sale_price) desc limit 10;
 
-- Find top 5 highest selling products in each region
select * from df_orders;

select a.* from(
select product_id, region,sum(sale_price) as total_sale_price, row_number() over(partition by region order by sale_price desc) as rnk
from df_orders group by product_id, region) a where a.rnk<=5;
 
-- Find month over month growth comparison for 2022 and 2023 sales e.g : jan 2022 vs jan 2023
select * from df_orders;

select year(order_date) from df_orders;

with cte as(
select year(order_date) as order_year, month(order_date) as order_month,
sum(sale_price) as sales from df_orders group by year(order_date), month(order_date)
)

-- select order_month, 
-- case when order_year=2022 then sales else 0 end as sales_2022
-- ,case when order_year=2023 then sales else 0 end as sales_2023
-- from cte group by order_month order by order_month;

-- But with above query we get not expected output, so we use sum and inside sum we use case statements
select order_month, 
sum(case when order_year=2022 then sales else 0 end) as sales_2022
,sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte group by order_month order by order_month;


-- for each category which month had highest sales
select * from df_orders;
desc df_orders;

with cte as(
select category, date_format(order_date,'%Y-%m') as order_year_month, sum(sale_price) as sales,
row_number() over(partition by category order by sum(sale_price) desc) as r_num from df_orders
group by category, date_format(order_date,'%Y-%m') order by date_format(order_date,'%Y-%m') )

select category, order_year_month, sales from cte where r_num=1;

-- Which sub category has highest growth by profit in 2023 compare to 2022
select * from df_orders;

with cte as(
select sub_category, year(order_date) as order_year, sum(sale_price) as sum_sale from df_orders
group by sub_category, year(order_date)),
cte1 as(
select sub_category, sum(case when order_year=2023 then sum_sale else 0 end) as sales_2023,
sum(case when order_year=2022 then sum_sale else 0 end) as sales_2022 from cte
group by sub_category)

select *, (sales_2023-sales_2022)*100/sales_2022  from cte1 order by ((sales_2023-sales_2022)*100/sales_2022) desc limit 1;

