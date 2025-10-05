-- Top 5 clients query

select
	fs.customer_id,
	sum(sales) as total_sales
from
	fact_sales fs
	inner join dim_customer dc
	on fs.customer_id = dc.customer_id
group by 
	fs.customer_id
order by
	total_sales DESC
limit 5;

-- Sales, transactions and average ticket by category query

select
	category,
	count(distinct dor.order_id) as total_transactions,
	sum(sales) as total_sales,
	round(sum(sales) / count(distinct dor.order_id),2) as average_ticket
from
	fact_sales fs
	inner join dim_product dp
	on fs.product_id = dp.product_id
	inner join dim_order dor
	on dor.order_id = fs.order_id
group by 
	category
order by
	total_sales DESC;

-- Running total by month query

select
	month_name as month,
	total_sales,
	sum(total_sales) 
		over(
			order by month 
			rows between 
			unbounded preceding 
			and current row
			) as running_total
from
	(select
	dd.month,
	dd.month_name,
	sum(sales) as total_sales
from
	fact_sales fs
	inner join dim_order dor
	on fs.order_id = dor.order_id
	inner join dim_date dd
	on dd.date = dor.order_date
group by
	dd.month, dd.month_name
order by
	dd.month ASC) as t1;

-- Sales and best selling category by region query

select
	region,
	category as best_selling_category,
	total_sales
from (
select
	region,
	category,
	sum(sum(sales)) over(partition by region) as total_sales,
	row_number() over(partition by region order by sum(sales) desc) as category_rank
from 
	fact_sales fs
	inner join dim_space ds
	on fs.postal_code = ds.postal_code
	inner join dim_product dp
	on fs.product_id = dp.product_id
group by
	region,
	category
) as t1
where
	category_rank = 1;

-- Sales and profit by year and month 

select
	year,
	month_name,
	sum(sales) as total_sales,
	sum(profit) as total_profit
from 
	fact_sales fs
	inner join dim_order dor
	on fs.order_id = dor.order_id
	inner join dim_date dd
	on dd.date = dor.order_date
group by
	year,
	month,
	month_name
order by
	year,
	month